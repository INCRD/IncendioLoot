local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local L = addon.L

local WaitForCouncilMembercount
IncendioLootLootCouncil = {}

local function CheckIfSenderIsPlayer(sender)
    return sender == UnitName("player")
end

local function round(n)
    return math.floor(n+0.5)
end

local function roundTwoDecimals(n)
    return math.floor(n * 100) / 100
end

local function CheckIfViableLootAvailable()
    for index = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(index) == Enum.LootSlotType.Item) then
            local _, _, _, _, LootQuality = GetLootSlotInfo(index)
            if (LootQuality >= 3) then
                return true
            end
        end
    end

    return false
end

local function BuildLootTable()
    for ItemIndex = 1, GetNumLootItems(), 1 do
        if (GetLootSlotType(ItemIndex) == Enum.LootSlotType.Item) then
            local TexturePath, ItemName, _, _, LootQuality = GetLootSlotInfo(ItemIndex)
            if (LootQuality >= 3) then
                local ItemLink = GetLootSlotLink(ItemIndex)
                local Item = {}
                Item["TexturePath"] = TexturePath
                Item["ItemName"] = ItemName
                Item["ItemLink"] = ItemLink
                Item["Index"] = ItemIndex
                Item["LootQuality"] = LootQuality
                Item["Assigned"] = false
                IncendioLootDataHandler.AddItemToLootTable(Item)
            end
        end
    end
    return(true)
end

local function BuildLootTableManually(ItemLink)
    local ItemName = GetItemInfo(ItemLink)
    local ItemID = string.match(ItemLink, "item:(%d+):")
    if (ItemName == nil) or (ItemName == "") then
        return
    end

    local TexturePath = GetItemIcon(ItemID)
    local Item = {}
    Item["TexturePath"] = TexturePath
    Item["ItemName"] = ItemName
    Item["ItemLink"] = ItemLink
    Item["Index"] = 1
    Item["LootQuality"] = 4
    Item["Assigned"] = false
    IncendioLootDataHandler.AddItemToLootTable(Item)

    return(true)
end

local function BuildVoteData()
    for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do 
        IncendioLootDataHandler.AddItemIndexToVoteData(Item.Index)
    end

    local VoteData = IncendioLootDataHandler.GetVoteData()
    for index, VoteDataValue in pairs(VoteData) do
        PlayerTable = VoteData[index]
        for member = 1, GetNumGroupMembers(), 1 do 
            local name, _, _, _, class, _, zone , online = GetRaidRosterInfo(member)
            local _, ClassFilename = UnitClass(name)
            local _, _, _, ClassColor = GetClassColor(ClassFilename)
            local ColoredName = WrapTextInColorCode(name, ClassColor)
            PlayerInformation = {class = class, zone = zone, online = online, rollType = L["NO_VOTE"], iLvl = " ", name = ColoredName, roll = math.random(1,100), vote = 0, autodecision = 0, note = " "}
            PlayerTable[ColoredName] = PlayerInformation
        end
    end
    IncendioLootDataHandler.SetVoteData(VoteData)
end

local function CheckIfML(MasterLooterTable, Name)
    local found = false
    for _, MasterLooter in pairs(MasterLooterTable) do
        if MasterLooter == Name then 
            found = true 
            break
        end
    end
    return found
end

local function BuildData(FromEvent, ItemLink)
    --Addon must be active
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    --Session must be inactive and Loot must be viable
    if (IncendioLootDataHandler.GetSessionActive() or not CheckIfViableLootAvailable() or not IsInRaid()) and FromEvent then
        return
    end

    --We don't want to use IL in LFG
    local LfgDungeonID = select(10, GetInstanceInfo())
    if LfgDungeonID ~= nil then
        return
    end

    --We use InstanceID for now, to determine of we should start the council
    local InstanceID = select(8, GetInstanceInfo())

    if UnitIsGroupLeader("player") and IncendioLootDataHandler.GetRaidIDs()[InstanceID] ~= nil then
        WaitForCouncilMembercount = 0
        local numGroupMembers = GetNumGroupMembers()
        for i = 1, numGroupMembers do
            local name = GetUnitName("raid" .. i)
            if CheckIfML(IncendioLoot.ILOptions.profile.options.masterlooters, name) then
                WaitForCouncilMembercount = WaitForCouncilMembercount + 1
            end
        end
        IncendioLootDataHandler.WipeData()
        if FromEvent then
            IncendioLootDataHandler.SetSessionActiveInactive(BuildLootTable())
        else
            IncendioLootDataHandler.SetSessionActiveInactive(BuildLootTableManually(ItemLink))
        end
        local Payload = {
            LootTable = IncendioLootDataHandler.GetLootTable(),
            SessionActive = IncendioLootDataHandler.GetSessionActive()
        }
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED, 
            LootCouncil:Serialize(Payload), "RAID")
        if WaitForCouncilMembercount == 0 then
            IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
            LootCouncil:Serialize(IncendioLootDataHandler.GetLootTable()), "RAID")
        end
    end
