local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil", "AceConsole-3.0","AceEvent-3.0", "AceComm-3.0","AceSerializer-3.0")
local LootTable
local VoteData

local function CheckIfViableLootAvailable()
    for index = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(index) == Enum.LootSlotType.Item) then
            local _, _, _, _, LootQuality = GetLootSlotInfo(index)
            if (LootQuality >= 3) then
                return true
            end
        end
    end
end

local function BuildLootTable()
    if UnitIsGroupLeader("player") then 
        if not CheckIfViableLootAvailable() then
            return
        end
    end

    if not IncendioLootDataHandler.GetSessionActive then
        if UnitIsGroupLeader("player") then
            for index = 1, GetNumLootItems(), 1 do
                if (GetLootSlotType(index) == Enum.LootSlotType.Item) then
                    local TexturePath, ItemName, _, _, LootQuality = GetLootSlotInfo(index)
                    if (LootQuality >= 3) then
                        local ItemLink = GetLootSlotLink(index)
                        local Item = {}
                        Item["TexturePath"] = TexturePath
                        Item["ItemName"] = ItemName
                        Item["ItemLink"] = ItemLink
                        Item["Index"] = index
                        Item["LootQuality"] = LootQuality
                        table.insert(LootTable, Item)  
                        VoteData[Item.Index] = {}
                    end
                end
            end
        end
    end
end

LootCouncil:RegisterEvent("LOOT_OPENED", function ()
    if UnitIsGroupLeader("player") then
        BuildLootTable()
        IncendioLootDataHandler.SetLootTable(LootTable)
        IncendioLootDataHandler.
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED,
        " ",
        IsInRaid() and "RAID" or "PARTY")
    end
end )