local addonName, addon = ...
local IncendioLoot = _G[addonName]
local DataHandler = IncendioLoot:NewModule("DataHandler", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootTable = {}
local VoteData = {}
local MasterLooter = {}
local SessionActive
IncendioLootDataHandler = {}

function IncendioLootDataHandler.SetSessionActive()
    SessionActive = true
end

function IncendioLootDataHandler.GetSessionActive()
    return(SessionActive)
end

function IncendioLootDataHandler.SetLootTable(NewLootTable)
    LootTable = NewLootTable
end

function IncendioLootDataHandler.GetLootTable()
    return(LootTable)
end


function IncendioLootDataHandler.SetVote(NewVoteData)
    VoteData = NewVoteData 
end

function IncendioLootDataHandler.GetVoteData()
    return(VoteData)
end

function IncendioLoot.SetMasterLooter(NewMasterLooter)
    MasterLooter = NewMasterLooter
end

function IncendioLoot.GetMasterLooter()
    return(MasterLooter)
end