end

local function BuildDataFromEvent()
    BuildData(true)
end

local function BuildDataFromChat(ItemLink)
    if IncendioLootDataHandler.GetSessionActive() then
        DEFAULT_CHAT_FRAME:AddMessage(L["CANNOT_ADD_ITEM"], 1, 1, 0)
        return
    end
    BuildData(false, ItemLink[3])
end

local function ReceiveMLs(prefix, str, distribution, sender)
    if ((CheckIfSenderIsPlayer(sender)) and not IncendioLoot.ILOptions.profile.options.general.debug) then 
        return
    end

    local _, ExternalMLs = LootCouncil:Deserialize(str)
    if not (ExternalMLs == nil) then
        IncendioLootDataHandler.SetExternalMLs(ExternalMLs)
        if IncendioLoot.ILOptions.profile.options.general.debug then 
            print("MLs Set")
        end
    end
end

function IncendioLootLootCouncil.AnnounceMLs()
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end

    local MasterLooter = IncendioLootDataHandler.GetMasterLooter()

    if (MasterLooter == nil) then 
        return
    end

    if not IsInRaid() then 
        return
    end

    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_MLS, LootCouncil:Serialize(MasterLooter), "RAID")
    end
end

function IncendioLootLootCouncil.BuildScrollData(VoteData, ItemIndex)
    local rows = {}
    local i = 1
    local PlayerTable
    IncendioLootDataHandler.WipeScrollData()

    PlayerTable = VoteData[ItemIndex]
    for index, PlayerInformation in pairs(PlayerTable) do
        if (tostring(PlayerInformation.rollType) ~= WrapTextInColorCode("PASS", IncendioLoot.COLORS.GREY)) then
            local cols = {
                { ["value"] = PlayerInformation.name },
                { ["value"] = PlayerInformation.zone },
                { ["value"] = tostring(PlayerInformation.online) },
                { ["value"] = tostring(PlayerInformation.rollType) },
                { ["value"] = tostring(PlayerInformation.iLvl) },
                { ["value"] = PlayerInformation.itemEquipped1},
                { ["value"] = PlayerInformation.itemEquipped2},
                { ["value"] = tostring(PlayerInformation.roll) },
                { ["value"] = PlayerInformation.vote },
                { ["value"] = PlayerInformation.autodecision },
                { ["value"] = PlayerInformation.note }
            }
            rows[i] = { ["cols"] = cols }
            i = i + 1
        end
    end
    IncendioLootDataHandler.SetScrollRows(rows)
end

local function ReceiveLootDataAndStartGUI(prefix, str, distribution, sender)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end

    if not IsInRaid() then 
        return
    end

    local isDebugOrCM = IncendioLootFunctions.CheckIfMasterLooter() or IncendioLoot.ILOptions.profile.options.general.debug
    if (not CheckIfSenderIsPlayer(sender)) and isDebugOrCM then 
        local _, Payload = LootCouncil:Deserialize(str)
        IncendioLootDataHandler.WipeData()
        IncendioLootDataHandler.SetLootTable(Payload.LootTable)
        IncendioLootDataHandler.SetSessionActiveInactive(Payload.SessionActive)
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_DATA_RECEIVED,
        " ", "RAID")
    end
    if isDebugOrCM then
        BuildVoteData()
        IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    end
end

function IncendioLootLootCouncil.SetSessionInactive()
    if not IsInRaid() then 
        return
    end
    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE, " ", "RAID")
    end
end

local function UpdateVoteData(Index, PlayerName, RollType, Ilvl, Note, ItemEquipped1, ItemEquipped2)
    if not IsInRaid() then 
        return
    end

    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.rollType = tostring(RollType)
    PlayerInformation.iLvl = Ilvl
    PlayerInformation.note = Note
    PlayerInformation.itemEquipped1 = ItemEquipped1
    PlayerInformation.itemEquipped2 = ItemEquipped2

    if UnitIsGroupLeader("player") and (tostring(PlayerInformation.rollType) ~= WrapTextInColorCode("PASS", IncendioLoot.COLORS.GREY)) then 
        local BasePlayerValue = 20000;
        local NumOfItems = IncendioLootLootDatabase.ReturnItemsLastTwoWeeksPlayer(PlayerName, tostring(RollType)) * 1000
        local AutoDecisionResult = roundTwoDecimals(((BasePlayerValue - NumOfItems - Ilvl + PlayerInformation.roll) / 10000) / 2 * 100)
        PlayerInformation.autodecision = AutoDecisionResult

        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_DATA_AUTODECISION, 
                                    LootCouncil:Serialize({AutoDecisionResult = AutoDecisionResult, Index = Index, PlayerName = PlayerName}), "RAID")
    end
