require("start")

function Precache( context )
	PrecacheResource("soundfile", "soundevents/all_sounds.vsndevts", context)
	PrecacheResource( "particle_folder", "particles/items", context)
	PrecacheResource( "particle_folder", "particles/hero", context)
	PrecacheResource( "particle_folder", "particles/axe_spiked_armor", context)
end

-- Create the game mode when we activate
function Activate()
	main:InitGameMode()
	main:testspawn()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(main, "OrderFilter"), main)
end

