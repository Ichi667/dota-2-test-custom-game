if main == nil then
    main = class({})
end

xptable = {
0,1,2,3,4,5,6,7,8,9,
10,11,12,13,14,15,16,17,18,19,
20,21,22,23,24,25,26,27,28,29,
30,31,32,33,34,35,36,37,38,39,
40,41,42,43,44,45,46,47,48,49,
50,51,52,53,54,55,56,57,58,59,
60,61,62,63,64,65,66,67,68,69,
70,71,72,73,74,75,76,77,78,79,
80,81,82,83,84,85,86,87,88,89,
90,91,92,93,94,95,96,97,98,99
}

function main:InitGameMode()
    print( "Template addon is loaded." )

    GameRules:SetStartingGold(99999)
    GameRules:SetHeroSelectionTime(120)
    GameRules:SetPreGameTime(0)
    GameRules:SetStrategyTime(0.0)
    GameRules:SetShowcaseTime(0.0)
    GameRules:SetGoldPerTick(0)
    GameRules:SetTreeRegrowTime(10.0)

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)

    GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(false)
    GameRules:GetGameModeEntity():SetMaximumAttackSpeed(1000)

    GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xptable)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'finalbosskilled'), self)

    GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)   
end

-- Evaluate the state of the game
function main:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --print( "Template addon script is running." )
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end


function main:finalbosskilled(data)
    if not data or not data.entindex_killed then
        return
    end

    local killed_unit = EntIndexToHScript(data.entindex_killed)
    if not killed_unit or killed_unit:IsNull() then
        return
    end

    if killed_unit:GetUnitName() == "npc_dota_creature_gnoll_assassindsdsdsd" then
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
    end
end

function main:testspawn()
local ward_spawn = Entities:FindByName(nil, "ward")
if not ward_spawn then return end
local point = ward_spawn:GetAbsOrigin()
    local ward1 = CreateUnitByName("npc_dota_base_ward", point, true, nil, nil, DOTA_TEAM_GOODGUYS)
    ward1:AddNewModifier(ward1, nil, "modifier_invulnerable", {})

    local ward_spawn_1 = Entities:FindByName(nil, "ward1")
    if not ward_spawn_1 then return end
    local point1 = ward_spawn_1:GetAbsOrigin()
    local ward2 = CreateUnitByName("npc_dota_base_ward1", point1, true, nil, nil, DOTA_TEAM_GOODGUYS)
    ward2:AddNewModifier(ward2, nil, "modifier_invulnerable", {})

    local ward_spawn_2 = Entities:FindByName(nil, "ward2")
    if not ward_spawn_2 then return end
    local point2 = ward_spawn_2:GetAbsOrigin()
    local ward3 = CreateUnitByName("npc_dota_base_ward", point2, true, nil, nil, DOTA_TEAM_GOODGUYS)
    ward3:AddNewModifier(ward3, nil, "modifier_invulnerable", {})

    local tower_spawn_1 = Entities:FindByName(nil, "tower1")
    local tower_spawn_2 = Entities:FindByName(nil, "tower2")
    if not tower_spawn_1 or not tower_spawn_2 then return end

    local point3 = tower_spawn_1:GetAbsOrigin()
    local tower1 = CreateUnitByName("npc_dota_t1_tower", point3, false, nil, nil, DOTA_TEAM_GOODGUYS)

    local point4 = tower_spawn_2:GetAbsOrigin()
    local tower2 = CreateUnitByName("npc_dota_t1_tower", point4, false, nil, nil, DOTA_TEAM_GOODGUYS)

    tower1:RemoveModifierByName("modifier_invulnerable")
    tower2:RemoveModifierByName("modifier_invulnerable")

    local ability1 = tower1:AddAbility("tower_splitshot")
    ability1:SetLevel(1)

    local ability2 = tower2:AddAbility("tower_splitshot")
    ability2:SetLevel(1)

    ability1:ToggleAbility()
    ability2:ToggleAbility()
end

function main:OrderFilter(filterTable)
    local orderType = filterTable.order_type

    if orderType == DOTA_UNIT_ORDER_PURCHASE_ITEM then
        local itemName = filterTable.shop_item_name

        local banned_items = {
            ["item_blink"] = true,
            ["item_clarity"] = true,
            ["item_faerie_fire"] = true,
            ["item_enchanted_mango"] = true,
            ["item_tango"] = true,
            ["item_flask"] = true,
            ["item_smoke_of_deceit"] = true,
            ["item_bottle"] = true,
            ["item_infused_raindrop"] = true,
            ["item_gem"] = true,
            ["item_rapier"] = true
        }

        if banned_items[itemName] then
            return false
        end
    end

    return true
end
