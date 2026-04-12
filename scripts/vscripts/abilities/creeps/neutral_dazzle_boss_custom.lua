local PARTICLE_POISON_PROJECTILE = "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf"
local PARTICLE_POISON_DEBUFF = "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
local PARTICLE_GRAVE_BUFF = "particles/units/heroes/hero_dazzle/dazzle_shadow_grave.vpcf"
local PARTICLE_WEAVE = "particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf"
local PARTICLE_WEAVE_DEBUFF = "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"

local SOUND_POISON_CAST = "Hero_Dazzle.Poison_Cast"
local SOUND_POISON_TARGET = "Hero_Dazzle.Poison_Tick"
local SOUND_GRAVE_CAST = "Hero_Dazzle.Shallow_Grave"
local SOUND_WEAVE_CAST = "Hero_Dazzle.Weave"

LinkLuaModifier("modifier_neutral_dazzle_boss_ai_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_dazzle_boss_poison_debuff_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_dazzle_boss_grave_buff_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_dazzle_boss_weave_debuff_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_dazzle_boss_cheat_death_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_dazzle_boss_cheat_death_buff_custom", "abilities/creeps/neutral_dazzle_boss_custom", LUA_MODIFIER_MOTION_NONE)

neutral_dazzle_boss_ai_controller_custom = class({})

function neutral_dazzle_boss_ai_controller_custom:GetIntrinsicModifierName()
	return "modifier_neutral_dazzle_boss_ai_custom"
end

modifier_neutral_dazzle_boss_ai_custom = class({})

function modifier_neutral_dazzle_boss_ai_custom:IsHidden() return true end
function modifier_neutral_dazzle_boss_ai_custom:IsPurgable() return false end

function modifier_neutral_dazzle_boss_ai_custom:OnCreated()
	if not IsServer() then return end
	self.next_grave_scan = 0
	self:StartIntervalThink(0.25)
end

function modifier_neutral_dazzle_boss_ai_custom:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent:IsAlive() then return end
	if parent:IsStunned() or parent:IsHexed() or parent:IsSilenced() then return end

	local poison = parent:FindAbilityByName("neutral_dazzle_boss_poison_touch_custom")
	if poison and poison:IsFullyCastable() then
		parent:CastAbilityNoTarget(poison, -1)
		return
	end

	local now = GameRules:GetGameTime()
	if now >= self.next_grave_scan then
		self.next_grave_scan = now + 1.0
		local grave = parent:FindAbilityByName("neutral_dazzle_boss_shadow_grave_custom")
		if grave and grave:IsFullyCastable() then
			local radius = grave:GetSpecialValueFor("radius")
			local threshold = grave:GetSpecialValueFor("health_threshold_pct")
			local allies = FindUnitsInRadius(
				parent:GetTeamNumber(),
				parent:GetAbsOrigin(),
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_CLOSEST,
				false
			)

			for _, ally in pairs(allies) do
				if ally ~= parent and ally:IsAlive() and ally:GetHealthPercent() < threshold and not ally:HasModifier("modifier_neutral_dazzle_boss_grave_buff_custom") then
					parent:CastAbilityOnTarget(ally, grave, -1)
					return
				end
			end
		end
	end

	local weave = parent:FindAbilityByName("neutral_dazzle_boss_weave_burst_custom")
	if weave and weave:IsFullyCastable() then
		local hp_threshold = weave:GetSpecialValueFor("self_health_threshold_pct")
		if parent:GetHealthPercent() < hp_threshold then
			parent:CastAbilityNoTarget(weave, -1)
			return
		end
	end
end

neutral_dazzle_boss_poison_touch_custom = class({})

function neutral_dazzle_boss_poison_touch_custom:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound(SOUND_POISON_CAST)

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local projectile = {
			Target = enemy,
			Source = caster,
			Ability = self,
			EffectName = PARTICLE_POISON_PROJECTILE,
			iMoveSpeed = 1200,
			bDodgeable = true,
			bProvidesVision = false,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
	end

	self.projectile_duration = duration
end

function neutral_dazzle_boss_poison_touch_custom:OnProjectileHit(target, location)
	if not target then return true end
	if target:IsMagicImmune() then return true end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("impact_damage")
	local duration = self.projectile_duration or self:GetSpecialValueFor("duration")

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self,
	})

	target:AddNewModifier(caster, self, "modifier_neutral_dazzle_boss_poison_debuff_custom", { duration = duration * (1 - target:GetStatusResistance()) })
	target:EmitSound(SOUND_POISON_TARGET)
	return true
end

modifier_neutral_dazzle_boss_poison_debuff_custom = class({})

function modifier_neutral_dazzle_boss_poison_debuff_custom:IsDebuff() return true end
function modifier_neutral_dazzle_boss_poison_debuff_custom:IsPurgable() return true end

function modifier_neutral_dazzle_boss_poison_debuff_custom:OnCreated()
	self.max_slow_pct = self:GetAbility():GetSpecialValueFor("max_slow_pct")
	self.duration = self:GetRemainingTime()
end

function modifier_neutral_dazzle_boss_poison_debuff_custom:OnRefresh()
	self.max_slow_pct = self:GetAbility():GetSpecialValueFor("max_slow_pct")
	self.duration = self:GetRemainingTime()
end

