local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false;
local LootTable = {}
local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
LootCouncilMainFrame.frame:Hide()
local ScrollContainer = CreateFrame("Frame","TableScrollFrame",LootCouncilMainFrame.frame,"BackdropTemplate")
ScrollContainer:Hide()
ScrollContainer.scrollFrame = CreateFrame("ScrollFrame",nil,ScrollContainer,"UIPanelScrollFrameTemplate")
ScrollContainer.scrollFrame.scrollChild = CreateFrame("Frame",nil,ScrollContainer.scrollFrame)
local content = ScrollContainer.scrollFrame.scrollChild
content.rows = {} -- each row of data is one wide button stored here
local VoteData = {}
local CurrentIndex
local SessionActive


local function ResetMainFrameStatus()
    MainFrameInit = false;
    SessionActive = false;
    for k in pairs (LootTable) do 
        LootTable[k] = nil
    end
    for k in pairs (VoteData) do 
        VoteData[k] = nil
    end

    print("ClosedFrame")

    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE,
        " ",
        IsInRaid() and "RAID" or "PARTY")
    end
end

local function CloseGUI(CloseButtonFrame, ItemFrame)
    CloseButtonFrame:Release()
    ItemFrame:Release()
    LootCouncilMainFrame.frame:Hide()
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


local function updateList(index)
    local PlayerTable = VoteData[index]
    local LoopCounter = 0;
    local InformationCounter = 0;
    for locPlayerName, locPlayerInformation  in pairs (PlayerTable) do
        LoopCounter = LoopCounter + 1
        InformationCounter = 0;
            if content.rows[LoopCounter] then 
                content.rows[LoopCounter]:Hide()
            end
            -- create a row if not created yet (buttons[i] is a whole row; buttons[i].columns[j] are columns)
            if not content.rows[LoopCounter] then
                local PlayerInformation = PlayerTable[locPlayerName]
                local button = CreateFrame("Button",nil,content)
                button:SetSize(500,40)
                button:SetPoint("TOPLEFT",0,-(LoopCounter-1)*20)
                button:SetScript("OnClick", function ()
                    SendChatMessage("Item "..PlayerInformation.itemLink.." wurde an "..PlayerInformation.name.." vergeben.", "RAID")
                end)
                button.columns = {} -- creating columns for the row
                for columnCounter=1,7 do
                    button.columns[columnCounter] = button:CreateFontString(nil,"ARTWORK","GameFontHighlight")
                    button.columns[columnCounter]:SetPoint("LEFT",(columnCounter-1)*100,0)
                end
                content.rows[LoopCounter] = button
            end
            -- now actually update the contents of the row
            for locPlayerInformationClass, PlayerInformationValue in pairs (locPlayerInformation) do
                local PlayerInformation = PlayerTable[locPlayerName]
                InformationCounter = InformationCounter + 1;
                if not (PlayerInformationValue == nil) and not (PlayerInformationValue == PlayerInformation.itemLink) then
                    content.rows[LoopCounter].columns[InformationCounter]:SetText(tostring(PlayerInformationValue))
                end
            end
            -- show the row that has data
            content.rows[LoopCounter]:Show()
    end
    -- hide all extra rows (if list shrunk, hiding leftover)
end

local function CreateScrollFrame(index)
    if not (CurrentIndex == index) then 
        return
    end
    ScrollContainer:SetSize(900,450)
    ScrollContainer:SetPoint("CENTER")
    ScrollContainer:Hide()
    ScrollContainer:SetMovable(false)
    ScrollContainer:SetBackdropColor(0, 0, 0, 1)

    ScrollContainer.scrollFrame:SetPoint("TOPLEFT",12,-32)
    ScrollContainer.scrollFrame:SetPoint("BOTTOMRIGHT",-34,8)

    -- creating a scrollChild to contain the content
    ScrollContainer.scrollFrame.scrollChild:SetSize(100,100)
    ScrollContainer.scrollFrame.scrollChild:SetPoint("TOPLEFT",5,-5)
    ScrollContainer.scrollFrame:SetScrollChild(ScrollContainer.scrollFrame.scrollChild)
    
    updateList(index)

    ScrollContainer.scrollFrame.scrollChild:Show()
    ScrollContainer:Show()
