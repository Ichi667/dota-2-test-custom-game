hero_dash_strike = class({})

function hero_dash_strike:Precache(context)
    PrecacheResource("particle", "particles/antimage_dash/antimage_dash.vpcf", context)
end

function hero_dash_strike:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()
    local direction = caster:GetForwardVector()

    local dash_distance = self:GetSpecialValueFor("dash_distance")
    local strike_radius = self:GetSpecialValueFor("strike_radius")
    local damage_pct = self:GetSpecialValueFor("damage_pct")
    local target_point = origin + direction * dash_distance

    local enemies = FindUnitsInLine(
        caster:GetTeamNumber(),
        origin,
        target_point,
        nil,
        strike_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    )

    local damage = caster:GetAverageTrueAttackDamage(nil) * damage_pct * 0.01

    for _, enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            ability = self,
        })
    end

    FindClearSpaceForUnit(caster, target_point, true)
    caster:FaceTowards(target_point + direction)

    local particle = ParticleManager:CreateParticle(
        "particles/antimage_dash/antimage_dash.vpcf",
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, target_point)
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn("Hero_VoidSpirit.AstralStep.Cast", caster)
end