local addonName, addon = ...
local IncendioLoot = _G[addonName]
local Equippable
local FrameOpen
local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local ChildCount = 0
local rollStates = {
    {type = "BIS", name = "BIS"},
    {type = "UPGRADE", name = "Upgrade"},
    {type = "SECOND", name = "Secondspeck"},
    {type = "OTHER", name = "Anderes"},
    {type = "TRANSMOG", name = "Transmog"}
}
local VotingMainFrameClose
local VotingButtonFrameCLose
IncendioLootLootVoting = {}

local function CreateRollButton(ItemGroup, rollState, ItemLink, Index)
    local button = LootVotingGUI:Create("Button")
    button:SetText(rollState.name)
    button:SetCallback("OnClick", function() 
        local _, AverageItemLevel = GetAverageItemLevel()
        LootVoting:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, LootVoting:Serialize({ ItemLink = ItemLink, rollType = rollState.type, Index = Index, iLvl = AverageItemLevel }), IsInRaid() and "RAID" or "PARTY") 
        ChildCount = ChildCount - 1
        if (ChildCount == 0) then 
            IncendioLootLootVoting.CloseGUI()
        else
            ItemGroup.frame:Hide()
        end
    end)
    button:SetWidth(100)
    return button
end

function IncendioLootLootVoting.CloseGUI()
    if (VotingMainFrameClose == nil) then 
        return
    end
    if VotingMainFrameClose:IsShown() then
        LootVotingGUI:Release(VotingMainFrameClose)
        LootVotingGUI:Release(VotingButtonFrameCLose)
        FrameOpen = false
    end
end

local function HandleLooted()
    ChildCount = 0

    if (not UnitInRaid("player") or not UnitInParty("player")) and not IncendioLoot.ILOptions.profile.options.general.debug then 
        return
    end
    if (not IncendioLootDataHandler.GetSessionActive()) or FrameOpen then
        return
    end

    local LootVotingMainFrame = LootVotingGUI:Create("Window")
    LootVotingMainFrame:SetTitle("Incendio Loot - Wir brauchen Meersälze!")
    LootVotingMainFrame:EnableResize(false)
    VotingMainFrameClose = LootVotingMainFrame

    local CloseButtonFrame = LootVotingGUI:Create("InlineGroup")
    CloseButtonFrame:SetTitle("")
    CloseButtonFrame:SetLayout("Fill")
    VotingButtonFrameCLose = CloseButtonFrame

    local CloseButton = LootVotingGUI:Create("Button")
    CloseButton:SetText("Close")
    CloseButton:SetCallback("OnClick", function ()
        IncendioLootLootVoting.CloseGUI()
    end)
    CloseButtonFrame:AddChild(CloseButton)
    CloseButtonFrame.frame:SetPoint("BOTTOMRIGHT",LootVotingMainFrame.frame,"BOTTOMRIGHT",0,-45)
    CloseButtonFrame.frame:SetWidth(150)
    CloseButtonFrame.frame:SetHeight(60)
    CloseButtonFrame.frame:Show()


    for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
        if type(Item) == "table" then
            local TexturePath = Item.TexturePath
            local ItemName = Item.ItemName
            local ItemLink = Item.ItemLink
            local Index = Item.Index

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
            ChildCount = ChildCount + 1
            for _, rollState in pairs(rollStates) do
                ItemGroup:AddChild(CreateRollButton(ItemGroup, rollState, ItemLink, Index, CloseButtonFrame))
            end
        end
    end
    LootVotingMainFrame:SetLayout("ILVooting")
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
    local SetData = (not UnitIsGroupLeader("player") or 
        not IncendioLootFunctions.CheckIfMasterLooter()) and
        not IncendioLootDataHandler.GetSessionActive()

    if SetData then
        local _, LootTable = LootVoting:Deserialize(str)
        IncendioLootDataHandler.WipeData()
        IncendioLootDataHandler.SetLootTable(LootTable)
        IncendioLootDataHandler.SetSessionActiveInactive(true)
        if IncendioLoot.ILOptions.profile.options.general.debug then 
            print("Data Set for Voting")
        end
    end
    
    HandleLooted()
end

function LootVoting:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootVoting)
    LootVoting:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                            HandleLootLootedEvent)

    LootVoting:RegisterChatCommand("ILShow", function ()
        if not IncendioLootDataHandler.GetSessionActive() or FrameOpen then
            return
        end
        HandleLooted()
    end)
end

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    local DoAutopass = (IncendioLoot.ILOptions.profile.options.general.autopass and
        not UnitIsGroupLeader("player"))
        
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