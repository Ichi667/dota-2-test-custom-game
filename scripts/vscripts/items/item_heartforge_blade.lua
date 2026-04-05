LinkLuaModifier("modifier_item_heartforge_blade", "items/item_heartforge_blade", LUA_MODIFIER_MOTION_NONE)

item_heartforge_blade = class({})

function item_heartforge_blade:GetIntrinsicModifierName()
    return "modifier_item_heartforge_blade"
end

modifier_item_heartforge_blade = class({})

local HP_REGEN_PERCENT_PRIORITY = {
    "modifier_item_dragonic_heart",
    "modifier_item_heartforge_blade",
}

function modifier_item_heartforge_blade:IsHidden() return true end
function modifier_item_heartforge_blade:IsPurgable() return false end
function modifier_item_heartforge_blade:RemoveOnDeath() return false end
function modifier_item_heartforge_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_heartforge_blade:IsPrimaryRegenModifier()
    local parent = self:GetParent()
    if not parent then return false end

    for _, modifier_name in ipairs(HP_REGEN_PERCENT_PRIORITY) do
        local modifiers = parent:FindAllModifiersByName(modifier_name)
        if #modifiers > 0 then
            return modifiers[1] == self
        end
    end

    return false
end

function modifier_item_heartforge_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_item_heartforge_blade:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_item_heartforge_blade:OnRefresh()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_item_heartforge_blade:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_damage") or 0
end

function modifier_item_heartforge_blade:GetModifierEvasion_Constant()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_evasion") or 0
end

function modifier_item_heartforge_blade:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_strength") or 0
end

function modifier_item_heartforge_blade:GetModifierConstantHealthRegen()
    if not self:IsPrimaryRegenModifier() then return 0 end

    local parent = self:GetParent()
    if not parent then return 0 end

    local ability = self:GetAbility()
    if not ability then return 0 end

    local regen_pct = ability:GetSpecialValueFor("bonus_health_regen_pct")
    return parent:GetMaxHealth() * regen_pct * 0.01
end

function modifier_item_heartforge_blade:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability or not parent:IsAlive() then return end

    local radius = ability:GetSpecialValueFor("burn_radius")
    local damage = ability:GetSpecialValueFor("burn_damage_base") + (parent:GetMaxHealth() * ability:GetSpecialValueFor("burn_damage_max_health_pct") * 0.01)

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
        ApplyDamage({
            victim = enemy,
            attacker = parent,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        })
    end
end