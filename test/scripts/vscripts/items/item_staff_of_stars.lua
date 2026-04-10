LinkLuaModifier("modifier_item_staff_of_stars", "items/item_staff_of_stars", LUA_MODIFIER_MOTION_NONE)

item_staff_of_stars = class({})

function item_staff_of_stars:GetIntrinsicModifierName()
    return "modifier_item_staff_of_stars"
end

modifier_item_staff_of_stars = class({})

function modifier_item_staff_of_stars:IsHidden() return true end
function modifier_item_staff_of_stars:IsPurgable() return false end
function modifier_item_staff_of_stars:RemoveOnDeath() return false end
-- УБРАЛИ MULTIPLE
-- function modifier_item_staff_of_stars:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_staff_of_stars:OnCreated()
    self:OnRefresh()
end

function modifier_item_staff_of_stars:OnRefresh()
    local ability = self:GetAbility()
    if not ability then return end

    self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
    self.base_spell_amp = ability:GetSpecialValueFor("bonus_spell_amp")
    self.spell_amp_per_int = ability:GetSpecialValueFor("spell_amp_per_int")
    self.bonus_mana_regen_amp = ability:GetSpecialValueFor("bonus_mana_regen_amp")
    self.bonus_health = ability:GetSpecialValueFor("bonus_health")
    self.bonus_mana = ability:GetSpecialValueFor("bonus_mana")
    self.bonus_cdr = ability:GetSpecialValueFor("bonus_cdr")
end

function modifier_item_staff_of_stars:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_item_staff_of_stars:GetModifierBonusStats_Intellect()
    return self.bonus_intellect or 0
end

function modifier_item_staff_of_stars:GetModifierSpellAmplify_Percentage()
    local parent = self:GetParent()
    if not parent then
        return self.base_spell_amp or 0
    end

    local int_amp = parent:GetIntellect(true) * (self.spell_amp_per_int or 0)
    return (self.base_spell_amp or 0) + int_amp
end

function modifier_item_staff_of_stars:GetModifierMPRegenAmplify_Percentage()
    return self.bonus_mana_regen_amp or 0
end

function modifier_item_staff_of_stars:GetModifierHealthBonus()
    return self.bonus_health or 0
end

function modifier_item_staff_of_stars:GetModifierManaBonus()
    return self.bonus_mana or 0
end

function modifier_item_staff_of_stars:GetModifierPercentageCooldown()
    return self.bonus_cdr or 0
end