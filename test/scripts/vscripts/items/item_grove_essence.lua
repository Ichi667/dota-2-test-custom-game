LinkLuaModifier("modifier_item_grove_essence", "items/item_grove_essence", LUA_MODIFIER_MOTION_NONE)

item_grove_essence = class({})

function item_grove_essence:GetIntrinsicModifierName()
    return "modifier_item_grove_essence"
end

modifier_item_grove_essence = class({})

function modifier_item_grove_essence:IsHidden()
    return true
end

function modifier_item_grove_essence:IsPurgable()
    return false
end

function modifier_item_grove_essence:RemoveOnDeath()
    return false
end

function modifier_item_grove_essence:OnCreated()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    self:SetStackCount(0)
    self:StartIntervalThink(self.interval)
end

function modifier_item_grove_essence:OnRefresh()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    self:StartIntervalThink(self.interval)
end

function modifier_item_grove_essence:UpdateValues()
    local ability = self:GetAbility()

    if not ability then
        self.bonus_strenght = 0
        self.bonus_dexterity = 0
        self.bonus_intellenge = 0
        self.tree_radius = 0
        self.regen_per_tree = 0
        self.interval = 0.25
        return
    end

    self.bonus_strenght = ability:GetSpecialValueFor("bonus_strenght")
    self.bonus_dexterity = ability:GetSpecialValueFor("bonus_dexterity")
    self.bonus_intellenge = ability:GetSpecialValueFor("bonus_intellenge")
    self.tree_radius = ability:GetSpecialValueFor("tree_radius")
    self.regen_per_tree = ability:GetSpecialValueFor("regen_per_tree")
    self.interval = 0.25
end

function modifier_item_grove_essence:OnIntervalThink()
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if not parent then
        return
    end

    if not parent:IsAlive() then
        self:SetStackCount(0)
        return
    end

    local trees = GridNav:GetAllTreesAroundPoint(
        parent:GetAbsOrigin(),
        self.tree_radius,
        false
    )

    local tree_count = #trees

    self:SetStackCount(tree_count)

    if self.ForceRefresh then
        self:ForceRefresh()
    end

    parent:CalculateStatBonus(true)
end

function modifier_item_grove_essence:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_item_grove_essence:GetModifierBonusStats_Strength()
    return self.bonus_strenght or 0
end

function modifier_item_grove_essence:GetModifierBonusStats_Agility()
    return self.bonus_dexterity or 0
end

function modifier_item_grove_essence:GetModifierBonusStats_Intellect()
    return self.bonus_intellenge or 0
end

function modifier_item_grove_essence:GetModifierConstantHealthRegen()
    local regen_per_tree = self.regen_per_tree or 0
    local tree_count = self:GetStackCount()

    return tree_count * regen_per_tree
end