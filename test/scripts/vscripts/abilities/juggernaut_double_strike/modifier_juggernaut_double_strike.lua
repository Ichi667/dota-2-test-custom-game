modifier_juggernaut_double_strike = class({})

function modifier_juggernaut_double_strike:IsHidden() return true end
function modifier_juggernaut_double_strike:IsPurgable() return false end

function modifier_juggernaut_double_strike:OnCreated()
	self.chance = self:GetAbility():GetSpecialValueFor("double_strike_chance")
	self.pseudo = 4101
	self.performing_second_hit = false
end

function modifier_juggernaut_double_strike:OnRefresh()
	self.chance = self:GetAbility():GetSpecialValueFor("double_strike_chance")
end

function modifier_juggernaut_double_strike:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_juggernaut_double_strike:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if self.performing_second_hit then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	if self:GetAbility():GetLevel() <= 0 then return end

	if not RollPseudoRandomPercentage(self.chance, self.pseudo, self:GetParent()) then return end

	self.performing_second_hit = true
	self:GetParent():PerformAttack(
		params.target,
		true,
		true,
		true,
		false,
		false,
		false,
		true
	)
	self.performing_second_hit = false

	local particle = ParticleManager:CreateParticle("particles/juggernaut_doublestrike/juggernaut_ti8_sword_crit_b_golden.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
	ParticleManager:ReleaseParticleIndex(particle)
	EmitSoundOn("Hero_Juggernaut.BladeDance", params.target)
end
