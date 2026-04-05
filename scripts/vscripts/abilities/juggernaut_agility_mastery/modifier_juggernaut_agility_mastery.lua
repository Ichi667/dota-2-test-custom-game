modifier_juggernaut_agility_mastery = class({})

function modifier_juggernaut_agility_mastery:IsHidden() return true end
function modifier_juggernaut_agility_mastery:IsPurgable() return false end

function modifier_juggernaut_agility_mastery:OnCreated()
	self.bonus_per_agi = self:GetAbility():GetSpecialValueFor("bonus_per_agi")
end

function modifier_juggernaut_agility_mastery:OnRefresh()
	self.bonus_per_agi = self:GetAbility():GetSpecialValueFor("bonus_per_agi")
end

function modifier_juggernaut_agility_mastery:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_juggernaut_agility_mastery:GetModifierAttackSpeedBonus_Constant()
	return self:GetParent():GetAgility() * self.bonus_per_agi
end

function modifier_juggernaut_agility_mastery:GetModifierPreAttack_BonusDamage()
	return self:GetParent():GetAgility() * self.bonus_per_agi
end
