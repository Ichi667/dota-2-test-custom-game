LinkLuaModifier("modifier_lina_flame_clock_custom", "abilities/lina/lina_flame_clock_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_flame_clock_custom_burn", "abilities/lina/lina_flame_clock_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_flame_clock_custom_shard_int", "abilities/lina/lina_flame_clock_custom", LUA_MODIFIER_MOTION_NONE)

lina_flame_clock_custom = class({})

function lina_flame_clock_custom:Precache(context)
    PrecacheResource("particle", "particles/items2_fx/radiance.vpcf", context)
end

function lina_flame_clock_custom:OnSpellStart()
    local caster = self:GetCaster()
    if not caster then return end

    caster:EmitSound("Hero_Lina.DragonSlave")
    caster:AddNewModifier(caster, self, "modifier_lina_flame_clock_custom", {
        duration = self:GetSpecialValueFor("duration")
    })
end

modifier_lina_flame_clock_custom = class({})

function modifier_lina_flame_clock_custom:IsHidden()
    return false
end

function modifier_lina_flame_clock_custom:IsPurgable()
    return false
end

function modifier_lina_flame_clock_custom:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_lina_flame_clock_custom:OnCreated()
    local ability = self:GetAbility()
    if not ability then return end

    self.radius = ability:GetSpecialValueFor("radius")
    self.int_pct = ability:GetSpecialValueFor("int_damage_pct")
    self.interval = ability:GetSpecialValueFor("damage_interval")

    if not IsServer() then return end

    self:GetParent():EmitSound("DOTA_Item.Radiance")

    local p1 = ParticleManager:CreateParticle("particles/hero/lina_ult.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p1, false, false, -1, false, false)

    local p2 = ParticleManager:CreateParticle("particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(p2, 1, Vector(self.radius, 1, 1))
    self:AddParticle(p2, false, false, -1, false, false)

    self:StartIntervalThink(self.interval)
end

function modifier_lina_flame_clock_custom:OnRefresh()
    local ability = self:GetAbility()
    if not ability then return end

    self.radius = ability:GetSpecialValueFor("radius")
    self.int_pct = ability:GetSpecialValueFor("int_damage_pct")
    self.interval = ability:GetSpecialValueFor("damage_interval")
end

function modifier_lina_flame_clock_custom:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("DOTA_Item.Radiance")
end

function modifier_lina_flame_clock_custom:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    local damage = caster:GetIntellect(false) * self.int_pct * 0.01 * self.interval

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, ability, "modifier_lina_flame_clock_custom_burn", {
            duration = self.interval + 0.2
        })

        ApplyDamage({
            attacker = caster,
            victim = enemy,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability
        })
    end
end

function modifier_lina_flame_clock_custom:OnTakeDamage(params)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    if params.attacker ~= caster then return end
    if params.damage <= 0 then return end
    if not params.unit or params.unit:IsNull() then return end
    if params.unit:GetTeamNumber() == caster:GetTeamNumber() then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end

    local int_gain = ability:GetSpecialValueFor("shard_bonus_int")
    local duration = ability:GetSpecialValueFor("shard_bonus_duration")

    if duration <= 0 then return end

    local mod = caster:FindModifierByName("modifier_lina_flame_clock_custom_shard_int")

    if not mod then
        mod = caster:AddNewModifier(caster, ability, "modifier_lina_flame_clock_custom_shard_int", {
            duration = duration
        })
    else
        mod:SetDuration(duration, true)
    end

    if mod then
        mod:AddIntStack(int_gain)
    end
end

modifier_lina_flame_clock_custom_burn = class({})

function modifier_lina_flame_clock_custom_burn:IsHidden()
    return false
end

function modifier_lina_flame_clock_custom_burn:IsPurgable()
    return false
end

function modifier_lina_flame_clock_custom_burn:GetTexture()
    return "item_radiance"
end

function modifier_lina_flame_clock_custom_burn:GetEffectName()
    return "particles/items2_fx/radiance_owner.vpcf"
end

modifier_lina_flame_clock_custom_shard_int = class({})

function modifier_lina_flame_clock_custom_shard_int:IsHidden()
    return false
end

function modifier_lina_flame_clock_custom_shard_int:IsPurgable()
    return false
end

function modifier_lina_flame_clock_custom_shard_int:GetTexture()
    return "aghanim_shard"
end

function modifier_lina_flame_clock_custom_shard_int:OnCreated()
    self.int = 0

    if not IsServer() then return end
    self:SetStackCount(0)
end

function modifier_lina_flame_clock_custom_shard_int:AddIntStack(value)
    if not IsServer() then return end

    value = value or 0
    self.int = (self.int or 0) + value
    self:SetStackCount(self.int)
    self:ForceRefresh()
end

function modifier_lina_flame_clock_custom_shard_int:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_lina_flame_clock_custom_shard_int:GetModifierBonusStats_Intellect()
    return self.int or 0
end