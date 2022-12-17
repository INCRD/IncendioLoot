local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false;
local VoteData = {}
local CurrentIndex
local MainFrameClose
local ItemFrameClose
local ButtonFrameCLose
IncendioLootLootCouncilGUI = {}

local function ResetMainFrameStatus()
    MainFrameInit = false;
    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE,
        " ",
        IsInRaid() and "RAID" or "PARTY")
    end
end

local function CloseGUI()
    LootCouncilAceGUI:Release(ButtonFrameCLose)
    LootCouncilAceGUI:Release(ItemFrameClose)
    LootCouncilAceGUI:Release(MainFrameClose)
end

StaticPopupDialogs["ENDSESSION"] = {
    text = "Möchten Sie die Sitzung beenden?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        CloseGUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function UpdateVoteData(Index, PlayerName, RollType, Ilvl)
    local PlayerTable = VoteData[Index]
    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.rollType = tostring(RollType)
    PlayerInformation.iLvl = Ilvl
end

local function CreateScrollFrame(index)
   
end

local function CreateItemFrame(ItemFrame)
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
                        --TODO
                    end);
                end
            end
        end
    end
    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_COUNCIL,
        LootCouncilGUI:Serialize(IncendioLootDataHandler.GetLootTable()),
        IsInRaid() and "RAID" or "PARTY")
    end
    --CreateScrollFrame(CurrentIndex)
end

local function PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame, TestTable2)
    ItemFrame.frame:SetPoint("TOPLEFT",LootCouncilMainFrame.frame,"TOPLEFT",-150,10)
    ItemFrame.frame:SetWidth(150)
    ItemFrame.frame:SetHeight(LootCouncilMainFrame.frame:GetHeight()- 50)
    ItemFrame.frame:Show()

    TestTable2.frame:SetPoint("CENTER", LootCouncilMainFrame.frame, "CENTER", -150, -40)

    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-45)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()
end

function IncendioLootLootCouncilGUI.HandleLootLootedEvent()
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
            CloseGUI()
        end)

        CloseButtonFrame:AddChild(CloseButton)

        CreateItemFrame(ItemFrame)
        local TestTable2 = ScrollingTableTest:CreateST(IncendioLootDataHandler.GetScrollFrameColls(), _, 30, _, LootCouncilMainFrame.frame)
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame, TestTable2)
        

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
    if not SessionActive then 
        return
    end

    local _, LootVote = LootCouncilGUI:Deserialize(str)
    local NewItemLink = LootVote.ItemLink
    local NewRollType = LootVote.rollType
    local NewIndex = LootVote.Index
    local ILvl = round(LootVote.iLvl)

    UpdateVoteData(NewIndex,sender,NewRollType, ILvl)
    --CreateScrollFrame(NewIndex)
end

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    ScrollingTableTest = LibStub("ScrollingTable")

    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)

    LootCouncilGUI:RegisterChatCommand("ILOpen", function ()
        IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    end)
end