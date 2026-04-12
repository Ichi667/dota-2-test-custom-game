if main == nil then
    main = class({})
end

require("wave_settings")
require("systems/neutral_camp_manager")
require("systems/creep_drop_system")

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
    ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self)
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(self, "OnEntityHurt"), self)

    self.neutral_camp_manager = NeutralCampManager()
    self.neutral_camp_manager:Init()

    self.creep_drop_system = CreepDropSystem()
    self.creep_drop_system:Init()

    GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)   

    self:InitRoundSystem()
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

function main:OnEntityHurt(data)
    if not self.neutral_camp_manager or not data then
        return
    end

    if not data.entindex_killed or not data.entindex_attacker then
        return
    end

    local victim = EntIndexToHScript(data.entindex_killed)
    local attacker = EntIndexToHScript(data.entindex_attacker)

    if not victim or victim:IsNull() or not attacker or attacker:IsNull() then
        return
    end

    self.neutral_camp_manager:OnEntityHurt(victim, attacker)
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

    for i = 1, 3 do
        table.insert(spawns, {
            spawn_name = "chest_lvl_1_" .. i,
            unit_name = "npc_dota_case_1_lvl",
            team = DOTA_TEAM_BADGUYS,
            find_clear_space = true,
            abilities = {
            }
        })
    end

    for i = 15, 35 do
        table.insert(spawns, {
            spawn_name = "wave_path_" .. i,
            unit_name = "npc_dota_base_ward2",
            team = DOTA_TEAM_GOODGUYS,
            find_clear_space = true,
            modifiers = {
                "modifier_invulnerable"
            },
            abilities = {
            }
        })
    end

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

function main:InitRoundSystem()
    self.wave_settings = WAVE_SETTINGS or {}
    self.round_settings = {
        prep_time = self.wave_settings.initial_delay or 20,
        wave_interval = self.wave_settings.default_interval or 35,
        spawn_point_name = self.wave_settings.spawn_point_name or "wave_spawn",
        waypoint_prefix = self.wave_settings.waypoint_prefix or "wave_path_",
        waypoint_count_max = self.wave_settings.waypoint_count_max or 64,
        target_scan_radius = self.wave_settings.target_scan_radius or 700,
        fort_override_radius = self.wave_settings.fort_override_radius or 1200,
        spawn_scatter_radius = self.wave_settings.spawn_scatter_radius or 120
    }

    self.round_state = {
        current_round = 0,
        next_wave_time = GameRules:GetGameTime() + self.round_settings.prep_time
    }

    self.wave_waypoints = self:CollectWaypoints(
        self.round_settings.waypoint_prefix,
        self.round_settings.waypoint_count_max
    )

    self.round_creeps = {}

    CustomNetTables:SetTableValue("round_system", "state", self:GetRoundStateNetTableData())

    GameRules:GetGameModeEntity():SetContextThink("round_system_think", function()
        return self:RoundSystemThink()
    end, 0.25)
    Convars:RegisterCommand("wave_debug_print", function()
        self:DebugPrintWaveSettings()
    end, "Print configured waves", FCVAR_CHEAT)
end

