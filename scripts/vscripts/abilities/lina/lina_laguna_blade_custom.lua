LinkLuaModifier("modifier_lina_laguna_blade_custom_tracker", "abilities/lina/lina_laguna_blade_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_laguna_blade_custom_no_count", "abilities/lina/lina_laguna_blade_custom", LUA_MODIFIER_MOTION_NONE)

lina_laguna_blade_custom = class({})

function lina_laguna_blade_custom:GetIntrinsicModifierName()
    return "modifier_lina_laguna_blade_custom_tracker"
end

modifier_lina_laguna_blade_custom_tracker = class({})

function modifier_lina_laguna_blade_custom_tracker:IsHidden() return true end
function modifier_lina_laguna_blade_custom_tracker:IsPurgable() return false end

function modifier_lina_laguna_blade_custom_tracker:OnCreated()
    self.damage_threshold = self:GetAbility():GetSpecialValueFor("damage_threshold")
    self.search_radius = self:GetAbility():GetSpecialValueFor("search_radius")
    self.knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance")
    self.knockback_duration = self:GetAbility():GetSpecialValueFor("knockback_duration")
    self.aoe_radius = self:GetAbility():GetSpecialValueFor("aoe_radius")
    self.attr_damage_pct = self:GetAbility():GetSpecialValueFor("attribute_damage_pct")
    self.proc_cd = self:GetAbility():GetSpecialValueFor("proc_cooldown")
    self.damage_pool = 0
end

function modifier_lina_laguna_blade_custom_tracker:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_lina_laguna_blade_custom_tracker:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.damage <= 0 then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():HasModifier("modifier_lina_laguna_blade_custom_no_count") then return end
    if GameRules:GetGameTime() < (self.next_proc_time or 0) then return end
    if params.inflictor == self:GetAbility() then return end

    self.damage_pool = self.damage_pool + params.damage

    while self.damage_pool >= self.damage_threshold do
        if not self:TryProc() then
            break
        end
        self.damage_pool = self.damage_pool - self.damage_threshold
    end
end

function modifier_lina_laguna_blade_custom_tracker:TryProc()
    local caster = self:GetParent()
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        self.search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    local target = enemies[1]
    if not target then
        return false
    end

    self.next_proc_time = GameRules:GetGameTime() + self.proc_cd

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
    caster:EmitSound("Ability.LagunaBlade")

    local center = caster:GetAbsOrigin()
    target:AddNewModifier(caster, self:GetAbility(), "modifier_knockback", {
        should_stun = 0,
        knockback_duration = self.knockback_duration,
        duration = self.knockback_duration,
        knockback_distance = self.knockback_distance,
        knockback_height = 0,
        center_x = center.x,
        center_y = center.y,
        center_z = center.z
    })

    local total_attributes = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect(false)
    local aoe_damage = total_attributes * self.attr_damage_pct * 0.01

    caster:AddNewModifier(caster, self:GetAbility(), "modifier_lina_laguna_blade_custom_no_count", { duration = 0.2 })

    local victims = FindUnitsInRadius(
        caster:GetTeamNumber(),
        target:GetAbsOrigin(),
        nil,
        self.aoe_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(victims) do
        ApplyDamage({
            attacker = caster,
            victim = enemy,
            damage = aoe_damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()
        })
    end

    target:EmitSound("Ability.LagunaBladeImpact")
    return true
end

modifier_lina_laguna_blade_custom_no_count = class({})
function modifier_lina_laguna_blade_custom_no_count:IsHidden() return true end
function modifier_lina_laguna_blade_custom_no_count:IsPurgable() return false end
