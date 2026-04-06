LinkLuaModifier("modifier_item_thunder_scepter", "items/item_thunder_scepter", LUA_MODIFIER_MOTION_NONE)

item_thunder_scepter = class({})

function item_thunder_scepter:GetIntrinsicModifierName()
    return "modifier_item_thunder_scepter"
end

function item_thunder_scepter:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    if not target or not caster then return end

    local is_enemy = target:GetTeamNumber() ~= caster:GetTeamNumber()
    if is_enemy and target:TriggerSpellAbsorb(self) then
        return
    end

    local duration = self:GetSpecialValueFor("cyclone_duration")
    target:AddNewModifier(caster, self, "modifier_eul_cyclone", { duration = duration })
    target:EmitSound("DOTA_Item.Cyclone.Activate")

    if is_enemy then
        local target_index = target:entindex()
        local damage = self:GetSpecialValueFor("cyclone_enemy_damage")

        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("thunder_scepter_cyclone_"), function()
            local victim = EntIndexToHScript(target_index)
            if not victim or victim:IsNull() or not victim:IsAlive() then return nil end

            ApplyDamage({
                victim = victim,
                attacker = caster,
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self,
            })

            victim:EmitSound("DOTA_Item.Cyclone.Damage")
            return nil
        end, duration)
    end
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
function modifier_item_thunder_scepter:GetModifierPercentageCasttime() return self:GetAbility():GetSpecialValueFor("bonus_cast_speed_pct") end
