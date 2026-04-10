LinkLuaModifier("modifier_item_phaseblade", "items/item_phaseblade", LUA_MODIFIER_MOTION_NONE)

item_phaseblade = class({})

function item_phaseblade:GetIntrinsicModifierName()
    return "modifier_item_phaseblade"
end

modifier_item_phaseblade = class({})

local DAMAGE_DEFENSE_PRIORITY = {
    "modifier_item_crystal_defender",
    "modifier_item_iron_shield",
    "modifier_item_phaseblade",
}

function modifier_item_phaseblade:IsHidden() return true end
function modifier_item_phaseblade:IsPurgable() return false end
function modifier_item_phaseblade:RemoveOnDeath() return false end
function modifier_item_phaseblade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_phaseblade:OnCreated()
    if not IsServer() then return end
    self.pseudo_random_id = self:GetAbility() and self:GetAbility():entindex() or 0
end

function modifier_item_phaseblade:OnRefresh()
    if not IsServer() then return end
    self.pseudo_random_id = self:GetAbility() and self:GetAbility():entindex() or self.pseudo_random_id
end

function modifier_item_phaseblade:IsPrimaryDefenseModifier()
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

function modifier_item_phaseblade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    }
end

function modifier_item_phaseblade:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_agility") or 0
end

function modifier_item_phaseblade:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_damage") or 0
end

function modifier_item_phaseblade:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_attack_speed") or 0
end

function modifier_item_phaseblade:GetModifierIncomingDamageConstant(params)
    if not IsServer() then return 0 end
    if not self:IsPrimaryDefenseModifier() then return 0 end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability then return 0 end
    if params.target ~= parent then return 0 end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end

    local chance = ability:GetSpecialValueFor("damage_evade_chance")
    if not RollPseudoRandomPercentage(chance, self.pseudo_random_id, parent) then return 0 end

    return -(params.damage or 0)
end
