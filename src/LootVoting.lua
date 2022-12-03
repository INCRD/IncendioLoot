local addonName, addon = ...
local IncendioLoot = _G[addonName]

local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false
local DebugMode = false
local ChildCount = 0
local rollStates = {
    {type = "BIS", name = "BIS"},
    {type = "UPGRADE", name = "Upgrade"},
    {type = "SECOND", name = "Secondspeck"},
    {type = "OTHER", name = "Anderes"},
    {type = "TRANSMOG", name = "Transmog"},
}

local function ResetMainFrameStatus()
    MainFrameInit = false
end

local function CreateRollButton(ItemGroup, rollState, ItemLink, LootVotingMainFrame)
    local button = LootVotingGUI:Create("Button")
    button:SetText(rollState.name)
    button:SetCallback("OnClick", function() 
        LootVoting:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, LootVoting:Serialize({ ItemLink = ItemLink, rollType = rollState.type }), IsInRaid() and "RAID" or "GUILD") 
        ChildCount = ChildCount - 1
        if (ChildCount == 0) then 
            LootVotingGUI:Release(LootVotingMainFrame)
            ResetMainFrameStatus()
        else
            ItemGroup.frame:Hide()
        end
    end)
    button:SetWidth(100)
    return button
end

local function HandleLooted(LootTable)
    if not UnitInRaid("player") and not DebugMode then 
        return
    end
    
    local LootAvailable = false
    for CheckCounter = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(CheckCounter) == Enum.LootSlotType.Item) then
            LootAvailable = true
        end
    end

    if not LootAvailable then 
        return
    end
    
    --Init frame
    local LootVotingMainFrame = LootVotingGUI:Create("Window")
    MainFrameInit = true

    LootVotingMainFrame:SetTitle("Incendio Loot - Wähl den Loot aus, mann")
    LootVotingMainFrame:EnableResize(false)

    for key, Item in pairs(LootTable) do
        local TexturePath = Item.TexturePath
        local ItemName = Item.ItemName
        local locked
        local ItemLink = Item.ItemLink

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
            GameTooltip:SetHyperlink(ItemLink);
            GameTooltip:Show();
        end);

        IconWidget1:SetCallback("OnLeave", function()
            GameTooltip:Hide();
        end);

        ChildCount = ChildCount + 1
        for _, rollState in pairs(rollStates) do
            ItemGroup:AddChild(CreateRollButton(ItemGroup, rollState, ItemLink, LootVotingMainFrame))
        end;
    end
    LootVotingMainFrame:SetLayout("ILVooting")
    LootVotingMainFrame:SetCallback("OnClose", ResetMainFrameStatus)
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

        FrameObject:SetBackdropBorderColor(0,0,1,1)
        FrameObject:SetBackdropColor(0,0,0,0)
        FrameObject:SetHeight(VotingFrameHeight)
    end
)

local function HandleLootVoteCastEvent()
    
end

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    local _, LootTable = LootVoting:Deserialize(str)
    HandleLooted(LootTable)
end

function LootVoting:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootVoting)
    LootVoting:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                            HandleLootLootedEvent)
end

--Events


--Only for Debugging
LootVoting:RegisterEvent("LOOT_OPENED", function ()
    if (DebugMode) then 
        LootVoting:HandleLooted()
    end
end )

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    --MasterLooter Giert
    RollOnLoot(rollID, nil)
end )

