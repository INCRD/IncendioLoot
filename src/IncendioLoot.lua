local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon("IncendioLoot",
                                                "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
_G[addonName] = IncendioLoot
IncendioLoot.Version = GetAddOnMetadata(addonName, 'Version')
IncendioLoot.AddonActive = false
IncendioLootFunctions = {}

local ReceivedOutOfDateMessage = false
local AceConsole = LibStub("AceConsole-3.0")

--[[
    ["subcommand"] = {
        ["callback"] = function(args),
        ["description"] = string
]]
local CommandCallbacks = {}

--[[
    Global events
    The event names cannot exceed 16 bytes
]] --
IncendioLoot.EVENTS = {
    EVENT_VERSION_CHECK = "IL.VerChk", -- version comparison
    EVENT_LOOT_LOOTED = "IL.LLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_PLAYER = "IL.LVotedPlayer", -- whenever a player sets a vote on an item
    EVENT_LOOT_ANNOUNCE_COUNCIL = "IL.Council", -- announces the council as raidlead
    EVENT_SET_VOTING_INACTIVE = "IL.VoteInA", -- announces the council as raidlead
    EVENT_LOOT_LOOTDATA_BUILDED = "IL.LootBuild", -- Lootdata has been builded and structured
    EVENT_LOOT_ANNOUNCE_MLS = "IL.AnnounceMLs", -- Announces Masterlooters to all addonusers
    EVENT_LOOT_VOTE_COUNCIL = "IL.AnnounceVote", -- Announces the own vote to Council
    EVENT_LOOT_ASSIGN_ITEM_COUNCIL = "IL.AssignItem",
    EVENT_DATA_RECEIVED = "IL.DataReceived"
}

--[[
    Static Text Constants
]] --
IncendioLoot.STATICS = {
    NO_VOTE = "Kein Vote",
    ASSIGN_ITEM = "Möchtest du das Item zuweisen",
    END_SESSION = "Möchtest du die Sitzung beenden?",
    WIPE_DATABASE = "Möchtest du WIRKLICH die Lootdatenbank löschen?",
    DATABASE_WIPED = "Die Lootdatenbank wurde gelöscht.",
    DOUBLE_USE_WARNING = "WARNUNG, ein weiteres LootAddon ist aktiv! Dies kann zu Problemen führen.",
    OUT_OF_DATE_ADDON = "Achtung, deine Version von IncendioLoot ist nicht aktuell. Aktuelle Version: ",
    SELECT_PLAYER_FIRST = "Bitte erst einen Spieler auswählen!",
    ITEM_ALREADY_ASSIGNED = "Das Item wurde bereits zugewiesen."
}

--[[
    UwU pretty colors
]]
IncendioLoot.COLORS = {
    LIGHTBLUE = 'FF00CCFF'
}

local C = IncendioLoot.COLORS

function IncendioLootFunctions.CheckIfMasterLooter()
    if UnitIsGroupLeader("player") then 
        return(true)
    end
    local MasterLooter = IncendioLootDataHandler.GetExternalMasterLooter()
    
    for i, MasterLooter in pairs(MasterLooter) do
        if (UnitName("player") == MasterLooter) then
            return(true)
        end
        
    end
end

local function HandleVersionCheckEvent(prefix, str, distribution, sender)
    if (sender == UnitName("player")) then
        return 
    end
    local ver, msg = tonumber(IncendioLoot.Version), tonumber(str)
    if (msg and ver < msg and not ReceivedOutOfDateMessage) then
        AceConsole:Print(IncendioLoot.STATICS.OUT_OF_DATE_ADDON..str)
        ReceivedOutOfDateMessage = true
    end
end

local function HandleGroupRosterUpdate()
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_VERSION_CHECK,
                                IncendioLoot.Version, IsInRaid() and "RAID" or "PARTY")
end

function IncendioLoot:RegisterSubCommand(subcommand, callback, description)
    if not CommandCallbacks[subcommand] then
        CommandCallbacks[subcommand] = {
            callback = callback,
            description = description
        }
    else
        AceConsole:Print("Chat command "..subcommand.." was already registered, therefore it's being ignored. Callstack is "..debugstack())
    end
end

local function PrintChatCommands()
    AceConsole:Print(WrapTextInColorCode("/il", C.LIGHTBLUE).." - IncendioLoot [v"..WrapTextInColorCode(IncendioLoot.Version, C.LIGHTBLUE).."]")
    for command, tbl in pairs(CommandCallbacks) do
        AceConsole:Print("  "..WrapTextInColorCode(command, C.LIGHTBLUE).." - "..tbl.description)
    end
end

--[[
    Init
]] --
function IncendioLoot:OnInitialize()
    local DefaultOptions = {
        profile = {
            options = {
                general = {
                    active = false,
                    debug = false,
                    autopass = false
                },
                masterlooters = {
                    ml1 = "",
                    ml2 = "",
                    ml3 = ""
                }
            }
        }
    }
    local DefaultDBOptions = {
        profile = {
            history = {
            }
        }
    }
    LibStub("AceComm-3.0"):Embed(IncendioLoot)
    self.ILOptions = LibStub("AceDB-3.0"):New("IncendioLootOptionsDB", DefaultOptions, true)
    self.ILHistory = LibStub("AceDB-3.0"):New("IncendioLootHistoryDB", DefaultDBOptions, true)
end

local function CreateScrollCol(ColName, Width, sort)
    if sort then
        return {
            ["name"] = ColName,
            ["width"] = Width,
            ["align"] = "LEFT",
            ["colorargs"] = nil,
            ["defaultsort"] = "dsc",
            ["sortnext"]= 4,
            ["DoCellUpdate"] = nil,
        }
    end
    return {
        ["name"] = ColName,
        ["width"] = Width,
        ["align"] = "LEFT",
        ["colorargs"] = nil,
        ["defaultsort"] = "dsc",
        ["sortnext"]= 4,
        ["comparesort"] = function (cella, cellb, column)
            --maybe build own search function?
        end,
        ["DoCellUpdate"] = nil,
    }
end

local function BuildBasicData()
    local ScrollCols = {}
    table.insert(ScrollCols, CreateScrollCol("Name", 80, true))
    table.insert(ScrollCols, CreateScrollCol("Class", 80, true))
    table.insert(ScrollCols, CreateScrollCol("Zone", 80))
    table.insert(ScrollCols, CreateScrollCol("Online", 80))
    table.insert(ScrollCols, CreateScrollCol("Answer", 80))
    table.insert(ScrollCols, CreateScrollCol("Itemlevel", 80))
    table.insert(ScrollCols, CreateScrollCol("Roll", 80, true))
    table.insert(ScrollCols, CreateScrollCol("Votes", 80))
    table.insert(ScrollCols, CreateScrollCol("Auto Decision", 80))

    return(ScrollCols)
end

local function BuildBasicHistoryData()
    local ScrollCols = {}
    table.insert(ScrollCols, CreateScrollCol("Name", 80, true))
    table.insert(ScrollCols, CreateScrollCol("Klasse", 100, true))
    table.insert(ScrollCols, CreateScrollCol("Antwort", 80))
    table.insert(ScrollCols, CreateScrollCol("Roll", 50))
    table.insert(ScrollCols, CreateScrollCol("Item", 120, true))
    table.insert(ScrollCols, CreateScrollCol("Instanz", 100))
    table.insert(ScrollCols, CreateScrollCol("Datum", 100, true))
    table.insert(ScrollCols, CreateScrollCol("Uhrzeit", 100, true))

    return(ScrollCols)
end

local function SetSessionInactive()
    IncendioLootDataHandler.SetSessionActiveInactive(false)
    IncendioLootLootVoting.CloseGUI()
    IncendioLootLootCouncilGUI.CloseGUI()
    IncendioLootDataHandler.WipeData()
    print("The Session has been closed")
end

local function trim(str)
    return str ~= nil and string.gsub(str, "^%s*(.-)%s*$", "%1") or nil
end

local function is_str_empty(str)
    return str == nil or trim(str) == ""
end

local function SetUpCommandHandler()
    IncendioLoot:RegisterChatCommand("il", function(msg)
        local args = {}
        if not is_str_empty(msg) then
            -- just select 3 args for now, should cover 99% of cases
            args = { AceConsole:GetArgs(msg, 1), AceConsole:GetArgs(msg, 2), AceConsole:GetArgs(msg, 3) }
        end

        local subCommand = #args > 0 and args[1] or nil
        if subCommand == nil or not CommandCallbacks[subCommand] then
            PrintChatCommands()
        else
            -- skip first arg (which is the subcommand)
            local cb_args = {}
            for i = 2, #args do
                cb_args[i-1] = args[i]
            end

            CommandCallbacks[subCommand].callback(cb_args)
        end
    end)

    IncendioLoot:RegisterSubCommand("help", PrintChatCommands, "Zeigt diese Befehls-Liste an.")
end

function IncendioLoot:OnEnable()
    IncendioLootDataHandler.BuildAndSetMLTable()
    IncendioLoot:RegisterComm(IncendioLoot.EVENTS.EVENT_VERSION_CHECK, HandleVersionCheckEvent)
    IncendioLoot:RegisterComm(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE,
    SetSessionInactive)
    IncendioLoot:RegisterEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
end

local function BuildBasics()
    IncendioLootDataHandler.BuildAndSetMLTable()
    IncendioLootDataHandler.InitScrollFrameCols(BuildBasicData())
    IncendioLootDataHandler.InitHistoryScrollFrameCols(BuildBasicHistoryData())
end

local function CheckOtherLootAddons()
    local _,_,_,Enabled = GetAddOnInfo("RCLootCouncil")
    if Enabled then 
        print("\124cffFF0000" ..IncendioLoot.STATICS.DOUBLE_USE_WARNING.. "\124r")
    end
end

function IncendioLoot:OnInitialize()
    local DefaultOptions = {
        profile = {
            options = {
                general = {
                    active = false,
                    debug = false,
                    autopass = false
                },
                masterlooters = {
                    ml1 = "",
                    ml2 = "",
                    ml3 = ""
                }
            }
        }
    }
    local DefaultDBOptions = {
        profile = {
            history = {
            }
        }
    }
    LibStub("AceComm-3.0"):Embed(IncendioLoot)
    self.ILOptions = LibStub("AceDB-3.0"):New("IncendioLootOptionsDB", DefaultOptions, true)
    self.ILHistory = LibStub("AceDB-3.0"):New("IncendioLootHistoryDB", DefaultDBOptions, true)
end

function IncendioLoot:OnEnable()
    RegisterCommsAndEvents()
    BuildBasics()
    CheckOtherLootAddons()
    IncendioLootDataHandler.InitScrollFrameCols(BuildBasicData())
    SetUpCommandHandler()
end
