modifier_juggernaut_rage_custom = class({})

function modifier_juggernaut_rage_custom:IsHidden()
	return false
end

function modifier_juggernaut_rage_custom:IsDebuff()
	return false
end

function modifier_juggernaut_rage_custom:IsPurgable()
	return false
end

function modifier_juggernaut_rage_custom:OnCreated()
	self.flat_armor_ignore = self:GetAbility():GetSpecialValueFor("flat_armor_ignore")
	self.agi_bonus_pct = self:GetAbility():GetSpecialValueFor("agility_bonus_pct")
	self.shard_magic_resist = self:GetAbility():GetSpecialValueFor("shard_magic_resist")
	if self.shard_magic_resist == nil or self.shard_magic_resist == 0 then
		self.shard_magic_resist = 80
	end

	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_juggernaut_rage_custom:OnRefresh()
	self.flat_armor_ignore = self:GetAbility():GetSpecialValueFor("flat_armor_ignore")
	self.agi_bonus_pct = self:GetAbility():GetSpecialValueFor("agility_bonus_pct")
	self.shard_magic_resist = self:GetAbility():GetSpecialValueFor("shard_magic_resist")
	if self.shard_magic_resist == nil or self.shard_magic_resist == 0 then
		self.shard_magic_resist = 80
	end
end

function modifier_juggernaut_rage_custom:HasShardUpgrade()
	local parent = self:GetParent()
	if not parent then return false end

	if parent.HasShard and parent:HasShard() then
		return true
	end

	return parent:HasModifier("modifier_item_aghanims_shard")
end

function modifier_juggernaut_rage_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_juggernaut_rage_custom:GetModifierProcAttack_BonusDamage_Physical(params)
	if not IsServer() then return 0 end
	if params.attacker ~= self:GetParent() then return 0 end
	if not params.target or params.target:IsBuilding() or params.target:IsOther() then return 0 end

	local base_damage = params.original_damage or params.damage or self:GetParent():GetAverageTrueAttackDamage(params.target)
	if base_damage <= 0 then return 0 end

	local armor = params.target:GetPhysicalArmorValue(false)
	local reduced_armor = armor - self.flat_armor_ignore

	local function physical_multiplier(value)
		return 1 - ((0.06 * value) / (1 + 0.06 * math.abs(value)))
	end

	local current_mult = physical_multiplier(armor)
	local ignored_mult = physical_multiplier(reduced_armor)
	local bonus_damage = base_damage * (ignored_mult - current_mult)

	return math.max(0, bonus_damage)
end

function modifier_juggernaut_rage_custom:GetModifierBonusStats_Agility()
	return self:GetParent():GetBaseAgility() * self.agi_bonus_pct * 0.01
end

function modifier_juggernaut_rage_custom:GetModifierMagicalResistanceBonus()
	if self:HasShardUpgrade() then
		return self.shard_magic_resist
	end
	return 0
end

function modifier_juggernaut_rage_custom:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	if MODIFIER_STATE_MUTED ~= nil then
		state[MODIFIER_STATE_MUTED] = true
	end

	if self:HasShardUpgrade() then
		if MODIFIER_STATE_DEBUFF_IMMUNE ~= nil then
			state[MODIFIER_STATE_DEBUFF_IMMUNE] = true
		elseif MODIFIER_STATE_MAGIC_IMMUNE ~= nil then
			state[MODIFIER_STATE_MAGIC_IMMUNE] = true
		end
	end

	return state
end

function modifier_juggernaut_rage_custom:PlayEffects()
	local particle_cast = "particles/juggernaut_rage/life_stealer_rage.vpcf"
	local parent = self:GetParent()

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, parent, PATTACH_POINT_FOLLOW, "attach_attack2", parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 2, parent, PATTACH_CENTER_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)

	self:AddParticle(effect_cast, false, false, -1, false, false)
end