end

local function UpdateAutodecision(Index, PlayerName, AutoDecisionResult)
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.autodecision = AutoDecisionResult
end

local function HandleAutoDecision(prefix, str, distribution, sender)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    
    if not IncendioLootDataHandler.GetSessionActive() or not IncendioLootFunctions.CheckIfMasterLooter() then 
        return
    end

    local _, AutoDecision = LootCouncil:Deserialize(str)
    local NewIndex = AutoDecision.Index
    local AutoDecisionResult = AutoDecision.AutoDecisionResult
    local PlayerName = AutoDecision.PlayerName
    UpdateAutodecision(NewIndex, PlayerName, AutoDecisionResult)
    IncendioLootLootCouncilGUI.CreateScrollFrame(NewIndex)
end

local function UpdateExternalAssignItem(prefix, str, distribution, sender)
    local isDebugOrCM = IncendioLootFunctions.CheckIfMasterLooter() or IncendioLoot.ILOptions.profile.options.general.debug
    if CheckIfSenderIsPlayer(sender) or not isDebugOrCM then
        return
    end

    local _, CouncilAssign = LootCouncil:Deserialize(str)
    local Index = CouncilAssign.Index
    local NewPlayerName = CouncilAssign.NewPlayerName
    local NewRollType = CouncilAssign.NewRollType
    local ItemLink = CouncilAssign.ItemLink
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local PlayerInformation = PlayerTable[NewPlayerName]
    local InstanceName, _, DifficultyIndex, DifficultyName, _, _, _, InstanceMapeID, _ = GetInstanceInfo()
    IncendioLootLootDatabase.AddItemToDatabase(NewPlayerName,InstanceMapeID,PlayerInformation.class, InstanceName, PlayerInformation.rollType, ItemLink, PlayerInformation.vote, PlayerInformation.roll,DifficultyIndex,DifficultyName)
    PlayerInformation.rollType = NewRollType
    IncendioLootLootCouncilGUI.CreateScrollFrame(Index)

    IncendioLootLootCouncil.SetItemAssignedIcon(Index)
end

local function UpdateExternalCMVote(prefix, str, distribution, sender)
    local isDebugOrCM = IncendioLootFunctions.CheckIfMasterLooter() or IncendioLoot.ILOptions.profile.options.general.debug
    if CheckIfSenderIsPlayer(sender) or not isDebugOrCM then
        return
    end
    local _, CouncilVote = LootCouncil:Deserialize(str)
    local Index = CouncilVote.Index
    local OldPlayerName = CouncilVote.OldPlayerName
    local NewPlayerName = CouncilVote.NewPlayerName

    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    if (OldPlayerName ~= "none") then
        local PlayerInformation = PlayerTable[OldPlayerName]
        PlayerInformation.vote = PlayerInformation.vote - 1
    end
    local PlayerInformation = PlayerTable[NewPlayerName]
    PlayerInformation.vote = PlayerInformation.vote + 1
    IncendioLootLootCouncilGUI.CreateScrollFrame(Index)
end

function IncendioLootLootCouncil.PrepareAndAddItemToHistory(Index, PlayerName)
    if not IsInRaid() then 
        return
    end
    if not UnitIsGroupLeader("player") then
        DEFAULT_CHAT_FRAME:AddMessage("Dies darf nur der Masterlooter tun!", 1, 1, 0)
        return
    end
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local LootTable = IncendioLootDataHandler.GetLootTable()
    for i, value in pairs(LootTable) do
        if (value["Index"] == Index) then
            local PlayerInformation = PlayerTable[PlayerName]
            local InstanceName, _, DifficultyIndex, DifficultyName, _, _, _, InstanceMapeID, _ = GetInstanceInfo()
            IncendioLootLootDatabase.AddItemToDatabase(PlayerName,InstanceMapeID,PlayerInformation.class, InstanceName, PlayerInformation.rollType, value["ItemLink"], PlayerInformation.vote, PlayerInformation.roll,DifficultyIndex,DifficultyName)
            PlayerInformation.rollType = "Zugewiesen"
            IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_ASSIGN_ITEM_COUNCIL, 
                        LootCouncil:Serialize({Index = Index, NewPlayerName = PlayerName, NewRollType = "Zugewiesen", ItemLink = value["ItemLink"]}), "RAID")
            IncendioLootLootCouncilGUI.CreateScrollFrame(Index)
            IncendioLootLootCouncil.SetItemAssignedIcon(Index)
        end
    end
