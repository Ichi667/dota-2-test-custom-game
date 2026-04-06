axe_guts_blood = class({})

LinkLuaModifier("modifier_axe_guts_blood", "abilities/axe_guts_blood/axe_guts_blood", LUA_MODIFIER_MOTION_NONE)

axe_guts_blood.EFFECTS = {
	cast_particle = "particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf",
	cast_sound = "Hero_Axe.Culling_Blade_Buff",
}

function axe_guts_blood:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:SetHealth(1)
	caster:AddNewModifier(caster, self, "modifier_axe_guts_blood", { duration = duration })

	local call_ability = caster:FindAbilityByName("axe_berserkers_call_custom")
	if call_ability and call_ability:GetLevel() > 0 then
		call_ability:PerformCall(caster, call_ability:GetSpecialValueFor("duration"))
	end

	caster:EmitSound(self.EFFECTS.cast_sound)
	local particle = ParticleManager:CreateParticle(self.EFFECTS.cast_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particle)
end

modifier_axe_guts_blood = class({})

function modifier_axe_guts_blood:IsPurgable() return false end

function modifier_axe_guts_blood:OnCreated()
	self:OnRefresh()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(self.spin_interval)
end

function modifier_axe_guts_blood:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.spin_interval = math.max(0.03, ability:GetSpecialValueFor("spin_interval"))
	self.model_scale_bonus = ability:GetSpecialValueFor("model_scale_bonus")
end

function modifier_axe_guts_blood:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local helix_ability = parent:FindAbilityByName("axe_berserk_helix_custom")
	if helix_ability and helix_ability:GetLevel() > 0 then
		helix_ability:PerformSingleSpin(parent)
	end
end

function modifier_axe_guts_blood:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}
end

function modifier_axe_guts_blood:GetMinHealth()
	return 1
end

function modifier_axe_guts_blood:GetModifierModelScale()
	return self.model_scale_bonus
end

function modifier_axe_guts_blood:GetDisableHealing()
	return 1
end
