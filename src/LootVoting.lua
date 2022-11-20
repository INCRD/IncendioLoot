local addonName, addon = ...
local IncendioLoot = _G[addonName]

local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false
local DebugMode = false
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

local function CreateRollButton(rollState)
    local button = LootVotingGUI:Create("Button")
    button:SetText(rollState.name)
    button:SetCallback("OnClick", function() LootVoting:SendMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, { ItemLink = ItemLink, rollType = rollState.type }) end)
    button:SetWidth(100)
    return button
end

function LootVoting:HandleLooted()
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
    local LootVotingMainFrame = LootVotingGUI:Create("Frame")
    MainFrameInit = true

    LootVotingMainFrame:SetTitle("Incendio Loot")
    LootVotingMainFrame:SetStatusText("Wähl den Loot aus, mann")

    for counter = 1, GetNumLootItems(), 1 do
        local TexturePath
        local ItemName
        local locked
        local ItemLink
        

        if (GetLootSlotType(counter) == Enum.LootSlotType.Item) then

            TexturePath, ItemName = GetLootSlotInfo(counter)
            ItemLink = GetLootSlotLink(counter)

            local ItemGroup = LootVotingGUI:Create("InlineGroup")
            ItemGroup:SetLayout("Flow") 
            ItemGroup:SetFullWidth(true)
            ItemGroup:SetHeight(70)
            LootVotingMainFrame:AddChild(ItemGroup)

            local IconWidget1 = LootVotingGUI:Create("Icon")
            IconWidget1:SetWidth(100)
            IconWidget1:SetHeight(40)
            IconWidget1:SetImageSize(40,40)
            IconWidget1:SetImage(TexturePath)
            IconWidget1:SetLabel(ItemName)
            ItemGroup:AddChild(IconWidget1)

            IconWidget1:SetCallback("OnEnter", function()
                GameTooltip:SetHyperlink(ItemLink);
                GameTooltip:Show();
            end);

            for _, rollState in pairs(rollStates) do
                ItemGroup:AddChild(CreateRollButton(rollState))
            end
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

        FrameObject:SetBackdropBorderColor(0,0,0,0)
        FrameObject:SetBackdropColor(0,0,0,0)
        FrameObject:SetHeight(VotingFrameHeight)
    end
)

function LootVoting:OnEnable()
    --LootVotingMainFrame:Hide()
end

--Events

--Only for Debugging
LootVoting:RegisterEvent("LOOT_OPENED", function ()
    if (DebugMode) then 
        LootVoting:HandleLooted()
    end
end )

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    RollOnLoot(rollID, nil)
end )