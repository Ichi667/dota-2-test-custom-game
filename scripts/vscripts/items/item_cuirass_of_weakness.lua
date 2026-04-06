LinkLuaModifier("modifier_item_cuirass_of_weakness", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_aura", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_of_weakness_buff", "items/item_cuirass_of_weakness", LUA_MODIFIER_MOTION_NONE)

item_cuirass_of_weakness = class({})

function item_cuirass_of_weakness:GetIntrinsicModifierName()
    return "modifier_item_cuirass_of_weakness"
end

function item_cuirass_of_weakness:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("aura_radius")
    local affected_count = 0

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        if enemy:HasModifier("modifier_item_cuirass_of_weakness_aura") then
            affected_count = affected_count + 1
        end
    end

    caster:AddNewModifier(caster, self, "modifier_item_cuirass_of_weakness_buff", {
        duration = self:GetSpecialValueFor("active_duration"),
        affected_count = affected_count,
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

function modifier_item_cuirass_of_weakness_buff:OnCreated(kv)
    self.affected_count = tonumber(kv and kv.affected_count) or 0
end

function modifier_item_cuirass_of_weakness_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_cuirass_of_weakness_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("aura_armor_reduction") * self.affected_count
end

function modifier_item_cuirass_of_weakness_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("aura_attack_speed_reduction") * self.affected_count
end
