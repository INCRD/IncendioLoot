local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
IncendioLootLootCouncil = {}

local function CheckIfSenderIsPlayer(sender)
    return sender == UnitName("player")
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
                if IsEquippableItem(ItemLink) then
                    local Item = {}
                    Item["TexturePath"] = TexturePath
                    Item["ItemName"] = ItemName
                    Item["ItemLink"] = ItemLink
                    Item["Index"] = ItemIndex
                    Item["LootQuality"] = LootQuality
                    IncendioLootDataHandler.AddItemToLootTable(Item)
                    IncendioLootDataHandler.AddItemIndexToVoteData(Item.Index)
                end
            end
        end
    end
end

local function BuildVoteData()
    local VoteData = IncendioLootDataHandler.GetVoteData()
    for index, VoteDataValue in pairs(VoteData) do
        local ItemLink = GetLootSlotLink(index)
        PlayerTable = VoteData[index]
        for member = 1, GetNumGroupMembers(), 1 do 
            local name, _, _, _, class, _, zone , online = GetRaidRosterInfo(member)
            PlayerInformation = {class = class, zone = zone, online = online, rollType = IncendioLoot.STATICS.NO_VOTE, iLvl = " ", name = name, roll = math.random(1,100), vote = 0, autodecision = 0}
            PlayerTable[name] = PlayerInformation
        end
    end
    IncendioLootDataHandler.SetVoteData(VoteData)
end

local function BuildLootAndVoteTable()
    BuildLootTable()
    BuildVoteData()

    return(true)
end

local function BuildData()
    if IncendioLootDataHandler.GetSessionActive() or not CheckIfViableLootAvailable() then
        return
    end

    if UnitIsGroupLeader("player") then
        IncendioLootDataHandler.WipeData()
        IncendioLootDataHandler.SetSessionActiveInactive(BuildLootAndVoteTable())
        local Payload = {
            LootTable = IncendioLootDataHandler.GetLootTable(),
            VoteTable = IncendioLootDataHandler.GetVoteData(),
            SessionActive = IncendioLootDataHandler.GetSessionActive()
        }
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED, 
            LootCouncil:Serialize(Payload), 
            IsInRaid() and "RAID" or "PARTY")
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
            LootCouncil:Serialize(IncendioLootDataHandler.GetLootTable()),
            IsInRaid() and "RAID" or "PARTY")
    end
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
    local MasterLooter = IncendioLootDataHandler.GetMasterLooter()

    if (MasterLooter == nil) then 
        return
    end

    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_MLS, LootCouncil:Serialize(MasterLooter), IsInRaid() and "RAID" or "PARTY")
    end
end

function IncendioLootLootCouncil.BuildScrollData(VoteData, ItemIndex)
    local rows = {}
    local i = 1
    local PlayerTable
    IncendioLootDataHandler.WipeScrollData()

    PlayerTable = VoteData[ItemIndex]
    for index, PlayerInformation in pairs(PlayerTable) do
        local cols = {
            { ["value"] = PlayerInformation.name },
            { ["value"] = PlayerInformation.class },
            { ["value"] = PlayerInformation.zone },
            { ["value"] = tostring(PlayerInformation.online) },
            { ["value"] = tostring(PlayerInformation.rollType) },
            { ["value"] = tostring(PlayerInformation.iLvl) },
            { ["value"] = tostring(PlayerInformation.roll) },
            { ["value"] = PlayerInformation.vote },
            { ["value"] = PlayerInformation.autodecision }
        }
        rows[i] = { ["cols"] = cols }
        i = i + 1
    end
    IncendioLootDataHandler.SetScrollRows(rows)
end

local function ReceiveLootDataAndStartGUI(prefix, str, distribution, sender)
    local isDebugOrCM = IncendioLootFunctions.CheckIfMasterLooter() or IncendioLoot.ILOptions.profile.options.general.debug
    if (not CheckIfSenderIsPlayer(sender) and isDebugOrCM) then 
        local _, Payload = LootCouncil:Deserialize(str)
        IncendioLootDataHandler.SetLootTable(Payload.LootTable)
        IncendioLootDataHandler.SetVoteData(Payload.VoteTable)
        IncendioLootDataHandler.SetSessionActiveInactive(Payload.SessionActive)
    end
    if isDebugOrCM then
        IncendioLootLootCouncilGUI.HandleLootLootedEvent()
    end
end

function IncendioLootLootCouncil.SetSessionInactive()
    if UnitIsGroupLeader("player") then
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE,
        " ",
        IsInRaid() and "RAID" or "PARTY")
    end
end

local function UpdateVoteData(Index, PlayerName, RollType, Ilvl)
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local PlayerInformation = PlayerTable[PlayerName]
    PlayerInformation.rollType = tostring(RollType)
    PlayerInformation.iLvl = Ilvl
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
    if not UnitIsGroupLeader("player") then
        print("Your are not allowed to do this!")
        return
    end
    local PlayerTable = IncendioLootDataHandler.GetVoteData()[Index]
    local LootTable = IncendioLootDataHandler.GetLootTable()
    for i, value in pairs(LootTable) do
        if (value["Index"] == Index) then 
            local PlayerInformation = PlayerTable[PlayerName]
            local InstanceName, _, DifficultyIndex, DifficultyName, _, _, _, InstanceMapeID, _ = GetInstanceInfo()
            IncendioLootLootDatabase.AddItemToDatabase(PlayerName,InstanceMapeID,PlayerInformation.class, InstanceName, PlayerInformation.rollType, value["ItemLink"], PlayerInformation.vote, PlayerInformation.roll,DifficultyIndex,DifficultyName)
        end
    end
end


local function CheckAndBuildOwnVoted(Index, PlayerName, PlayerTable)
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
                        LootCouncil:Serialize({Index = Index, OldPlayerName = value, NewPlayerName = PlayerName}), 
                        IsInRaid() and "RAID" or "PARTY")
                    return(true)
                end
            end
        end
    OwnVoteData[Index] = PlayerName
    IncendioLootDataHandler.SetOwnVoteData(OwnVoteData)
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_COUNCIL, 
                        LootCouncil:Serialize({Index = Index, OldPlayerName = "none", NewPlayerName = PlayerName}), 
                        IsInRaid() and "RAID" or "PARTY")
    return(true)
end

function IncendioLootLootCouncil.UpdateCouncilVoteData(Index, PlayerName)
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

local function round(n)
    return math.floor(n+0.5)
end

local function HandleLootVotePlayerEvent(prefix, str, distribution, sender)
    if not IncendioLootDataHandler.GetSessionActive() or not IncendioLootFunctions.CheckIfMasterLooter() then 
        return
    end

    local _, LootVote = LootCouncil:Deserialize(str)
    local NewItemLink = LootVote.ItemLink
    local NewRollType = LootVote.rollType
    local NewIndex = LootVote.Index
    local ILvl = round(LootVote.iLvl)
    UpdateVoteData(NewIndex,sender,NewRollType, ILvl)
    IncendioLootLootCouncilGUI.CreateScrollFrame(NewIndex)
end

function LootCouncil:OnEnable()
    LootCouncil:RegisterEvent("GROUP_ROSTER_UPDATE", IncendioLootLootCouncil.AnnounceMLs)
    LootCouncil:RegisterEvent("LOOT_OPENED", BuildData)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_MLS,
                            ReceiveMLs)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED,
                            ReceiveLootDataAndStartGUI)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_PLAYER,
                            HandleLootVotePlayerEvent)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_COUNCIL,
                            UpdateExternalCMVote)
end