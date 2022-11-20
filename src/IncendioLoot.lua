local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon("IncendioLoot",
                                                "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
_G[addonName] = IncendioLoot
IncendioLoot.Version = tonumber(GetAddOnMetadata(addonName, 'Version'))
IncendioLoot.ReceivedOutOfDateMessage = false
local AceConsole = LibStub("AceConsole-3.0")

local tonumber = tonumber

--[[
    Global events
    The event names cannot exceed 16 bytes
]] --
IncendioLoot.EVENTS = {
    EVENT_VERSION_CHECK = "IL.VerChk", -- version comparison
    EVENT_LOOT_SESSION_STARTED = "IL.LSessStarted", -- whenever a new "loot session" is started
    EVENT_LOOT_LOOTED = "IL.LLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_CAST = "IL.LVoteCast", -- whenever a loot council member votes on an item
    EVENT_LOOT_DISTRIBUTED = "IL.LDist", -- whenever the council distributes an item
    EVENT_LOOT_VOTE_PLAYER = "IL.LVotedPlayer" -- whenever a player sets a vote on an item
}

local function HandleVersionCheckEvent(prefix, str, distribution, sender)
    if (sender == player) then return end
    local ver, msg, InCombat = IncendioLoot.Version, tonumber(str),
                               InCombatLockdown()
    if (msg and ver < msg and not IncendioLoot.ReceivedOutOfDateMessage) then
        AceConsole:Print("version_out_of_date: "..msg)
        IncendioLoot.ReceivedOutOfDateMessage = true
    end
end

local function HandleGroupRosterUpdate()
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_VERSION_CHECK,
                                 IncendioLoot.Version,
                                 IsInRaid() and "RAID" or "PARTY")
end

--[[
    Loot utils
]] --

IncendioLoot.LootUtil = {}
function IncendioLoot.LootUtil:SendLootEvent(item, looter, encounter)
    if (IsInRaid()) then
        local data = {item = item, looter = looter, encounter = encounter}
        local s = IncendioLoot:Serialize(data)
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED, s,
                                     "RAID")
    end
end

--[[
    Init
]] --
function IncendioLoot:OnInitialize()
    LibStub("AceComm-3.0"):Embed(IncendioLoot)
    self.DB = LibStub("AceDB-3.0"):New("IncendioLootDB")
    IncendioLoot:RegisterEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
end
