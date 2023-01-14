--[[
V2 Ideas:
    - Store chat in db for a history

--]] 

local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootChatFrame = IncendioLoot:NewModule("LootChatFrame", "AceComm-3.0", "AceEvent-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local ChatMessages = {}
local ChatFrameSet
local ChatFrame
local TargetScrollFrame
local CurrentIndex
local LastChatMsg
local ChatFrameActive = false
IncendioLootChatFrames = {}

--[[
    Creates a chat frame (that is, a frame containing a ScrollFrame for the chat messages and an input frame for entering text) and
    hooks up handler functions to it.
--]]

local function sortedKeys(query, sortFunction)
    local keys, len = {}, 0
    for k,_ in pairs(query) do
      len = len + 1
      keys[len] = k
    end
    table.sort(keys, sortFunction)
    return keys
end

function IncendioLootChatFrames.AddChatMessage(Index)
    if not ChatMessages[Index] then 
        return
    end
    for _, k in pairs(sortedKeys(ChatMessages[Index])) do
        if (k > LastChatMsg) then
            local NewLabel = AceGUI:Create("Label")
            local NewMsgContent = ""
            for i = 1, #ChatMessages[Index][k], 40 do
                NewMsgContent = NewMsgContent .. string.sub(ChatMessages[Index][k], i, i+39) .. "\n"
            end

            NewLabel:SetText(NewMsgContent)
            TargetScrollFrame:AddChild(NewLabel)
            LastChatMsg = k
        end
        if #ChatMessages[Index][k] > 20 then
            TargetScrollFrame:SetScroll(#ChatMessages[Index][k] * 50)
        end
    end
end

function IncendioLootChatFrames.WipdeData()
    if not ChatFrameActive  then 
        return
    end
    ChatFrame.frame:Hide()
    ChatFrameSet = false
    ChatMessages = {}
    ChatFrameActive = false
end

function IncendioLootChatFrames.CreateChatFrame(ItemIndex)
    local OldChatFrame
    if not IsInRaid() then 
        return
    end

    if ChatFrameSet then
        OldChatFrame = ChatFrame
        OldChatFrame.frame:Hide()
    end

    ChatFrame = AceGUI:Create("InlineGroup")
    ChatFrame:SetLayout("Flow")
    ChatFrame:SetTitle("")
    ChatFrame:SetWidth(230)
    ChatFrame:SetHeight(350)

    ChatFrame.frame:SetScript("OnHide", function ()
        ChatFrameSet = false
    end)

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
            NewIndex = ItemIndex,
            Message = InputText:GetText(),
        }
        InputText:SetText("")
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_CHAT_SENT,
                                      LootChatFrame:Serialize(data), "RAID")
    end
    InputText:SetCallback("OnEnterPressed", SendEvent)
    InputFrame:SetLayout("Flow")
    InputFrame:AddChild(InputText)
    ChatFrame:AddChild(InputFrame)

    ChatFrameSet = true
    TargetScrollFrame = ScrollFrame
    CurrentIndex = ItemIndex
    LastChatMsg = 0
    ChatFrameActive = true
    return ChatFrame
end

local function AddChatMessageToQueue(sender, msg, Index)
    local _, ClassFilename = UnitClass(sender)
    local _, _, _, ClassColor = GetClassColor(ClassFilename)
    local ColoredName = WrapTextInColorCode(sender, ClassColor)
    local NewMsg = ColoredName .. ": " .. msg
    
    if not ChatMessages[Index] then
        ChatMessages[Index] = {}
    end

    ChatMessages[Index][#ChatMessages[Index]+1] = NewMsg
    if CurrentIndex ~= Index then
        return
    end
    
    IncendioLootChatFrames.AddChatMessage(Index)
end

local function HandleChatSentEvent(prefix, str, distribution, sender)
    local _, data = LootChatFrame:Deserialize(str)
    AddChatMessageToQueue(sender, data.Message, data.NewIndex)
end

-- tbd how to initialize
function LootChatFrame:OnEnable()
    LootChatFrame:RegisterComm(IncendioLoot.EVENTS.EVENT_CHAT_SENT, HandleChatSentEvent)
end