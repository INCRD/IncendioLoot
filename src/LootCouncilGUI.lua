local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false;
local CurrentIndex
local MainFrameClose
local ItemFrameClose
local ButtonFrameCLose
local ScrollingFrame 

IncendioLootLootCouncilGUI = {}

local function ResetMainFrameStatus()
    MainFrameInit = false;
end

function IncendioLootLootCouncilGUI.CloseGUI()
    if (MainFrameClose == nil) then
        return
    end
    if MainFrameClose:IsShown() then
        LootCouncilAceGUI:Release(ButtonFrameCLose)
        LootCouncilAceGUI:Release(ItemFrameClose)
        LootCouncilAceGUI:Release(MainFrameClose)
        ResetMainFrameStatus()
    end
end

StaticPopupDialogs["IL_ENDSESSION"] = {
    text = "Möchten Sie die Sitzung beenden?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        IncendioLootLootCouncilGUI.CloseGUI()
        IncendioLootLootCouncil.SetSessionInactive()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function UpdateVoteData(Index, PlayerName, RollType, Ilvl)
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.rollType = tostring(RollType)
    PlayerInformation.iLvl = Ilvl
end

local function CreateScrollFrame(index)
    local hightlight = { 
        ["r"] = 1.0, 
        ["g"] = 0.9, 
        ["b"] = 0.0, 
        ["a"] = 0.5, -- important, you want to see your text!
    }
    IncendioLootLootCouncil.BuildScrollData(IncendioLootDataHandler.GetVoteData(), index)
    if (not ScrollingFrame == nil) then
        ScrollingFrame.frame:Hide()
        ScrollingFrame = {}
    end
    ScrollingFrame = LootCouncilGUIST:CreateST(IncendioLootDataHandler.GetScrollFrameColls(), _, 30, hightlight, MainFrameClose.frame)
    ScrollingFrame.frame:SetPoint("CENTER", MainFrameClose.frame, "CENTER", -150, -40)
    ScrollingFrame:SetData(IncendioLootDataHandler.GetScrollRows())
    print("done")
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
                    --IconWidget1:SetLabel(ItemName)
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
                        CreateScrollFrame(Item.Index)
                    end);
                    if isFirst then
                        CreateScrollFrame(Item.Index)
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
            StaticPopup_Show ("IL_ENDSESSION")
        end)

        CloseButtonFrame:AddChild(CloseButton)

        CreateItemFrame(ItemFrame)
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)
        MainFrameInit = true;
    end
end

local function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

local func

local function HandleLootVotePlayerEvent(prefix, str, distribution, sender)
    if not IncendioLootDataHandler.GetSessionActive() then 
        return
    end

    if not IncendioLootFunctions.CheckIfMasterLooter() then
        return
    end

    local _, LootVote = LootCouncilGUI:Deserialize(str)
    local NewItemLink = LootVote.ItemLink
    local NewRollType = LootVote.rollType
    local NewIndex = LootVote.Index
    local ILvl = round(LootVote.iLvl)

    --UpdateVoteData(NewIndex,sender,NewRollType, ILvl)
    CreateScrollFrame(NewIndex)
end

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    LootCouncilGUIST = LibStub("ScrollingTable")
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
    LootCouncilGUI:RegisterChatCommand("ILOpen", function ()
        IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    end)
end