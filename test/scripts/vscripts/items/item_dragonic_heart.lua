LinkLuaModifier("modifier_item_dragonic_heart", "items/item_dragonic_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_dragonic_heart_heal_reduction", "items/item_dragonic_heart", LUA_MODIFIER_MOTION_NONE)

item_dragonic_heart = class({})

function item_dragonic_heart:GetIntrinsicModifierName()
    return "modifier_item_dragonic_heart"
end

modifier_item_dragonic_heart = class({})

local HP_REGEN_PERCENT_PRIORITY = {
    "modifier_item_dragonic_heart",
    "modifier_item_heartforge_blade",
}

local MAX_HP_PERCENT_PRIORITY = {
    "modifier_item_dragonic_heart",
}

function modifier_item_dragonic_heart:IsHidden() return true end
function modifier_item_dragonic_heart:IsPurgable() return false end
function modifier_item_dragonic_heart:RemoveOnDeath() return false end
function modifier_item_dragonic_heart:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_dragonic_heart:IsPrimaryModifier(priority_list)
    local parent = self:GetParent()
    if not parent then return false end

    for _, modifier_name in ipairs(priority_list) do
        local modifiers = parent:FindAllModifiersByName(modifier_name)
        if #modifiers > 0 then
            return modifiers[1] == self
        end
    end

    return false
end

function modifier_item_dragonic_heart:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_dragonic_heart:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_strength") or 0
end

function modifier_item_dragonic_heart:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_agility") or 0
end

function modifier_item_dragonic_heart:GetModifierBonusStats_Intellect()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_intellect") or 0
end

function modifier_item_dragonic_heart:GetModifierExtraHealthPercentage()
    if not self:IsPrimaryModifier(MAX_HP_PERCENT_PRIORITY) then return 0 end
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_max_health_pct") or 0
end

function modifier_item_dragonic_heart:GetModifierConstantHealthRegen()
    if not self:IsPrimaryModifier(HP_REGEN_PERCENT_PRIORITY) then return 0 end

    local parent = self:GetParent()
    if not parent then return 0 end

    local ability = self:GetAbility()
    if not ability then return 0 end

    local regen_pct = ability:GetSpecialValueFor("bonus_health_regen_pct")
    return parent:GetMaxHealth() * regen_pct * 0.01
end

function modifier_item_dragonic_heart:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability then return end
    if params.attacker ~= parent then return end
    if parent:IsIllusion() or parent:PassivesDisabled() then return end

    local target = params.target
    if not target or target:IsNull() or target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if target:IsBuilding() or target:IsOther() then return end

    target:AddNewModifier(parent, ability, "modifier_item_dragonic_heart_heal_reduction", {
        duration = ability:GetSpecialValueFor("heal_reduction_duration"),
    })
end

modifier_item_dragonic_heart_heal_reduction = class({})

function modifier_item_dragonic_heart_heal_reduction:IsHidden() return false end
function modifier_item_dragonic_heart_heal_reduction:IsPurgable() return true end
function modifier_item_dragonic_heart_heal_reduction:IsDebuff() return true end
function modifier_item_dragonic_heart_heal_reduction:GetTexture() return "heart" end

function modifier_item_dragonic_heart_heal_reduction:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_dragonic_heart_heal_reduction:GetReductionValue()
    local ability = self:GetAbility()
    return -(ability and ability:GetSpecialValueFor("heal_reduction_pct") or 0)
end

function modifier_item_dragonic_heart_heal_reduction:GetModifierHealAmplify_PercentageTarget()
    return self:GetReductionValue()
end

function modifier_item_dragonic_heart_heal_reduction:GetModifierHPRegenAmplify_Percentage()
    return self:GetReductionValue()
end

function modifier_item_dragonic_heart_heal_reduction:GetModifierLifestealRegenAmplify_Percentage()
    return self:GetReductionValue()
end

function modifier_item_dragonic_heart_heal_reduction:GetModifierSpellLifestealRegenAmplify_Percentage()
    return self:GetReductionValue()
end