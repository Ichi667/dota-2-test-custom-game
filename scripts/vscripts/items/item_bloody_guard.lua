LinkLuaModifier("modifier_item_bloody_guard", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloody_guard_aura", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloody_guard_active", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)

item_bloody_guard = class({})

function item_bloody_guard:GetIntrinsicModifierName()
    return "modifier_item_bloody_guard"
end

function item_bloody_guard:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_bloody_guard_active", {
        duration = self:GetSpecialValueFor("active_duration"),
    })
end

modifier_item_bloody_guard = class({})

function modifier_item_bloody_guard:IsHidden() return true end
function modifier_item_bloody_guard:IsPurgable() return false end
function modifier_item_bloody_guard:RemoveOnDeath() return false end
function modifier_item_bloody_guard:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_bloody_guard:IsAura() return true end
function modifier_item_bloody_guard:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_bloody_guard:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_bloody_guard:GetModifierAura() return "modifier_item_bloody_guard_aura" end
function modifier_item_bloody_guard:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

function modifier_item_bloody_guard:OnCreated()
    if not IsServer() then return end
    self.processing = false
end

function modifier_item_bloody_guard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_bloody_guard:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_bloody_guard:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_bloody_guard:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_bloody_guard:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_bloody_guard:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end

function modifier_item_bloody_guard:GetSpellLifestealPct()
    local ability = self:GetAbility()
    if not ability then return 0 end

    local total = ability:GetSpecialValueFor("bonus_spell_lifesteal")
    local active_modifier = self:GetParent():FindModifierByName("modifier_item_bloody_guard_active")
    if active_modifier then
        total = total + ability:GetSpecialValueFor("active_bonus_spell_lifesteal")
    end

    return total
end

function modifier_item_bloody_guard:OnTakeDamage(params)
    if not IsServer() then return end
    if self.processing then return end

    local parent = self:GetParent()
    if params.attacker ~= parent then return end
    if parent:IsIllusion() then return end
    if not params.inflictor then return end
    if not params.unit or params.unit:IsNull() or params.unit:IsBuilding() then return end
    if params.damage <= 0 then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end

    local lifesteal_pct = self:GetSpellLifestealPct()
    if lifesteal_pct <= 0 then return end

    local heal = params.damage * lifesteal_pct * 0.01
    if heal <= 0 then return end

    self.processing = true
    parent:Heal(heal, self:GetAbility())
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, nil)
    self.processing = false
end

modifier_item_bloody_guard_aura = class({})

function modifier_item_bloody_guard_aura:IsHidden() return false end
function modifier_item_bloody_guard_aura:IsPurgable() return false end
function modifier_item_bloody_guard_aura:IsDebuff() return true end

function modifier_item_bloody_guard_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_item_bloody_guard_aura:GetModifierAttackSpeedBonus_Constant()
    return -self:GetAbility():GetSpecialValueFor("aura_attack_speed_slow")
end

function modifier_item_bloody_guard_aura:GetModifierIncomingDamage_Percentage(params)
    if not params or not params.inflictor then return 0 end
    return self:GetAbility():GetSpecialValueFor("aura_spell_damage_taken_pct")
end

modifier_item_bloody_guard_active = class({})

function modifier_item_bloody_guard_active:IsHidden() return false end
function modifier_item_bloody_guard_active:IsPurgable() return true end
