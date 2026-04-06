LinkLuaModifier("modifier_item_cuirass_of_weakness", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_aura", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_buff", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)

item_cuirass_of_weakness = class({})

function item_cuirass_of_weakness:GetIntrinsicModifierName()
    return "modifier_item_cuirass_of_weakness"
end

function item_cuirass_of_weakness:OnSpellStart()
    local caster = self:GetCaster()
    if not caster then
        return
    end

    local radius = self:GetSpecialValueFor("aura_radius")
    local affected_count = 0

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        if enemy
            and not enemy:IsNull()
            and enemy:IsAlive()
            and not enemy:IsBuilding()
        then
            affected_count = affected_count + 1
        end
    end

    local duration = self:GetSpecialValueFor("active_duration")

    local buff = caster:FindModifierByName("modifier_item_cuirass_of_weakness_buff")
    if buff then
        buff:SetDuration(duration, true)
        buff:SetStackCount(affected_count)
        buff.affected_count = affected_count
    else
        buff = caster:AddNewModifier(
            caster,
            self,
            "modifier_item_cuirass_of_weakness_buff",
            {
                duration = duration,
                affected_count = affected_count
            }
        )

        if buff then
            buff:SetStackCount(affected_count)
            buff.affected_count = affected_count
        end
    end

    caster:EmitSound("DOTA_Item.AssaultCuirass.Activate")
end



modifier_item_cuirass_of_weakness = class({})

function modifier_item_cuirass_of_weakness:IsHidden()
    return true
end

function modifier_item_cuirass_of_weakness:IsPurgable()
    return false
end

function modifier_item_cuirass_of_weakness:RemoveOnDeath()
    return false
end

function modifier_item_cuirass_of_weakness:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_cuirass_of_weakness:IsAura()
    return true
end

function modifier_item_cuirass_of_weakness:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_cuirass_of_weakness:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
end

function modifier_item_cuirass_of_weakness:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_cuirass_of_weakness:GetModifierAura()
    return "modifier_item_cuirass_of_weakness_aura"
end

function modifier_item_cuirass_of_weakness:GetAuraRadius()
    if not self:GetAbility() then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_cuirass_of_weakness:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_item_cuirass_of_weakness:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_cuirass_of_weakness:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end



modifier_item_cuirass_of_weakness_aura = class({})

function modifier_item_cuirass_of_weakness_aura:IsHidden()
    return false
end

function modifier_item_cuirass_of_weakness_aura:IsDebuff()
    return true
end

function modifier_item_cuirass_of_weakness_aura:IsPurgable()
    return false
end

function modifier_item_cuirass_of_weakness_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_item_cuirass_of_weakness_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_item_cuirass_of_weakness_aura:IsStrongestAura()
    local parent = self:GetParent()
    if not parent then
        return false
    end

    local modifiers = parent:FindAllModifiersByName("modifier_item_cuirass_of_weakness_aura")
    local best_modifier = nil
    local best_value = -999999

    for _, mod in ipairs(modifiers) do
        if mod and not mod:IsNull() and mod:GetAbility() then
            local value = mod:GetAbility():GetSpecialValueFor("aura_armor_reduction")

            if value > best_value then
                best_value = value
                best_modifier = mod
            elseif value == best_value and best_modifier and best_modifier:GetCaster() and mod:GetCaster() then
                if mod:GetCaster():entindex() < best_modifier:GetCaster():entindex() then
                    best_modifier = mod
                end
            elseif value == best_value and not best_modifier then
                best_modifier = mod
            end
        end
    end

    return best_modifier == self
end

function modifier_item_cuirass_of_weakness_aura:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then
        return 0
    end

    if not self:IsStrongestAura() then
        return 0
    end

    return -self:GetAbility():GetSpecialValueFor("aura_armor_reduction")
end

function modifier_item_cuirass_of_weakness_aura:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then
        return 0
    end

    if not self:IsStrongestAura() then
        return 0
    end

    return -self:GetAbility():GetSpecialValueFor("aura_attack_speed_reduction")
end



modifier_item_cuirass_of_weakness_buff = class({})

function modifier_item_cuirass_of_weakness_buff:IsHidden()
    return false
end

function modifier_item_cuirass_of_weakness_buff:IsPurgable()
    return true
end

function modifier_item_cuirass_of_weakness_buff:OnCreated(kv)
    self.affected_count = tonumber(kv and kv.affected_count) or 0

    if IsServer() then
        self:SetStackCount(self.affected_count)
    end
end

function modifier_item_cuirass_of_weakness_buff:OnRefresh(kv)
    self.affected_count = tonumber(kv and kv.affected_count) or self:GetStackCount() or 0

    if IsServer() then
        self:SetStackCount(self.affected_count)
    end
end

function modifier_item_cuirass_of_weakness_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_item_cuirass_of_weakness_buff:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then
        return 0
    end

    local count = self:GetStackCount()
    return self:GetAbility():GetSpecialValueFor("active_armor_per_enemy") * count
end

function modifier_item_cuirass_of_weakness_buff:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then
        return 0
    end

    local count = self:GetStackCount()
    return self:GetAbility():GetSpecialValueFor("active_attack_speed_per_enemy") * count
end