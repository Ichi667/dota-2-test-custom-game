axe_berserkers_call_custom = class({})

LinkLuaModifier("modifier_axe_berserkers_call_custom", "abilities/axe_berserkers_call_custom/axe_berserkers_call_custom", LUA_MODIFIER_MOTION_NONE)

axe_berserkers_call_custom.EFFECTS = {
	cast_particle = "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf",
	buff_particle = "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf",
	taunt_modifier = "modifier_axe_berserkers_call",
	cast_sound = "Hero_Axe.Berserkers_Call",
}

function axe_berserkers_call_custom:Precache(context)
	PrecacheResource("particle", self.EFFECTS.cast_particle, context)
	PrecacheResource("particle", self.EFFECTS.buff_particle, context)
end

function axe_berserkers_call_custom:OnSpellStart()
	self:PerformCall(self:GetCaster(), self:GetSpecialValueFor("duration"))
end

function axe_berserkers_call_custom:PerformCall(caster, duration)
	if not IsServer() then
		return
	end

	local radius = self:GetSpecialValueFor("radius")
	caster:EmitSound(self.EFFECTS.cast_sound)
	caster:AddNewModifier(caster, self, "modifier_axe_berserkers_call_custom", { duration = duration })

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, self.EFFECTS.taunt_modifier, { duration = duration })
	end

	local particle = ParticleManager:CreateParticle(self.EFFECTS.cast_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particle)
end

modifier_axe_berserkers_call_custom = class({})

function modifier_axe_berserkers_call_custom:IsPurgable() return false end

function modifier_axe_berserkers_call_custom:OnCreated()
	self:OnRefresh()

	if not IsServer() then
		return
	end

	local particle = ParticleManager:CreateParticle(axe_berserkers_call_custom.EFFECTS.buff_particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_axe_berserkers_call_custom:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.bonus_armor_pct = ability:GetSpecialValueFor("bonus_armor_pct")
	self.attack_speed_bonus = ability:GetSpecialValueFor("attack_speed_bonus")
end

function modifier_axe_berserkers_call_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_axe_berserkers_call_custom:GetModifierPhysicalArmorBonus()
	local parent = self:GetParent()
	return parent:GetPhysicalArmorBaseValue() * self.bonus_armor_pct * 0.01
end

function modifier_axe_berserkers_call_custom:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_bonus
end
