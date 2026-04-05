juggernaut_double_strike = class({})
LinkLuaModifier("modifier_juggernaut_double_strike", "custom_abilities/juggernaut_double_strike/modifier_juggernaut_double_strike", LUA_MODIFIER_MOTION_NONE)

function juggernaut_double_strike:GetIntrinsicModifierName()
	return "modifier_juggernaut_double_strike"
end
