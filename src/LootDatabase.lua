local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootDatabase = IncendioLoot:NewModule("LootDatabase", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local L = addon.L
IncendioLootLootDatabase = {}

function IncendioLootLootDatabase.AddItemToDatabase(PlayerName, MapID, Class, Instance, RollType, ItemLink, Votes, Roll, DifficultyIndex, DifficultyName)
    if IncendioLoot.ILHistory.factionrealm.history[PlayerName] == nil then
        IncendioLoot.ILHistory.factionrealm.history[PlayerName] = {}
    end
    table.insert(IncendioLoot.ILHistory.factionrealm.history[PlayerName],{
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
    local table = IncendioLoot.ILHistory.factionrealm.history[PlayerName]
    if table == nil then 
        return 0
    end

    local count = 0
    for _, entry in pairs(table) do
        if entry.PlayerName == PlayerName and entry.RollType == RollType then
            local currentDate = time(date("!*t"))
            local diffInDays = (difftime(currentDate, tonumber(entry.UnixTimeStamp)) / 86400)
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

local function SyncData(PlayerNameToSend)
    for i, value in pairs(IncendioLoot.ILHistory.factionrealm.history) do
        print(i)
        local Serialized = LootDatabase:Serialize({PlayerName = i, Data = IncendioLoot.ILHistory.factionrealm.history[i]})
        local configForDeflate = {level = 5}
        local compressed = LootDatabaseDeflate:CompressDeflate(Serialized, configForDeflate)
        local EncodedForWoW = LootDatabaseDeflate:EncodeForWoWAddonChannel(compressed)
        
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_GET_DB_SYNC, 
        EncodedForWoW, "WHISPER", PlayerNameToSend[3], "BULK")
    end
end

local function HandleSync(prefix, str, distribution, sender)
    if sender == GetUnitName("Player") then 
        print("Nöl")
        return
    end

    if not IncendioLoot.ILOptions.profile.options.general.allowDBSync then 
        print("Jemand hat versucht eine Datenbank zu synchronisieren. Doch die Funktkion ist nicht aktiv.")
        return
    end

    local DataReceived = LootDatabaseDeflate:DecodeForWoWAddonChannel(str)
    local uncompressed = LootDatabaseDeflate:DecompressDeflate(DataReceived)
    local _, DeSerialized = LootDatabase:Deserialize(uncompressed)
    if IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] == nil then
        IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] = {}
    end
    IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] = DeSerialized.Data
end

function LootDatabase:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootDatabase)
    LootDatabaseDeflate = LibStub("LibDeflate")
    IncendioLoot:RegisterSubCommand("syncdb", SyncData, L["COMMAND_SYNCDB"])
end

function LootDatabase:OnEnable()
    LootDatabase:RegisterComm(IncendioLoot.EVENTS.EVENT_GET_DB_SYNC,
                              HandleSync)
end
