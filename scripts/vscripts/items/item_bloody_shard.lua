LinkLuaModifier("modifier_item_bloody_shard", "items/item_bloody_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloody_shard_crit_nomiss", "items/item_bloody_shard", LUA_MODIFIER_MOTION_NONE)

item_bloody_shard = class({})

function item_bloody_shard:GetIntrinsicModifierName()
    return "modifier_item_bloody_shard"
end

modifier_item_bloody_shard = class({})

function modifier_item_bloody_shard:IsHidden()
    return true
end

function modifier_item_bloody_shard:IsPurgable()
    return false
end

function modifier_item_bloody_shard:RemoveOnDeath()
    return false
end

function modifier_item_bloody_shard:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_bloody_shard:OnCreated()
    self.records = {}
    self:OnRefresh()
end

function modifier_item_bloody_shard:OnRefresh()
    local ability = self:GetAbility()

    if not ability then
        self.bonus_strength = 0
        self.bonus_agility = 0
        self.bonus_damage = 0
        self.bonus_attack_speed = 0
        self.bonus_attack_range = 0
        self.bonus_status_resistance = 0
        self.bonus_hp_regen_amp = 0
        self.bonus_slow_resistance = 0
        self.crit_chance = 0
        self.crit_multiplier = 0
        return
    end

    self.bonus_strength = ability:GetSpecialValueFor("bonus_strength")
    self.bonus_agility = ability:GetSpecialValueFor("bonus_agility")
    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_attack_range = ability:GetSpecialValueFor("bonus_attack_range")
    self.bonus_status_resistance = ability:GetSpecialValueFor("bonus_status_resistance")
    self.bonus_hp_regen_amp = ability:GetSpecialValueFor("bonus_hp_regen_amp")
    self.bonus_slow_resistance = ability:GetSpecialValueFor("bonus_slow_resistance")
    self.crit_chance = ability:GetSpecialValueFor("crit_chance")
    self.crit_multiplier = ability:GetSpecialValueFor("crit_multiplier")
end

function modifier_item_bloody_shard:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
    }

    return funcs
end

function modifier_item_bloody_shard:IsPrimaryModifier()
    local parent = self:GetParent()
    local modifiers = parent:FindAllModifiersByName("modifier_item_bloody_shard")

    return modifiers[1] == self
end

function modifier_item_bloody_shard:GetModifierBonusStats_Strength()
    return self.bonus_strength
end

function modifier_item_bloody_shard:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_item_bloody_shard:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_bloody_shard:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_item_bloody_shard:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end

function modifier_item_bloody_shard:GetModifierStatusResistanceStacking()
    return self.bonus_status_resistance
end

function modifier_item_bloody_shard:GetModifierHPRegenAmplify_Percentage()
    return self.bonus_hp_regen_amp
end

function modifier_item_bloody_shard:GetModifierSlowResistance_Stacking()
    return self.bonus_slow_resistance
end

function modifier_item_bloody_shard:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local target = params.target

    if params.attacker ~= parent then
        return
    end

    if not self:IsPrimaryModifier() then
        return
    end

    if parent:IsIllusion() then
        return
    end

    if parent:PassivesDisabled() then
        return
    end

    if not target then
        return
    end

    if target:IsBuilding() or target:IsOther() then
        return
    end

    parent._global_item_crit_records = parent._global_item_crit_records or {}
    if params.record ~= nil and parent._global_item_crit_records[params.record] then
        return
    end

    if RollPseudoRandomPercentage(self.crit_chance, self:GetAbility():entindex(), parent) then
        self.records[params.record] = true
        if params.record ~= nil then
            parent._global_item_crit_records[params.record] = true
        end

        parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_bloody_shard_crit_nomiss", {
            record = params.record
        })

        return self.crit_multiplier
    end
end

function modifier_item_bloody_shard:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    if params.attacker ~= self:GetParent() then
        return
    end

    self:ClearRecord(params.record)
end

function modifier_item_bloody_shard:OnAttackFail(params)
    if not IsServer() then
        return
    end

    if params.attacker ~= self:GetParent() then
        return
    end

    self:ClearRecord(params.record)
end

function modifier_item_bloody_shard:OnAttackRecordDestroy(params)
    if not IsServer() then
        return
    end

    if params.attacker ~= self:GetParent() then
        return
    end

    self:ClearRecord(params.record)
end

function modifier_item_bloody_shard:ClearRecord(record)
    self.records[record] = nil

    local parent = self:GetParent()
    if not parent then return end
    if parent and parent._global_item_crit_records and record ~= nil then
        parent._global_item_crit_records[record] = nil
    end

    local modifiers = parent:FindAllModifiersByName("modifier_item_bloody_shard_crit_nomiss")

    for _, modifier in pairs(modifiers) do
        if modifier.record == record then
            modifier:Destroy()
        end
    end
end

modifier_item_bloody_shard_crit_nomiss = class({})

function modifier_item_bloody_shard_crit_nomiss:IsHidden()
    return true
end

function modifier_item_bloody_shard_crit_nomiss:IsPurgable()
    return false
end

function modifier_item_bloody_shard_crit_nomiss:OnCreated(kv)
    if not IsServer() then
        return
    end

    self.record = kv.record
end

function modifier_item_bloody_shard_crit_nomiss:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_EVASION
    }

    return funcs
end

function modifier_item_bloody_shard_crit_nomiss:GetModifierDisableEvasion(params)
    if params and params.record and params.record == self.record then
        return 1
    end

    return 0
end

function modifier_item_bloody_shard_crit_nomiss:CheckState()
    return {
        [MODIFIER_STATE_CANNOT_MISS] = true
    }
end