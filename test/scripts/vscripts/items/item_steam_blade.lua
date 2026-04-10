LinkLuaModifier("modifier_item_steam_blade", "items/item_steam_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_steam_blade_burn", "items/item_steam_blade", LUA_MODIFIER_MOTION_NONE)

item_steam_blade = class({})

function item_steam_blade:Precache(context)
    PrecacheResource("particle", "particles/items/radiance_mana.vpcf", context)
    PrecacheResource("particle", "particles/items/radiance_owner_mana.vpcf", context)
end

function item_steam_blade:GetIntrinsicModifierName()
    return "modifier_item_steam_blade"
end

modifier_item_steam_blade = class({})

function modifier_item_steam_blade:IsHidden() return true end
function modifier_item_steam_blade:IsPurgable() return false end
function modifier_item_steam_blade:RemoveOnDeath() return false end
function modifier_item_steam_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_steam_blade:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)

    self.owner_particle = ParticleManager:CreateParticle("particles/items/radiance_owner_mana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.owner_particle, false, false, -1, false, false)
end

function modifier_item_steam_blade:OnRefresh()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_item_steam_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_steam_blade:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end

function modifier_item_steam_blade:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
end

function modifier_item_steam_blade:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_steam_blade:GetModifierMPRegenAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_amp")
end

function modifier_item_steam_blade:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability or not parent:IsAlive() then return end

    local damage = ability:GetSpecialValueFor("pulse_damage_base") + parent:GetMaxMana() * ability:GetSpecialValueFor("pulse_damage_max_mana_pct") * 0.01
    local radius = ability:GetSpecialValueFor("pulse_radius")

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        enemy:AddNewModifier(parent, ability, "modifier_item_steam_blade_burn", { duration = 1.1 })
        ApplyDamage({
            victim = enemy,
            attacker = parent,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        })
    end
end

modifier_item_steam_blade_burn = class({})

function modifier_item_steam_blade_burn:IsHidden() return false end
function modifier_item_steam_blade_burn:IsPurgable() return false end
function modifier_item_steam_blade_burn:IsDebuff() return true end
function modifier_item_steam_blade_burn:GetTexture() return "item_radiance" end

function modifier_item_steam_blade_burn:OnCreated()
    if not IsServer() then return end

    self.particle = ParticleManager:CreateParticle("particles/items/radiance_mana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
end
