local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local L = addon.L

local MainFrameInit = false;
local Collapsed = false;
local CurrentIndex
local MainFrameClose
local ItemFrameClose
local ButtonFrameCLose
local MainFrameCollapsedClose
local ButtonFrameCollapsedClose
local ScrollingFrame 
local ScrollingFrameSet
local SelectedPlayerName
local IconChilds = {}

IncendioLootLootCouncilGUI = {}

local function ResetMainFrameStatus()
    MainFrameInit = false;
end

local function CloseCollapsed()
    if not Collapsed then 
        return
    end

    LootCouncilAceGUI:Release(ButtonFrameCollapsedClose)
    LootCouncilAceGUI:Release(MainFrameCollapsedClose)
    Collapsed = false
    IncendioLootLootCouncilGUI.HandleLootLootedEvent()
end

local function CloseGUIManual()
    if (MainFrameClose == nil) then
        return
    end
    if not MainFrameInit then 
        return
    end
    if ScrollingFrameSet then
        ScrollingFrame:Hide()
        ScrollingFrameSet = false
    end
    LootCouncilAceGUI:Release(ButtonFrameCLose)
    LootCouncilAceGUI:Release(ItemFrameClose)
    LootCouncilAceGUI:Release(MainFrameClose)
    ResetMainFrameStatus()
    IconChilds = {}
end

function IncendioLootLootCouncilGUI.CloseGUI()
    if (MainFrameClose == nil) then
        return
    end
    if ScrollingFrameSet then
        ScrollingFrame:Hide()
        ScrollingFrameSet = false
    end
    if MainFrameClose:IsShown() then
        ResetMainFrameStatus()
        LootCouncilAceGUI:Release(ButtonFrameCLose)
        LootCouncilAceGUI:Release(ItemFrameClose)
        LootCouncilAceGUI:Release(MainFrameClose)
    end
    IconChilds = {}
end

local function CollapseFrame()
    if not Collapsed then
        IncendioLootLootCouncilGUI.CloseGUI()
        local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
        LootCouncilMainFrame:SetTitle("Incendio Lootcouncil")
        LootCouncilMainFrame:SetStatusText("")
        LootCouncilMainFrame:SetLayout("Fill")
        LootCouncilMainFrame:EnableResize(false)
        MainFrameCollapsedClose = LootCouncilMainFrame
        LootCouncilMainFrame.frame:SetWidth(1000)
        LootCouncilMainFrame.frame:SetHeight(50)

        local CloseButtonFrame = LootCouncilAceGUI:Create("InlineGroup")
        CloseButtonFrame:SetTitle("")
        CloseButtonFrame:SetLayout("Flow")
        ButtonFrameCollapsedClose = CloseButtonFrame

        local CollapseExpandButton = LootCouncilAceGUI:Create("Button")
        CollapseExpandButton:SetText("Collapse / Expand")
        CollapseExpandButton:SetCallback("OnClick", function ()
            CloseCollapsed()
        end)
        CloseButtonFrame:AddChild(CollapseExpandButton)
        CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-55)
        CloseButtonFrame.frame:SetWidth(150)
        CloseButtonFrame.frame:SetHeight(60)
        CloseButtonFrame.frame:Show()

        Collapsed = true
    end
end


