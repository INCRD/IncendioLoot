local addonName, addon = ...
local IncendioLoot = _G[addonName]
local SessionStartGUI = IncendioLoot:NewModule("SessionStartGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local L = addon.L
local LastPosition = {point = "CENTER", relativeTo = UIParent, relativeToPoint = "CENTER", x = 0, y = 0}
local FrameOpened = false

-- Funktion zur Erzeugung des Fensters
function CreateLootWindow()
    if FrameOpened then 
        return
    end

    local LootTable = IncendioLootDataHandler.GetLootTable()
    local LineHeight = 25
    local Scale = 1.1
    local TotalHeight = #LootTable * LineHeight * Scale + (80 * Scale)

    local SessionWindow = CreateFrame("Frame", "LootWindow", UIParent, "BackdropTemplate")
    SessionWindow:SetPoint(LastPosition.point, LastPosition.relativeTo, LastPosition.relativeToPoint, LastPosition.x, LastPosition.y)
    SessionWindow:SetSize(400 * Scale, TotalHeight)
    SessionWindow:SetMovable(true)
    SessionWindow:SetScale(Scale)
    SessionWindow:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
          left = 11,
          right = 12,
          top = 12,
          bottom = 11
        }
      })

    local titleBar = CreateFrame("Frame", nil, SessionWindow, "BackdropTemplate")
    titleBar:SetScale(Scale)
    titleBar:SetPoint("TOPLEFT", 0, 15)
    titleBar:SetPoint("TOPRIGHT", 0, 15)
    titleBar:SetHeight(20)
    titleBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 11,
            right = 12,
            top = 12,
            bottom = 11
            }
        }
    )
    titleBar:SetBackdropColor(0, 0, 0, 0.7)
    titleBar:SetBackdropBorderColor(1, 1, 1, 0.7)
    titleBar:EnableMouse(true)
    titleBar:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        SessionWindow:StartMoving()
      end
    end)
    titleBar:SetScript("OnMouseUp", function(self, button)
        SessionWindow:StopMovingOrSizing()
    end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", titleBar, "CENTER")
    title:SetText(L["TITLE_SESSION_WINDOW"])

    -- Checkboxen und Namen für jedes Item
    for i = 1, #LootTable do
        local Line = CreateFrame("Frame", nil, SessionWindow)
        Line:SetPoint("TOPLEFT", 10, -(i * LineHeight))
        Line:SetPoint("TOPRIGHT", -10, -(i * LineHeight))
        Line:SetHeight(20)
        Line:SetScale(Scale)
        
        local Checkbox = CreateFrame("CheckButton", "LootCheckbox" .. i, Line, "UICheckButtonTemplate")
        Checkbox:SetPoint("TOPLEFT", 0, 0)
        Checkbox:SetHeight(20)
        Checkbox:SetWidth(20)
        Checkbox:SetChecked(true)
        Checkbox:SetScript("OnClick", function(self)
            LootTable[i].IsChecked = self:GetChecked()
        end)
        Checkbox:SetScale(Scale)
       
        local NameFrame = CreateFrame("Frame", nil, Line)
        NameFrame:SetSize(80, 20)
        NameFrame:SetPoint("LEFT", Checkbox, "RIGHT", 10, 0)
        NameFrame:SetScale(Scale)

        local Name = NameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Name:SetPoint("LEFT", NameFrame, "LEFT")
        Name:SetText(LootTable[i].ItemLink)
        Name:SetScale(Scale)

        NameFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(Name, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetHyperlink(LootTable[i].ItemLink)
            GameTooltip:Show()
        end);
        NameFrame:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end

    -- OK-Button
    local OKButton = CreateFrame("Button", "LootOKButton", SessionWindow, "UIPanelButtonTemplate")
    OKButton:SetPoint("BOTTOM", SessionWindow, "BOTTOM", -70, 15)
    OKButton:SetSize(100, 25)
    OKButton:SetText(L["OK"])
    OKButton:SetScript("OnClick", function()
    -- Informationen über den Zustand der Checkboxen abrufen
            local j = 1
            for Index, Value in pairs(LootTable) do
                if (Value.IsChecked) then
                    -- Move i's kept value to j's position, if it's not already there.
                    if (Index ~= j) then
                        LootTable[j] = LootTable[Index];
                        LootTable[Index] = nil;
                    end
                    j = j + 1; -- Increment position of where we'll place the next kept value.
                    Value.IsChecked = nil
                else
                    LootTable[Index] = nil;
                end
            end
            IncendioLootDataHandler.SetLootTable(LootTable)
            SessionWindow:Hide()
            SessionWindow = nil
            IncendioLootLootCouncil.BuildDataFromSession()
        end
    )
    OKButton:SetScale(Scale)

    local CancelButton = CreateFrame("Button", nil, SessionWindow, "UIPanelButtonTemplate")
    CancelButton:SetPoint("BOTTOM", SessionWindow, "BOTTOM", 70, 15)
    CancelButton:SetSize(100, 25)
    CancelButton:SetText(L["Cancel"])
    CancelButton:SetScript("OnClick", function()
        SessionWindow:Hide()
        SessionWindow = nil
    end)

    CancelButton:SetScale(Scale)

    SessionWindow:SetScript("OnHide", function ()
        LastPosition.point, LastPosition.relativeTo, LastPosition.relativeToPoint, LastPosition.x, LastPosition.y = SessionWindow:GetPoint()
        FrameOpened = false
    end)

    FrameOpened = true
    IncendioLootLootCouncil.AnnounceMLs()
end

local function BuildLootTable()
    for ItemIndex = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(ItemIndex) == Enum.LootSlotType.Item) then
            local TexturePath, ItemName, _, _, LootQuality = GetLootSlotInfo(ItemIndex)
            if (LootQuality >= 3) then
                local ItemLink = GetLootSlotLink(ItemIndex)
                local Item = {}
                Item["TexturePath"] = TexturePath
                Item["ItemName"] = ItemName
                Item["ItemLink"] = ItemLink
                Item["Index"] = ItemIndex
                Item["LootQuality"] = LootQuality
                Item["Assigned"] = false
                Item["IsChecked"] = 3
                IncendioLootDataHandler.AddItemToLootTable(Item)
            end
        end
    end
    return(true)
end

local function BuildDataFromEvent()
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end

    --Session must be inactive
    if IncendioLootDataHandler.GetSessionActive() then
        return
    end

    --We don't want to use IL in LFG
    local LfgDungeonID = select(10, GetInstanceInfo())

    if LfgDungeonID ~= nil then
        return
    end

    --We use InstanceID for now, to determine of we should start the council
    local InstanceID = select(8, GetInstanceInfo())

    if UnitIsGroupLeader("player") and IncendioLootDataHandler.GetRaidIDs()[InstanceID] ~= nil then
        IncendioLootDataHandler.WipeData()
        BuildLootTable()
        if #IncendioLootDataHandler.GetLootTable() > 0 then
            CreateLootWindow()
        end
    end
end

function SessionStartGUI:OnEnable()
    SessionStartGUI:RegisterEvent("LOOT_OPENED", BuildDataFromEvent)
end