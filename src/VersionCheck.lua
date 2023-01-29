local addonName, addon = ...
local IncendioLoot = _G[addonName]
local VersionCheck = IncendioLoot:NewModule("VersionCheck", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local AceConsole = LibStub("AceConsole-3.0")
local ScrollingTable = LibStub("ScrollingTable")

local E = IncendioLoot.EVENTS
local L = IncendioLoot.L
local C = IncendioLoot.COLORS
local _V = IncendioLoot.Version

local ReceivedOutOfDateMessage = false
local VersionTable = {} -- { [ player=version ] }

local ScrollingTableHolder

local function CreateScrollingTable()
    if ScrollingTableHolder then
        ScrollingTableHolder:Hide()
    end

    local numRows = select("#", GetNumGroupMembers())

    ScrollingTableHolder = ScrollingTable:CreateST(cols, numRows, 20)

    local data = {}

    local ver = tonumber(_V)
    for memberIdx = 1, numRows, 1 do 
        local name = select(1, GetRaidRosterInfo(memberIdx))
        table.insert(data, {
            ["cols"] = {
                { ["value"] = name },
                { ["value"] = function() 
                    local memberVersion = VersionTable[name] or "nil"
                    local hasValidVersion = memberVersion ~= nil and type(memberVersion) ~= "string"
                    local color = hasValidVersion and C.GREEN or ((memberVersion ~= nil and memberVersion < ver) and C.ORANGE or C.GREY)
                    return WrapTextInColorCode(memberVersion, C.ORANGE) 
                end }
            }
        })
    end

    ScrollingTableHolder:SetData(data)
    ScrollingTableHolder:SortData()
    ScrollingTableHolder:Show()
end


local function HandleVersionCheckCommand()
    if not IsInRaid() then
        return
    end

    VersionCheck:SendCommMessage(E.EVENT_VERSION_REQUEST, "r!!", IsInRaid() and "RAID" or "GROUP", nil, "BULK")
    CreateScrollingTable()
end

local function HandleVersionCheckEvent(_, str, _, sender)
    if (sender == UnitName("player")) then
        return 
    end

    local ver, msg = tonumber(IncendioLoot.Version), tonumber(str)
    if (msg and ver < msg and not ReceivedOutOfDateMessage) then
        AceConsole:Print(string.format(L["OUT_OF_DATE_ADDON"], msg))
        ReceivedOutOfDateMessage = true
    end

    VersionTable[sender] = ver
end

local function HandleVersionRequestEvent(_, data, _, sender)
    if sender == UnitName("player") or data:match("^s!!") then
        -- either we're ourselves, so we don't need to answer, or we got an answer to our request
        VersionCheck[sender] = data
        if ScrollingTableHolder then
            ScrollingTableHolder:SortData()
        end
    else
        -- respond to request
        VersionCheck:SendCommMessage(E.EVENT_VERSION_REQUEST, "s!!".._V, "WHISPER", sender)
    end
end

function VersionCheck:OnEnable()
    VersionCheck:RegisterComm(E.EVENT_VERSION_CHECK, HandleVersionCheckEvent)
    VersionCheck:RegisterComm(E.EVENT_VERSION_REQUEST, HandleVersionRequestEvent)
    IncendioLoot:RegisterSubCommand("vchk", HandleVersionCheckCommand, L["COMMAND_VERSION_CHECK"])
end