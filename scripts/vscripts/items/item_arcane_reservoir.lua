LinkLuaModifier("modifier_item_arcane_reservoir", "items/item_arcane_reservoir", LUA_MODIFIER_MOTION_NONE)

item_arcane_reservoir = class({})
modifier_item_arcane_reservoir = class({})

function item_arcane_reservoir:GetIntrinsicModifierName()
    return "modifier_item_arcane_reservoir"
end

function item_arcane_reservoir:OnSpellStart()
    if not IsServer() then
        return
    end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then
        return
    end

    local charges = self:GetCurrentCharges()
    if charges <= 0 then
        return
    end

    local restore_per_charge = self:GetSpecialValueFor("restore_per_charge")
    local total_restore = charges * restore_per_charge

    caster:Heal(total_restore, self)
    caster:GiveMana(total_restore)

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, total_restore, nil)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, total_restore, nil)

    self:SetCurrentCharges(0)

    caster:EmitSound("DOTA_Item.MagicWand.Activate")
end

modifier_item_arcane_reservoir.__index = modifier_item_arcane_reservoir

function modifier_item_arcane_reservoir:IsHidden()
    return true
end

function modifier_item_arcane_reservoir:IsPurgable()
    return false
end

function modifier_item_arcane_reservoir:RemoveOnDeath()
    return false
end

function modifier_item_arcane_reservoir:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_arcane_reservoir:OnCreated()
    self:UpdateValues()
end

function modifier_item_arcane_reservoir:OnRefresh()
    self:UpdateValues()
end

function modifier_item_arcane_reservoir:UpdateValues()
    local ability = self:GetAbility()

    self.bonus_strength = 0
    self.bonus_agility = 0
    self.bonus_intellect = 0
    self.bonus_health_regen = 0
    self.bonus_health = 0
    self.bonus_attack_speed = 0
    self.bonus_armor = 0
    self.bonus_mana_pct = 0
    self.bonus_mana_regen = 0
    self.charge_radius = 1200
    self.max_charges = 20

    if not ability then
        return
    end

    self.bonus_strength = ability:GetSpecialValueFor("bonus_strength")
    self.bonus_agility = ability:GetSpecialValueFor("bonus_agility")
    self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
    self.bonus_health_regen = ability:GetSpecialValueFor("bonus_health_regen")
    self.bonus_health = ability:GetSpecialValueFor("bonus_health")
    self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_armor = ability:GetSpecialValueFor("bonus_armor")
    self.bonus_mana_pct = ability:GetSpecialValueFor("bonus_mana_pct")
    self.bonus_mana_regen = ability:GetSpecialValueFor("bonus_mana_regen")
    self.charge_radius = ability:GetSpecialValueFor("charge_radius")
    self.max_charges = ability:GetSpecialValueFor("max_charges")
end

function modifier_item_arcane_reservoir:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_item_arcane_reservoir:GetModifierBonusStats_Strength()
    return self.bonus_strength
end

function modifier_item_arcane_reservoir:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_item_arcane_reservoir:GetModifierBonusStats_Intellect()
    return self.bonus_intellect
end

function modifier_item_arcane_reservoir:GetModifierConstantHealthRegen()
    return self.bonus_health_regen
end

function modifier_item_arcane_reservoir:GetModifierHealthBonus()
    return self.bonus_health
end

function modifier_item_arcane_reservoir:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_item_arcane_reservoir:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_arcane_reservoir:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_arcane_reservoir:GetModifierExtraManaPercentage()
    return self.bonus_mana_pct
end

function modifier_item_arcane_reservoir:OnAbilityExecuted(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local unit = params.unit
    local used_ability = params.ability

    if not parent or parent:IsNull() then
        return
    end

    if not ability or ability:IsNull() then
        return
    end

    if not unit or unit:IsNull() then
        return
    end

    if not used_ability or used_ability:IsNull() then
        return
    end

    if not unit:IsAlive() then
        return
    end

    if used_ability:IsItem() then
        return
    end

    local all_modifiers = parent:FindAllModifiersByName("modifier_item_arcane_reservoir")
    if #all_modifiers < 1 then
        return
    end

    if all_modifiers[1] ~= self then
        return
    end

    local distance = (unit:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
    if distance > self.charge_radius then
        return
    end

    local current_charges = ability:GetCurrentCharges()
    if current_charges >= self.max_charges then
        return
    end

    ability:SetCurrentCharges(math.min(current_charges + 1, self.max_charges))

    parent:EmitSound("DOTA_Item.MagicWand.Charge")
end