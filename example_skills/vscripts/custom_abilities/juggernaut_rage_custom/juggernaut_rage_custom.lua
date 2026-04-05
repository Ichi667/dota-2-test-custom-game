juggernaut_rage_custom = class({})
LinkLuaModifier("modifier_juggernaut_rage_custom", "custom_abilities/juggernaut_rage_custom/modifier_juggernaut_rage_custom", LUA_MODIFIER_MOTION_NONE)

function juggernaut_rage_custom:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_juggernaut_rage_custom", { duration = self:GetSpecialValueFor("duration") })
	EmitSoundOn("Hero_LifeStealer.Rage", self:GetCaster())
end
