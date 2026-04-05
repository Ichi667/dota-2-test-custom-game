LinkLuaModifier("modifier_item_Staff_of_Streams", "items/item_Staff_of_Streams", LUA_MODIFIER_MOTION_NONE)

item_Staff_of_Streams = class({})

function item_Staff_of_Streams:GetIntrinsicModifierName()
    return "modifier_item_Staff_of_Streams"
end

function item_Staff_of_Streams:GetAbilityTextureName()
    if self:GetToggleState() then
        return "Staff_of_Streams_on"
    end
    return "Staff_of_Streams"
end

function item_Staff_of_Streams:OnToggle()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local enabled = self:GetToggleState()
    self:PlayToggleEffects(caster, enabled)

    local modifiers = caster:FindAllModifiersByName("modifier_item_Staff_of_Streams")
    for _, mod in pairs(modifiers) do
        if mod and mod:GetAbility() == self then
            mod:ForceRefresh()
        end
    end
end

function item_Staff_of_Streams:PlayToggleEffects(caster, enabled)
    local effect_path = enabled and "particles/staff_of_streams/mana_eff_1.vpcf" or "particles/staff_of_streams/health_eff_1.vpcf"
    local particle = ParticleManager:CreateParticle(effect_path, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_item_Staff_of_Streams = class({})

function modifier_item_Staff_of_Streams:IsHidden() return true end
function modifier_item_Staff_of_Streams:IsPurgable() return false end
function modifier_item_Staff_of_Streams:RemoveOnDeath() return false end
function modifier_item_Staff_of_Streams:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_Staff_of_Streams:OnCreated()
    self.interval = 0.25
    self:UpdateValues()

    if not IsServer() then return end
    self:SetStackCount(0)
    self:StartIntervalThink(self.interval)
end

function modifier_item_Staff_of_Streams:OnRefresh()
    self:UpdateValues()
    if not IsServer() then return end
    self:StartIntervalThink(self.interval)
end

function modifier_item_Staff_of_Streams:UpdateValues()
    local ability = self:GetAbility()
    if not ability then
        self.bonus_strength = 0
        self.bonus_agility = 0
        self.bonus_intellect = 0
        self.bonus_movement_speed = 0
        self.tree_radius = 0
        self.regen_per_tree = 0
        return
    end

    self.bonus_strength = ability:GetSpecialValueFor("bonus_strength")
    self.bonus_agility = ability:GetSpecialValueFor("bonus_agility")
    self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
    self.bonus_movement_speed = ability:GetSpecialValueFor("bonus_movement_speed")
    self.tree_radius = ability:GetSpecialValueFor("tree_radius")
    self.regen_per_tree = ability:GetSpecialValueFor("regen_per_tree")
end

function modifier_item_Staff_of_Streams:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or not parent:IsAlive() then
        self:SetStackCount(0)
        return
    end

    local trees = GridNav:GetAllTreesAroundPoint(parent:GetAbsOrigin(), self.tree_radius, false)
    local tree_count = trees and #trees or 0

    if self:GetStackCount() ~= tree_count then
        self:SetStackCount(tree_count)
    end
end

function modifier_item_Staff_of_Streams:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_Staff_of_Streams:GetModifierBonusStats_Strength()
    return self.bonus_strength or 0
end

function modifier_item_Staff_of_Streams:GetModifierBonusStats_Agility()
    return self.bonus_agility or 0
end

function modifier_item_Staff_of_Streams:GetModifierBonusStats_Intellect()
    return self.bonus_intellect or 0
end

function modifier_item_Staff_of_Streams:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_movement_speed or 0
end

function modifier_item_Staff_of_Streams:GetCurrentTreeRegen()
    return (self:GetStackCount() or 0) * (self.regen_per_tree or 0)
end

function modifier_item_Staff_of_Streams:GetModifierConstantHealthRegen()
    local ability = self:GetAbility()
    if not ability or ability:GetToggleState() then return 0 end
    return self:GetCurrentTreeRegen()
end

function modifier_item_Staff_of_Streams:GetModifierConstantManaRegen()
    local ability = self:GetAbility()
    if not ability or not ability:GetToggleState() then return 0 end
    return self:GetCurrentTreeRegen()
end
