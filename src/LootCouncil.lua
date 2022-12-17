local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
IncendioLootLootCouncil = {}

local function CheckIfSenderIsPlayer(sender)
    return((sender == UnitName("player")))
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
                IncendioLootDataHandler.AddItemToLootTable(Item)
                IncendioLootDataHandler.AddItemIndexToVoteData(Item.Index)
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
            PlayerInformation = {class = class, zone = zone, online = online, rollType = "Kein Vote", iLvl = " ", name = name, roll = math.random(1,100)}
            PlayerTable[name] = PlayerInformation
        end
    end
    IncendioLootDataHandler.SetVoteData(VoteData)
end

local function BuildLootAndVoteTable()
    if not CheckIfViableLootAvailable() then
        return
    end
    BuildLootTable()
    BuildVoteData()

    return(true)
end

local function BuildData()
    if IncendioLootDataHandler.GetSessionActive() then 
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
    if ((CheckIfSenderIsPlayer(sender)) and not IncendioLoot.ILOptions.profile.options.general.debug ) then 
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

local function BuildScrollData(VoteData)
    local rows = {}
    local i = 1
    PlayerTable = VoteData[1]
    for index, PlayerInformation in pairs(PlayerTable) do
        local cols = {
            { ["value"] = PlayerInformation.name },
            { ["value"] = PlayerInformation.class },
            { ["value"] = PlayerInformation.zone },
            { ["value"] = tostring(PlayerInformation.online) },
            { ["value"] = tostring(PlayerInformation.rollType) },
            { ["value"] = tostring(PlayerInformation.iLvl) },
            { ["value"] = tostring(PlayerInformation.roll) }
        }
        rows[i] = { ["cols"] = cols }
        i = i + 1
    end
    IncendioLootDataHandler.SetScrollRows(rows)
    print(LootCouncil:Serialize(rows))
end

local function ReceiveLootDataAndStartGUI(prefix, str, distribution, sender)
    if (not CheckIfSenderIsPlayer(sender) and not IncendioLoot.ILOptions.profile.options.general.debug) then 
        local _, Payload = LootCouncil:Deserialize(str)
        IncendioLootDataHandler.SetLootTable(Payload.LootTable)
        IncendioLootDataHandler.SetVoteData(Payload.VoteData)
        IncendioLootDataHandler.SetSessionActiveInactive(Payload.SessionActive)
    end
    BuildScrollData(IncendioLootDataHandler.GetVoteData())
    IncendioLootLootCouncilGUI.HandleLootLootedEvent()
end

function LootCouncil:OnEnable()
    LootCouncil:RegisterEvent("GROUP_ROSTER_UPDATE", IncendioLootLootCouncil.AnnounceMLs)
    LootCouncil:RegisterEvent("LOOT_OPENED", BuildData)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_ANNOUNCE_MLS,
                            ReceiveMLs)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTDATA_BUILDED,
                            ReceiveLootDataAndStartGUI)
end