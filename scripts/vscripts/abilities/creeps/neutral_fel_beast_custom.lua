LinkLuaModifier("modifier_neutral_fel_beast_evasion_custom", "abilities/creeps/neutral_fel_beast_custom", LUA_MODIFIER_MOTION_NONE)

neutral_fel_beast_evasion_custom = class({})

function neutral_fel_beast_evasion_custom:GetIntrinsicModifierName()
	return "modifier_neutral_fel_beast_evasion_custom"
end

modifier_neutral_fel_beast_evasion_custom = class({})

function modifier_neutral_fel_beast_evasion_custom:IsHidden() return true end
function modifier_neutral_fel_beast_evasion_custom:IsPurgable() return false end

function modifier_neutral_fel_beast_evasion_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}
end

function modifier_neutral_fel_beast_evasion_custom:GetModifierAvoidDamage(params)
	if not IsServer() then return 0 end
	if not params.attacker or params.attacker:IsNull() then return 0 end
	if params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return 0 end

	local chance = self:GetAbility():GetSpecialValueFor("avoid_chance")
	if RollPercentage(chance) then
		return 1
	end

	return 0
end
