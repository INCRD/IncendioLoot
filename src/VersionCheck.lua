local addonName, addon = ...
local IncendioLoot = _G[addonName]
local VersionCheck = IncendioLoot:NewModule("VersionCheck", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local AceConsole = LibStub("AceConsole-3.0")
local ScrollingTable = LibStub("ScrollingTable")

local E = IncendioLoot.EVENTS
local L = IncendioLoot.L

local C = IncendioLoot.COLORS
local O -- options, init in :OnEnable
local V = IncendioLoot.Version
local I
local D
--    19

local ReceivedOutOfDateMessage = false
local VersionTable = {} -- { [ player={ version=string, isActive=bool } ] }

local FrameHolder


--[[
    returns true if v1str is less than v2str
    assumes number are in SEMVER (x.y.z) format

    e.g.:
        0.8.3, 0.9.0 -> true
        0.8.3, 0.8.3 -> false
        0.8.3, 0.3.0 -> false
        0.3, 0.9.3 -> false
        0.3, nil -> nil
]]--
local function VersionCompare(v1str, v2str)
    if not v1str or not v2str then return end

	local major1, minor1, patch1 = string.split(".", v1str)
	local major2, minor2, patch2 = string.split(".", v2str)
    
    if patch1 == nil or patch2 == nil then return false end

	if major1 ~= major2 then
		return tonumber(major1) < tonumber(major2)
	elseif minor1 ~= minor2 then
		return tonumber(minor1) < tonumber(minor2)
	else
		return tonumber(patch1) < tonumber(patch2)
	end
end

local function CreateScrollingTable()
    if FrameHolder ~= nil then
        FrameHolder.st:SetData({})
        FrameHolder:Hide()
    else
        FrameHolder = CreateFrame("Frame", "VersionCheckFrameHolder", UIParent, "BackdropTemplate")
        FrameHolder:SetSize(290, 400)
        FrameHolder:SetPoint("CENTER")
        FrameHolder:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            --edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 32,
            --edgeSize = 16,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
          })
        FrameHolder:SetBackdropColor(0, 0, 0, 0.25)
        FrameHolder:SetMovable(true)
        FrameHolder:EnableMouse(true)
        FrameHolder:RegisterForDrag("LeftButton")
        FrameHolder:SetScript("OnDragStart", function(self) self:StartMoving() end)
        FrameHolder:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        FrameHolder:SetFrameStrata("FULLSCREEN_DIALOG")
        tinsert(UISpecialFrames, "VersionCheckFrameHolder")        

        FrameHolder.st = ScrollingTable:CreateST({
            {
                ["name"] = L["VCHK_NAME"],
                ["width"] = 120
            },
            {
                ["name"] = L["VCHK_VERSION"],
                ["width"] = 50,
                ["align"] = "CENTER"
            },
            {
                ["name"] = L["VCHK_ACTIVE"],
                ["width"] = 50,
                ["align"] = "CENTER"
            }
        }, 15, 20, nil, FrameHolder)
    end

    local numRows = GetNumGroupMembers()

    local data = {}

    for memberIdx = 1, numRows, 1 do 
        local name = select(1, GetRaidRosterInfo(memberIdx))
        local row = {
            ["cols"] = {
                { ["value"] = name },
                { ["value"] = function() 
                    local lookup = VersionTable[name]
                    local memberVersion = lookup ~= nil and lookup.version or "?"
                    local hasValidVersion = memberVersion ~= nil and memberVersion ~= "?"
                    local hasOldVersion = VersionCompare(memberVersion, V)
                    local color = hasValidVersion and (hasOldVersion and C.ORANGE or C.GREEN) or C.GREY
                    return WrapTextInColorCode(memberVersion, color)
                end },
                { ["value"] = function()
                    local lookup = VersionTable[name]
                    return (lookup and (lookup.isActive and "+")) or (lookup ~= nil and "-" or "?")
                end }
            }
        }
        
        table.insert(data, row)
    end

    FrameHolder.st:SetData(data)
    FrameHolder.st.frame:SetPoint("TOP", FrameHolder, "TOP", 0, -50)
    FrameHolder:Show()
end

local function InsertVersion(player, version, isActive)
    VersionTable[player] = { version = version, isActive = isActive }
end


local function HandleVersionCheckCommand()
    if not IsInRaid() then
        return
    end

    VersionTable = {}
    VersionCheck:SendCommMessage(E.EVENT_VERSION_REQUEST, "r!!", IsInRaid() and "RAID" or "GROUP", nil, "BULK")
    InsertVersion(UnitName("player"), V, O.general.active)
    CreateScrollingTable()
end

local function HandleVersionCompareEvent(_, str, _, sender)
    if sender == UnitName("player") then
        return 
    end

    if (str and VersionCompare(V, str) and not ReceivedOutOfDateMessage) then
        AceConsole:Print(string.format(L["OUT_OF_DATE_ADDON"], str))
        ReceivedOutOfDateMessage = true
    end
end

local function HandleVersionRequestEvent(_, data, _, sender)
    if UnitName("player") == sender then return end

    local filteredData = data:match("^s!!") and data:gsub("^s!!", "") or nil
    if filteredData ~= nil then
        local ver, isActive = string.split("|", filteredData)
        InsertVersion(sender, ver, isActive)

        if FrameHolder and FrameHolder.st then
            FrameHolder.st:Refresh()
        end
    else
        -- respond to request
        VersionCheck:SendCommMessage(E.EVENT_VERSION_REQUEST, 
            "s!!"..V.."|"..(O.general.active and "1" or "0"), 
            "WHISPER", sender)
    end
end

function VersionCheck:OnEnable()
    O = IncendioLoot.ILOptions.profile.options
    VersionCheck:RegisterComm(E.EVENT_VERSION_COMPARE, HandleVersionCompareEvent)
    VersionCheck:RegisterComm(E.EVENT_VERSION_REQUEST, HandleVersionRequestEvent)
    IncendioLoot:RegisterSubCommand("vchk", HandleVersionCheckCommand, L["COMMAND_VERSION_CHECK"])
end
