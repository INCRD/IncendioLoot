local addonName, addon = ...
local IncendioLoot = _G[addonName]

local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceGUI-3.0")

LootVoting:RegisterChatCommand("ILVote", "PrintTest")

function LootVoting:PrintTest(input)
    
end

function LootVoting:OnEnable()
    print("test")
end