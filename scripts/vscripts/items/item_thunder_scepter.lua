LinkLuaModifier("modifier_item_thunder_scepter", "items/item_thunder_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_scepter_cyclone", "items/item_thunder_scepter", LUA_MODIFIER_MOTION_BOTH)

item_thunder_scepter = class({})

function item_thunder_scepter:GetIntrinsicModifierName()
    return "modifier_item_thunder_scepter"
end

function item_thunder_scepter:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    if not target then return end
    if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(caster, self, "modifier_item_thunder_scepter_cyclone", {
        duration = self:GetSpecialValueFor("cyclone_duration"),
    })
end

modifier_item_thunder_scepter = class({})

function modifier_item_thunder_scepter:IsHidden() return true end
function modifier_item_thunder_scepter:IsPurgable() return false end
function modifier_item_thunder_scepter:RemoveOnDeath() return false end
function modifier_item_thunder_scepter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_thunder_scepter:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }
end

function modifier_item_thunder_scepter:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_item_thunder_scepter:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_thunder_scepter:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_thunder_scepter:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_amp") end
function modifier_item_thunder_scepter:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_spell_amp") end
function modifier_item_thunder_scepter:GetModifierPercentageCasttime() return -self:GetAbility():GetSpecialValueFor("bonus_cast_speed_pct") end

modifier_item_thunder_scepter_cyclone = class({})

function modifier_item_thunder_scepter_cyclone:IsHidden() return false end
function modifier_item_thunder_scepter_cyclone:IsPurgable() return false end
function modifier_item_thunder_scepter_cyclone:IsDebuff() return self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() end

function modifier_item_thunder_scepter_cyclone:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_item_thunder_scepter_cyclone:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("cyclone_enemy_damage")
end

function modifier_item_thunder_scepter_cyclone:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if not parent or not caster or not ability then return end

    if parent:GetTeamNumber() ~= caster:GetTeamNumber() and self.damage > 0 then
        ApplyDamage({
            victim = parent,
            attacker = caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        })
    end
end
