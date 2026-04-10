LinkLuaModifier("modifier_lina_light_strike_array_custom", "abilities/lina/lina_light_strike_array_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_light_strike_array_custom_burn", "abilities/lina/lina_light_strike_array_custom", LUA_MODIFIER_MOTION_NONE)

lina_light_strike_array_custom = class({})

function lina_light_strike_array_custom:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_laguna_blade_shard_scorch.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", context)
end

function lina_light_strike_array_custom:GetAOERadius()
    return self:GetSpecialValueFor("light_strike_array_aoe")
end

function lina_light_strike_array_custom:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("light_strike_array_delay_time")

    CreateModifierThinker(
        caster,
        self,
        "modifier_lina_light_strike_array_custom",
        { duration = delay },
        point,
        caster:GetTeamNumber(),
        false
    )
end

modifier_lina_light_strike_array_custom = class({})

function modifier_lina_light_strike_array_custom:IsHidden() return true end
function modifier_lina_light_strike_array_custom:IsPurgable() return false end

function modifier_lina_light_strike_array_custom:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.stun = self.ability:GetSpecialValueFor("light_strike_array_stun_duration")
    self.radius = self.ability:GetSpecialValueFor("light_strike_array_aoe")

    if not IsServer() then return end
    self:PlayEffects1()
end

function modifier_lina_light_strike_array_custom:OnDestroy()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then return end
    if not self.caster or self.caster:IsNull() then return end
    if not self.parent or self.parent:IsNull() then return end

    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, false)

    local mana_damage_pct = self.ability:GetSpecialValueFor("light_strike_array_damage_mana_pct")

    local damage_source = self.caster:GetMana()
    local talent = self.caster:FindAbilityByName("special_bonus_unique_lina_custom_8")
    if talent and talent:GetLevel() > 0 then
        damage_source = self.caster:GetMaxMana()
    end

    local damage = damage_source * mana_damage_pct * 0.01

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        self.parent:GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = self.caster,
            damage = damage,
            damage_type = self.ability:GetAbilityDamageType(),
            ability = self.ability
        })

        enemy:AddNewModifier(self.caster, self.ability, "modifier_stunned", {
            duration = self.stun * (1 - enemy:GetStatusResistance())
        })
    end

    self:PlayEffects2()

    local burn_duration = self.ability:GetSpecialValueFor("burn_duration")
    local talent_duration = self.caster:FindAbilityByName("special_bonus_unique_lina_custom_3")
    if talent_duration and talent_duration:GetLevel() > 0 then
        burn_duration = burn_duration + talent_duration:GetSpecialValueFor("value")
    end

    local burn_thinker = CreateModifierThinker(
        self.caster,
        self.ability,
        "modifier_lina_light_strike_array_custom_burn",
        { duration = burn_duration },
        self.parent:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

    if burn_thinker then
        local old_origin = self.parent:GetOrigin()
        local new_origin = burn_thinker:GetOrigin()

        if (new_origin - old_origin):Length2D() > 1 then
            burn_thinker:SetAbsOrigin(old_origin)
        end
    end

    UTIL_Remove(self.parent)
end

function modifier_lina_light_strike_array_custom:PlayEffects1()
    local particle_cast = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf"
    local sound_cast = "Ability.PreLightStrikeArray"

    local effect_cast = ParticleManager:CreateParticleForTeam(
        particle_cast,
        PATTACH_WORLDORIGIN,
        self.caster,
        self.caster:GetTeamNumber()
    )
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    EmitSoundOnLocationForAllies(self.parent:GetOrigin(), sound_cast, self.caster)
end

function modifier_lina_light_strike_array_custom:PlayEffects2()
    local particle_cast = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
    local sound_cast = "Ability.LightStrikeArray"

    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    EmitSoundOnLocationWithCaster(self.parent:GetOrigin(), sound_cast, self.caster)
end

modifier_lina_light_strike_array_custom_burn = class({})

function modifier_lina_light_strike_array_custom_burn:IsHidden() return true end
function modifier_lina_light_strike_array_custom_burn:IsPurgable() return false end

function modifier_lina_light_strike_array_custom_burn:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.radius = self.ability:GetSpecialValueFor("burn_radius")
    self.burn_tick = self.ability:GetSpecialValueFor("burn_tick")

    if not IsServer() then return end

    local scorch = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_lina/lina_spell_laguna_blade_shard_scorch.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(scorch, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(scorch, 1, self.parent:GetAbsOrigin())
    self:AddParticle(scorch, false, false, -1, false, false)

    local fireball = ParticleManager:CreateParticle(
        "particles/hero/lina_2.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(fireball, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(fireball, 1, Vector(self.radius, 1, 1))
    self:AddParticle(fireball, false, false, -1, false, false)

    self:StartIntervalThink(self.burn_tick)
end

function modifier_lina_light_strike_array_custom_burn:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then return end
    if not self.caster or self.caster:IsNull() then return end
    if not self.parent or self.parent:IsNull() then return end

    local burn_pct_per_sec = self.ability:GetSpecialValueFor("burn_max_hp_pct_per_sec")
    local talent = self.caster:FindAbilityByName("special_bonus_unique_lina_custom_6")
    if talent and talent:GetLevel() > 0 then
        burn_pct_per_sec = burn_pct_per_sec + talent:GetSpecialValueFor("value")
    end

    local burn_damage = burn_pct_per_sec * 0.01 * self.burn_tick

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        ApplyDamage({
            attacker = self.caster,
            victim = enemy,
            damage = enemy:GetMaxHealth() * burn_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        })
    end


end

function modifier_lina_light_strike_array_custom_burn:OnDestroy()
    if not IsServer() then return end
    if self.parent and not self.parent:IsNull() then
        UTIL_Remove(self.parent)
    end
end