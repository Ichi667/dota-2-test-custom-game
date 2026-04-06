LinkLuaModifier("modifier_item_spell_blade", "items/item_spell_blade", LUA_MODIFIER_MOTION_NONE)

item_spell_blade = class({})

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
        EffectName = "particles/items_fx/ethereal_blade.vpcf",
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        bDodgeable = true,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        ExtraData = {
            intellect = caster:GetIntellect(),
        },
    }

    ProjectileManager:CreateTrackingProjectile(projectile)
    caster:EmitSound("DOTA_Item.EtherealBlade.Activate")
end

function item_spell_blade:OnProjectileHit_ExtraData(target, location, extra_data)
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
        local int_at_cast = tonumber(extra_data and extra_data.intellect) or caster:GetIntellect()
        local damage = int_at_cast * self:GetSpecialValueFor("active_int_multiplier")

        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        })
    end

    target:EmitSound("DOTA_Item.EtherealBlade.Target")

    local pfx = ParticleManager:CreateParticle("particles/items_fx/ethereal_blade_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(pfx)

    return true
end

modifier_item_spell_blade = class({})

function modifier_item_spell_blade:IsHidden() return true end
function modifier_item_spell_blade:IsPurgable() return false end
function modifier_item_spell_blade:RemoveOnDeath() return false end
function modifier_item_spell_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_spell_blade:OnCreated()
    if not IsServer() then return end
    self.processing = false
    self.pseudo_random_id = DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2
end

function modifier_item_spell_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_spell_blade:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_spell_blade:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_spell_blade:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_spell_blade:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_spell_blade:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_spell_blade:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end

function modifier_item_spell_blade:OnTakeDamage(params)
    if not IsServer() then return end
    if self.processing then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not ability or not parent or params.attacker ~= parent then return end
    if parent:IsIllusion() or parent:PassivesDisabled() then return end
    if not params.unit or params.unit:IsNull() then return end
    if not params.inflictor then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end

    local crit_chance = ability:GetSpecialValueFor("spell_crit_chance")
    if not RollPseudoRandomPercentage(crit_chance, self.pseudo_random_id, parent) then
        return
    end

    local multiplier = ability:GetSpecialValueFor("spell_damage_multiplier")
    local extra_damage = params.damage * (multiplier - 1)
    if extra_damage <= 0 then return end

    self.processing = true
    ApplyDamage({
        victim = params.unit,
        attacker = parent,
        damage = extra_damage,
        damage_type = params.damage_type,
        ability = ability,
        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
    })
    self.processing = false

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL_SPELL, params.unit, params.damage * multiplier, nil)
end
