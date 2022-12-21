local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false;
local CurrentIndex
local MainFrameClose
local ItemFrameClose
local ButtonFrameCLose
local CouncilButtonFrameClose
local ScrollingFrame 
local ScrollingFrameSet
local SelectedPlayerName

IncendioLootLootCouncilGUI = {}

local function ResetMainFrameStatus()
    MainFrameInit = false;
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
        LootCouncilAceGUI:Release(ButtonFrameCLose)
        LootCouncilAceGUI:Release(ItemFrameClose)
        LootCouncilAceGUI:Release(CouncilButtonFrameClose)
        LootCouncilAceGUI:Release(MainFrameClose)
        ResetMainFrameStatus()
    end
end

StaticPopupDialogs["IL_ENDSESSION"] = {
    text = IncendioLoot.STATICS.END_SESSION,
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self)
        IncendioLootLootCouncilGUI.CloseGUI()
        IncendioLootLootCouncil.SetSessionInactive()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["IL_ASSIGNITEM"] = {
    text = IncendioLoot.STATICS.ASSIGN_ITEM,
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data, data2)
        IncendioLootLootCouncil.PrepareAndAddItemToHistory(data, data2)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function IncendioLootLootCouncilGUI.CreateScrollFrame(index)
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
    CurrentIndex = index

    ScrollingFrame:RegisterEvents({
        ["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
            if realrow == nil then 
                return
            end
            local celldata = data[realrow].cols[1]
            SelectedPlayerName = celldata["value"]
        end,
    });
end

local function CreateItemFrame(ItemFrame)
    local isFirst = true
    local LootTable = IncendioLootDataHandler.GetLootTable()
    for Loot, Item in pairs(LootTable) do
        if type(Item) == "table" then
            if IsEquippableItem(Item.ItemLink) then
                if (Item.LootQuality >= 3 ) then
                    local IconWidget1 = LootCouncilAceGUI:Create("Icon")
                    IconWidget1:SetLabel(Item.ItemName)
                    IconWidget1:SetImageSize(40,40)
                    IconWidget1:SetImage(Item.TexturePath)
                    ItemFrame:AddChild(IconWidget1)

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
                        IncendioLootLootCouncilGUI.CreateScrollFrame(Item.Index)
                    end);
                    if isFirst then
                        IncendioLootLootCouncilGUI.CreateScrollFrame(Item.Index)
                        CurrentIndex = Item.Index
                        isFirst = false
                    end
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

    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-45)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()
end

function IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    ScrollingFrame = nil
    if not (IncendioLootDataHandler.GetSessionActive()) then
        print("No Active Session")
        return
    end
    if not MainFrameInit then 
        local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
        LootCouncilMainFrame:SetTitle("Incendio Lootcouncil")
        LootCouncilMainFrame:SetStatusText("")
        LootCouncilMainFrame:SetLayout("Fill")
        LootCouncilMainFrame:EnableResize(false)
        MainFrameClose = LootCouncilMainFrame

        local ItemFrame = LootCouncilAceGUI:Create("InlineGroup")
        ItemFrame:SetTitle("Items")
        ItemFrame:SetLayout("Flow")
        ItemFrameClose = ItemFrame

        local CloseButtonFrame = LootCouncilAceGUI:Create("InlineGroup")
        CloseButtonFrame:SetTitle("")
        CloseButtonFrame:SetLayout("Fill")
        ButtonFrameCLose = CloseButtonFrame

        local CloseButton = LootCouncilAceGUI:Create("Button")
        CloseButton:SetText("Close")
        CloseButton:SetCallback("OnClick", function ()
            StaticPopup_Show("IL_ENDSESSION")
        end)

        CloseButtonFrame:AddChild(CloseButton)

        local CouncilButtonFrame = LootCouncilAceGUI:Create("InlineGroup")
        CouncilButtonFrame:SetTitle("")
        CouncilButtonFrame:SetLayout("Flow")
        CouncilButtonFrameClose = CouncilButtonFrame
    
        local VoteButton = LootCouncilAceGUI:Create("Button")
        VoteButton:SetText("Vote")
        VoteButton:SetCallback("OnClick", function ()
            IncendioLootLootCouncil.UpdateCouncilVoteData(CurrentIndex, SelectedPlayerName)
        end)

        local AssignItemButton = LootCouncilAceGUI:Create("Button")
        AssignItemButton:SetText("Assign")
        AssignItemButton:SetCallback("OnClick", function ()
            local ILAssignDialog = StaticPopup_Show("IL_ASSIGNITEM")
            ILAssignDialog.data = CurrentIndex
            ILAssignDialog.data2 = SelectedPlayerName
        end)

        
        CouncilButtonFrame:AddChild(VoteButton)
        CouncilButtonFrame:AddChild(AssignItemButton)
    
        CouncilButtonFrame.frame:SetPoint("CENTER",MainFrameClose.frame,"CENTER",578,225)
        CouncilButtonFrame.frame:SetWidth(150)
        CouncilButtonFrame.frame:SetHeight(60)
        CouncilButtonFrame.frame:Show()

        CreateItemFrame(ItemFrame)
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)
        MainFrameInit = true;
    end
end

function LootCouncilGUI:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    LootCouncilGUIST = LibStub("ScrollingTable")
end

function LootCouncilGUI:OnEnable()
    LootCouncilGUI:RegisterChatCommand("ILOpen", IncendioLootLootCouncilGUI.HandleLootLootedEvent)
end