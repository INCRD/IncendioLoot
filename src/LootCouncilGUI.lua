local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false;
local VoteData = {}
local CurrentIndex
local SessionActive
local MainFrameClose
local ItemFrameClose
local ButtonFrameCLose

local function ResetMainFrameStatus()
    MainFrameInit = false;
    SessionActive = false;
    for k in pairs (LootTable) do 
        LootTable[k] = nil
    end
    for k in pairs (VoteData) do 
        VoteData[k] = nil
    end

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

local function BuildVoteData()
    for index, VoteDataValue in pairs(VoteData) do
        local ItemLink = GetLootSlotLink(index)
        PlayerTable = VoteData[index]
        for member = 1, GetNumGroupMembers(), 1 do 
            local name, _, _, _, class, _, zone , online = GetRaidRosterInfo(member)
            PlayerInformation = {class = class, zone = zone, online = online, rollType = "Kein Vote", iLvl = " ", name = name, itemLink = ItemLink}
            PlayerTable[name] = PlayerInformation
        end
    end
end

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
                        CurrentIndex = Item.Index
                        --CreateScrollFrame(Item.Index)
                    end);
                end
            end
        end
    end
    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_COUNCIL,
        LootCouncilGUI:Serialize(LootTable),
        IsInRaid() and "RAID" or "PARTY")
    end
    BuildVoteData()
    --CreateScrollFrame(CurrentIndex)
end

local function PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)
    ItemFrame.frame:SetPoint("TOPLEFT",LootCouncilMainFrame.frame,"TOPLEFT",-150,10)
    ItemFrame.frame:SetWidth(150)
    ItemFrame.frame:SetHeight(LootCouncilMainFrame.frame:GetHeight()- 50)
    ItemFrame.frame:Show()

    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-45)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()
end

local function HandleLootLootedEvent()
    print("Nöl")

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
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)

        local ColumnA= {
            ["name"] = "Column A",
            ["width"] = 200,
            ["align"] = "RIGHT",
            ["defaultsort"] = "dsc",
            ["sortnext"]= 4,
            ["comparesort"] = function (cella, cellb, column)
                return cella.value < cellb.value;
            end,
            ["DoCellUpdate"] = nil,
        }
        local ColumnB= {
            ["name"] = "Column B",
            ["width"] = 200,
            ["align"] = "RIGHT",
            ["defaultsort"] = "dsc",
            ["sortnext"]= 4,
            ["comparesort"] = function (cella, cellb, column)
                return cella.value < cellb.value;
            end,
            ["DoCellUpdate"] = nil,
        }
        local ColumnC= {
            ["name"] = "Column C",
            ["width"] = 200,
            ["align"] = "RIGHT",
            ["defaultsort"] = "dsc",
            ["sortnext"]= 4,
            ["comparesort"] = function (cella, cellb, column)
                return cella.value < cellb.value;
            end,
            ["DoCellUpdate"] = nil,
        }
        local ColumnD= {
            ["name"] = "Column D",
            ["width"] = 200,
            ["align"] = "RIGHT",
            ["defaultsort"] = "dsc",
            ["sortnext"]= 4,
            ["comparesort"] = function (cella, cellb, column)
                return cella.value < cellb.value;
            end,
            ["DoCellUpdate"] = nil,
        }
        local ka = {}
        table.insert(ka, ColumnA)
        table.insert(ka, ColumnB)
        table.insert(ka, ColumnC)
        table.insert(ka, ColumnD)
        
        local TestTable2 = ScrollingTableTest:CreateST(ka, _, 30, _, LootCouncilMainFrame.frame)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)

        if UnitIsGroupLeader("player") then
            IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
            LootCouncilGUI:Serialize(LootTable),
            IsInRaid() and "RAID" or "PARTY")
        end
        SessionActive = true
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

local function CouncilAnnouncedHandler(prefix, str, distribution, sender)
    local _, NewLootTable = LootCouncilGUI:Deserialize(str)
    local PlayerName = UnitName("player")
    local CanSee = UnitIsGroupLeader("player") or NewLootTable["ML1"] == PlayerName or 
        NewLootTable["ML2"] == PlayerName or NewLootTable["ML3"] == PlayerName
    if UnitIsGroupLeader("player") then 
        return
    end

    if CanSee and not MainFrameInit then 
        LootTable = NewLootTable
        HandleLootLootedEvent()
    end
end

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    ScrollingTableTest = LibStub("ScrollingTable")

    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_COUNCIL,
                            CouncilAnnouncedHandler)
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED,
                            HandleLootLootedEvent)
end