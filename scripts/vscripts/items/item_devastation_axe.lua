LinkLuaModifier("modifier_item_devastation_axe", "items/item_devastation_axe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_devastation_axe_active", "items/item_devastation_axe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_devastation_axe_armor_debuff", "items/item_devastation_axe", LUA_MODIFIER_MOTION_NONE)

item_devastation_axe = class({})

function item_devastation_axe:Precache(context)
    PrecacheResource("particle", "particles/items/sven_ti10_hgs_gods_strength_ring.vpcf", context)
    PrecacheResource("particle", "particles/items/devastation_splash.vpcf", context)
end

local SOUND_APPLY_ACTIVE = "devastation_activate"
local SOUND_CLEAVE = "Hero_Sven.Attack"

function item_devastation_axe:GetIntrinsicModifierName()
    return "modifier_item_devastation_axe"
end

function item_devastation_axe:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("active_duration")
    caster:RemoveModifierByName("modifier_item_devastation_axe_active")
    caster:AddNewModifier(caster, self, "modifier_item_devastation_axe_active", { duration = duration })

    if SOUND_APPLY_ACTIVE ~= "" then
        caster:EmitSound(SOUND_APPLY_ACTIVE)
    end

    local particle = ParticleManager:CreateParticle("particles/items/sven_ti10_hgs_gods_strength_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_item_devastation_axe = class({})
local CLEAVE_MODIFIER_PRIORITY = {
    "modifier_item_devastation_axe",
    "modifier_item_woodsplitter_axe_3",
    "modifier_item_woodsplitter_axe_2",
    "modifier_item_woodsplitter_axe",
}

function modifier_item_devastation_axe:IsHidden() return true end
function modifier_item_devastation_axe:IsPurgable() return false end
function modifier_item_devastation_axe:RemoveOnDeath() return false end
function modifier_item_devastation_axe:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_devastation_axe:OnCreated()
    if not IsServer() then return end
    self.processed_records = {}
end

function modifier_item_devastation_axe:OnRefresh()
    if not IsServer() then return end
    self.processed_records = self.processed_records or {}
end

function modifier_item_devastation_axe:IsPrimaryModifier()
    local parent = self:GetParent()
    if not parent then return false end

    for _, modifier_name in ipairs(CLEAVE_MODIFIER_PRIORITY) do
        local modifiers = parent:FindAllModifiersByName(modifier_name)
        if #modifiers > 0 then
            return modifiers[1] == self
        end
    end

    return false
end

function modifier_item_devastation_axe:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
    }
end

function modifier_item_devastation_axe:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    if not ability or not parent then return 0 end
    if parent:IsRangedAttacker() then
        return ability:GetSpecialValueFor("bonus_damage_ranged")
    end
    return ability:GetSpecialValueFor("bonus_damage_melee")
end

function modifier_item_devastation_axe:GetModifierHealthBonus()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_health") or 0
end

function modifier_item_devastation_axe:GetModifierConstantManaRegen()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_mana_regen") or 0
end

function modifier_item_devastation_axe:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_all_stats") or 0
end

function modifier_item_devastation_axe:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_all_stats") or 0
end

function modifier_item_devastation_axe:GetModifierBonusStats_Intellect()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_all_stats") or 0
end

function modifier_item_devastation_axe:OnAttackRecordDestroy(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if self.processed_records and params.record ~= nil then
        self.processed_records[params.record] = nil
    end
end

function modifier_item_devastation_axe:ApplyArmorDebuffAround(main_target)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability or not main_target or main_target:IsNull() then return end

    local radius = ability:GetSpecialValueFor("cleave_distance")
    local duration = ability:GetSpecialValueFor("armor_reduction_duration")
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        main_target:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        if enemy ~= main_target and enemy:IsAlive() and not enemy:IsBuilding() and not enemy:IsOther() then
            local debuff = enemy:AddNewModifier(parent, ability, "modifier_item_devastation_axe_armor_debuff", { duration = duration })
            if debuff then debuff:IncrementStackCount() end
        end
    end
end

function modifier_item_devastation_axe:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local target = params.target

    if not parent or not ability then return end
    if params.attacker ~= parent then return end
    if not self:IsPrimaryModifier() then return end
    if parent:IsIllusion() or parent:PassivesDisabled() or parent:IsRangedAttacker() then return end
    if not target or target:IsNull() or target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if target:IsBuilding() or target:IsOther() then return end

    if params.record ~= nil then
        self.processed_records = self.processed_records or {}
        if self.processed_records[params.record] then return end
        self.processed_records[params.record] = true
    end

    local base_damage = params.damage or params.original_damage or parent:GetAverageTrueAttackDamage(target)
    local damage_for_cleave = base_damage

    local active_modifier = parent:FindModifierByName("modifier_item_devastation_axe_active")
    if active_modifier then
        local damage_multiplier = active_modifier:GetDamageMultiplier()
        local bonus_damage = base_damage * (damage_multiplier - 1)

        ApplyDamage({
            victim = target,
            attacker = parent,
            damage = bonus_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = ability,
        })

        local stun_duration = ability:GetSpecialValueFor("active_stun_duration")
        target:AddNewModifier(parent, ability, "modifier_stunned", {
            duration = stun_duration * (1 - target:GetStatusResistance()),
        })

        damage_for_cleave = base_damage * damage_multiplier
        active_modifier:Destroy()
    end

    local cleave_damage = damage_for_cleave * ability:GetSpecialValueFor("cleave_damage_pct") * 0.01
    local cleave_radius = ability:GetSpecialValueFor("cleave_distance")

    DoCleaveAttack(parent, target, ability, cleave_damage, 150, cleave_radius, cleave_radius, "particles/items/devastation_splash.vpcf")

    if SOUND_CLEAVE ~= "" then
        parent:EmitSound(SOUND_CLEAVE)
    end

    local main_debuff = target:AddNewModifier(parent, ability, "modifier_item_devastation_axe_armor_debuff", {
        duration = ability:GetSpecialValueFor("armor_reduction_duration"),
    })
    if main_debuff then main_debuff:IncrementStackCount() end

    self:ApplyArmorDebuffAround(target)
end

modifier_item_devastation_axe_active = class({})
function modifier_item_devastation_axe_active:IsHidden() return false end
function modifier_item_devastation_axe_active:IsPurgable() return false end
function modifier_item_devastation_axe_active:GetTexture() return "devastation_axe" end

function modifier_item_devastation_axe_active:GetDamageMultiplier()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("active_damage_multiplier") or 1
end

modifier_item_devastation_axe_armor_debuff = class({})
function modifier_item_devastation_axe_armor_debuff:IsHidden() return false end
function modifier_item_devastation_axe_armor_debuff:IsPurgable() return true end
function modifier_item_devastation_axe_armor_debuff:IsDebuff() return true end
function modifier_item_devastation_axe_armor_debuff:GetTexture() return "devastation_axe" end
function modifier_item_devastation_axe_armor_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_devastation_axe_armor_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_devastation_axe_armor_debuff:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return -ability:GetSpecialValueFor("armor_reduction_per_stack") * self:GetStackCount()
end
