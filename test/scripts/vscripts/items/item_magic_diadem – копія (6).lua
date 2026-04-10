LinkLuaModifier("modifier_item_magic_diadem", "items/item_magic_diadem", LUA_MODIFIER_MOTION_NONE)

item_magic_diadem = class({})

function item_magic_diadem:GetIntrinsicModifierName()
    return "modifier_item_magic_diadem"
end

modifier_item_magic_diadem = class({})

function modifier_item_magic_diadem:IsHidden() return true end
function modifier_item_magic_diadem:IsPurgable() return false end
function modifier_item_magic_diadem:RemoveOnDeath() return false end

function modifier_item_magic_diadem:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
end

function modifier_item_magic_diadem:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_magic_diadem:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_magic_diadem:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_magic_diadem:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end