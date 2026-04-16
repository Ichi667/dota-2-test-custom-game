antimage_mana_void_custom = class({})

LinkLuaModifier("modifier_antimage_mana_void_custom_block_regen", "abilities/antimage/antimage_mana_void_custom.lua", LUA_MODIFIER_MOTION_NONE)

function antimage_mana_void_custom:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local radius = self:GetSpecialValueFor("radius")
    local mana_burn_pct = self:GetSpecialValueFor("mana_burn_pct")
    local damage_from_burn_pct = self:GetSpecialValueFor("damage_from_burn_pct")
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    local debuff_duration = self:GetSpecialValueFor("disable_regen_duration")
    if caster:HasShard() then
        debuff_duration = debuff_duration + self:GetSpecialValueFor("shard_bonus_disable_regen_duration")
    end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        local mana_to_burn = enemy:GetMaxMana() * mana_burn_pct * 0.01
        local mana_burned = math.min(enemy:GetMana(), mana_to_burn)
        if mana_burned > 0 then
            enemy:Script_ReduceMana(mana_burned, self)
        end

        local damage = mana_burned * damage_from_burn_pct * 0.01
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        })

        enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = stun_duration })

        if debuff_duration > 0 then
            enemy:AddNewModifier(caster, self, "modifier_antimage_mana_void_custom_block_regen", { duration = debuff_duration })
        end
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOnLocationWithCaster(point, "Hero_Antimage.ManaVoid", caster)
end

modifier_antimage_mana_void_custom_block_regen = class({})

function modifier_antimage_mana_void_custom_block_regen:IsDebuff() return true end
function modifier_antimage_mana_void_custom_block_regen:IsPurgable() return true end

function modifier_antimage_mana_void_custom_block_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
end

function modifier_antimage_mana_void_custom_block_regen:GetModifierHealAmplify_PercentageTarget()
    return -100
end

function modifier_antimage_mana_void_custom_block_regen:GetModifierHPRegenAmplify_Percentage()
    return -100
end

function modifier_antimage_mana_void_custom_block_regen:GetModifierTotalPercentageManaRegen()
    return -100
end