end

local function CreateItemFrame(ItemFrame)
    local IsFirst = true
    if not SessionActive then
        if UnitIsGroupLeader("player") then
            for index = 1, GetNumLootItems(), 1 do
                if (GetLootSlotType(index) == Enum.LootSlotType.Item) then
                    local TexturePath, ItemName, _, _, LootQuality = GetLootSlotInfo(index)
                    local ItemLink = GetLootSlotLink(index)
                    local Item = {}
                    Item["TexturePath"] = TexturePath
                    Item["ItemName"] = ItemName
                    Item["ItemLink"] = ItemLink
                    Item["Index"] = index
                    Item["LootQuality"] = LootQuality
                    table.insert(LootTable, Item)  
                    LootTable["ML1"] = IncendioLoot.ILOptions.profile.options.masterlooters.ml1
                    LootTable["ML2"] = IncendioLoot.ILOptions.profile.options.masterlooters.ml2
                    LootTable["ML3"] = IncendioLoot.ILOptions.profile.options.masterlooters.ml3
                end
            end
        end

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
                            CreateScrollFrame(Item.Index)
                        end);
                        VoteData[Item.Index] = {}
                        if IsFirst then
                            IsFirst = false
                            CurrentIndex = Item.Index
                        end
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
        CreateScrollFrame(CurrentIndex)
    end
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

local function CheckIfViableLootAvailable()
    for index = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(index) == Enum.LootSlotType.Item) then
            local _, _, _, _, LootQuality = GetLootSlotInfo(index)
            if (LootQuality >= 3) then
                return true
            end
        end
    end
end

local function HandleLootLootedEvent()
    if UnitIsGroupLeader("player") then 
        if not CheckIfViableLootAvailable() then
            return
        end
    end

    if not MainFrameInit then 
        LootCouncilMainFrame.frame:Show()
        LootCouncilMainFrame:SetTitle("Incendio Lootcouncil")
        LootCouncilMainFrame:SetStatusText("")
        LootCouncilMainFrame:SetLayout("Fill")
        LootCouncilMainFrame:EnableResize(false)

        local ItemFrame = LootCouncilAceGUI:Create("InlineGroup")
        ItemFrame:SetTitle("Items")
        ItemFrame:SetLayout("Flow")

        local CloseButtonFrame = LootCouncilAceGUI:Create("InlineGroup")
        CloseButtonFrame:SetTitle("")
        CloseButtonFrame:SetLayout("Fill")

        local CloseButton = LootCouncilAceGUI:Create("Button")
        CloseButton:SetText("Close")
        CloseButton:SetCallback("OnClick", function ()
            CloseGUI(CloseButtonFrame, ItemFrame)
        end)

        CloseButtonFrame:AddChild(CloseButton)

        CreateItemFrame(ItemFrame)
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)
        LootCouncilMainFrame.frame:Show()

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
    CreateScrollFrame(NewIndex)
end

local function CouncilAnnouncedHandler(prefix, str, distribution, sender)
    local _, NewLootTable = LootCouncilGUI:Deserialize(str)
    local PlayerName = UnitName("player")
    local CanSee = UnitIsGroupLeader("player") or NewLootTable["ML1"] == PlayerName or 
        NewLootTable["ML2"] == PlayerName or NewLootTable["ML3"] == PlayerName

        print(PlayerName)
    print(NewLootTable["ML2"])
    if UnitIsGroupLeader("player") then 
        return
    end

    if CanSee and not MainFrameInit then 
        LootTable = NewLootTable
        HandleLootLootedEvent()
    end
end

LootCouncilGUI:RegisterEvent("LOOT_OPENED", function ()
    if UnitIsGroupLeader("player") then
       HandleLootLootedEvent()
    end
end )

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)   
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_COUNCIL,
                            CouncilAnnouncedHandler)
end