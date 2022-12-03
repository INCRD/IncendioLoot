LoadAddOn("LibCompress")

local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil", "AceConsole-3.0",
                                           "AceEvent-3.0", "AceComm-3.0",
                                           "AceSerializer-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")

--[[
    Event handling
]] --


local function HandleLootVoteCastEvent(prefix, str, distribution, sender)
    local _, data = LootCouncil:Deserialize(str)
    AceConsole:Print(data)
end

local function HandleLootDistributedEvent(prefix, str, distribution, sender)
    local _, data = LootCouncil:Deserialize(str)
    AceConsole:Print(data)
end

local function HandleLootSessionStartedEvent(prefix, str, distribution, sender)
    local _, data = LootCouncil:Deserialize(str)
    AceConsole:Print(data)
end

function LootCouncil:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootCouncil)
    
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_DISTRIBUTED,
                             HandleLootDistributedEvent)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_SESSION_STARTED,
                             HandleLootSessionStartedEvent)
end
