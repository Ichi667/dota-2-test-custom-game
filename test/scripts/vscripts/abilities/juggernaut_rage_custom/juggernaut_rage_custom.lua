juggernaut_rage_custom = class({})
LinkLuaModifier("modifier_juggernaut_rage_custom", "abilities/juggernaut_rage_custom/modifier_juggernaut_rage_custom", LUA_MODIFIER_MOTION_NONE)

function juggernaut_rage_custom:Precache(context)
	PrecacheResource("particle", "particles/juggernaut_rage/life_stealer_rage.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_life_stealer.vsndevts", context)
end

function juggernaut_rage_custom:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_juggernaut_rage_custom", { duration = self:GetSpecialValueFor("duration") })
	EmitSoundOn("Hero_LifeStealer.Rage", self:GetCaster())
end