end


local function CheckAndBuildOwnVoted(Index, PlayerName, PlayerTable)
    if not IsInRaid() then 
        return
    end

    local OwnVoteData = IncendioLootDataHandler.GetOwnVoteData()
        for LocIndex, value in pairs(OwnVoteData) do
            if LocIndex == Index then 
                if (PlayerName == value) then
                    return(false)
                else
                    local PlayerInformation = PlayerTable[value]
                    PlayerInformation.vote = PlayerInformation.vote - 1
                    OwnVoteData[LocIndex] = PlayerName
                    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_COUNCIL, 
                        LootCouncil:Serialize({Index = Index, OldPlayerName = value, NewPlayerName = PlayerName}), "RAID")
                    return(true)
                end
            end
        end
    OwnVoteData[Index] = PlayerName
    IncendioLootDataHandler.SetOwnVoteData(OwnVoteData)
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_COUNCIL, 
                        LootCouncil:Serialize({Index = Index, OldPlayerName = "none", NewPlayerName = PlayerName}), "RAID")
    return(true)
end

function IncendioLootLootCouncil.UpdateCouncilVoteData(Index, PlayerName, NewrollType)
    if (Index == nil or PlayerName == nil) then
        return
    end
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    if not CheckAndBuildOwnVoted(Index,PlayerName,PlayerTable) then
        return
    end

    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.vote = PlayerInformation.vote + 1
    IncendioLootLootCouncilGUI.CreateScrollFrame(Index)
end

local function ReceiveDataAndCheck(prefix, str, distribution, sender)
    if not UnitIsGroupLeader("player") then
        return
    end
    if CheckIfSenderIsPlayer(sender) then
        return
    end
    if not IsInRaid() then 
        return
    end
    if IncendioLoot.ILOptions.profile.options.general.debug then
        print("Membercount vorher: "..WaitForCouncilMembercount)
    end
    WaitForCouncilMembercount = WaitForCouncilMembercount - 1
    if IncendioLoot.ILOptions.profile.options.general.debug then
        print("Membercount nachher: "..WaitForCouncilMembercount)
    end
    if WaitForCouncilMembercount == 0 then 
        if IncendioLoot.ILOptions.profile.options.general.debug then 
            print("Members Received")
        end
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
            LootCouncil:Serialize(IncendioLootDataHandler.GetLootTable()), "RAID")
    end
end

local function HandleLootVotePlayerEvent(prefix, str, distribution, sender)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    
    if not IncendioLootDataHandler.GetSessionActive() or not IncendioLootFunctions.CheckIfMasterLooter() then 
        return
    end

    local _, LootVote = LootCouncil:Deserialize(str)
    local NewItemLink = LootVote.ItemLink
    local NewRollType = LootVote.rollType
    local NewIndex = LootVote.Index
    local ILvl = round(LootVote.iLvl)
    local Note = LootVote.Note
    local ItemEquipped1 = LootVote.ItemEquipped1
    local ItemEquipped2 = LootVote.ItemEquipped2
    local _, ClassFilename = UnitClass(sender)
    local _, _, _, ClassColor = GetClassColor(ClassFilename)
    local ColoredName = WrapTextInColorCode(sender, ClassColor)

    UpdateVoteData(NewIndex, ColoredName, NewRollType, ILvl, Note, ItemEquipped1, ItemEquipped2)
    IncendioLootLootCouncilGUI.CreateScrollFrame(NewIndex)
end

function LootCouncil:OnInitialize()
    IncendioLoot:RegisterSubCommand("additem", BuildDataFromChat, L["COMMAND_ADDITEM"])
end

function LootCouncil:OnEnable()
    LootCouncil:RegisterEvent("GROUP_ROSTER_UPDATE", IncendioLootLootCouncil.AnnounceMLs)
    LootCouncil:RegisterEvent("LOOT_OPENED", BuildDataFromEvent)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_MLS,
                            ReceiveMLs)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED,
                            ReceiveLootDataAndStartGUI)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_COUNCIL,
                            UpdateExternalCMVote)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ASSIGN_ITEM_COUNCIL,
                            UpdateExternalAssignItem)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_DATA_RECEIVED,
                            ReceiveDataAndCheck)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_DATA_AUTODECISION,
                            HandleAutoDecision)
end
