local addonName, addon = ...
local IncendioLoot = _G[addonName]

local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false
local DebugMode = false
local InRaid = UnitInRaid("player")

local function ResetMainFrameStatus()
    MainFrameInit = false
end

function LootVoting:HandleLooted()
    if not InRaid and not DebugMode then 
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

            local BISButton = LootVotingGUI:Create("Button")
            BISButton:SetText("BIS")
            BISButton:SetCallback("OnClick", function() LootVoting:SendMessage("IL_BIS", ItemLink) end)
            BISButton:SetWidth(100)
            ItemGroup:AddChild(BISButton)

            local UpgradeButton = LootVotingGUI:Create("Button")
            UpgradeButton:SetText("Upgrade")
            UpgradeButton:SetCallback("OnClick", function() LootVoting:SendMessage("IL_UPG", ItemLink) end)
            UpgradeButton:SetWidth(100)
            ItemGroup:AddChild(UpgradeButton)

            local SecondSpeckButton = LootVotingGUI:Create("Button")
            SecondSpeckButton:SetText("Secondspeck")
            SecondSpeckButton:SetCallback("OnClick", function() LootVoting:SendMessage("IL_SND", ItemLink) end)
            SecondSpeckButton:SetWidth(100)
            ItemGroup:AddChild(SecondSpeckButton)

            local AndereButton = LootVotingGUI:Create("Button")
            AndereButton:SetText("Anderes")
            AndereButton:SetCallback("OnClick", function() LootVoting:SendMessage("IL_OTH", ItemLink) end)
            AndereButton:SetWidth(100)
            ItemGroup:AddChild(AndereButton)

            local TransmogButton = LootVotingGUI:Create("Button")
            TransmogButton:SetText("Transmog")
            TransmogButton:SetCallback("OnClick", function() LootVoting:SendMessage("IL_MOG", ItemLink) end)
            TransmogButton:SetWidth(100)
            ItemGroup:AddChild(TransmogButton)
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