antimage_mana_break_custom = class({})

LinkLuaModifier("modifier_antimage_mana_break_custom", "abilities/antimage/antimage_mana_break_custom.lua", LUA_MODIFIER_MOTION_NONE)

function antimage_mana_break_custom:GetIntrinsicModifierName()
    return "modifier_antimage_mana_break_custom"
end

modifier_antimage_mana_break_custom = class({})

function modifier_antimage_mana_break_custom:IsHidden() return true end
function modifier_antimage_mana_break_custom:IsPurgable() return false end

function modifier_antimage_mana_break_custom:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_antimage_mana_break_custom:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if params.attacker ~= parent then
        return
    end

    local target = params.target
    if not target or target:IsNull() or target:IsBuilding() or target:IsOther() then
        return
    end

    if parent:PassivesDisabled() then
        return
    end

    local ability = self:GetAbility()
    if not ability then
        return
    end

    local mana_burn_pct = ability:GetSpecialValueFor("mana_burn_pct")
    local talent = parent:FindAbilityByName("special_bonus_unique_antimage_custom_5")
    if talent and talent:GetLevel() > 0 then
        mana_burn_pct = mana_burn_pct + talent:GetSpecialValueFor("value")
    end

    local burn_from_max = target:GetMaxMana() * mana_burn_pct * 0.01
    local mana_burned = math.min(target:GetMana(), burn_from_max)
    if mana_burned <= 0 then
        return
    end

    target:Script_ReduceMana(mana_burned, ability)

    local damage_pct = ability:GetSpecialValueFor("damage_from_burn_pct")
    local bonus_damage = mana_burned * damage_pct * 0.01

    ApplyDamage({
        victim = target,
        attacker = parent,
        damage = bonus_damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
        ability = ability
    })

    local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(particle)
    target:EmitSound("Hero_Antimage.ManaBreak")
end
