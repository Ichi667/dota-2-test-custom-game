LinkLuaModifier("modifier_neutral_camp_tag", "modifiers/modifier_neutral_camp_tag", LUA_MODIFIER_MOTION_NONE)

if NeutralCampManager == nil then
    NeutralCampManager = class({})
end

NeutralCampManager.DEFAULT_REWARD_LEVEL_GAP = 10
NeutralCampManager.DEFAULT_RESPAWN_INTERVAL = 60

NeutralCampManager.CAMPS = {
    -- Примеры. Добавьте/измените спавны под имена энтити на карте.
    {
        spawn_name = "neutral_camp_easy_1",
        pack = {
            { unit_name = "npc_dota_neutral_kobold", count = 2 },
            { unit_name = "npc_dota_neutral_kobold_tunneler", count = 1 },
        },
    },
    {
        spawn_name = "neutral_camp_medium_1",
        pack = {
            { unit_name = "npc_dota_neutral_centaur_outrunner", count = 2 },
            { unit_name = "npc_dota_neutral_centaur_khan", count = 1 },
        },
    },
}

function NeutralCampManager:Init(options)
    options = options or {}

    self.respawn_interval = options.respawn_interval or self.DEFAULT_RESPAWN_INTERVAL
    self.reward_level_gap = options.reward_level_gap or self.DEFAULT_REWARD_LEVEL_GAP
    self.camps = self:BuildCampState(options.camps or self.CAMPS)
    self.unit_entindex_to_camp = {}

    self:StartThinker()
end

function NeutralCampManager:BuildCampState(camp_config)
    local camps = {}

    for _, camp_data in ipairs(camp_config) do
        if camp_data.spawn_name and camp_data.pack and #camp_data.pack > 0 then
            table.insert(camps, {
                spawn_name = camp_data.spawn_name,
                pack = camp_data.pack,
                spawned_units = {},
                force_find_clear_space = camp_data.force_find_clear_space ~= false,
            })
        end
    end

    return camps
end

function NeutralCampManager:StartThinker()
    GameRules:GetGameModeEntity():SetContextThink("NeutralCampManagerThink", function()
        return self:OnThink()
    end, 1)
end

function NeutralCampManager:OnThink()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    local game_time = GameRules:GetDOTATime(false, false)
    if game_time < 0 then
        return 1
    end

    local seconds_from_minute = math.floor(game_time) % self.respawn_interval
    if seconds_from_minute == 0 then
        self:TrySpawnAllCamps()
        return 1
    end

    return 1
end

function NeutralCampManager:TrySpawnAllCamps()
    for _, camp in ipairs(self.camps) do
        self:TrySpawnCamp(camp)
    end
end

function NeutralCampManager:TrySpawnCamp(camp)
    self:CleanupCampUnits(camp)

    if #camp.spawned_units > 0 then
        return
    end

    local spawn_entity = Entities:FindByName(nil, camp.spawn_name)
    if not spawn_entity then
        print("[NeutralCampManager] Spawn point not found: " .. tostring(camp.spawn_name))
        return
    end

    for _, unit_data in ipairs(camp.pack) do
        for _ = 1, (unit_data.count or 1) do
            local creep = CreateUnitByName(
                unit_data.unit_name,
                spawn_entity:GetAbsOrigin(),
                camp.force_find_clear_space,
                nil,
                nil,
                DOTA_TEAM_NEUTRALS
            )

            if creep then
                creep:AddNewModifier(creep, nil, "modifier_neutral_camp_tag", {})

                camp.spawned_units[#camp.spawned_units + 1] = creep
                self.unit_entindex_to_camp[creep:entindex()] = camp
            else
                print("[NeutralCampManager] Failed to spawn unit: " .. tostring(unit_data.unit_name))
            end
        end
    end
end

function NeutralCampManager:CleanupCampUnits(camp)
    local alive_units = {}

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            alive_units[#alive_units + 1] = unit
        elseif unit and not unit:IsNull() then
            self.unit_entindex_to_camp[unit:entindex()] = nil
        end
    end

    camp.spawned_units = alive_units
end

function NeutralCampManager:IsManagedNeutral(unit)
    return unit and not unit:IsNull() and unit:HasModifier("modifier_neutral_camp_tag")
end

function NeutralCampManager:ShouldSuppressReward(victim, attacker)
    if not self:IsManagedNeutral(victim) then
        return false
    end

    if not attacker or attacker:IsNull() then
        return false
    end

    local hero = attacker
    if not hero:IsRealHero() then
        hero = attacker:GetOwner()
    end

    if not hero or hero:IsNull() or not hero:IsRealHero() then
        return false
    end

    local level_gap = hero:GetLevel() - victim:GetLevel()
    return level_gap >= self.reward_level_gap
end

function NeutralCampManager:OnModifyGold(filter_table)
    local victim_index = filter_table.killed_entindex_const
    local attacker_index = filter_table.player_id_const

    if not victim_index or not attacker_index then
        return true
    end

    local victim = EntIndexToHScript(victim_index)
    local player = PlayerResource:GetPlayer(attacker_index)
    local hero = player and player:GetAssignedHero() or nil

    if self:ShouldSuppressReward(victim, hero) then
        filter_table.gold = 0
    end

    return true
end

function NeutralCampManager:OnModifyExperience(filter_table)
    local victim_index = filter_table.killed_entindex_const
    local player_id = filter_table.player_id_const

    if not victim_index or not player_id then
        return true
    end

    local victim = EntIndexToHScript(victim_index)
    local player = PlayerResource:GetPlayer(player_id)
    local hero = player and player:GetAssignedHero() or nil

    if self:ShouldSuppressReward(victim, hero) then
        filter_table.experience = 0
    end

    return true
end
