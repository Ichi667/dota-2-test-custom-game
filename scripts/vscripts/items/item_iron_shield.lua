LinkLuaModifier("modifier_item_iron_shield", "items/item_iron_shield", LUA_MODIFIER_MOTION_NONE)

item_iron_shield = class({})

function item_iron_shield:GetIntrinsicModifierName()
    return "modifier_item_iron_shield"
end

modifier_item_iron_shield = class({})

local DAMAGE_DEFENSE_PRIORITY = {
    "modifier_item_crystal_defender",
    "modifier_item_iron_shield",
    "modifier_item_phaseblade",
}

function modifier_item_iron_shield:IsHidden() return true end
function modifier_item_iron_shield:IsPurgable() return false end
function modifier_item_iron_shield:RemoveOnDeath() return false end
function modifier_item_iron_shield:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_iron_shield:IsPrimaryDefenseModifier()
    local parent = self:GetParent()
    if not parent then return false end

    for _, modifier_name in ipairs(DAMAGE_DEFENSE_PRIORITY) do
        local modifiers = parent:FindAllModifiersByName(modifier_name)
        if #modifiers > 0 then
            return modifiers[1] == self
        end
    end

    return false
end

function modifier_item_iron_shield:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
    }
end

function modifier_item_iron_shield:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_armor") or 0
end

function modifier_item_iron_shield:GetModifierConstantHealthRegen()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_health_regen") or 0
end

function modifier_item_iron_shield:GetModifierHealthBonus()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_health") or 0
end

function modifier_item_iron_shield:GetModifierPhysical_ConstantBlock(params)
    if not IsServer() then return 0 end
    if not self:IsPrimaryDefenseModifier() then return 0 end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability then return 0 end

    local chance = ability:GetSpecialValueFor("block_chance")
    if not RollPercentage(chance) then return 0 end

    local block = parent:IsRangedAttacker() and ability:GetSpecialValueFor("block_damage_ranged") or ability:GetSpecialValueFor("block_damage_melee")

    return math.min(params.damage or 0, block)
end
