LinkLuaModifier("modifier_item_duelist_amylet", "items/item_duelist_amylet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_duelist_amylet_barrier", "items/item_duelist_amylet", LUA_MODIFIER_MOTION_NONE)

item_duelist_amylet = class({})

function item_duelist_amylet:GetIntrinsicModifierName()
    return "modifier_item_duelist_amylet"
end

function item_duelist_amylet:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not target then return end

    if target:TriggerSpellAbsorb(self) then
        return
    end

    target:AddNewModifier(caster, self, "modifier_item_duelist_amylet_barrier", {
        duration = self:GetSpecialValueFor("active_duration"),
    })
end

modifier_item_duelist_amylet = class({})

function modifier_item_duelist_amylet:IsHidden() return true end
function modifier_item_duelist_amylet:IsPurgable() return false end
function modifier_item_duelist_amylet:RemoveOnDeath() return false end
function modifier_item_duelist_amylet:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_duelist_amylet:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_item_duelist_amylet:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_duelist_amylet:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_duelist_amylet:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_duelist_amylet:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_duelist_amylet:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_magic_resistance")
end

modifier_item_duelist_amylet_barrier = class({})

function modifier_item_duelist_amylet_barrier:IsHidden() return false end
function modifier_item_duelist_amylet_barrier:IsPurgable() return true end

function modifier_item_duelist_amylet_barrier:OnCreated()
    self.barrier = self:GetAbility():GetSpecialValueFor("active_barrier")
end

function modifier_item_duelist_amylet_barrier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_duelist_amylet_barrier:GetModifierIncomingDamageConstant(params)
    if not IsServer() then return 0 end
    if not params or not params.damage or params.damage <= 0 then return 0 end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end

    local block = math.min(self.barrier, params.damage)
    self.barrier = self.barrier - block

    if self.barrier <= 0 then
        self:Destroy()
    else
        self:SetStackCount(math.ceil(self.barrier))
    end

    return -block
end

function modifier_item_duelist_amylet_barrier:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("active_attack_speed")
end

function modifier_item_duelist_amylet_barrier:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("active_armor")
end

function modifier_item_duelist_amylet_barrier:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("active_move_speed_pct")
end
