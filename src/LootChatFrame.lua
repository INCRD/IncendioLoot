--[[
V2 Ideas:
    - Store chat in db for a history

--]] 

local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootChatFrame = IncendioLoot:NewModule("LootChatFrame", "AceComm-3.0", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local lastTextMessage
local lastTextMessageFrame

local ChatFrames = {}
local ChatMessages = {}
IncendioLootChatFrames = {}

--[[
    Creates a chat frame (that is, a frame containing a ScrollFrame for the chat messages and an input frame for entering text) and
    hooks up handler functions to it.
--]]

function IncendioLootChatFrames.CloseGUI()
    for k, value in pairs(ChatFrames) do
        value.frame:Hide()
    end
end

function IncendioLootChatFrames.CreateChatFrame(itemIndex)
    if not IsInRaid() then 
        return
    end

    local ChatFrame = AceGUI:Create("InlineGroup")
    ChatFrame:SetLayout("Flow")
    ChatFrame:SetTitle("")
    ChatFrame:SetWidth(230)
    ChatFrame:SetHeight(350)

    local ScrollFrame = AceGUI:Create("ScrollFrame")
    ScrollFrame:SetWidth(230)
    ScrollFrame:SetHeight(300)
    ScrollFrame:SetScroll(1)
    ChatFrame:AddChild(ScrollFrame)

    local InputFrame = AceGUI:Create("InlineGroup")
    local InputText = AceGUI:Create("EditBox")
    InputText:DisableButton(true)
    InputText:SetWidth(180)
    local SendEvent = function()
        local data = {
            itemIndex = itemIndex,
            message = InputText:GetText(),
        }
        InputText:SetText("")
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_CHAT_SENT,
                                      LootChatFrame:Serialize(data), "RAID")
    end
    InputText:SetCallback("OnEnterPressed", SendEvent)
    InputFrame:SetLayout("Flow")
    InputFrame:AddChild(InputText)
    ChatFrame:AddChild(InputFrame)
    ChatFrames[itemIndex] = ChatFrame
    ChatMessages[itemIndex] = ""
    return ChatFrame
end

local function AddChatMessage (self, sender, timestamp, message)
    local NewLabel = AceGUI:Create("Label")
    local NewMsgContent = ""
    for i = 1, #message, 30 do
        NewMsgContent = NewMsgContent .. string.sub(message, i, i+29) .. "\n"
    end
    local _, ClassFilename = UnitClass(sender)
    local _, _, _, ClassColor = GetClassColor(ClassFilename)
    local ColoredName = WrapTextInColorCode(sender, ClassColor)

    local NewMsg = ColoredName .. ": " .. NewMsgContent
    local FontObject = CreateFont("ILChat")

    NewLabel:SetText(NewMsg)
    TargetScrollFrame:AddChild(NewLabel)
end

local function HandleChatSentEvent(prefix, str, distribution, sender)
    local _, data = LootChatFrame:Deserialize(str)
    local itemIndex = data.itemIndex
    local msg = data.message

    local TargetChatFrame = ChatFrames[itemIndex]
    if not TargetChatFrame then
        -- raise error - alex: WHY?!
        return
    end

    TargetChatFrame:AddChatMessage(sender, time(), msg)
end

-- tbd how to initialize
function LootChatFrame:OnEnable()
    LootChatFrame:RegisterComm(IncendioLoot.EVENTS.EVENT_CHAT_SENT, HandleChatSentEvent)
    print("done")
end

function IncendioLootChatFrames.WipeData()
    ChatFrames = {}
    ChatMessages = {}
end