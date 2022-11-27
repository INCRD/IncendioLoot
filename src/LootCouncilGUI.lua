local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local AceConsole = LibStub("AceConsole-3.0")

--[[
    Event handling
]] --
local function HandleLootLootedEvent(prefix, str, distribution, sender)
    print("Blub")
end

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)    
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED, HandleLootLootedEvent)
end