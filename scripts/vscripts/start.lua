if main == nil then
    main = class({})
end

xptable = {
0,1000,2000,3000,4000,5000,6000,7000,8000,9000,
10000,11000,12000,13000,14000,15000,16000,17000,18000,19000,
20000,21000,22000,23000,24000,25000,26000,27000,28000,29000,
30000,31000,32000,33000,34000,35000,36000,37000,38000,39000,
40000,41000,42000,43000,44000,45000,46000,47000,48000,49000,
50000,51000,52000,53000,54000,55000,56000,57000,58000,59000,
60000,61000,62000,63000,64000,65000,66000,67000,68000,69000,
70000,71000,72000,73000,74000,75000,76000,77000,78000,79000,
80000,81000,82000,83000,84000,85000,86000,87000,88000,89000,
90000,91000,92000,93000,94000,95000,96000,97000,98000,99000
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

function main:spawns()
    local spawns = {
        {
            spawn_name = "ward",
            unit_name = "npc_dota_base_ward",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = true,
            modifiers = {
                "modifier_invulnerable"
            }
        },
        {
            spawn_name = "ward1",
            unit_name = "npc_dota_base_ward1",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = true,
            modifiers = {
                "modifier_invulnerable"
            },
            abilities = {
            }
        },
        {
            spawn_name = "ward2",
            unit_name = "npc_dota_base_ward",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = true,
            modifiers = {
                "modifier_invulnerable"
            },
            abilities = {
            }
        },
        {
            spawn_name = "tower1",
            unit_name = "npc_dota_t1_tower",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = false,
            remove_modifiers = {
                "modifier_invulnerable"
            },
            abilities = {
                {
                    name = "tower_splitshot",
                    level = 1,
                    toggle = true
                },
            }
        },
        {
            spawn_name = "tower2",
            unit_name = "npc_dota_t1_tower",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = false,
            remove_modifiers = {
                "modifier_invulnerable"
            },
            abilities = {
                {
                    name = "tower_splitshot",
                    level = 1,
                    toggle = true
                }
            }
        },
    }

    self.spawned_units = self.spawned_units or {}

    for _, data in ipairs(spawns) do
        local unit = self:SpawnUnitFromConfig(data)
        if unit then
            table.insert(self.spawned_units, unit)
        end
    end
end

function main:SpawnUnitFromConfig(data)
    local spawn_ent = Entities:FindByName(nil, data.spawn_name)
    if not spawn_ent then
        print("Не найдена точка: " .. tostring(data.spawn_name))
        return nil
    end

    local unit = CreateUnitByName(
        data.unit_name,
        spawn_ent:GetAbsOrigin(),
        data.find_clear_space or false,
        nil,
        nil,
        data.team or DOTA_TEAM_NEUTRALS
    )

    if not unit then
        print("Не удалось создать юнита: " .. tostring(data.unit_name))
        return nil
    end

    if data.modifiers then
        for _, modifier_name in ipairs(data.modifiers) do
            unit:AddNewModifier(unit, nil, modifier_name, {})
        end
    end

    if data.remove_modifiers then
        for _, modifier_name in ipairs(data.remove_modifiers) do
            unit:RemoveModifierByName(modifier_name)
        end
    end

    if data.abilities then
        for _, ability_data in ipairs(data.abilities) do
            self:AddAbilityFromConfig(unit, ability_data)
        end
    end

    return unit
end

function main:AddAbilityFromConfig(unit, ability_data)
    if not ability_data or not ability_data.name then
        return
    end

    local ability = unit:FindAbilityByName(ability_data.name)

    if not ability then
        ability = unit:AddAbility(ability_data.name)
    end

    if not ability then
        print("Не удалось добавить способность " .. tostring(ability_data.name) .. " юниту " .. tostring(unit:GetUnitName()))
        return
    end

    if ability_data.level and ability_data.level > 0 then
        ability:SetLevel(ability_data.level)
    end

    if ability_data.toggle and ability:IsToggle() then
        if not ability:GetToggleState() then
            ability:ToggleAbility()
        end
    end

    if ability_data.auto_cast and unit:GetPlayerOwnerID() ~= nil then
        unit:CastAbilityNoTarget(ability, unit:GetPlayerOwnerID())
    end
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
