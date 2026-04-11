if CreepDropSystem == nil then
    CreepDropSystem = class({})
end

CreepDropSystem.DROP_TABLE = {
    ["npc_dota_neutral_kobold"] = {
        chance = 50,
        count = 1,
        items = {
            { item = "item_clarity", weight = 60 },
            { item = "item_faerie_fire", weight = 25 },
            { item = "item_enchanted_mango", weight = 15 },
        }
    },

    ["npc_dota_neutral_centaur_outrunner"] = {
        chance = 20,
        count = 2,
        items = {
            { item = "item_flask", weight = 50 },
            { item = "item_clarity", weight = 30 },
            { item = "item_enchanted_mango", weight = 20 },
        }
    },

    ["npc_dota_case_1_lvl"] = {
        chance = 100,
        count = 1,
        items = {
            { item = "item_ogre_axe", weight = 34 },
            { item = "item_blade_of_alacrity", weight = 33 },
            { item = "item_staff_of_wizardry", weight = 33 },
        }
    },
}

function CreepDropSystem:Init(config)
    self.drop_table = config or self.DROP_TABLE
end

function CreepDropSystem:OnEntityKilled(killed_unit, killer_unit)
    if not killed_unit or killed_unit:IsNull() then
        return
    end

    local drop_data = self.drop_table[killed_unit:GetUnitName()]
    if not drop_data then
        return
    end

    if not self:RollDrop(drop_data.chance) then
        return
    end

    local selected_items = self:SelectItems(drop_data.items, drop_data.count or 1)
    if not selected_items or #selected_items == 0 then
        return
    end

    for _, item_name in ipairs(selected_items) do
        self:CreateDrop(killed_unit, killer_unit, item_name)
    end
end

function CreepDropSystem:RollDrop(chance)
    if not chance or chance <= 0 then
        return false
    end

    return RollPercentage(chance)
end

function CreepDropSystem:SelectItems(items, count)
    if not items or #items == 0 or count <= 0 then
        return {}
    end

    local pool = {}
    for i, data in ipairs(items) do
        if data.item and (data.weight or 0) > 0 then
            pool[#pool + 1] = {
                item = data.item,
                weight = data.weight
            }
        end
    end

    local result = {}
    local rolls_count = math.min(count, #pool)

    for _ = 1, rolls_count do
        local picked_index = self:GetWeightedRandomIndex(pool)
        if not picked_index then
            break
        end

        result[#result + 1] = pool[picked_index].item
        table.remove(pool, picked_index) -- без повторов
    end

    return result
end

function CreepDropSystem:GetWeightedRandomIndex(pool)
    local total_weight = 0

    for _, entry in ipairs(pool) do
        total_weight = total_weight + (entry.weight or 0)
    end

    if total_weight <= 0 then
        return nil
    end

    local roll = RandomInt(1, total_weight)
    local current = 0

    for index, entry in ipairs(pool) do
        current = current + (entry.weight or 0)
        if roll <= current then
            return index
        end
    end

    return nil
end

function CreepDropSystem:CreateDrop(killed_unit, killer_unit, item_name)
    if not item_name then
        return
    end

    local item = CreateItem(item_name, nil, nil)
    if not item then
        print("[CreepDropSystem] Failed to create item: " .. tostring(item_name))
        return
    end

    local drop = CreateItemOnPositionSync(killed_unit:GetAbsOrigin(), item)

    if killer_unit and not killer_unit:IsNull() then
        item:SetPurchaser(killer_unit)
    end

    if drop then
        local launch_direction = RandomVector(120)
        item:LaunchLootInitialHeight(false, 220, 0.75, launch_direction)
    end
end