local addonName, addon = ...
local IncendioLoot = _G[addonName]
local Equippable
local LootTable = {}
local SessionActive 
local FrameOpen
local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local ChildCount = 0
local rollStates = {
    {type = "BIS", name = "BIS"},
    {type = "UPGRADE", name = "Upgrade"},
    {type = "SECOND", name = "Secondspeck"},
    {type = "OTHER", name = "Anderes"},
    {type = "TRANSMOG", name = "Transmog"},
}
local MainFrameClose
local ButtonFrameCLose

local function CreateRollButton(ItemGroup, rollState, ItemLink, LootVotingMainFrame, Index, CloseButtonFrame)
    local button = LootVotingGUI:Create("Button")
    button:SetText(rollState.name)
    button:SetCallback("OnClick", function() 
        _, AverageItemLevel = GetAverageItemLevel()
        LootVoting:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, LootVoting:Serialize({ ItemLink = ItemLink, rollType = rollState.type, Index = Index, iLvl = AverageItemLevel }), IsInRaid() and "RAID" or "PARTY") 
        ChildCount = ChildCount - 1
        if (ChildCount == 0) then 
            LootVotingGUI:Release(LootVotingMainFrame)
            CloseButtonFrame:Release()
            for k in pairs (LootTable) do 
                LootTable[k] = nil
            end
            SessionActive = false
        else
            ItemGroup.frame:Hide()
        end
    end)
    button:SetWidth(100)
    return button
end

local function CloseGUI()
    LootVotingGUI:Release(MainFrameClose)
    LootVotingGUI:Release(ButtonFrameCLose)
    FrameOpen = false
end

local function HandleLooted()
    if not UnitInRaid("player") and not DebugMode then 
        return
    end
    if (LootTable == nil) or FrameOpen then
        return
    end

    local LootVotingMainFrame = LootVotingGUI:Create("Window")
    LootVotingMainFrame:SetTitle("Incendio Loot - Wähl den Loot aus, mann")
    LootVotingMainFrame:EnableResize(false)
    MainFrameClose = LootVotingMainFrame

    local CloseButtonFrame = LootVotingGUI:Create("InlineGroup")
    CloseButtonFrame:SetTitle("")
    CloseButtonFrame:SetLayout("Fill")
    ButtonFrameCLose = CloseButtonFrame

    local CloseButton = LootVotingGUI:Create("Button")
    CloseButton:SetText("Close")
    CloseButton:SetCallback("OnClick", function ()
        CloseGUI()
    end)
    CloseButtonFrame:AddChild(CloseButton)
    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootVotingMainFrame.frame,"BOTTOMRIGHT",0,-45)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()


    for key, Item in pairs(LootTable) do
        if type(Item) == "table" then
            local TexturePath = Item.TexturePath
            local ItemName = Item.ItemName
            local locked
            local ItemLink = Item.ItemLink
            local Index = Item.Index

            if IsEquippableItem(ItemLink) then 

                local ItemGroup = LootVotingGUI:Create("InlineGroup")
                ItemGroup:SetLayout("Flow") 
                ItemGroup:SetFullWidth(true)
                ItemGroup:SetHeight(70)
                LootVotingMainFrame:AddChild(ItemGroup)

                local IconWidget1 = LootVotingGUI:Create("InteractiveLabel")
                IconWidget1:SetWidth(100)
                IconWidget1:SetHeight(40)
                IconWidget1:SetImageSize(40,40)
                IconWidget1:SetImage(TexturePath)
                IconWidget1:SetText(ItemName)
                ItemGroup:AddChild(IconWidget1)

                IconWidget1:SetCallback("OnEnter", function()
                    GameTooltip:SetOwner(IconWidget1.frame, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetHyperlink(ItemLink)
                    GameTooltip:Show()
                end)
                IconWidget1:SetCallback("OnLeave", function()
                    GameTooltip:Hide();
                end)
                if not SessionActive then
                    ChildCount = ChildCount + 1
                end
                for _, rollState in pairs(rollStates) do
                    ItemGroup:AddChild(CreateRollButton(ItemGroup, rollState, ItemLink, LootVotingMainFrame, Index, CloseButtonFrame))
                end
            end
        end
    end
    LootVotingMainFrame:SetLayout("ILVooting")
    SessionActive = true
    LootVotingMainFrame.frame:Show()
    FrameOpen = true
end

LootVotingGUI:RegisterLayout("ILVooting", 
    function(content, children)
        local VotingFrameHeight = 170

        FrameContent = content["obj"] 
        FrameObject = FrameContent["frame"]
        for i = 1, #children do
            if (i > 1) then
                VotingFrameHeight = VotingFrameHeight + 140
            end
        end

        FrameObject:SetHeight(VotingFrameHeight)
    end
)

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    if SessionActive then
        return
    end
    
    local _, NewLootTable = LootVoting:Deserialize(str)
    LootTable = NewLootTable
    HandleLooted()
end

local function SetSessionInactive()
    SessionActive = false
    FrameOpen = false
end

function LootVoting:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootVoting)
    LootVoting:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                            HandleLootLootedEvent)
    LootVoting:RegisterComm(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE,
                            SetSessionInactive)
    LootVoting:RegisterChatCommand("ILShow", function ()
        if not SessionActive or FrameOpen then
            return
        end
        HandleLooted()
    end)
end

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    local DoAutopass = IncendioLoot.ILOptions.profile.options.general.autopass or
        not UnitIsGroupLeader("player") or 
        IncendioLootDataHandler.GetAddonActive()
    
    if not DoAutopass then
        return
    end

    local pendingLootRolls = GetActiveLootRollIDs()
    for i=1, #pendingLootRolls do
        if not (pendingLootRolls == nil) then
            RollOnLoot(pendingLootRolls[i], 0)
        end
    end
end )