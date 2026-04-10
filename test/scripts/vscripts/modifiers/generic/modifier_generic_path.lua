
modifier_generic_path = class(mod_hidden)
function modifier_generic_path:CheckState()
return
{
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
}
end