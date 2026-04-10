LinkLuaModifier("modifier_lina_dragon_slave_custom_slow", "abilities/lina/lina_dragon_slave_custom", LUA_MODIFIER_MOTION_NONE)

lina_dragon_slave_custom = class({})
lina_dragon_slave_custom_scepter = class(lina_dragon_slave_custom)

function lina_dragon_slave_custom:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_frost.vpcf", context)
end

function lina_dragon_slave_custom:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self, level)
    local caster = self:GetCaster()
    if caster and caster:HasAbility("special_bonus_unique_lina_custom_2") then
        local talent = caster:FindAbilityByName("special_bonus_unique_lina_custom_2")
        if talent and talent:GetLevel() > 0 then
            cd = cd + talent:GetSpecialValueFor("value")
        end
    end
    return math.max(0, cd)
end

function lina_dragon_slave_custom:GetManaCost(level)
    if self:GetAbilityName() == "lina_dragon_slave_custom_scepter" then
        local caster = self:GetCaster()
        if caster then
            return math.floor(caster:GetMana() * self:GetSpecialValueFor("current_mana_cost_pct") * 0.01)
        end
    end
    return self.BaseClass.GetManaCost(self, level)
end

function lina_dragon_slave_custom:OnInventoryContentsChanged()
    if self:GetAbilityName() ~= "lina_dragon_slave_custom_scepter" then return end
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster then return end

    if caster:HasScepter() then
        self:SetHidden(false)
        if self:GetLevel() < 1 then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function lina_dragon_slave_custom:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function lina_dragon_slave_custom:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local projectile_name = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
    local projectile_distance = self:GetSpecialValueFor("dragon_slave_distance")
    local projectile_speed = self:GetSpecialValueFor("dragon_slave_speed")
    local projectile_start_radius = self:GetSpecialValueFor("dragon_slave_width_initial")
    local projectile_end_radius = self:GetSpecialValueFor("dragon_slave_width_end")

    local direction = point - caster:GetOrigin()
    direction.z = 0
    if direction:Length2D() < 1 then
        direction = caster:GetForwardVector()
    end
    local projectile_direction = direction:Normalized()

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetAbsOrigin(),
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = projectile_name,
        fDistance = projectile_distance,
        fStartRadius = projectile_start_radius,
        fEndRadius = projectile_end_radius,
        vVelocity = projectile_direction * projectile_speed,
        bProvidesVision = false,
    }
    ProjectileManager:CreateLinearProjectile(info)

    EmitSoundOn("Hero_Lina.DragonSlave.Cast", caster)
    EmitSoundOn("Hero_Lina.DragonSlave", caster)
end

function lina_dragon_slave_custom:OnProjectileHitHandle(target, location, projectile)
    if not target then return end

    local caster = self:GetCaster()
    local base_damage = self:GetSpecialValueFor("damage")
    local int_pct = self:GetSpecialValueFor("int_damage_pct")

    local talent_damage = caster:FindAbilityByName("special_bonus_unique_lina_custom_1")
    if talent_damage and talent_damage:GetLevel() > 0 then
        int_pct = int_pct + talent_damage:GetSpecialValueFor("value")
    end

    local damageTable = {
        victim = target,
        attacker = caster,
        damage = base_damage + caster:GetIntellect(false) * int_pct * 0.01,
        damage_type = self:GetAbilityDamageType(),
        ability = self,
    }
    ApplyDamage(damageTable)

    local talent_slow = caster:FindAbilityByName("special_bonus_unique_lina_custom_4")
    if talent_slow and talent_slow:GetLevel() > 0 then
        target:AddNewModifier(caster, self, "modifier_lina_dragon_slave_custom_slow", {
            duration = self:GetSpecialValueFor("slow_duration") * (1 - target:GetStatusResistance())
        })
    end
    local dir = ProjectileManager:GetLinearProjectileVelocity(projectile)
    dir.z = 0
    dir = dir:Normalized()
    self:PlayEffects(target, dir)
end

function lina_dragon_slave_custom:PlayEffects(target, direction)
    local particle_cast = "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

modifier_lina_dragon_slave_custom_slow = class({})
function modifier_lina_dragon_slave_custom_slow:IsHidden() return false end
function modifier_lina_dragon_slave_custom_slow:IsPurgable() return true end
function modifier_lina_dragon_slave_custom_slow:GetTexture() return "lina_dragon_slave" end
function modifier_lina_dragon_slave_custom_slow:GetEffectName() return "particles/status_fx/status_effect_frost.vpcf" end

function modifier_lina_dragon_slave_custom_slow:OnCreated()
    self.slow = -self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_lina_dragon_slave_custom_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_lina_dragon_slave_custom_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end