StaticPopupDialogs["IL_ENDSESSION"] = {
    text = L["END_SESSION"],
    button1 = L["YES"],
    button2 = L["NO"],
    OnAccept = function(self)
        IncendioLootLootCouncilGUI.CloseGUI()
        IncendioLootLootCouncil.SetSessionInactive()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["IL_ASSIGNITEM"] = {
    text = L["ASSIGN_ITEM"],
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data, data2)
        if not UnitIsGroupLeader("player") then
            print("Dies darf nur der Masterlooter tun!")
            return
        end

        if data2 == nil then
            return
        end

        local LootTable = IncendioLootDataHandler.GetLootTable()
        for i, value in pairs(LootTable) do
            if (value["Index"] == data) then 
                if value["Assigend"] == true then
                    print(L["ITEM_ALREADY_ASSIGNED"])
                    return
                else
                    value["Assigend"] = true
                    SendChatMessage(string.format(L["COUNCIL_ASSIGNED_ITEM"], value.ItemLink, data2), "RAID")
                end
            end
        end
        IncendioLootLootCouncil.PrepareAndAddItemToHistory(data, data2)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function IncendioLootLootCouncil.SetItemAssignedIcon(Index)
    for i, value in pairs(IconChilds) do
        if value.Index == Index then
            value.IconWidget:SetImage(LootCouncilShareMedia:Fetch("texture", "Green Checkmark"))
            value.Assigend = true
        end
    end

end

local function ScrollFrameMenu(button)
    if button == "RightButton" then
        local menuList = {
            {text = "Zuweisen", func = function() 
                    local ILAssignDialog = StaticPopup_Show("IL_ASSIGNITEM")
                    ILAssignDialog.data = CurrentIndex
                    ILAssignDialog.data2 = SelectedPlayerName 
                end},
            {text = "Vote", func = function() IncendioLootLootCouncil.UpdateCouncilVoteData(CurrentIndex, SelectedPlayerName) end}
          }
        local menu = CreateFrame("Frame", "ILScrollFrameMenu", UIParent, "UIDropDownMenuTemplate")
        EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
    end
  end
  

function IncendioLootLootCouncilGUI.CreateScrollFrame(index)
    if not MainFrameInit then
        return
    end
    if CurrentIndex ~= index then 
        return
    end
    if ScrollingFrameSet then
        ScrollingFrame:Hide()
        ScrollingFrameSet = false
    end

    local hightlight = { 
        ["r"] = 1.0, 
        ["g"] = 0.9, 
        ["b"] = 0.0, 
        ["a"] = 0.5
    }

    IncendioLootLootCouncil.BuildScrollData(IncendioLootDataHandler.GetVoteData(), index)
    ScrollingFrame = LootCouncilGUIST:CreateST(IncendioLootDataHandler.GetScrollFrameColls(), 13, 30, hightlight, MainFrameClose.frame)
    ScrollingFrame:EnableSelection(ScrollingFrame, true)
    ScrollingFrame.frame:SetPoint("CENTER", MainFrameClose.frame, "CENTER", -115, -40)
    ScrollingFrame:SetData(IncendioLootDataHandler.GetScrollRows())
    ScrollingFrameSet = true

    ScrollingFrame:RegisterEvents({
        ["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button)
            if realrow == nil then 
                return
            end
            local celldata = data[realrow].cols[1]
            SelectedPlayerName = celldata["value"]
            ScrollFrameMenu(button)
        end,
    });
end

local function CreateItemFrame(ItemFrame)
    local isFirst = true
    local LootTable = IncendioLootDataHandler.GetLootTable()
    for Loot, Item in pairs(LootTable) do
        if type(Item) == "table" then
            if (Item.LootQuality >= 3 ) then
                local IconWidget1 = LootCouncilAceGUI:Create("Icon")
                IconWidget1:SetLabel(Item.ItemName)
                IconWidget1:SetImageSize(40,40)
                IconWidget1:SetImage(LootCouncilShareMedia:Fetch("texture", "Red Cross"))
                ItemFrame:AddChild(IconWidget1)
                local IconChild = {Index = Item.Index, IconWidget = IconWidget1, Texture = Item.TexturePath, Assigend = false}
                table.insert(IconChilds,IconChild)

                IconWidget1:SetCallback("OnEnter", function()
                    GameTooltip:SetOwner(IconWidget1.frame, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetHyperlink(Item.ItemLink)
                    GameTooltip:Show()
                end);
                IconWidget1:SetCallback("OnLeave", function()
                    GameTooltip:Hide();
                end);
                IconWidget1:SetCallback("OnClick", function()
                    for i, value in pairs(IconChilds) do
                        if not value.Assigend then
                            value.IconWidget:SetImage(LootCouncilShareMedia:Fetch("texture", "Red Cross"))
                        else
                            value.IconWidget:SetImage(LootCouncilShareMedia:Fetch("texture", "Green Checkmark"))
                        end
                    end
                    IconWidget1:SetImage(Item.TexturePath)
                    CurrentIndex = Item.Index
                    IncendioLootLootCouncilGUI.CreateScrollFrame(Item.Index)
                end);
                if isFirst then
                    CurrentIndex = Item.Index
                    IncendioLootLootCouncilGUI.CreateScrollFrame(Item.Index)
                    IconWidget1:SetImage(Item.TexturePath)
                    isFirst = false
                end
            end
        end
    end
end

local function PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame, ScrollingFrame)
    ItemFrame.frame:SetPoint("TOPLEFT",LootCouncilMainFrame.frame,"TOPLEFT",-150,10)
    ItemFrame.frame:SetWidth(150)
    ItemFrame.frame:SetHeight(LootCouncilMainFrame.frame:GetHeight()- 50)
    ItemFrame.frame:Show()

    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-75)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()
end

function IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    if not (IncendioLootDataHandler.GetSessionActive()) or MainFrameInit then
        print(L["COUNCIL_FRAME_CHECK"])
        return
    end

    ScrollingFrame = nil
    local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
    LootCouncilMainFrame:SetTitle("Incendio Lootcouncil")
    LootCouncilMainFrame:SetStatusText("")
    LootCouncilMainFrame:SetLayout("Fill")
    LootCouncilMainFrame:EnableResize(false)
    MainFrameClose = LootCouncilMainFrame
    MainFrameInit = true;

    local ItemFrame = LootCouncilAceGUI:Create("InlineGroup")
    ItemFrame:SetTitle("Items")
    ItemFrame:SetLayout("Flow")
    ItemFrameClose = ItemFrame

    local CloseButtonFrame = LootCouncilAceGUI:Create("InlineGroup")
    CloseButtonFrame:SetTitle("")
    CloseButtonFrame:SetLayout("Flow")
    ButtonFrameCLose = CloseButtonFrame

    local CloseButton = LootCouncilAceGUI:Create("Button")
    CloseButton:SetText("Close")
    CloseButton:SetCallback("OnClick", function ()
        if UnitIsGroupLeader("player") then
            StaticPopup_Show("IL_ENDSESSION")
        else
            IncendioLootLootCouncilGUI.CloseGUI()
        end
    end)
    CloseButtonFrame:AddChild(CloseButton)

    local CollapseExpandButton = LootCouncilAceGUI:Create("Button")
    CollapseExpandButton:SetText("Collapse / Expand")
    CollapseExpandButton:SetCallback("OnClick", function ()
        CollapseFrame()
    end)
    CloseButtonFrame:AddChild(CollapseExpandButton)

    CreateItemFrame(ItemFrame)
    PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)

    LootCouncilMainFrame.frame:SetWidth(1000)

    LootCouncilMainFrame:SetCallback("OnClose", CloseGUIManual)
end

function LootCouncilGUI:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    LootCouncilGUIST = LibStub("ScrollingTable")
    LootCouncilShareMedia = LibStub("LibSharedMedia-3.0")
    LootCouncilShareMedia:Register("texture", "Green Checkmark", "Interface/AddOns/IncendioLoot/media/greencheckmark.blp")
    LootCouncilShareMedia:Register("texture", "Red Cross", "Interface/AddOns/IncendioLoot/media/redcross.blp")
end

function LootCouncilGUI:OnEnable()
    IncendioLoot:RegisterSubCommand("council", IncendioLootLootCouncilGUI.HandleLootLootedEvent, L["COMMAND_COUNCIL"])
end