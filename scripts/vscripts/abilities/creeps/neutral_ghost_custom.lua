LinkLuaModifier("modifier_neutral_ghost_max_health_burn_custom", "abilities/creeps/neutral_ghost_custom", LUA_MODIFIER_MOTION_NONE)

neutral_ghost_max_health_burn_custom = class({})

function neutral_ghost_max_health_burn_custom:GetIntrinsicModifierName()
	return "modifier_neutral_ghost_max_health_burn_custom"
end

modifier_neutral_ghost_max_health_burn_custom = class({})

function modifier_neutral_ghost_max_health_burn_custom:IsHidden() return true end
function modifier_neutral_ghost_max_health_burn_custom:IsPurgable() return false end

function modifier_neutral_ghost_max_health_burn_custom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_neutral_ghost_max_health_burn_custom:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if not params.target or params.target:IsNull() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end

	local pct = self:GetAbility():GetSpecialValueFor("max_health_damage_pct")
	local damage = params.target:GetMaxHealth() * pct * 0.01

	ApplyDamage({
		victim = params.target,
		attacker = self:GetParent(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	})
end
