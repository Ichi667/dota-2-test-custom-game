LinkLuaModifier("modifier_kobold_tunneler_disarm_custom", "abilities/creeps/kobold_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kobold_tunneler_disarm_custom_debuff", "abilities/creeps/kobold_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kobold_taskmaster_command_aura_custom", "abilities/creeps/kobold_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kobold_taskmaster_command_aura_custom_effect", "abilities/creeps/kobold_custom", LUA_MODIFIER_MOTION_NONE)

kobold_tunneler_disarm_custom = class({})

function kobold_tunneler_disarm_custom:GetIntrinsicModifierName()
	return "modifier_kobold_tunneler_disarm_custom"
end


modifier_kobold_tunneler_disarm_custom = class({})

function modifier_kobold_tunneler_disarm_custom:IsHidden() return true end
function modifier_kobold_tunneler_disarm_custom:IsPurgable() return false end

function modifier_kobold_tunneler_disarm_custom:OnCreated()
	self.attacks_to_proc = self:GetAbility():GetSpecialValueFor("attacks_to_proc")
	self.disarm_duration = self:GetAbility():GetSpecialValueFor("disarm_duration")
	self.attack_count = 0
end

function modifier_kobold_tunneler_disarm_custom:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_kobold_tunneler_disarm_custom:OnAttackLanded(params)
	if not IsServer() then return end
	if self:GetParent() ~= params.attacker then return end
	if not params.target or params.target:IsNull() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	if params.attacker:PassivesDisabled() then return end

	self.attack_count = self.attack_count + 1
	if self.attack_count < self.attacks_to_proc then return end

	self.attack_count = 0
	params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kobold_tunneler_disarm_custom_debuff", {duration = self.disarm_duration * (1 - params.target:GetStatusResistance())})
end


modifier_kobold_tunneler_disarm_custom_debuff = class({})

function modifier_kobold_tunneler_disarm_custom_debuff:IsDebuff() return true end
function modifier_kobold_tunneler_disarm_custom_debuff:IsPurgable() return true end

function modifier_kobold_tunneler_disarm_custom_debuff:CheckState()
	return
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_kobold_tunneler_disarm_custom_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_kobold_tunneler_disarm_custom_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


kobold_taskmaster_command_aura_custom = class({})

function kobold_taskmaster_command_aura_custom:GetIntrinsicModifierName()
	return "modifier_kobold_taskmaster_command_aura_custom"
end


modifier_kobold_taskmaster_command_aura_custom = class({})

function modifier_kobold_taskmaster_command_aura_custom:IsHidden() return true end
function modifier_kobold_taskmaster_command_aura_custom:IsPurgable() return false end
function modifier_kobold_taskmaster_command_aura_custom:IsAura() return true end
function modifier_kobold_taskmaster_command_aura_custom:GetAuraDuration() return 0.2 end
function modifier_kobold_taskmaster_command_aura_custom:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_kobold_taskmaster_command_aura_custom:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kobold_taskmaster_command_aura_custom:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_kobold_taskmaster_command_aura_custom:GetModifierAura() return "modifier_kobold_taskmaster_command_aura_custom_effect" end


modifier_kobold_taskmaster_command_aura_custom_effect = class({})

function modifier_kobold_taskmaster_command_aura_custom_effect:IsHidden() return false end
function modifier_kobold_taskmaster_command_aura_custom_effect:IsPurgable() return false end

function modifier_kobold_taskmaster_command_aura_custom_effect:OnCreated()
	self.bonus_evasion = self:GetAbility():GetSpecialValueFor("bonus_evasion")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_kobold_taskmaster_command_aura_custom_effect:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_kobold_taskmaster_command_aura_custom_effect:GetModifierEvasion_Constant()
	return self.bonus_evasion
end

function modifier_kobold_taskmaster_command_aura_custom_effect:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_kobold_taskmaster_command_aura_custom_effect:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end
