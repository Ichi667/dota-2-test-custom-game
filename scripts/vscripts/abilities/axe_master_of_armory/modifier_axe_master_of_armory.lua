modifier_axe_master_of_armory = class({})

function modifier_axe_master_of_armory:IsHidden() return true end
function modifier_axe_master_of_armory:IsPurgable() return false end

function modifier_axe_master_of_armory:OnCreated()
    self:UpdateValues()

    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_axe_master_of_armory:OnRefresh()
    self:UpdateValues()
end

function modifier_axe_master_of_armory:OnIntervalThink()
    self:UpdateValues()
end

function modifier_axe_master_of_armory:UpdateValues()
    local ability = self:GetAbility()
    local parent = self:GetParent()

    self.armor_per_stat = ability and ability:GetSpecialValueFor("armor_per_stat") or 0
    self.cached_armor = 0

    if not parent then
        return
    end

    self.cached_armor = (parent:GetStrength() + parent:GetIntellect(false)) * self.armor_per_stat
end

function modifier_axe_master_of_armory:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_axe_master_of_armory:GetModifierPhysicalArmorBonus()
    local parent = self:GetParent()
    if not parent then return 0 end

    return (parent:GetStrength() + parent:GetIntellect(false)) * self.armor_per_stat
end