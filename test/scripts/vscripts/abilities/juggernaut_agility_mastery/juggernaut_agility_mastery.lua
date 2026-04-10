juggernaut_agility_mastery = class({})
LinkLuaModifier("modifier_juggernaut_agility_mastery", "abilities/juggernaut_agility_mastery/modifier_juggernaut_agility_mastery", LUA_MODIFIER_MOTION_NONE)

function juggernaut_agility_mastery:GetIntrinsicModifierName()
	return "modifier_juggernaut_agility_mastery"
end
