LinkLuaModifier("modifier_neutral_camp_tag", "modifiers/modifier_neutral_camp_tag", LUA_MODIFIER_MOTION_NONE)

if NeutralCampManager == nil then
    NeutralCampManager = class({})
end

NeutralCampManager.DEFAULT_REWARD_LEVEL_GAP = 10
NeutralCampManager.DEFAULT_RESPAWN_INTERVAL = 60
NeutralCampManager.DEFAULT_AGGRO_RADIUS = 500
NeutralCampManager.DEFAULT_LEASH_DURATION = 15
NeutralCampManager.DEFAULT_LEASH_DISTANCE = 1500
NeutralCampManager.DEFAULT_RETURN_RADIUS_MIN = 150
NeutralCampManager.DEFAULT_RETURN_RADIUS_MAX = 250
NeutralCampManager.DEFAULT_THINK_INTERVAL = 0.25
NeutralCampManager.DEFAULT_RETURN_REISSUE_INTERVAL = 1.0

NeutralCampManager.CAMPS = {
    {
        spawn_name = "camp_spawn_1",
        pack = {
            { unit_name = "npc_kobold", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_2",
        pack = {
            { unit_name = "npc_kobold", count = 2 },
            { unit_name = "npc_kobold_t", count = 2 },
            { unit_name = "npc_kobold_m", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_3",
        pack = {
            { unit_name = "npc_kobold", count = 2 },
            { unit_name = "npc_kobold_t", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_4",
        pack = {
            { unit_name = "npc_kobold", count = 1 },
            { unit_name = "npc_kobold_t", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_5",
        pack = {
            { unit_name = "npc_kobold_t", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_6",
        pack = {
            { unit_name = "npc_kobold", count = 1 },
            { unit_name = "npc_kobold_t", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_7",
        pack = {
            { unit_name = "npc_kobold_t", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_8",
        pack = {
            { unit_name = "npc_kobold_t", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_9",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_high_priest", count = 1 },
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_10",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 1 },
            { unit_name = "npc_kobold_t", count = 2 },
            { unit_name = "npc_kobold_m", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_11",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_12",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 1 },
            { unit_name = "npc_kobold_t", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_13",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 1 },
            { unit_name = "npc_kobold_t", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_14",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 2 },
            { unit_name = "npc_dota_neutral_forest_troll_high_priest", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_15",
        pack = {
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 2 },
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_16",
        pack = {
            { unit_name = "npc_dota_neutral_tadpole", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_17",
        pack = {
            { unit_name = "npc_dota_neutral_tadpole", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_18",
        pack = {
            { unit_name = "npc_dota_neutral_tadpole", count = 3 },
            { unit_name = "npc_dota_neutral_froglet", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_19",
        pack = {
            { unit_name = "npc_dota_neutral_tadpole", count = 4 },
            { unit_name = "npc_dota_neutral_froglet", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_20",
        pack = {
            { unit_name = "npc_dota_neutral_ghost", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_21",
        pack = {
            { unit_name = "npc_dota_neutral_ghost", count = 2 },
            { unit_name = "npc_dota_neutral_fel_beast", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_22",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_23",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_24",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_25",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_26",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_27",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_28",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_29",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_30",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_31",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 3 },
        },
    },
    {
        spawn_name = "camp_spawn_32",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_33",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
        },
    },
    {
        spawn_name = "camp_spawn_34",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
            { unit_name = "npc_dota_neutral_ghost", count = 1 },
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_35",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
            { unit_name = "npc_dota_neutral_ghost", count = 1 },
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 1 },
        },
    },
    {
        spawn_name = "camp_spawn_36",
        pack = {
            { unit_name = "npc_dota_neutral_gnoll_assassin", count = 2 },
            { unit_name = "npc_dota_neutral_ghost", count = 1 },
            { unit_name = "npc_dota_neutral_forest_troll_berserker", count = 1 },
        },
    },
}

function NeutralCampManager:Init(options)
    options = options or {}

    self.respawn_interval = options.respawn_interval or self.DEFAULT_RESPAWN_INTERVAL
    self.reward_level_gap = options.reward_level_gap or self.DEFAULT_REWARD_LEVEL_GAP
    self.aggro_radius = options.aggro_radius or self.DEFAULT_AGGRO_RADIUS
    self.leash_duration = options.leash_duration or self.DEFAULT_LEASH_DURATION
    self.leash_distance = options.leash_distance or self.DEFAULT_LEASH_DISTANCE
    self.return_radius_min = options.return_radius_min or self.DEFAULT_RETURN_RADIUS_MIN
    self.return_radius_max = options.return_radius_max or self.DEFAULT_RETURN_RADIUS_MAX
    self.think_interval = options.think_interval or self.DEFAULT_THINK_INTERVAL
    self.return_reissue_interval = options.return_reissue_interval or self.DEFAULT_RETURN_REISSUE_INTERVAL

    self.camps = self:BuildCampState(options.camps or self.CAMPS)
    self.unit_entindex_to_camp = {}
    self.unit_rewards = {}
    self.last_respawn_second = nil

    self:TrySpawnAllCamps()
    self:StartThinker()
end

function NeutralCampManager:CampHasAliveUnits(camp)
    if not camp then
        return false
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            return true
        end
    end

    return false
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
                aggro_target = nil,
                aggro_expires_at = 0,
                spawn_origin = nil,
                returning = false,
            })
        end
    end

    return camps
end

function NeutralCampManager:StartThinker()
    GameRules:GetGameModeEntity():SetContextThink("NeutralCampManagerThink", function()
        return self:OnThink()
    end, self.think_interval)
end

function NeutralCampManager:OnThink()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    local game_time = GameRules:GetDOTATime(false, false)
    if game_time < 0 then
        return self.think_interval
    end

    local game_second = math.floor(game_time)
    local seconds_from_minute = game_second % self.respawn_interval

    if seconds_from_minute == 0 and self.last_respawn_second ~= game_second then
        self:TrySpawnAllCamps()
        self.last_respawn_second = game_second
    end

    self:UpdateCampBehavior()
    return self.think_interval
end

function NeutralCampManager:TrySpawnAllCamps()
    for _, camp in ipairs(self.camps) do
        self:TrySpawnCamp(camp)
    end
end

function NeutralCampManager:TrySpawnCamp(camp)
    self:CleanupCampUnits(camp)

    if self:CampHasAliveUnits(camp) then
        return
    end

    local spawn_entity = Entities:FindByName(nil, camp.spawn_name)
    if not spawn_entity then
        print("[NeutralCampManager] Spawn point not found: " .. tostring(camp.spawn_name))
        return
    end

    camp.spawn_origin = spawn_entity:GetAbsOrigin()

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

                creep.neutral_return_radius = RandomInt(self.return_radius_min, self.return_radius_max)
                creep.neutral_last_return_order = 0

                self.unit_rewards[creep:entindex()] = {
                    gold_min = creep.GetMinimumGoldBounty and creep:GetMinimumGoldBounty() or 0,
                    gold_max = creep.GetMaximumGoldBounty and creep:GetMaximumGoldBounty() or 0,
                    xp = creep.GetDeathXP and creep:GetDeathXP() or 0,
                }

                if creep.SetMinimumGoldBounty then
                    creep:SetMinimumGoldBounty(0)
                end
                if creep.SetMaximumGoldBounty then
                    creep:SetMaximumGoldBounty(0)
                end
                if creep.SetDeathXP then
                    creep:SetDeathXP(0)
                end

                camp.spawned_units[#camp.spawned_units + 1] = creep
                self.unit_entindex_to_camp[creep:entindex()] = camp
            else
                print("[NeutralCampManager] Failed to spawn unit: " .. tostring(unit_data.unit_name))
            end
        end
    end

    camp.aggro_target = nil
    camp.aggro_expires_at = 0
    camp.returning = false
end

function NeutralCampManager:CleanupCampUnits(camp)
    local alive_units = {}

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            alive_units[#alive_units + 1] = unit
        elseif unit and not unit:IsNull() then
            self.unit_entindex_to_camp[unit:entindex()] = nil
            self.unit_rewards[unit:entindex()] = nil
        end
    end

    camp.spawned_units = alive_units

    if #camp.spawned_units == 0 then
        camp.aggro_target = nil
        camp.aggro_expires_at = 0
        camp.returning = false
    end
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

function NeutralCampManager:ResolveHero(unit)
    if not unit or unit:IsNull() then
        return nil
    end

    if unit:IsRealHero() then
        return unit
    end

    if unit.GetOwnerEntity then
        local owner = unit:GetOwnerEntity()
        if owner and not owner:IsNull() and owner:IsRealHero() then
            return owner
        end
    end

    if unit.GetPlayerOwnerID then
        local player_id = unit:GetPlayerOwnerID()
        if player_id ~= nil and player_id >= 0 then
            return PlayerResource:GetSelectedHeroEntity(player_id)
        end
    end

    return nil
end

function NeutralCampManager:FindHeroInRange(position, radius)
    local targets = FindUnitsInRadius(
        DOTA_TEAM_NEUTRALS,
        position,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )

    for _, target in ipairs(targets) do
        if target and not target:IsNull() and target:IsRealHero() and target:IsAlive() then
            return target
        end
    end

    return nil
end

function NeutralCampManager:FindCampByUnit(unit)
    if not unit or unit:IsNull() then
        return nil
    end

    local camp = self.unit_entindex_to_camp[unit:entindex()]
    if camp then
        return camp
    end

    for _, search_camp in ipairs(self.camps) do
        for _, camp_unit in ipairs(search_camp.spawned_units) do
            if camp_unit == unit then
                return search_camp
            end
        end
    end

    return nil
end

function NeutralCampManager:IsCampUnitInRange(camp, position, radius)
    if not camp or not position then
        return false
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            if (unit:GetAbsOrigin() - position):Length2D() <= radius then
                return true
            end
        end
    end

    return false
end

function NeutralCampManager:IsAnyUnitTooFarFromSpawn(camp)
    if not camp or not camp.spawn_origin then
        return false
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            if (unit:GetAbsOrigin() - camp.spawn_origin):Length2D() > self.leash_distance then
                return true
            end
        end
    end

    return false
end

function NeutralCampManager:AreAllUnitsBackToSpawn(camp)
    if not camp or not camp.spawn_origin then
        return false
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            local return_radius = unit.neutral_return_radius or self.return_radius_max
            if (unit:GetAbsOrigin() - camp.spawn_origin):Length2D() > return_radius then
                return false
            end
        end
    end

    return true
end

function NeutralCampManager:CommandUnitAggro(unit, target)
    if not unit or unit:IsNull() or not unit:IsAlive() then
        return
    end

    if not target or target:IsNull() or not target:IsAlive() then
        return
    end

    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = target:entindex(),
        Queue = false,
    })
end

function NeutralCampManager:CommandUnitReturn(unit, camp, force)
    if not unit or unit:IsNull() or not unit:IsAlive() then
        return
    end

    if not camp or not camp.spawn_origin then
        return
    end

    local now = GameRules:GetGameTime()
    if not force and unit.neutral_last_return_order and now - unit.neutral_last_return_order < self.return_reissue_interval then
        return
    end

    unit.neutral_last_return_order = now

    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = camp.spawn_origin,
        Queue = false,
    })
end

function NeutralCampManager:StartReturning(camp)
    if not camp then
        return
    end

    camp.returning = true
    camp.aggro_target = nil
    camp.aggro_expires_at = 0

    if not camp.spawn_origin then
        local spawn_entity = Entities:FindByName(nil, camp.spawn_name)
        if spawn_entity then
            camp.spawn_origin = spawn_entity:GetAbsOrigin()
        end
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            self:CommandUnitReturn(unit, camp, true)
        end
    end
end

function NeutralCampManager:UpdateReturningCamp(camp)
    if not camp or not camp.returning then
        return
    end

    if not camp.spawn_origin then
        local spawn_entity = Entities:FindByName(nil, camp.spawn_name)
        if spawn_entity then
            camp.spawn_origin = spawn_entity:GetAbsOrigin()
        else
            return
        end
    end

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            local return_radius = unit.neutral_return_radius or self.return_radius_max
            local distance = (unit:GetAbsOrigin() - camp.spawn_origin):Length2D()

            if distance > return_radius then
                self:CommandUnitReturn(unit, camp, false)
            else
                unit:Stop()
            end
        end
    end

    if self:AreAllUnitsBackToSpawn(camp) then
        camp.returning = false
        camp.aggro_target = nil
        camp.aggro_expires_at = 0
    end
end

function NeutralCampManager:AggroCamp(camp, target, source_position)
    if not camp or camp.returning then
        return
    end

    if not target or target:IsNull() or not target:IsAlive() then
        return
    end

    camp.aggro_target = target
    camp.aggro_expires_at = GameRules:GetGameTime() + self.leash_duration

    for _, unit in ipairs(camp.spawned_units) do
        if unit and not unit:IsNull() and unit:IsAlive() then
            local within_radius = true

            if source_position then
                within_radius = (unit:GetAbsOrigin() - source_position):Length2D() <= self.aggro_radius
            end

            if within_radius then
                self:CommandUnitAggro(unit, target)
            end
        end
    end
end

function NeutralCampManager:UpdateCampBehavior()
    local now = GameRules:GetGameTime()

    for _, camp in ipairs(self.camps) do
        self:CleanupCampUnits(camp)

        if #camp.spawned_units > 0 then
            if camp.returning then
                self:UpdateReturningCamp(camp)
            else
                local target = camp.aggro_target
                local target_alive = target and not target:IsNull() and target:IsAlive()

                if self:IsAnyUnitTooFarFromSpawn(camp) then
                    self:StartReturning(camp)
                elseif target_alive and now <= (camp.aggro_expires_at or 0) then
                    self:AggroCamp(camp, target)
                elseif target_alive or (camp.aggro_expires_at or 0) > 0 then
                    self:StartReturning(camp)
                else
                    for _, unit in ipairs(camp.spawned_units) do
                        if unit and not unit:IsNull() and unit:IsAlive() then
                            local hero = self:FindHeroInRange(unit:GetAbsOrigin(), self.aggro_radius)
                            if hero then
                                self:AggroCamp(camp, hero, unit:GetAbsOrigin())
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function NeutralCampManager:OnEntityHurt(victim, attacker)
    local hero = self:ResolveHero(attacker)
    if not hero or hero:IsNull() or not hero:IsAlive() then
        return
    end

    local camp = self:FindCampByUnit(victim)
    if not camp or camp.returning then
        return
    end

    if not self:IsCampUnitInRange(camp, victim:GetAbsOrigin(), self.aggro_radius) then
        return
    end

    self:AggroCamp(camp, hero, victim:GetAbsOrigin())
end

function NeutralCampManager:OnEntityKilled(victim, killer_unit)
    if not self:IsManagedNeutral(victim) then
        return
    end

    local entindex = victim:entindex()
    local reward_data = self.unit_rewards[entindex]
    self.unit_entindex_to_camp[entindex] = nil
    self.unit_rewards[entindex] = nil

    local hero = self:ResolveHero(killer_unit)
    if not hero or hero:IsNull() then
        return
    end

    if self:ShouldSuppressReward(victim, hero) then
        return
    end

    reward_data = reward_data or { gold_min = 0, gold_max = 0, xp = 0 }

    local min_gold = reward_data.gold_min or 0
    local max_gold = reward_data.gold_max or min_gold
    if max_gold < min_gold then
        max_gold = min_gold
    end

    local gold = RandomInt(min_gold, max_gold)
    if gold > 0 then
        local player_id = hero:GetPlayerOwnerID()
        if player_id ~= nil and player_id >= 0 then
            PlayerResource:ModifyGold(player_id, gold, true, DOTA_ModifyGold_CreepKill)
        end
    end

    local xp = reward_data.xp or 0
    if xp > 0 then
        hero:AddExperience(xp, DOTA_ModifyXP_CreepKill, false, true)
    end
end