local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootHistoryGUI = IncendioLoot:NewModule("LootHistoryGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local HistoryTable
local HistoryOpen

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

local function CreateWindow()
    if HistoryOpen then
        return
    end

    local myAddonFrame = CreateFrame("Frame", "MyAddonFrame", UIParent, "BackdropTemplate")
    local rows = {}
    local playerName = UnitName("player")
    local i = 1

    myAddonFrame:SetSize(800, 400)
    myAddonFrame:SetPoint("CENTER")
    myAddonFrame:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    myAddonFrame:SetBackdropColor(0, 0, 0, 1)
    myAddonFrame:SetMovable(true)
    myAddonFrame:EnableMouse(true)
    myAddonFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    myAddonFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

      local hightlight = { 
        ["r"] = 1.0, 
        ["g"] = 0.9, 
        ["b"] = 0.0, 
        ["a"] = 0.5
    }

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
    HistoryTable = LootCouncilHistoryGUIST:CreateST(IncendioLootDataHandler.GetHistoryScrollFrameColls(), 13, 22, hightlight, myAddonFrame)
    HistoryTable.frame:SetPoint("CENTER", myAddonFrame, "CENTER", 0, -40)
    HistoryTable.frame:SetBackdropColor(0, 0, 0, 0)
    HistoryTable:SetData(rows)

    local dateFilterBox = CreateFrame("EditBox", "MyAddonDateFilterBox", myAddonFrame, "InputBoxTemplate")
    dateFilterBox:SetSize(100, 20)
    dateFilterBox:SetPoint("TOPLEFT", myAddonFrame, "TOPLEFT", 10, -50)
    dateFilterBox:SetAutoFocus(false)
    local dateFilterBoxTitle = myAddonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dateFilterBoxTitle:SetPoint("BOTTOMLEFT", dateFilterBox, "TOPLEFT", 0, 5)
    dateFilterBoxTitle:SetText("Datum filtern:")
    dateFilterBox:SetScript("OnTextChanged", function(self)
        local filterText = dateFilterBox:GetText()
        HistoryTable:SetData(FilterLootHistory(filterText, "Date"))
      end)

    local itemFilterBox = CreateFrame("EditBox", "MyAddonItemFilterBox", myAddonFrame, "InputBoxTemplate")
    itemFilterBox:SetSize(200, 20)
    itemFilterBox:SetPoint("TOPLEFT", dateFilterBox, "TOPRIGHT", 10, 0)
    itemFilterBox:SetAutoFocus(false)
    local itemFilterBoxTitle = myAddonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemFilterBoxTitle:SetPoint("BOTTOMLEFT", itemFilterBox, "TOPLEFT", 0, 5)
    itemFilterBoxTitle:SetText("Gegenstand filtern:")
    itemFilterBox:SetScript("OnTextChanged", function(self)
        local filterText = self:GetText()
        HistoryTable:SetData(FilterLootHistory(filterText, "ItemLink"))
      end)

    local playerFilterBox = CreateFrame("EditBox", "MyAddonPlayerFilterBox", myAddonFrame, "InputBoxTemplate")
    playerFilterBox:SetSize(150, 20)
    playerFilterBox:SetPoint("TOPLEFT", itemFilterBox, "TOPRIGHT", 10, 0)
    playerFilterBox:SetAutoFocus(false)
    local playerFilterBoxTitle = myAddonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFilterBoxTitle:SetPoint("BOTTOMLEFT", playerFilterBox, "TOPLEFT", 0, 5)
    playerFilterBoxTitle:SetText("Spieler filtern:")
    playerFilterBox:SetScript("OnTextChanged", function(self)
        local filterText = self:GetText()
        HistoryTable:SetData(FilterLootHistory(filterText, "PlayerName"))
      end)

    local titleText = myAddonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOP", myAddonFrame, "TOP", 0, -10)
    titleText:SetText("Historie")
    titleText:SetJustifyH("CENTER")

    local closeButton = CreateFrame("Button", "MyAddonCloseButton", myAddonFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", myAddonFrame, "TOPRIGHT", -10, -10)
    closeButton:SetScript("OnClick", function() 
        myAddonFrame:Hide()
        HistoryOpen = false
    end)
    closeButton:SetText("Schließen")

    myAddonFrame:Show()
    HistoryTable:Show()

    HistoryOpen = true
end

SLASH_ILOPENHISTORY1 = "/ilopenhistory"
SlashCmdList["ILOPENHISTORY"] = function()
    CreateWindow()
end

function LootHistoryGUI:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootHistoryGUI)
    LootCouncilHistoryGUIST = LibStub("ScrollingTable")
end