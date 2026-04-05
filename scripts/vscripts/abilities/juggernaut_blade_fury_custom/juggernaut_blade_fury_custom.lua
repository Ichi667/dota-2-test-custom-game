juggernaut_blade_fury_custom = class({})
LinkLuaModifier("modifier_juggernaut_blade_fury_custom", "abilities/juggernaut_blade_fury_custom/modifier_juggernaut_blade_fury_custom", LUA_MODIFIER_MOTION_NONE)

function juggernaut_blade_fury_custom:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_juggernaut_blade_fury_custom", { duration = self:GetSpecialValueFor("duration") })
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetCaster())
end
