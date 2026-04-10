if CreepDropSystem == nil then
    CreepDropSystem = class({})
end

CreepDropSystem.DROP_TABLE = {
    -- ["npc_name"] = {
    --     { item = "item_name", chance = 25 }, -- chance in %
    -- },
    ["npc_dota_neutral_kobold"] = {
        { item = "item_clarity", chance = 12 },
    },
    ["npc_dota_neutral_centaur_outrunner"] = {
        { item = "item_flask", chance = 8 },
    },
}

function CreepDropSystem:Init(config)
    self.drop_table = config or self.DROP_TABLE
end

function CreepDropSystem:OnEntityKilled(killed_unit, killer_unit)
    if not killed_unit or killed_unit:IsNull() then
        return
    end

    local drops = self.drop_table[killed_unit:GetUnitName()]
    if not drops then
        return
    end

    for _, drop_data in ipairs(drops) do
        if self:RollDrop(drop_data.chance) then
            self:CreateDrop(killed_unit, killer_unit, drop_data.item)
        end
    end
end

function CreepDropSystem:RollDrop(chance)
    if not chance or chance <= 0 then
        return false
    end

    return RollPercentage(chance)
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
