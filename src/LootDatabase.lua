local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootDatabase = IncendioLoot:NewModule("LootDatabase", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local L = addon.L
local IsPlayerInRaid = false
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
        local Serialized = LootDatabase:Serialize({PlayerName = i, Data = value})
        local configForDeflate = {level = 9}
        local compressed = LootDatabaseDeflate:CompressDeflate(Serialized, configForDeflate)
        local EncodedForWoW = LootDatabaseDeflate:EncodeForWoWAddonChannel(compressed)
        
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_GET_DB_SYNC, 
        EncodedForWoW, "WHISPER", PlayerNameToSend[3], "BULK")
    end
end

local function HandleSync(prefix, str, distribution, sender)
    if sender == GetUnitName("Player") then 
        return
    end

    local numGroupMembers = GetNumGroupMembers()
    if numGroupMembers == 0 then 
        return
    end

    IsPlayerInRaid = false
    for i = 1, numGroupMembers do
        local name = GetUnitName("raid" .. i)
        if name == sender then 
            IsPlayerInRaid = true
        end
    end

    if not IsPlayerInRaid then 
        return
    end

    if not IncendioLoot.ILOptions.profile.options.general.allowDBSync then 
        print(L["SYNC_NOT_ACTIVATED"])
        return
    end

    local DataReceived = LootDatabaseDeflate:DecodeForWoWAddonChannel(str)
    local uncompressed = LootDatabaseDeflate:DecompressDeflate(DataReceived)
    local _, DeSerialized = LootDatabase:Deserialize(uncompressed)
    if IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] == nil then
        IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] = {}
    end

    IncendioLoot.ILHistory.factionrealm.history[DeSerialized.PlayerName] = DeSerialized.Data

    print(string.format(L["SYNC_SUCCESS"], DeSerialized.PlayerName))
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
