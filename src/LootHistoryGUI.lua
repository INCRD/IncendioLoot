local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootHistoryGUI = IncendioLoot:NewModule("LootHistoryGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local HistoryTable
local HistoryOpen



local function GetDataRows()
    local i = 1
    local rows = {}
    for _, Players in pairs(IncendioLoot.ILHistory.profile.history) do
        for _, Content in ipairs(Players) do
            local cols = {
                { ["value"] = Content.PlayerName },
                { ["value"] = Content.Class },
                { ["value"] = Content.RollType },
                { ["value"] = Content.ItemLink },
                { ["value"] = Content.Instance },
                { ["value"] = Content.Date },
                { ["value"] = Content.Time }
            }
            rows[i] = { ["cols"] = cols }
            i = i + 1
        end
    end
    return(rows)
end

local function FilterLootHistory(filterText, columnName)
    local filteredData = {}
    local i = 1
    for PlayerName, Players in pairs(IncendioLoot.ILHistory.profile.history) do
        for _, Content in ipairs(Players) do
            if string.find(string.lower(Content[columnName]), string.lower(filterText)) then
                local cols = {
                    { ["value"] = PlayerName },
                    { ["value"] = Content.Class },
                    { ["value"] = Content.RollType },
                    { ["value"] = Content.Roll },
                    { ["value"] = Content.ItemLink },
                    { ["value"] = Content.Instance },
                    { ["value"] = Content.Date },
                    { ["value"] = Content.Time }
                }
                filteredData[i] = { ["cols"] = cols }
                i = i + 1
            end
        end
    end
    return filteredData
end

local function CreateDateFilterBox(HistoryMainFrame)
    local DateFilterBox = CreateFrame("EditBox", "ILDateFilterBox", HistoryMainFrame, "InputBoxTemplate")
    DateFilterBox:SetSize(100, 20)
    DateFilterBox:SetPoint("TOPLEFT", HistoryMainFrame, "TOPLEFT", 10, -50)
    DateFilterBox:SetAutoFocus(false)
    local DateFilterBoxTitle = HistoryMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DateFilterBoxTitle:SetPoint("BOTTOMLEFT", DateFilterBox, "TOPLEFT", 0, 5)
    DateFilterBoxTitle:SetText("Datum filtern:")
    DateFilterBox:SetScript("OnTextChanged", function(self)
        local filterText = DateFilterBox:GetText()
        HistoryTable:SetData(FilterLootHistory(filterText, "Date"))
    end)

    return DateFilterBox
end

local function CreateItemFilterBox(HistoryMainFrame, DateFilterBox)
    local ItemFilterBox = CreateFrame("EditBox", "ILItemFilterBox", HistoryMainFrame, "InputBoxTemplate")

    ItemFilterBox:SetSize(200, 20)
    ItemFilterBox:SetPoint("TOPLEFT", DateFilterBox, "TOPRIGHT", 10, 0)
    ItemFilterBox:SetAutoFocus(false)

    local ItemFilterBoxTitle = HistoryMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    ItemFilterBoxTitle:SetPoint("BOTTOMLEFT", ItemFilterBox, "TOPLEFT", 0, 5)
    ItemFilterBoxTitle:SetText("Gegenstand filtern:")
    ItemFilterBox:SetScript("OnTextChanged", function(self)
            local filterText = self:GetText()
            HistoryTable:SetData(FilterLootHistory(filterText, "ItemLink"))
        end)

    return ItemFilterBox
end

local function CreatePlayerFilterBox(HistoryMainFrame, ItemFilterBox)
    local PlayerFilterBox = CreateFrame("EditBox", "ILPlayerFilterBox", HistoryMainFrame, "InputBoxTemplate")

    PlayerFilterBox:SetSize(150, 20)
    PlayerFilterBox:SetPoint("TOPLEFT", ItemFilterBox, "TOPRIGHT", 10, 0)
    PlayerFilterBox:SetAutoFocus(false)

    local PlayerFilterBoxTitle = HistoryMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    PlayerFilterBoxTitle:SetPoint("BOTTOMLEFT", PlayerFilterBox, "TOPLEFT", 0, 5)
    PlayerFilterBoxTitle:SetText("Spieler filtern:")
    PlayerFilterBox:SetScript("OnTextChanged", function(self)
            local filterText = self:GetText()
            HistoryTable:SetData(FilterLootHistory(filterText, "PlayerName"))
        end)
end

local function CreateWindow()
    if HistoryOpen then
        return
    end

    local HistoryMainFrame = CreateFrame("Frame", "HistoryMainFrame", UIParent, "BackdropTemplate")

    HistoryMainFrame:SetSize(800, 400)
    HistoryMainFrame:SetPoint("CENTER")
    HistoryMainFrame:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    HistoryMainFrame:SetBackdropColor(0, 0, 0, 1)
    HistoryMainFrame:SetMovable(true)
    HistoryMainFrame:EnableMouse(true)
    HistoryMainFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    HistoryMainFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

    local TitleText = HistoryMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    TitleText:SetPoint("TOP", HistoryMainFrame, "TOP", 0, -10)
    TitleText:SetText("Historie")
    TitleText:SetJustifyH("CENTER")

    local CloseButton = CreateFrame("Button", "ILCloseButton", HistoryMainFrame, "UIPanelCloseButton")
    CloseButton:SetPoint("TOPRIGHT", HistoryMainFrame, "TOPRIGHT", -10, -10)
    CloseButton:SetScript("OnClick", function() 
        HistoryMainFrame:Hide()
        HistoryOpen = false
    end)
    CloseButton:SetText("Schließen")

    local ScrollFramehighlight = { 
        ["r"] = 1.0, 
        ["g"] = 0.9, 
        ["b"] = 0.0, 
        ["a"] = 0.5
    }
    HistoryTable = LootCouncilHistoryGUIST:CreateST(IncendioLootDataHandler.GetHistoryScrollFrameColls(), 13, 22, ScrollFramehighlight, HistoryMainFrame)
    HistoryTable.frame:SetPoint("CENTER", HistoryMainFrame, "CENTER", 0, -40)
    HistoryTable.frame:SetBackdropColor(0, 0, 0, 0)
    HistoryTable:SetData(GetDataRows())

    local DateFilterBox = CreateDateFilterBox(HistoryMainFrame)
    local ItemFilterBox = CreateItemFilterBox(HistoryMainFrame, DateFilterBox)
    CreatePlayerFilterBox(HistoryMainFrame, ItemFilterBox)

    HistoryMainFrame:Show()
    HistoryTable:Show()

    HistoryOpen = true
end

function LootHistoryGUI:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootHistoryGUI)
    LootCouncilHistoryGUIST = LibStub("ScrollingTable")
end

function LootHistoryGUI:OnEnable()
    IncendioLoot:RegisterSubCommand("history", CreateWindow, "Zeigt die Loothistorie an.")
end