modifier_juggernaut_blade_fury_custom = class({})

function modifier_juggernaut_blade_fury_custom:IsPurgable() return false end

function modifier_juggernaut_blade_fury_custom:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
	self.move_speed_bonus = self:GetAbility():GetSpecialValueFor("move_speed_bonus")
	self.accumulator = 0
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self.fx = ParticleManager:CreateParticle("particles/hero/juggernaut_blade_fury_abyssal_golden.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_juggernaut_blade_fury_custom:OnDestroy()
	if not IsServer() then return end
	if self.fx then
		ParticleManager:DestroyParticle(self.fx, false)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
	StopSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetParent())
	EmitSoundOn("Hero_Juggernaut.BladeFuryStop", self:GetParent())
end

function modifier_juggernaut_blade_fury_custom:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local attacks_per_second = math.max(parent:GetAttacksPerSecond(false), 0.2)
	local attack_interval = 1 / attacks_per_second
	self.accumulator = self.accumulator + 0.03
	if self.accumulator < attack_interval then return end
	self.accumulator = self.accumulator - attack_interval

	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	local damage = parent:GetAverageTrueAttackDamage(nil) * self.damage_pct * 0.01
	for _, enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = parent,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = self:GetAbility(),
		})
		local hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:ReleaseParticleIndex(hit_fx)
	end
end

function modifier_juggernaut_blade_fury_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_juggernaut_blade_fury_custom:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus
end

function modifier_juggernaut_blade_fury_custom:GetEffectName()
	return "particles/status_fx/status_effect_jugg_blade_fury.vpcf"
end

function modifier_juggernaut_blade_fury_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
