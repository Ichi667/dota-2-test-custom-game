LinkLuaModifier("modifier_item_cuirass_of_weakness", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_aura", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_buff", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)

item_cuirass_of_weakness = class({})

function item_cuirass_of_weakness:GetIntrinsicModifierName()
    return "modifier_item_cuirass_of_weakness"
end

function item_cuirass_of_weakness:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_cuirass_of_weakness_buff", {
        duration = self:GetSpecialValueFor("active_duration"),
    })
end

modifier_item_cuirass_of_weakness = class({})

function modifier_item_cuirass_of_weakness:IsHidden() return true end
function modifier_item_cuirass_of_weakness:IsPurgable() return false end
function modifier_item_cuirass_of_weakness:RemoveOnDeath() return false end
function modifier_item_cuirass_of_weakness:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_cuirass_of_weakness:IsAura() return true end
function modifier_item_cuirass_of_weakness:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_cuirass_of_weakness:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_cuirass_of_weakness:GetModifierAura() return "modifier_item_cuirass_of_weakness_aura" end
function modifier_item_cuirass_of_weakness:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

function modifier_item_cuirass_of_weakness:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_cuirass_of_weakness:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_cuirass_of_weakness:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

modifier_item_cuirass_of_weakness_aura = class({})

function modifier_item_cuirass_of_weakness_aura:IsHidden() return false end
function modifier_item_cuirass_of_weakness_aura:IsPurgable() return false end
function modifier_item_cuirass_of_weakness_aura:IsDebuff() return true end

function modifier_item_cuirass_of_weakness_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_cuirass_of_weakness_aura:GetModifierPhysicalArmorBonus()
    return -self:GetAbility():GetSpecialValueFor("aura_armor_reduction")
end

function modifier_item_cuirass_of_weakness_aura:GetModifierAttackSpeedBonus_Constant()
    return -self:GetAbility():GetSpecialValueFor("aura_attack_speed_reduction")
end

modifier_item_cuirass_of_weakness_buff = class({})

function modifier_item_cuirass_of_weakness_buff:IsHidden() return false end
function modifier_item_cuirass_of_weakness_buff:IsPurgable() return true end

function modifier_item_cuirass_of_weakness_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_cuirass_of_weakness_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("aura_armor_reduction")
end

function modifier_item_cuirass_of_weakness_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("aura_attack_speed_reduction")
end
