LinkLuaModifier("modifier_forest_troll_high_priest_heal_custom_ai", "abilities/creeps/neutral_forest_frog_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_forest_troll_berserker_frenzy_custom", "abilities/creeps/neutral_forest_frog_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_forest_troll_berserker_frenzy_custom_buff", "abilities/creeps/neutral_forest_frog_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tadpole_mana_burn_aura_custom", "abilities/creeps/neutral_forest_frog_custom", LUA_MODIFIER_MOTION_NONE)

forest_troll_high_priest_heal_custom = class({})

function forest_troll_high_priest_heal_custom:GetIntrinsicModifierName()
	return "modifier_forest_troll_high_priest_heal_custom_ai"
end

function forest_troll_high_priest_heal_custom:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local heal = self:GetSpecialValueFor("heal")

	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,ally in pairs(allies) do
		ally:Heal(heal, self)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal, nil)
	end
end

modifier_forest_troll_high_priest_heal_custom_ai = class({})
function modifier_forest_troll_high_priest_heal_custom_ai:IsHidden() return true end
function modifier_forest_troll_high_priest_heal_custom_ai:IsPurgable() return false end

function modifier_forest_troll_high_priest_heal_custom_ai:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.3)
end

function modifier_forest_troll_high_priest_heal_custom_ai:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if not ability or not ability:IsFullyCastable() then return end
	if parent:IsSilenced() or parent:IsStunned() or parent:IsHexed() then return end

	local radius = ability:GetSpecialValueFor("radius")
	local threshold_pct = ability:GetSpecialValueFor("health_threshold_pct")

	local allies = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,ally in pairs(allies) do
		if ally:GetHealthPercent() < threshold_pct then
			parent:CastAbilityNoTarget(ability, -1)
			return
		end
	end
end


forest_troll_berserker_frenzy_custom = class({})
function forest_troll_berserker_frenzy_custom:GetIntrinsicModifierName() return "modifier_forest_troll_berserker_frenzy_custom" end

modifier_forest_troll_berserker_frenzy_custom = class({})
function modifier_forest_troll_berserker_frenzy_custom:IsHidden() return true end
function modifier_forest_troll_berserker_frenzy_custom:IsPurgable() return false end

function modifier_forest_troll_berserker_frenzy_custom:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_forest_troll_berserker_frenzy_custom:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local mod = self:GetParent():FindModifierByName("modifier_forest_troll_berserker_frenzy_custom_buff")
	if not mod then
		mod = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_forest_troll_berserker_frenzy_custom_buff", {duration = duration})
	end

	if mod then
		mod:IncrementStackCount()
		mod:SetDuration(duration, true)
	end
end

modifier_forest_troll_berserker_frenzy_custom_buff = class({})
function modifier_forest_troll_berserker_frenzy_custom_buff:IsPurgable() return true end
function modifier_forest_troll_berserker_frenzy_custom_buff:IsHidden() return false end

function modifier_forest_troll_berserker_frenzy_custom_buff:OnCreated()
	self.attack_speed_per_hit = self:GetAbility():GetSpecialValueFor("attack_speed_per_hit")
	if not IsServer() then return end
	self:SetStackCount(0)
end

function modifier_forest_troll_berserker_frenzy_custom_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_forest_troll_berserker_frenzy_custom_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * self.attack_speed_per_hit
end


tadpole_mana_burn_aura_custom = class({})
function tadpole_mana_burn_aura_custom:GetIntrinsicModifierName() return "modifier_tadpole_mana_burn_aura_custom" end

modifier_tadpole_mana_burn_aura_custom = class({})
function modifier_tadpole_mana_burn_aura_custom:IsHidden() return true end
function modifier_tadpole_mana_burn_aura_custom:IsPurgable() return false end

function modifier_tadpole_mana_burn_aura_custom:OnCreated()
	if not IsServer() then return end
	self:OnRefresh()
	self:StartIntervalThink(1.0)
end

function modifier_tadpole_mana_burn_aura_custom:OnRefresh()
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then
		self.radius = 0
		self.mana_burn = 0
		return
	end

	self.radius = ability:GetSpecialValueFor("radius") or 0
	self.mana_burn = ability:GetSpecialValueFor("mana_burn_per_second") or 0
end

function modifier_tadpole_mana_burn_aura_custom:OnIntervalThink()
	if not IsServer() then return end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not parent or parent:IsNull() or not parent:IsAlive() then return end
	if not ability or ability:IsNull() then return end
	if self.radius <= 0 or self.mana_burn <= 0 then return end

	local total_burned = 0
	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetAbsOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MANA_ONLY,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		if enemy and not enemy:IsNull() and enemy:IsAlive() then
			local current_mana = enemy:GetMana()
			if current_mana > 0 then
				local burn = math.min(self.mana_burn, current_mana)
				enemy:SetMana(current_mana - burn)
				total_burned = total_burned + burn
			end
		end
	end

	if total_burned > 0 then
		parent:Heal(total_burned, ability)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, total_burned, nil)
	end
end