local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootDatabase = IncendioLoot:NewModule("LootDatabase", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
IncendioLootLootDatabase = {}

function IncendioLootLootDatabase.AddItemToDatabase(PlayerName, MapID, Class, Instance, RollType, ItemLink, Votes, Roll, DifficultyIndex, DifficultyName)
    if IncendioLoot.ILHistory.profile.history[PlayerName] == nil then
        IncendioLoot.ILHistory.profile.history[PlayerName] = {}
    end
    table.insert(IncendioLoot.ILHistory.profile.history[PlayerName],{
        PlayerName = PlayerName,
        MapID = MapID,
        Class = Class, 
        Instance = Instance, 
        RollType = RollType, 
        ItemLink = ItemLink, 
        Votes = Votes, 
        Date = date("%d/%m/%y"), 
        Time = date("%H:%M:%S"),
        Roll = Roll, 
        DifficultyIndex = DifficultyIndex,
        DifficultyName = DifficultyName,
        UnixTimeStamp = time(date("!*t"))})
end

function IncendioLootLootDatabase.ReturnItemsLastTwoWeeksPlayer(PlayerName, RollType)
    local table = IncendioLoot.ILHistory.profile.history[PlayerName]
    if table == nil then 
        return 0
    end

    local count = 0
    for _, entry in pairs(table) do
        if entry.PlayerName == PlayerName and entry.RollType == RollType then
            local currentDate = time(date("!*t"))
            local diffInDays = (difftime(currentDate, entry.UnixTimeStamp) / 86400)
            if diffInDays < 15 then
                count = count + 1
            end
        end
    end

    if IncendioLoot.ILOptions.profile.options.general.debug then
        print(count)
    end

    return count
end