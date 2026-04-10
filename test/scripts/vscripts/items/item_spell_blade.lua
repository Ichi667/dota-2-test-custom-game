LinkLuaModifier("modifier_item_spell_blade", "items/item_spell_blade", LUA_MODIFIER_MOTION_NONE)

item_spell_blade = class({})

function item_spell_blade:Precache(context)
    PrecacheResource("particle", "particles/items/ethereal_blade.vpcf", context)
    PrecacheResource("particle", "particles/items/ethereal_blade_explosion.vpcf", context)
end

function item_spell_blade:GetIntrinsicModifierName()
    return "modifier_item_spell_blade"
end

function item_spell_blade:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not caster or not target then return end

    local projectile = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/items/ethereal_blade.vpcf",
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        bDodgeable = true,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,
    }

    ProjectileManager:CreateTrackingProjectile(projectile)
    caster:EmitSound("DOTA_Item.EtherealBlade.Activate")
end

function item_spell_blade:OnProjectileHit(target, location)
    if not IsServer() then return true end
    if not target then return true end

    local caster = self:GetCaster()
    if not caster then return true end

    if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:TriggerSpellAbsorb(self) then
        return true
    end

    local duration = self:GetSpecialValueFor("ethereal_duration")
    target:AddNewModifier(caster, self, "modifier_item_ethereal_blade_ethereal", { duration = duration })

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        local damage = caster:GetIntellect(true) * self:GetSpecialValueFor("active_int_multiplier")

        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        })
    end

    target:EmitSound("DOTA_Item.EtherealBlade.Target")

    local pfx = ParticleManager:CreateParticle("particles/items/ethereal_blade_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(pfx)

    return true
end

modifier_item_spell_blade = class({})

function modifier_item_spell_blade:IsHidden() return true end
function modifier_item_spell_blade:IsPurgable() return false end
function modifier_item_spell_blade:RemoveOnDeath() return false end
function modifier_item_spell_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_spell_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_item_spell_blade:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_spell_blade:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_spell_blade:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_spell_blade:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_spell_blade:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_spell_blade:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end

function modifier_item_spell_blade:GetModifierTotalDamageOutgoing_Percentage(params)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local target = params and params.target

    if not ability or not parent or not target then return end
    if parent:IsIllusion() or parent:PassivesDisabled() then return end
    if target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if params.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then return end
    if parent:FindAllModifiersByName("modifier_item_spell_blade")[1] ~= self then return end
    if parent.block_crit ~= nil then return end

    local crit_chance = ability:GetSpecialValueFor("spell_crit_chance")
    if RollPercentage(crit_chance) then
        local multiplier = ability:GetSpecialValueFor("spell_damage_multiplier")
        local damage = params.original_damage + (params.original_damage / 100 * (multiplier - 100))
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)
        return multiplier - 100
    end
end