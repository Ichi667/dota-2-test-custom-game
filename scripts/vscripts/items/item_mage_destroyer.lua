LinkLuaModifier("modifier_item_mage_destroyer", "items/item_mage_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mage_destroyer_debuff", "items/item_mage_destroyer", LUA_MODIFIER_MOTION_NONE)

item_mage_destroyer = class({})

function item_mage_destroyer:GetIntrinsicModifierName()
    return "modifier_item_mage_destroyer"
end

modifier_item_mage_destroyer = class({})

function modifier_item_mage_destroyer:IsHidden() return true end
function modifier_item_mage_destroyer:IsPurgable() return false end
function modifier_item_mage_destroyer:RemoveOnDeath() return false end
function modifier_item_mage_destroyer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mage_destroyer:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_mage_destroyer:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_magic_resistance")
end

function modifier_item_mage_destroyer:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_mage_destroyer:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_mage_destroyer:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_mage_destroyer:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_mage_destroyer:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_mage_destroyer:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local target = params.target

    if params.attacker ~= parent then return end
    if parent:IsIllusion() or parent:PassivesDisabled() then return end
    if not target or target:IsNull() or not target:IsAlive() then return end
    if target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if target:IsBuilding() or target:IsOther() then return end

    target:AddNewModifier(parent, ability, "modifier_item_mage_destroyer_debuff", {
        duration = ability:GetSpecialValueFor("debuff_duration"),
    })
end

modifier_item_mage_destroyer_debuff = class({})

function modifier_item_mage_destroyer_debuff:IsHidden() return false end
function modifier_item_mage_destroyer_debuff:IsPurgable() return true end
function modifier_item_mage_destroyer_debuff:IsDebuff() return true end
function modifier_item_mage_destroyer_debuff:GetTexture() return "mage_slayer" end

function modifier_item_mage_destroyer_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_item_mage_destroyer_debuff:OnRefresh()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_item_mage_destroyer_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_mage_destroyer_debuff:GetModifierSpellAmplify_Percentage()
    return -self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end

function modifier_item_mage_destroyer_debuff:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if not parent or not caster or not ability then return end

    ApplyDamage({
        victim = parent,
        attacker = caster,
        damage = ability:GetSpecialValueFor("debuff_pure_dps"),
        damage_type = DAMAGE_TYPE_PURE,
        ability = ability,
    })

    local mana_burn = ability:GetSpecialValueFor("debuff_mana_burn_per_second")
    if mana_burn > 0 then
        parent:Script_ReduceMana(math.min(parent:GetMana(), mana_burn), ability)
    end
end
