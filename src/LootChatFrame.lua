--[[
V2 Ideas:
    - Store chat in db for a history

--]] 

local addonName, addon = ...
local IncendioLoot = _G[addonName]
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local E = IncendioLoot.EVENTS

local ChatFrames = {}

--[[
    Creates a chat frame (that is, a frame containing a ScrollFrame for the chat messages and an input frame for entering text) and
    hooks up handler functions to it.
--]]
function LootChatFrame:CreateChatFrame(itemIndex)
    local ChatFrame = AceGUI:Create("Frame")
    ChatFrame:SetLayout("Fill")

    local ScrollFrame = AceGUI:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")

    local InputFrame = AceGUI:Create("Frame")
    local InputText = AceGUI:Create("EditBox")
    local SendButton = AceGUI:Create("Button")
    local SendEvent = function()
        local data = {
            sender = UnitName("player"),
            itemIndex = itemIndex,
            message = InputText:GetText(),
            local_timestamp = time()
        }

        IncendioLoot:SendCommMessage(E.EVENT_CHAT_SENT,
                                      LootChatFrame:Serialize(data),
                                      IsInRaid() and "RAID" or "PARTY")
    end

    InputText:SetCallback("OnEnterPressed", SendEvent)
    SendButton:SetCallback("OnClick", SendEvent)
    SendButton:SetText("ÄKTSCHN")

    InputFrame:SetLayout("Flow")
    InputFrame:AddChild(InputText)
    InputFrame:AddChild(SendButton)

    ChatFrame:AddChild(ScrollFrame)
    ChatFrame:AddChild(InputFrame)

    ChatFrame.AddChatMessage = function(self, sender, timestamp, message)
        local TextMessage = self:CreateFontString(nil, "OVERLAY",
                                                  "GameFontNormal")
        TextMessage:SetPoint("LEFT")
        TextMessage:SetText("[" .. date("%H:%M", timestamp) .. "] " .. sender ..
                                ": " .. message)
        ScrollFrame:AddChild(TextMessage)
    end

    ChatFrames[itemIndex] = ChatFrame
    return ChatFrame
end

--[[
    Releases a chat frame from memory
--]]
function LootChatFrame:Release(itemIndex) ChatFrames[itemIndex] = nil end

local function HandleChatSentEvent(data)
    local sender, itemIndex, msg = LootChatFrame:Deserialize(data)

    local TargetChatFrame = ChatFrames[itemIndex]
    if not TargetChatFrame then
        -- raise error
        return
    end

    TargetChatFrame:AddChatMessage(sender, time(), msg)
end

-- tbd how to initialize
function OnInitialize()
    IncendioLoot:RegisterComm(E.EVENT_CHAT_SENT, HandleChatSentEvent)
end