function modifier_neutral_dazzle_boss_poison_debuff_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_neutral_dazzle_boss_poison_debuff_custom:GetModifierMoveSpeedBonus_Percentage()
	local duration = math.max(self.duration, 0.01)
	local elapsed = duration - self:GetRemainingTime()
	local factor = math.max(0, 1 - (elapsed / duration))
	return -self.max_slow_pct * factor
end

function modifier_neutral_dazzle_boss_poison_debuff_custom:GetEffectName()
	return PARTICLE_POISON_DEBUFF
end

function modifier_neutral_dazzle_boss_poison_debuff_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

neutral_dazzle_boss_shadow_grave_custom = class({})

function neutral_dazzle_boss_shadow_grave_custom:CastFilterResultTarget(target)
	if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return UF_FAIL_ENEMY
	end

	return UF_SUCCESS
end

function neutral_dazzle_boss_shadow_grave_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not target then return end

	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_neutral_dazzle_boss_grave_buff_custom", { duration = duration })
	target:EmitSound(SOUND_GRAVE_CAST)
end

modifier_neutral_dazzle_boss_grave_buff_custom = class({})

function modifier_neutral_dazzle_boss_grave_buff_custom:IsPurgable() return false end
function modifier_neutral_dazzle_boss_grave_buff_custom:GetEffectName() return PARTICLE_GRAVE_BUFF end
function modifier_neutral_dazzle_boss_grave_buff_custom:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_neutral_dazzle_boss_grave_buff_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_neutral_dazzle_boss_grave_buff_custom:GetMinHealth()
	return 1
end

neutral_dazzle_boss_weave_burst_custom = class({})

function neutral_dazzle_boss_weave_burst_custom:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound(SOUND_WEAVE_CAST)

	local pfx = ParticleManager:CreateParticle(PARTICLE_WEAVE, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(pfx)

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
		enemy:AddNewModifier(caster, self, "modifier_neutral_dazzle_boss_weave_debuff_custom", { duration = duration * (1 - enemy:GetStatusResistance()) })
	end
end

modifier_neutral_dazzle_boss_weave_debuff_custom = class({})

function modifier_neutral_dazzle_boss_weave_debuff_custom:IsDebuff() return true end
function modifier_neutral_dazzle_boss_weave_debuff_custom:IsPurgable() return true end

function modifier_neutral_dazzle_boss_weave_debuff_custom:OnCreated()
	self.damage_pct = self:GetAbility():GetSpecialValueFor("max_health_damage_pct")
	if not IsServer() then return end
	self:StartIntervalThink(1.0)
end

function modifier_neutral_dazzle_boss_weave_debuff_custom:OnRefresh()
	self.damage_pct = self:GetAbility():GetSpecialValueFor("max_health_damage_pct")
end

function modifier_neutral_dazzle_boss_weave_debuff_custom:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local damage = parent:GetMaxHealth() * self.damage_pct * 0.01

	ApplyDamage({
		victim = parent,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self:GetAbility(),
	})
end

function modifier_neutral_dazzle_boss_weave_debuff_custom:GetEffectName()
	return PARTICLE_WEAVE_DEBUFF
end

function modifier_neutral_dazzle_boss_weave_debuff_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

neutral_dazzle_boss_cheat_death_custom = class({})

function neutral_dazzle_boss_cheat_death_custom:GetIntrinsicModifierName()
	return "modifier_neutral_dazzle_boss_cheat_death_custom"
end

modifier_neutral_dazzle_boss_cheat_death_custom = class({})

function modifier_neutral_dazzle_boss_cheat_death_custom:IsHidden() return true end
function modifier_neutral_dazzle_boss_cheat_death_custom:IsPurgable() return false end

function modifier_neutral_dazzle_boss_cheat_death_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_neutral_dazzle_boss_cheat_death_custom:GetMinHealth()
	local ability = self:GetAbility()
	if ability and ability:IsCooldownReady() and not self:GetParent():HasModifier("modifier_neutral_dazzle_boss_cheat_death_buff_custom") then
		return 1
	end
	return 0
end

function modifier_neutral_dazzle_boss_cheat_death_custom:OnTakeDamage(params)
	if not IsServer() then return end
	local parent = self:GetParent()
	if params.unit ~= parent then return end
	if parent:IsIllusion() then return end

	local ability = self:GetAbility()
	if not ability or ability:IsNull() or not ability:IsCooldownReady() then return end
	if parent:HasModifier("modifier_neutral_dazzle_boss_cheat_death_buff_custom") then return end
	if parent:GetHealth() > 1 then return end

	local duration = ability:GetSpecialValueFor("duration")
	parent:AddNewModifier(parent, ability, "modifier_neutral_dazzle_boss_cheat_death_buff_custom", { duration = duration })
	ability:UseResources(false, false, false, true)
end

modifier_neutral_dazzle_boss_cheat_death_buff_custom = class({})

function modifier_neutral_dazzle_boss_cheat_death_buff_custom:IsPurgable() return false end
function modifier_neutral_dazzle_boss_cheat_death_buff_custom:GetEffectName() return PARTICLE_GRAVE_BUFF end
function modifier_neutral_dazzle_boss_cheat_death_buff_custom:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_neutral_dazzle_boss_cheat_death_buff_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_neutral_dazzle_boss_cheat_death_buff_custom:GetMinHealth()
	return 1
end
