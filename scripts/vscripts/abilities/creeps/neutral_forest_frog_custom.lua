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
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.mana_burn = self:GetAbility():GetSpecialValueFor("mana_burn_per_second")
	self:StartIntervalThink(1.0)
end

function modifier_tadpole_mana_burn_aura_custom:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local total_burned = 0
	local enemies = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_ANY_ORDER, false)

	for _,enemy in pairs(enemies) do
		local current_mana = enemy:GetMana()
		if current_mana > 0 then
			local burn = math.min(self.mana_burn, current_mana)
			enemy:ReduceMana(burn)
			total_burned = total_burned + burn
		end
	end

	if total_burned > 0 then
		parent:Heal(total_burned, self:GetAbility())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, total_burned, nil)
	end
end


frogmen_arm_of_the_deep = class({})

function frogmen_arm_of_the_deep:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local range = self:GetSpecialValueFor("range")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")

	local direction = point - caster:GetAbsOrigin()
	direction.z = 0
	if direction:Length2D() > range then
		direction = direction:Normalized() * range
		point = caster:GetAbsOrigin() + direction
	end

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, self:GetSpecialValueFor("projectile_width"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
		})
		enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = duration * (1 - enemy:GetStatusResistance())})
	end

	caster:EmitSound("Ability.Ravage")
end
