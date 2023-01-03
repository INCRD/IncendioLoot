local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local L = addon.L

local FrameOpen
local ChildCount = 0

local lootTypes = { "BIS", "UPGRADE", "SECOND", "OTHER", "TRANSMOG", "PASS" }
local rollStates = {}
local lootTypeColor = {
    ["BIS"] = IncendioLoot.COLORS.GREEN,
    ["UPGRADE"] = IncendioLoot.COLORS.ORANGE,
    ["SECOND"] = IncendioLoot.COLORS.BLUE,
    ["OTHER"] = IncendioLoot.COLORS.YELLOW,
    ["TRANSMOG"] = IncendioLoot.COLORS.PURPLE,
    ["PASS"] = IncendioLoot.COLORS.GREY
}
for _, type in ipairs(lootTypes) do
    table.insert(rollStates, {type = type, name = WrapTextInColorCode(L["VOTE_STATE_"..type], lootTypeColor[type])})
end

local VotingMainFrameClose
local ViableLootAvailable
IncendioLootLootVoting = {}

local function CreateRollButton(ItemGroup, rollState, ItemLink, Index, NoteBox)
    local button = LootVotingGUI:Create("Button")
    button:SetText(rollState.name)
    button:SetCallback("OnClick", function() 
        local _, AverageItemLevel = GetAverageItemLevel()
        LootVoting:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, LootVoting:Serialize({ItemLink = ItemLink, rollType = WrapTextInColorCode(rollState.type, lootTypeColor[rollState.type]), Index = Index, iLvl = AverageItemLevel, Note = NoteBox:GetText()}), IsInRaid() and "RAID" or "PARTY") 
        ChildCount = ChildCount - 1
        if (ChildCount == 0) then 
            for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
                if (Item.Index == Index) then 
                    Item.Rolled = true
                    IncendioLootLootVoting.CloseGUI()
                end
            end
        else
            for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
                if (Item.Index == Index) then 
                    Item.Rolled = true
                    IncendioLootLootVoting.CloseGUI()
                    LootVoting.ReOpenGUI()
                end
            end
        end
    end)
    button:SetWidth(92)
    return button
end

local function CloseGUIManual()
    if (VotingMainFrameClose == nil) then 
        return
    end
    if not FrameOpen then
        return
    end
    LootVotingGUI:Release(VotingMainFrameClose)
    FrameOpen = false
    ChildCount = 0
end

function IncendioLootLootVoting.CloseGUI()
    if (VotingMainFrameClose == nil) then 
        return
    end
    if VotingMainFrameClose:IsShown() then
        FrameOpen = false
        LootVotingGUI:Release(VotingMainFrameClose)
    end
    ChildCount = 0
end