function main:CollectWaypoints(prefix, max_count)
    local points = {}
    for index = 1, max_count do
        local name = prefix .. index
        local waypoint = Entities:FindByName(nil, name)
        if not waypoint then
            break
        end
        points[#points + 1] = waypoint:GetAbsOrigin()
    end
    return points
end

function main:GetRoundStateNetTableData()
    local time_left = math.max(0, self.round_state.next_wave_time - GameRules:GetGameTime())
    return {
        round = self.round_state.current_round,
        time_to_next = math.floor(time_left + 0.5)
    }
end

function main:RoundSystemThink()
    local game_time = GameRules:GetGameTime()
    if game_time >= self.round_state.next_wave_time then
        self:StartNextWave()
    end

    self:UpdateWaveCreepsBehavior()
    CustomNetTables:SetTableValue("round_system", "state", self:GetRoundStateNetTableData())
    return 0.25
end

function main:StartNextWave()
    self.round_state.current_round = self.round_state.current_round + 1
    local wave_data = self:GetWaveDataByRound(self.round_state.current_round)
    local next_interval = self.round_settings.wave_interval
    if wave_data and wave_data.interval then
        next_interval = wave_data.interval
    end
    self.round_state.next_wave_time = GameRules:GetGameTime() + next_interval

    local spawn_point = Entities:FindByName(nil, self.round_settings.spawn_point_name)
    if not spawn_point then
        print("[RoundSystem] Spawn point not found: " .. tostring(self.round_settings.spawn_point_name))
        return
    end

    if not wave_data or not wave_data.creeps or #wave_data.creeps == 0 then
        print("[RoundSystem] Wave " .. tostring(self.round_state.current_round) .. " has no creeps configured.")
        return
    end

    self:DebugPrintCurrentWave(self.round_state.current_round, wave_data)

    for _, creep_group in ipairs(wave_data.creeps) do
        local unit_name = creep_group.name
        local count = creep_group.count or 1
        local team = creep_group.team or DOTA_TEAM_BADGUYS

        for i = 1, count do
            local spawn_pos = spawn_point:GetAbsOrigin() + RandomVector(RandomFloat(0, self.round_settings.spawn_scatter_radius))
            local creep = CreateUnitByName(
                unit_name,
                spawn_pos,
                true,
                nil,
                nil,
                team
            )

            if creep then
                creep.round_waypoint_index = 1
                creep:SetMustReachEachGoalEntity(false)
                table.insert(self.round_creeps, creep)
            end
        end
    end
end

function main:GetWaveDataByRound(round_number)
    local waves = self.wave_settings.waves or {}
    if #waves == 0 then
        return nil
    end

    if waves[round_number] then
        return waves[round_number]
    end

    if self.wave_settings.repeat_last_wave then
        return waves[#waves]
    end

    return nil
end

function main:UpdateWaveCreepsBehavior()
    if not self.round_creeps then
        return
    end

    for index = #self.round_creeps, 1, -1 do
        local creep = self.round_creeps[index]
        if not creep or creep:IsNull() or not creep:IsAlive() then
            table.remove(self.round_creeps, index)
        else
            self:UpdateSingleCreepBehavior(creep)
        end
    end
end

function main:UpdateSingleCreepBehavior(creep)
    local origin = creep:GetAbsOrigin()
    local fort = Entities:FindByClassnameNearest("npc_dota_goodguys_fort", origin, self.round_settings.fort_override_radius)
    if fort and not fort:IsNull() and fort:IsAlive() then
        creep:MoveToTargetToAttack(fort)
        return
    end

    local enemies = FindUnitsInRadius(
        creep:GetTeamNumber(),
        origin,
        nil,
        self.round_settings.target_scan_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    if enemies and #enemies > 0 then
        creep:MoveToTargetToAttack(enemies[1])
        return
    end

    self:MoveCreepAlongPath(creep)
end

function main:MoveCreepAlongPath(creep)
    if not self.wave_waypoints or #self.wave_waypoints == 0 then
        return
    end

    local current_index = creep.round_waypoint_index or 1
    local current_target = self.wave_waypoints[current_index]
    if not current_target then
        current_target = self.wave_waypoints[#self.wave_waypoints]
        current_index = #self.wave_waypoints
    end

    local distance = (creep:GetAbsOrigin() - current_target):Length2D()
    if distance <= 150 and current_index < #self.wave_waypoints then
        current_index = current_index + 1
        creep.round_waypoint_index = current_index
        current_target = self.wave_waypoints[current_index]
    end

    if current_target then
        creep:MoveToPositionAggressive(current_target)
    end
end

function main:DebugPrintWaveSettings()
    print("[RoundSystem] ===== Wave Settings =====")
    print("[RoundSystem] initial_delay: " .. tostring(self.round_settings.prep_time))
    print("[RoundSystem] default_interval: " .. tostring(self.round_settings.wave_interval))
    print("[RoundSystem] spawn_point_name: " .. tostring(self.round_settings.spawn_point_name))
    print("[RoundSystem] waypoint_prefix: " .. tostring(self.round_settings.waypoint_prefix))

    local waves = self.wave_settings.waves or {}
    print("[RoundSystem] configured waves: " .. tostring(#waves))
    for wave_index, wave_data in ipairs(waves) do
        local interval = wave_data.interval or self.round_settings.wave_interval
        print("[RoundSystem] wave " .. tostring(wave_index) .. " interval=" .. tostring(interval))

        if wave_data.creeps then
            for _, creep_group in ipairs(wave_data.creeps) do
                print("[RoundSystem]   " .. tostring(creep_group.name) .. " x" .. tostring(creep_group.count or 1))
            end
        end
    end
    print("[RoundSystem] =========================")
end

function main:DebugPrintCurrentWave(round_number, wave_data)
    local interval = wave_data.interval or self.round_settings.wave_interval
    print("[RoundSystem] Spawning round " .. tostring(round_number) .. " (next in " .. tostring(interval) .. " sec)")
    for _, creep_group in ipairs(wave_data.creeps or {}) do
        print("[RoundSystem]   spawn: " .. tostring(creep_group.name) .. " x" .. tostring(creep_group.count or 1))
    end
end

function main:OnEntityKilled(data)
    self:finalbosskilled(data)

    if not data or not data.entindex_killed then
        return
    end

    local killed_unit = EntIndexToHScript(data.entindex_killed)
    if not killed_unit or killed_unit:IsNull() then
        return
    end

    local killer_unit = nil
    if data.entindex_attacker then
        killer_unit = EntIndexToHScript(data.entindex_attacker)
    end

    if self.creep_drop_system then
        self.creep_drop_system:OnEntityKilled(killed_unit, killer_unit)
    end

    if self.neutral_camp_manager then
        self.neutral_camp_manager:OnEntityKilled(killed_unit, killer_unit)
    end
end
