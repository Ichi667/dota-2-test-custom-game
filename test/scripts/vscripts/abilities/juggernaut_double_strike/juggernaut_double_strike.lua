juggernaut_double_strike = class({})
LinkLuaModifier("modifier_juggernaut_double_strike", "abilities/juggernaut_double_strike/modifier_juggernaut_double_strike", LUA_MODIFIER_MOTION_NONE)

function juggernaut_double_strike:Precache(context)
	PrecacheResource("particle", "particles/juggernaut_doublestrike/juggernaut_ti8_sword_crit_b_golden.vpcf", context)
end

function juggernaut_double_strike:GetIntrinsicModifierName()
	return "modifier_juggernaut_double_strike"
end
