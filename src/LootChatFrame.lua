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
local TargetScrollFrame
IncendioLootChatFrames = {}

--[[
    Creates a chat frame (that is, a frame containing a ScrollFrame for the chat messages and an input frame for entering text) and
    hooks up handler functions to it.
--]]

function IncendioLootChatFrames.CreateChatFrame(itemIndex)
    if not IsInRaid() then 
        return
    end

    local ChatFrame = AceGUI:Create("Window")
    ChatFrame:SetLayout("Flow")
    ChatFrame:SetTitle("")
    ChatFrame:SetWidth(230)
    ChatFrame:SetHeight(350)
    ChatFrame:EnableResize(false)
    
    ChatFrame.frame:SetMovable(false)
    ChatFrame.frame:SetScript("OnMouseDown", nil)
    ChatFrame.frame:SetScript("OnMouseUp", nil)

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

    ChatFrame.AddChatMessage = function(self, sender, timestamp, message)
        local NewLabel = AceGUI:Create("Label")
        local NewMsgContent = ""
        for i = 1, #message, 30 do
            NewMsgContent = NewMsgContent .. string.sub(message, i, i+29) .. "\n"
        end
        local _, ClassFilename = UnitClass(sender)
        local _, _, _, ClassColor = GetClassColor(ClassFilename)
        local ColoredName = WrapTextInColorCode(sender, ClassColor)

        local NewMsg = ColoredName .. ": " .. NewMsgContent

        NewLabel:SetText(NewMsg)
        TargetScrollFrame:AddChild(NewLabel)

        --[[ if lastTextMessageFrame then
            lastTextMessageFrame:Hide()
        end
        local TextMessage = self.frame:CreateFontString(nil, "OVERLAY",
                                                  "GameFontNormal")
        if lastTextMessage == nil then 
            lastTextMessage = "[" .. date("%H:%M", timestamp) .. "] " .. sender ..
            ": " .. message
        else
            lastTextMessage = lastTextMessage .. "\n" .. "[" .. date("%H:%M", timestamp) .. "] " .. sender ..
            ": " .. message
        end
        TextMessage:SetPoint("LEFT")
        TextMessage:SetJustifyH("LEFT")
        TextMessage:SetText(lastTextMessage)
        lastTextMessage = TextMessage:GetText()
        lastTextMessageFrame = TextMessage ]]
    end

    ChatFrames[itemIndex] = ChatFrame
    TargetScrollFrame = ScrollFrame
    
    return ChatFrame
end

--[[
    Releases a chat frame from memory
--]]
function IncendioLootChatFrames.Release(itemIndex) 
    ChatFrames[itemIndex] = nil 
end

local function HandleChatSentEvent(prefix, str, distribution, sender)
    local _, data = LootChatFrame:Deserialize(str)
    local itemIndex = data.itemIndex
    local msg = data.message

    local TargetChatFrame = ChatFrames[itemIndex]
    if not TargetChatFrame then
        -- raise error
        return
    end

    TargetChatFrame:AddChatMessage(sender, time(), msg)
end

-- tbd how to initialize
function LootChatFrame:OnEnable()
    LootChatFrame:RegisterComm(IncendioLoot.EVENTS.EVENT_CHAT_SENT, HandleChatSentEvent)
    print("done")
end
