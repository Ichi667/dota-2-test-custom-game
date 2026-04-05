LinkLuaModifier("modifier_item_woodsplitter_axe_3", "items/item_woodsplitter_axe_3", LUA_MODIFIER_MOTION_NONE)

item_woodsplitter_axe_3 = class({})

function item_woodsplitter_axe_3:GetIntrinsicModifierName()
    return "modifier_item_woodsplitter_axe_3"
end

function item_woodsplitter_axe_3:OnSpellStart()
    local caster = self:GetCaster()
    local target_pos = self:GetCursorPosition()

    GridNav:DestroyTreesAroundPoint(target_pos, 10, false)
    EmitSoundOnLocationWithCaster(target_pos, "Item.Tango.Activate", caster)
end

modifier_item_woodsplitter_axe_3 = class({})
local CLEAVE_MODIFIER_PRIORITY = {
    "modifier_item_devastation_axe",
    "modifier_item_woodsplitter_axe_3",
    "modifier_item_woodsplitter_axe_2",
    "modifier_item_woodsplitter_axe",
}

function modifier_item_woodsplitter_axe_3:IsHidden()
    return true
end

function modifier_item_woodsplitter_axe_3:IsPurgable()
    return false
end

function modifier_item_woodsplitter_axe_3:RemoveOnDeath()
    return false
end

function modifier_item_woodsplitter_axe_3:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_woodsplitter_axe_3:IsPrimaryCleaveSource()
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

function modifier_item_woodsplitter_axe_3:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_item_woodsplitter_axe_3:GetModifierPreAttack_BonusDamage()
    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not ability or not parent then
        return 0
    end

    if parent:IsRangedAttacker() then
        return ability:GetSpecialValueFor("bonus_damage_ranged")
    end

    return ability:GetSpecialValueFor("bonus_damage_melee")
end

function modifier_item_woodsplitter_axe_3:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not ability or params.attacker ~= parent then
        return
    end

    if parent:IsRangedAttacker() then
        return
    end

    if parent:IsIllusion() then
        return
    end

    if not params.target or params.target:IsNull() then
        return
    end

    if params.target:IsBuilding() or params.target:IsOther() then
        return
    end

    if not self:IsPrimaryCleaveSource() then
        return
    end

    local cleave_damage_pct = ability:GetSpecialValueFor("cleave_damage_pct")
    local cleave_starting_width = ability:GetSpecialValueFor("cleave_starting_width")
    local cleave_ending_width = ability:GetSpecialValueFor("cleave_ending_width")
    local cleave_distance = ability:GetSpecialValueFor("cleave_distance")

    DoCleaveAttack(
        parent,
        params.target,
        ability,
        params.original_damage * cleave_damage_pct * 0.01,
        cleave_starting_width,
        cleave_ending_width,
        cleave_distance,
        "particles/items_fx/battlefury_cleave.vpcf"
    )
end
