axe_berserk_helix_custom = class({})

LinkLuaModifier("modifier_axe_berserk_helix_custom", "abilities/axe_berserk_helix_custom/axe_berserk_helix_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_berserk_helix_custom_active", "abilities/axe_berserk_helix_custom/axe_berserk_helix_custom", LUA_MODIFIER_MOTION_NONE)

axe_berserk_helix_custom.EFFECTS = {
	spin_particle = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf",
	spin_sound = "Hero_Axe.CounterHelix",
}

function axe_berserk_helix_custom:GetIntrinsicModifierName()
	return "modifier_axe_berserk_helix_custom"
end

function axe_berserk_helix_custom:CastFilterResult()
	if not IsServer() then
		return UF_SUCCESS
	end

	local passive = self:GetCaster():FindModifierByName("modifier_axe_berserk_helix_custom")
	if passive and passive:GetStackCount() > 0 then
		return UF_SUCCESS
	end

	return UF_FAIL_CUSTOM
end

function axe_berserk_helix_custom:GetCustomCastError()
	return "#dota_hud_error_no_charges"
end

function axe_berserk_helix_custom:OnSpellStart()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local passive = caster:FindModifierByName("modifier_axe_berserk_helix_custom")
	if not passive or passive:GetStackCount() <= 0 then
		return
	end

	local spins = passive:GetStackCount()
	passive:SetStackCount(0)
	caster:AddNewModifier(caster, self, "modifier_axe_berserk_helix_custom_active", { spins = spins })
end

function axe_berserk_helix_custom:PerformSingleSpin(caster)
	if not IsServer() then
		return
	end

	local radius = self:GetSpecialValueFor("spin_radius")
	local attack_damage_pct = self:GetSpecialValueFor("spin_attack_damage_pct")
	local damage = caster:GetAverageTrueAttackDamage(caster) * attack_damage_pct * 0.01

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})
	end

	caster:EmitSound(self.EFFECTS.spin_sound)
	local particle = ParticleManager:CreateParticle(self.EFFECTS.spin_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particle)
end

modifier_axe_berserk_helix_custom = class({})

function modifier_axe_berserk_helix_custom:IsHidden() return false end
function modifier_axe_berserk_helix_custom:IsPurgable() return false end

function modifier_axe_berserk_helix_custom:OnCreated()
	self.damage_pool = 0
	self:OnRefresh()
	if IsServer() then
		self:SetStackCount(0)
	end
end

function modifier_axe_berserk_helix_custom:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.damage_for_charge = ability:GetSpecialValueFor("damage_for_charge")
	self.max_charges = ability:GetSpecialValueFor("max_charges")
	self.shard_spin_chance = ability:GetSpecialValueFor("shard_spin_chance")
end

function modifier_axe_berserk_helix_custom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_axe_berserk_helix_custom:OnTakeDamage(params)
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	if params.unit ~= parent then
		return
	end

	if parent:IsIllusion() or parent:PassivesDisabled() then
		return
	end

	if params.damage <= 0 then
		return
	end

	local ability = self:GetAbility()
	if not ability then
		return
	end

	if not ability:IsCooldownReady() and not parent:HasScepter() then
		return
	end

	self.damage_pool = self.damage_pool + params.damage
	while self.damage_pool >= self.damage_for_charge and self:GetStackCount() < self.max_charges do
		self.damage_pool = self.damage_pool - self.damage_for_charge
		self:IncrementStackCount()
	end
end

function modifier_axe_berserk_helix_custom:OnAttackLanded(params)
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	if params.attacker ~= parent then
		return
	end

	if not parent:HasShard() or parent:PassivesDisabled() or parent:IsIllusion() then
		return
	end

	if not RollPercentage(self.shard_spin_chance) then
		return
	end

	local ability = self:GetAbility()
	if not ability then
		return
	end

	ability:PerformSingleSpin(parent)
end

modifier_axe_berserk_helix_custom_active = class({})

function modifier_axe_berserk_helix_custom_active:IsPurgable() return false end

function modifier_axe_berserk_helix_custom_active:OnCreated(params)
	if not IsServer() then
		return
	end

	self.remaining_spins = params.spins or 0
	self:OnRefresh()
	self:StartIntervalThink(self.spin_interval)
	self:OnIntervalThink()
end

function modifier_axe_berserk_helix_custom_active:OnRefresh()
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.spin_interval = math.max(0.03, ability:GetSpecialValueFor("spin_interval"))
end

function modifier_axe_berserk_helix_custom_active:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	if not ability or self.remaining_spins <= 0 then
		self:Destroy()
		return
	end

	ability:PerformSingleSpin(parent)
	self.remaining_spins = self.remaining_spins - 1

	if self.remaining_spins <= 0 then
		self:Destroy()
	end
end