local function AutoPass()
    ViableLootAvailable = false;
    local AutoPassLootTable = IncendioLootDataHandler.GetLootTable()
    local AutoPassViableLoot = IncendioLootDataHandler.GetViableLoot()
    for key, Item in pairs(AutoPassLootTable) do
        if type(Item) == "table" then
            local ItemName = Item.ItemName
            if AutoPassViableLoot[ItemName] == nil then
                local ItemLink = Item.ItemLink
                local Index = Item.Index
                local _, AverageItemLevel = GetAverageItemLevel()
                LootVoting:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER, LootVoting:Serialize({ ItemLink = ItemLink,  rollType = L["DID_AUTO_PASS"], Index = Index, iLvl = AverageItemLevel }), IsInRaid() and "RAID" or "PARTY")
            else
                ViableLootAvailable = true
            end
        end
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

    if IncendioLoot.ILOptions.profile.options.general.addonAutopass then
        AutoPass()
        if not ViableLootAvailable then 
            return
        end
    end

    local LootVotingMainFrame = LootVotingGUI:Create("Frame")
    LootVotingMainFrame:SetTitle(L["VOTE_TITLE"])
    LootVotingMainFrame:EnableResize(false)
    VotingMainFrameClose = LootVotingMainFrame

    for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
        if (type(Item) == "table") and (not Item.Rolled or Item.Rolled == nil) then
            local TexturePath = Item.TexturePath
            local ItemName = Item.ItemName
            local ItemLink = Item.ItemLink
            local Index = Item.Index

            if (IncendioLootDataHandler.GetViableLoot()[ItemName] ~= nil) or 
            not IncendioLoot.ILOptions.profile.options.general.addonAutopass then

                local ItemGroup = LootVotingGUI:Create("InlineGroup")
                ItemGroup:SetLayout("Flow") 
                ItemGroup:SetHeight(100)
                ItemGroup:SetWidth(60 + (#rollStates * 92) + 200 ) --Basewidth + rollstatesAmount * fixedwidth + Notebox
                ItemGroup:SetAutoAdjustHeight(false)
                LootVotingMainFrame:AddChild(ItemGroup)

                local IconWidget1 = LootVotingGUI:Create("InteractiveLabel")
                IconWidget1:SetWidth(60)
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
                local NoteBox = LootVotingGUI:Create("EditBox")
                NoteBox:SetLabel("Notiz")
                NoteBox:SetMaxLetters(20)
                NoteBox:SetWidth(150)
                for _, rollState in pairs(rollStates) do
                    ItemGroup:AddChild(CreateRollButton(ItemGroup, rollState, ItemLink, Index, NoteBox))
                end

                ItemGroup:AddChild(NoteBox)
            end
        end
    end

    LootVotingMainFrame:SetLayout("ILVooting")
    LootVotingMainFrame:SetCallback("OnClose", CloseGUIManual)
    FrameOpen = true
end

function LootVoting.ReOpenGUI()
    HandleLooted()
end

LootVotingGUI:RegisterLayout("ILVooting", 
    function(content, children)
        local VotingFrameHeight = 165

        FrameContent = content["obj"] 
        FrameObject = FrameContent["frame"]
        for i = 1, #children do
            if (i > 1) then
                VotingFrameHeight = VotingFrameHeight + 90
            end
        end

        local y = 0
        for i, child in ipairs(children) do
            child:SetPoint("TOPLEFT", 0, -y)
            y = y + 86 + 2 
        end

        FrameObject:SetHeight(VotingFrameHeight)
        FrameObject:SetWidth(830)
        FrameObject:SetBackdropColor(0,0,0,0)
        FrameObject:SetBackdropBorderColor(0,0,0,0)
    end
)

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    
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

    IncendioLoot:RegisterSubCommand("show", function ()
        if not IncendioLootDataHandler.GetSessionActive() or FrameOpen then
            return
        end
        for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
            Item.Rolled = false
        end
        HandleLooted()
    end, L["COMMAND_SHOW"])
end

LootVoting:RegisterEvent("LOOT_OPENED", function (eventname, rollID)
    if IncendioLoot.ILOptions.profile.options.general.debug then
        local ViableLootRolls = {}
            for ItemIndex = 1, GetNumLootItems(), 1 do
                if (GetLootSlotType(ItemIndex) == Enum.LootSlotType.Item) then
                    local _, ItemName, _, _, LootQuality = GetLootSlotInfo(ItemIndex)
                    if (LootQuality >= 3) then
                        if (math.random(1,100) > 50) then
                            ViableLootRolls[ItemName] = true
                        end
                    end
                end
            end
        if not rawequal(next(ViableLootRolls), nil) then
                IncendioLootDataHandler.SetViableLoot(ViableLootRolls)
            end
        end
    end
)

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    IncendioLootDataHandler.WipeViableLootData()

    local DoAutopass = (IncendioLoot.ILOptions.profile.options.general.autopass and
        not UnitIsGroupLeader("player"))

    local ViableLootRolls = {}
    local pendingLootRolls = GetActiveLootRollIDs()
    for i=1, #pendingLootRolls do
        if (pendingLootRolls ~= nil) then
            local _, ItemName, _, _, _, CanNeed = GetLootRollItemInfo(pendingLootRolls[i])
            if DoAutopass then
                RollOnLoot(pendingLootRolls[i], 0)
            end
            if CanNeed then
                ViableLootRolls[ItemName] = CanNeed
            end
        end
    end
    if not rawequal(next(ViableLootRolls), nil) then
        IncendioLootDataHandler.SetViableLoot(ViableLootRolls)
    end
end )