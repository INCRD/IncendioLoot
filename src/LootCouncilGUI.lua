local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")

local LootCouncilAceGUI = LibStub("AceGUI-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local MainFrameInit = false;

local function ResetMainFrameStatus()
    MainFrameInit = false;
end

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    if not MainFrameInit then 

        local LootTable = {}
        local LootCouncilMainFrame = LootCouncilAceGUI:Create("Window")
        LootCouncilMainFrame:SetTitle("Incendio Lootcouncil")
        LootCouncilMainFrame:SetStatusText("")
        LootCouncilMainFrame:SetLayout("Flow")
        LootCouncilMainFrame:EnableResize(false)

        local LootCouncilMainFrame2 = LootCouncilAceGUI:Create("InlineGroup")
        --LootCouncilMainFrame2:SetTitle("Items")
        LootCouncilMainFrame2:SetLayout("Flow")

        local LootCouncilMainFrame3 = LootCouncilAceGUI:Create("InlineGroup")
        LootCouncilMainFrame3:SetTitle("")
        LootCouncilMainFrame3:SetLayout("Fill")

        local LootCouncilButton = LootCouncilAceGUI:Create("Button")
        LootCouncilButton:SetText("Close")
        LootCouncilButton:SetCallback("OnClick", function ()
            LootCouncilMainFrame3:Release()
            LootCouncilMainFrame2:Release()
            LootCouncilAceGUI:Release(LootCouncilMainFrame)
        end)

        for counter = 1, GetNumLootItems(), 1 do

            if (GetLootSlotType(counter) == Enum.LootSlotType.Item) then
                local TexturePath
                local ItemName
                local locked
                local ItemLink
                local Item = {}

                TexturePath, ItemName = GetLootSlotInfo(counter)
                ItemLink = GetLootSlotLink(counter)

                local IconWidget1 = LootCouncilAceGUI:Create("Icon")
                IconWidget1:SetLabel(ItemName)
                IconWidget1:SetImageSize(40,40)
                IconWidget1:SetImage(TexturePath)
                --IconWidget1:SetLabel(ItemName)
                LootCouncilMainFrame2:AddChild(IconWidget1)

                IconWidget1:SetCallback("OnEnter", function()
                    GameTooltip:SetHyperlink(ItemLink);
                    GameTooltip:Show();
                end);
                IconWidget1:SetCallback("OnLeave", function()
                    GameTooltip:FadeOut();
                end);
                Item["TexturePath"] = TexturePath
                Item["ItemName"] = ItemName
                Item["ItemLink"] = ItemLink
                table.insert(LootTable, Item)  
            end
        end

        LootCouncilMainFrame3:AddChild(LootCouncilButton)

        LootCouncilMainFrame.frame:SetWidth(1000)

        LootCouncilMainFrame2.frame:SetPoint("TOPLEFT",LootCouncilMainFrame.frame,"TOPLEFT",-150,10)
        LootCouncilMainFrame2.frame:SetWidth(150)
        LootCouncilMainFrame2.frame:SetHeight(LootCouncilMainFrame.frame:GetHeight()- 50)
        LootCouncilMainFrame2.frame:Show()

        LootCouncilMainFrame3.frame:SetPoint("BOTTOMRIGHT",LootCouncilMainFrame.frame,"BOTTOMRIGHT",0,-45)
        LootCouncilMainFrame3.frame:SetWidth(150)
        LootCouncilMainFrame3.frame:SetHeight(60)
        LootCouncilMainFrame3.frame:Show()


        LootCouncilMainFrame:SetCallback("OnClose", ResetMainFrameStatus)

        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
        LootCouncilGUI:Serialize(LootTable),
        IsInRaid() and "RAID" or "GUILD")
    end
end

local function HandleLootVotePlayerEvent(prefix, str, distribution, sender)
    local _, LootVote = LootCouncilGUI:Deserialize(str)
    print(sender)
    print(LootVote.ItemLink)
    print(LootVote.rollType)
    print("Ende")
end


LootCouncilGUI:RegisterEvent("LOOT_OPENED", function ()
    --if UnitIsGroupLeader("player") then
        HandleLootLootedEvent()
    --end
end )

function LootCouncilGUI:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)   
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
end

