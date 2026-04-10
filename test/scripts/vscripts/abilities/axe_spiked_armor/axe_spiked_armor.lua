axe_spiked_armor = class({})

LinkLuaModifier("modifier_axe_spiked_armor", "abilities/axe_spiked_armor/axe_spiked_armor", LUA_MODIFIER_MOTION_NONE)

axe_spiked_armor.EFFECTS = {
	retaliate_particle = "particles/axe_spiked_armor/centaur_crownfall_belt_retaliate.vpcf",
	retaliate_sound = "Hero_Centaur.Return",
}

function axe_spiked_armor:GetIntrinsicModifierName()
	return "modifier_axe_spiked_armor"
end

modifier_axe_spiked_armor = class({})

function modifier_axe_spiked_armor:IsHidden() return true end
function modifier_axe_spiked_armor:IsPurgable() return false end

function modifier_axe_spiked_armor:OnCreated()
	self.reflect_pct_per_armor = 0
	self:OnRefresh()
end

function modifier_axe_spiked_armor:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.reflect_pct_per_armor = ability:GetSpecialValueFor("reflect_pct_per_armor")
end

function modifier_axe_spiked_armor:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_axe_spiked_armor:OnAttackLanded(params)
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	if params.target ~= parent then
		return
	end

	if parent:PassivesDisabled() or parent:IsIllusion() then
		return
	end

	local attacker = params.attacker
	if not attacker or attacker:IsNull() or attacker:GetTeamNumber() == parent:GetTeamNumber() then
		return
	end

	local ability = self:GetAbility()
	if not ability then
		return
	end

	local armor = parent:GetPhysicalArmorValue(false)
	local reflect_damage = math.max(0, armor * (self.reflect_pct_per_armor or 0) * 0.01)

	if reflect_damage <= 0 then
		return
	end

	ApplyDamage({
		victim = attacker,
		attacker = parent,
		damage = reflect_damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = ability,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
	})

	local particle = ParticleManager:CreateParticle(axe_spiked_armor.EFFECTS.retaliate_particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:ReleaseParticleIndex(particle)
	attacker:EmitSound(axe_spiked_armor.EFFECTS.retaliate_sound)
end
