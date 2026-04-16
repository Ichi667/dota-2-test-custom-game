antimage_persecutor = class({})

LinkLuaModifier("modifier_antimage_persecutor", "abilities/antimage/antimage_persecutor.lua", LUA_MODIFIER_MOTION_NONE)

function antimage_persecutor:GetIntrinsicModifierName()
    return "modifier_antimage_persecutor"
end

modifier_antimage_persecutor = class({})

function modifier_antimage_persecutor:IsHidden() return true end
function modifier_antimage_persecutor:IsPurgable() return false end
function modifier_antimage_persecutor:RemoveOnDeath() return false end

function modifier_antimage_persecutor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_antimage_persecutor:GetModifierDamageOutgoing_Percentage(params)
    if not IsServer() then
        return 0
    end

    local parent = self:GetParent()
    local target = params.target
    if not target or target:IsNull() or parent:PassivesDisabled() then
        return 0
    end

    if target:GetMaxMana() <= 0 then
        return 0
    end

    local mana_missing_pct = (target:GetMaxMana() - target:GetMana()) / target:GetMaxMana() * 100
    local bonus_per_missing_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_per_missing_mana_pct")

    return mana_missing_pct * bonus_per_missing_pct
end
