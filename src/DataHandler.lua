local addonName, addon = ...
local IncendioLoot = _G[addonName]
local DataHandler = IncendioLoot:NewModule("DataHandler", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootTable 
local VoteData 
local MasterLooter 
local ExternalMasterLooters = {}
local SessionActive
local AddonActive
local ScrollCols 
local ScrollRows
IncendioLootDataHandler = {}

function IncendioLootDataHandler.InitScrollFrameCols(NewScrollCols)
    ScrollCols = NewScrollCols
end

function IncendioLootDataHandler.SetScrollRows(NewScrollRows)
    ScrollRows = NewScrollRows
end

function IncendioLootDataHandler.GetScrollRows()
    return(ScrollRows)
end

function IncendioLootDataHandler.GetScrollFrameColls()
    return(ScrollCols)
end

function IncendioLootDataHandler.SetSessionActiveInactive(ActiveInactive)
    SessionActive = ActiveInactive
end

function IncendioLootDataHandler.GetSessionActive()
    return(SessionActive)
end

function IncendioLootDataHandler.SetLootTable(NewLootTable)
    LootTable = NewLootTable
end

function IncendioLootDataHandler.AddItemToLootTable(Item)
    table.insert(LootTable, Item)
end

function IncendioLootDataHandler.GetLootTable()
    return(LootTable)
end

function IncendioLootDataHandler.SetVoteData(NewVoteData)
    VoteData = NewVoteData 
end

function IncendioLootDataHandler.GetVoteData()
    return(VoteData)
end

function IncendioLootDataHandler.AddItemIndexToVoteData(Index)
    VoteData[Index] = {}
end

function IncendioLootDataHandler.SetMasterLooter(NewMasterLooter)
    MasterLooter = NewMasterLooter
end

function IncendioLootDataHandler.GetMasterLooter()
    return(MasterLooter)
end

function IncendioLootDataHandler.SetAddonActive(NewAddonActive)
    AddonActive = NewAddonActive
end

function IncendioLootDataHandler.GetAddonActive()
    return(AddonActive)
end

function IncendioLootDataHandler.BuildAndSetMLTable()
    MasterLooter = {}
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml1)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml2)
    table.insert(MasterLooter, IncendioLoot.ILOptions.profile.options.masterlooters.ml3)
    IncendioLootLootCouncil.AnnounceMLs()
end

function IncendioLootDataHandler.GetExternalMasterLooter()
    return(ExternalMasterLooters)
end

function IncendioLootDataHandler.SetExternalMLs(NewExternalMLs)
    ExternalMasterLooters = NewExternalMLs
end

function IncendioLootDataHandler.WipeData()
        LootTable = {}
        VoteData = {}
        ScrollRows = {}
end
