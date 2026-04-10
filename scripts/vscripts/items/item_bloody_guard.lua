LinkLuaModifier("modifier_item_bloody_guard", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloody_guard_aura", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloody_guard_active", "items/item_bloody_guard", LUA_MODIFIER_MOTION_NONE)

item_bloody_guard = class({})

function item_bloody_guard:GetIntrinsicModifierName()
    return "modifier_item_bloody_guard"
end

function item_bloody_guard:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_item_bloody_guard_active", {
        duration = self:GetSpecialValueFor("active_duration"),
    })

    caster:EmitSound("DOTA_Item.Bloodstone.Cast")
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

function modifier_item_bloody_guard:GetSpellLifestealValue()
    local value = self:GetAbility():GetSpecialValueFor("bonus_spell_lifesteal")
    if self:GetParent():HasModifier("modifier_item_bloody_guard_active") then
        value = value + self:GetAbility():GetSpecialValueFor("active_bonus_spell_lifesteal")
    end
    return value
end

function modifier_item_bloody_guard:OnTakeDamage(keys)
    if not IsServer() then return end

    if keys.attacker ~= self:GetParent() then return end
    if keys.unit == keys.attacker then return end
    if not keys.unit or keys.unit:IsBuilding() or keys.unit:IsOther() then return end

    if self:GetParent():FindAllModifiersByName(self:GetName())[1] ~= self then return end
    if keys.damage_category ~= 0 then return end
    if not keys.inflictor then return end

    local flags = keys.damage_flags or 0
    if bit.band(flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then return end

    local lifesteal = self:GetSpellLifestealValue()
    local heal = (keys.original_damage or keys.damage or 0) * lifesteal * 0.01
    if heal <= 0 then return end

    local pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
    ParticleManager:SetParticleControl(pfx, 0, keys.attacker:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pfx)

    if keys.attacker:GetHealth() <= heal and bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
        keys.attacker:ForceKill(true)
    else
        keys.attacker:Heal(heal, self:GetAbility())
    end
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

function modifier_item_bloody_guard_active:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()

    local particle = ParticleManager:CreateParticle(
        "particles/items/bloodstone_heal.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        parent
    )

    ParticleManager:SetParticleControlEnt(
        particle,
        2,
        parent,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        parent:GetAbsOrigin(),
        true
    )

    ParticleManager:SetParticleControlEnt(
        particle,
        1,
        parent,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        parent:GetAbsOrigin(),
        true
    )

    ParticleManager:SetParticleControlEnt(
        particle,
        6,
        parent,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        parent:GetAbsOrigin(),
        true
    )

    self:AddParticle(particle, false, false, -1, false, true)
end