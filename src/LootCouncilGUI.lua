local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")

local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local MainFrameInit = false;
local LootTable = {}
local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
LootCouncilMainFrame.frame:Hide()
local ScrollContainer = CreateFrame("Frame","SimpleScrollFrameTableDemo",LootCouncilMainFrame.frame,"BackdropTemplate")
ScrollContainer:Hide()
ScrollContainer.scrollFrame = CreateFrame("ScrollFrame",nil,ScrollContainer,"UIPanelScrollFrameTemplate")
ScrollContainer.scrollFrame.scrollChild = CreateFrame("Frame",nil,ScrollContainer.scrollFrame)
local content = ScrollContainer.scrollFrame.scrollChild
content.rows = {} -- each row of data is one wide button stored here
local VoteData = {}

local function ResetMainFrameStatus()
    MainFrameInit = false;
end

local function updateList()
    for i=1,#VoteData do
        if content.rows[i] then 
           content.rows[i]:Hide()
        end
        -- create a row if not created yet (buttons[i] is a whole row; buttons[i].columns[j] are columns)
        if not content.rows[i] then
            local button = CreateFrame("Button",nil,content)
            button:SetSize(900,40)
            button:SetPoint("TOPLEFT",0,-(i-1)*20)
            button.columns = {} -- creating columns for the row
            for j=1,5 do
                if (i == 1) then
                button.columns[j] = button:CreateFontString(nil,"ARTWORK","GameFontGreen")
                else
                button.columns[j] = button:CreateFontString(nil,"ARTWORK","GameFontHighlight")
                end
                button.columns[j]:SetPoint("LEFT",(j-1)*100,0)
            end
            content.rows[i] = button
        end
        -- now actually update the contents of the row
        for j=1,5 do
            if not (VoteData[i][j] == nil) then
                content.rows[i].columns[j]:SetText(tostring(VoteData[i][j]))
            end
        end
        -- show the row that has data
        content.rows[i]:Show()
    end
    -- hide all extra rows (if list shrunk, hiding leftover)
    for i=#VoteData+1,#content.rows do
        content.rows[i]:Hide()
    end
end

local function CreateScrollFrame(Update, UpdateData)
    ScrollContainer:SetSize(900,450)
    ScrollContainer:SetPoint("CENTER")
    ScrollContainer:Hide()
    ScrollContainer:SetMovable(false)
    ScrollContainer:SetScript("OnMouseDown",ScrollContainer.StartMoving)
    ScrollContainer:SetScript("OnMouseUp",ScrollContainer.StopMovingOrSizing)
    ScrollContainer:SetBackdropColor(0, 0, 0, 1)

    ScrollContainer.scrollFrame:SetPoint("TOPLEFT",12,-32)
    ScrollContainer.scrollFrame:SetPoint("BOTTOMRIGHT",-34,8)

    -- creating a scrollChild to contain the content
    ScrollContainer.scrollFrame.scrollChild:SetSize(100,100)
    ScrollContainer.scrollFrame.scrollChild:SetPoint("TOPLEFT",5,-5)
    ScrollContainer.scrollFrame:SetScrollChild(ScrollContainer.scrollFrame.scrollChild)
     
    updateList()

    ScrollContainer.scrollFrame.scrollChild:Show()
    ScrollContainer:Show()
end

local function CreateItemFrame(ItemFrame)
    for counter = 1, GetNumLootItems(), 1 do

        if (GetLootSlotType(counter) == Enum.LootSlotType.Item) then
            local TexturePath
            local ItemName
            local locked
            local ItemLink
            local Item = {}
            local TestData  = {}
            table.insert(TestData, {"1", "2", "3", "4"})

            TexturePath, ItemName = GetLootSlotInfo(counter)
            ItemLink = GetLootSlotLink(counter)

            local IconWidget1 = LootCouncilAceGUI:Create("Icon")
            IconWidget1:SetLabel(ItemName)
            IconWidget1:SetImageSize(40,40)
            IconWidget1:SetImage(TexturePath)
            --IconWidget1:SetLabel(ItemName)
            ItemFrame:AddChild(IconWidget1)

            IconWidget1:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(IconWidget1.frame, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:SetHyperlink(ItemLink)
                GameTooltip:Show()
            end);
            IconWidget1:SetCallback("OnLeave", function()
                GameTooltip:Hide();
            end);
            IconWidget1:SetCallback("OnClick", function()
                CreateScrollFrame(true, TestData);
            end);
            Item["TexturePath"] = TexturePath
            Item["ItemName"] = ItemName
            Item["ItemLink"] = ItemLink
            table.insert(LootTable, Item)  
        end
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

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    if not MainFrameInit then 
        table.insert(VoteData, {"PlayerName", "PlayerClase", "Online" ,"Zone", "Vote"})

        for member = 1, GetNumGroupMembers(), 1 do 
            local name, _, _, _, class, _, zone , online = GetRaidRosterInfo(member)
            table.insert(VoteData, {name, class, online, zone, "No Vote"})
        end
        
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
            CloseButtonFrame:Release()
            ItemFrame:Release()
            LootCouncilAceGUI:Release(LootCouncilMainFrame)
        end)

        CloseButtonFrame:AddChild(CloseButton)

        CreateItemFrame(ItemFrame)
        PositionFrames(LootCouncilMainFrame, ItemFrame, CloseButtonFrame )
        CreateScrollFrame(false)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)

        --IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
        --LootCouncilGUI:Serialize(LootTable),
        --IsInRaid() and "RAID" or "PARTY")
    end
end

local function HandleLootVotePlayerEvent(prefix, str, distribution, sender)
    local _, LootVote = LootCouncilGUI:Deserialize(str)
    local Data = {}
    for member = 1, GetNumGroupMembers(), 1 do 
        local name, _, _, _, class, _, _ , _, online = GetRaidRosterInfo(member)
        if (sender== name) then
        table.insert(Data, {name, class, online, tostring(LootVote.rollType)})
        else
        table.insert(Data, {name, class, online})
        end
    end
    CreateScrollFrame(true, Data)
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
end