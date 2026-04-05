LinkLuaModifier("modifier_item_vampire_sword", "items/item_vampire_sword", LUA_MODIFIER_MOTION_NONE)

item_vampire_sword = class({})

function item_vampire_sword:GetIntrinsicModifierName()
    return "modifier_item_vampire_sword"
end

modifier_item_vampire_sword = class({})

function modifier_item_vampire_sword:IsHidden() return true end
function modifier_item_vampire_sword:IsPurgable() return false end
function modifier_item_vampire_sword:RemoveOnDeath() return false end

function modifier_item_vampire_sword:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_vampire_sword:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_vampire_sword:OnTakeDamage(params)
    if not IsServer() then return end

    if params.attacker == self:GetParent() and params.damage > 0 then
        local lifesteal = self:GetAbility():GetSpecialValueFor("bonus_lifesteal") / 100
        local heal = params.damage * lifesteal

        self:GetParent():Heal(heal, self:GetAbility())
    end
end