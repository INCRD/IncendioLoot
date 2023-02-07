local addonName, addon = ...
local IncendioLoot = _G[addonName]
local DataHandler = IncendioLoot:NewModule("DataHandler", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootTable 
local VoteData = {}
local MasterLooter 
local ExternalMasterLooters = {}
local SessionActive
local AddonActive
local ScrollCols 
local ScrollColsHistory
local ScrollRows
local OwnVoteData = {}
local SelfViableLoot = {}
IncendioLootDataHandler = {}

--Init RaidIDs [[
local RaidIDs = {
    [34] = true, --The Stockade (this is my Testdungeon...)
    [389] = true, --Ragefire Chasm (in case i'll ever do horde)
    [2522] = true --Vault of the Incarnates 
}
--]]

function IncendioLootDataHandler.SetViableLoot(NewViableLoot)
    SelfViableLoot = NewViableLoot;
end

function IncendioLootDataHandler.GetViableLoot()
    return SelfViableLoot
end

function IncendioLootDataHandler.GetOwnVoteData()
    return OwnVoteData
end

function IncendioLootDataHandler.SetOwnVoteData(NewOwnVoteData)
    OwnVoteData = NewOwnVoteData
end

function IncendioLootDataHandler.InitScrollFrameCols(NewScrollCols)
    ScrollCols = NewScrollCols
end

function IncendioLootDataHandler.InitHistoryScrollFrameCols(NewScrollCols)
    ScrollColsHistory = NewScrollCols
end

function IncendioLootDataHandler.SetScrollRows(NewScrollRows)
    ScrollRows = NewScrollRows
end

function IncendioLootDataHandler.GetScrollRows()
    return ScrollRows
end

function IncendioLootDataHandler.GetScrollFrameColls()
    return ScrollCols
end

function IncendioLootDataHandler.GetHistoryScrollFrameColls()
    return ScrollColsHistory
end

function IncendioLootDataHandler.SetSessionActiveInactive(ActiveInactive)
    SessionActive = ActiveInactive
end

function IncendioLootDataHandler.GetSessionActive()
    return SessionActive
end

function IncendioLootDataHandler.SetLootTable(NewLootTable)
    LootTable = NewLootTable
end

function IncendioLootDataHandler.AddItemToLootTable(Item)
    table.insert(LootTable, Item)
end

function IncendioLootDataHandler.GetLootTable()
    return LootTable
end

function IncendioLootDataHandler.SetVoteData(NewVoteData)
    VoteData = NewVoteData 
end

function IncendioLootDataHandler.GetVoteData()
    return VoteData
end

function IncendioLootDataHandler.AddItemIndexToVoteData(Index)
    VoteData[Index] = {}
end

function IncendioLootDataHandler.SetMasterLooter(NewMasterLooter)
    MasterLooter = NewMasterLooter
end

function IncendioLootDataHandler.GetMasterLooter()
    return MasterLooter
end

function IncendioLootDataHandler.SetAddonActive(NewAddonActive)
    AddonActive = NewAddonActive
end

function IncendioLootDataHandler.GetAddonActive()
    return AddonActive
end

function IncendioLootDataHandler.BuildAndSetMLTable()
    MasterLooter = {}
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml1)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml2)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml3)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml4)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml5)
    IncendioLootLootCouncil.AnnounceMLs()
end

function IncendioLootDataHandler.GetExternalMasterLooter()
    return ExternalMasterLooters
end

function IncendioLootDataHandler.SetExternalMLs(NewExternalMLs)
    ExternalMasterLooters = NewExternalMLs
end

function IncendioLootDataHandler.GetRaidIDs()
    return RaidIDs 
end

function IncendioLootDataHandler.WipeData()
        LootTable = {}
        VoteData = {}
        ScrollRows = {}
        OwnVoteData = {}
end

function IncendioLootDataHandler.WipeScrollData()
    ScrollRows = {}    
end

function IncendioLootDataHandler.WipeViableLootData()
    SelfViableLoot = {}
end
