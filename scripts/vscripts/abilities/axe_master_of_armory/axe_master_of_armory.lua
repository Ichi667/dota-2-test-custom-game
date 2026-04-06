axe_master_of_armory = class({})

LinkLuaModifier("modifier_axe_master_of_armory", "abilities/axe_master_of_armory/axe_master_of_armory", LUA_MODIFIER_MOTION_NONE)

function axe_master_of_armory:GetIntrinsicModifierName()
	return "modifier_axe_master_of_armory"
end

modifier_axe_master_of_armory = class({})

function modifier_axe_master_of_armory:IsHidden() return true end
function modifier_axe_master_of_armory:IsPurgable() return false end

function modifier_axe_master_of_armory:OnCreated()
	self:OnRefresh()
end

function modifier_axe_master_of_armory:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.armor_per_stat = ability:GetSpecialValueFor("armor_per_stat")
end

function modifier_axe_master_of_armory:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_axe_master_of_armory:GetModifierPhysicalArmorBonus()
	local parent = self:GetParent()
	return (parent:GetStrength() + parent:GetIntellect()) * self.armor_per_stat
end
