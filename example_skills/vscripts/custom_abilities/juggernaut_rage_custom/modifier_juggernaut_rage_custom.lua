modifier_juggernaut_rage_custom = class({})

function modifier_juggernaut_rage_custom:IsPurgable() return true end

function modifier_juggernaut_rage_custom:OnCreated()
	self.armor_ignore = self:GetAbility():GetSpecialValueFor("armor_ignore_pct")
	self.agi_bonus_pct = self:GetAbility():GetSpecialValueFor("agility_bonus_pct")
end

function modifier_juggernaut_rage_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_juggernaut_rage_custom:GetModifierIgnorePhysicalArmorPercentage()
	return self.armor_ignore
end

function modifier_juggernaut_rage_custom:GetModifierBonusStats_Agility()
	return self:GetParent():GetBaseAgility() * self.agi_bonus_pct * 0.01
end

function modifier_juggernaut_rage_custom:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function modifier_juggernaut_rage_custom:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_juggernaut_rage_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
