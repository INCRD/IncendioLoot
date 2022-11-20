local addonName, addon = ...
local IncendioLoot = _G[addonName]

local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local MainFrameInit = false

LootVoting:RegisterChatCommand("ILVote", "PrintTest")

function LootVoting:TookBIS()
    print("BIS")
end

function LootVoting:PrintTest(input)
    if MainFrameInit then 
        return
    end

    --Init frame
    local LootVotingMainFrame = LootVotingGUI:Create("Frame")

    MainFrameInit = true

    LootVotingMainFrame:SetTitle("Vote")
    LootVotingMainFrame:SetStatusText("Incendio Loot Voting")
    LootVotingMainFrame:SetLayout("Flow")

    local IconWidget1 = LootVotingGUI:Create("Icon")
    IconWidget1:SetLabel("Testicon")
    IconWidget1:SetWidth(150)
    LootVotingMainFrame:AddChild(IconWidget1)

    local IconButton1 = LootVotingGUI:Create("Button")
    IconButton1:SetText("BIS")
    IconButton1:SetCallback("OnClick", function() print("Bis") end)
    LootVotingMainFrame:AddChild(IconButton1)
end



function LootVoting:OnEnable()
    --LootVotingMainFrame:Hide()
end