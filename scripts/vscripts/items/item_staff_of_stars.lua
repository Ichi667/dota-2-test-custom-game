LinkLuaModifier("modifier_item_staff_of_stars", "items/item_staff_of_stars", LUA_MODIFIER_MOTION_NONE)

item_staff_of_stars = class({})

function item_staff_of_stars:GetIntrinsicModifierName()
    return "modifier_item_staff_of_stars"
end

modifier_item_staff_of_stars = class({})

function modifier_item_staff_of_stars:IsHidden() return true end
function modifier_item_staff_of_stars:IsPurgable() return false end
function modifier_item_staff_of_stars:RemoveOnDeath() return false end
function modifier_item_staff_of_stars:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_staff_of_stars:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
    }
end

function modifier_item_staff_of_stars:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_staff_of_stars:GetModifierSpellAmplify_Percentage()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    if not ability or not parent then return 0 end

    local base = ability:GetSpecialValueFor("bonus_spell_amp")
    local per_int = ability:GetSpecialValueFor("spell_amp_per_int")
    return base + (parent:GetIntellect() * per_int)
end

function modifier_item_staff_of_stars:GetModifierMPRegenAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_amp")
end

function modifier_item_staff_of_stars:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_staff_of_stars:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_staff_of_stars:GetModifierPercentageCooldownStacking()
    return self:GetAbility():GetSpecialValueFor("bonus_cdr")
end
