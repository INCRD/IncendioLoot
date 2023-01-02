local _, addon = ...
local L = addon.L

L["YES"] = "Yes"
L["NO"] = "No"

L["NO_VOTE"] = "?"
L["ASSIGN_ITEM"] = "Would you like to assign the item?"
L["END_SESSION"] = "Would you like to end the session?"
L["WIPE_DATABASE"] = "Do you REALLY want to wipe the loot database?"
L["IL_ACTIVATEADDONAUTOPASS"] = "This functon is currently in an instable state and will cause errors. Are you sure to proceed?"
L["DATABASE_WIPED"] = "The loot database has been wiped."
L["DOUBLE_USE_WARNING"] = "WARNING another loot addon is active! This may cause issues."
L["OUT_OF_DATE_ADDON"] = "Warning your version of IncendioLoot is not up to date. Current version: %s"
L["SELECT_PLAYER_FIRST"] = "Please select a player first!"
L["ITEM_ALREADY_ASSIGNED"] = "The item has already been assigned."
L["DO_AUTOPASS"] = "Would you like to automatically pass on loot offered through the default interface?"
L["COUNCIL_FRAME_CHECK"] = "The council window is already open or there is no active session."
L["DID_AUTO_PASS"] = "Automatically passed"

-- loot voting
L["VOTE_TITLE"] = "IncendioLoot - We are't troxic, I swear!"
L["VOTE_STATE_BIS"] = "BIS"
L["VOTE_STATE_UPGRADE"] = "Upgrade"
L["VOTE_STATE_SECOND"] = "Secondary"
L["VOTE_STATE_TRANSMOG"] = "Transmog"
L["VOTE_STATE_OTHER"] = "Other"
L["VOTE_STATE_PASS"] = "Pass"

-- loot council
L["COUNCIL_ASSIGNED_ITEM"] = "The item %s was assigned to %s."

-- loot history
L["HISTORY"] = "Loot history"
L["HISTORY_FILTER_DATE"] = "Filter date:"
L["HISTORY_FILTER_ITEM"] = "Filter item:"
L["HISTORY_FILTER_PLAYER"] = "Filter player:"

-- options
L["OPTION_GENERAL"] = "General"

L["OPTION_ENABLE"] = "Enable"
L["OPTION_ENABLE_DESCRIPTION"] = "Enables/Disables the addon"

L["OPTION_DEBUGMODE"] = "Debug mode"
L["OPTION_DEBUGMODE_DESCRIPTION"] = "Enables/Disables debug mode"

L["OPTION_AUTOPASS"] = "Autopass"
L["OPTION_AUTOPASS_DESCRIPTION"] = "Enables/Disables automatic passing on Loot provided by the WoW Interface"

L["OPTION_ADDONAUTOPASS"] = "Addon Autopass"
L["OPTION_ADDONAUTOPASS_DESCRIPTION"] = "Enables/Disables automatic passing on Loot provided by IncendioLoot"

L["OPTION_AUTOPASS_ASK"] = "Ask for autopass"
L["OPTION_AUTOPASS_ASK_DESCRIPTION"] = "Enables/Disables asking for autopass on joining a raid"

L["OPTION_DATABASE"] = "Database"
L["OPTION_DATABASE_WIPE"] = "Wipe database"

L["OPTION_MASTER_LOOTER"] = "Master Looter"
L["OPTION_MASTER_LOOTER_1"] = "Master Looter 1"
L["OPTION_MASTER_LOOTER_2"] = "Master Looter 2"
L["OPTION_MASTER_LOOTER_3"] = "Master Looter 3"
L["OPTION_MASTER_LOOTER_4"] = "Master Looter 4"
L["OPTION_MASTER_LOOTER_5"] = "Master Looter 5"

-- commands
L["COMMAND_HELP"] = "Displays this command list."
L["COMMAND_COUNCIL"] = "Displays the loot council window."
L["COMMAND_HISTORY"] = "Displays the loot history."
L["COMMAND_SHOW"] = "Displays the loot vote frame."
L["COMMAND_OPTIONS"] = "Opens the AddOn settings."

-- errors etc
L["ERROR_COMMAND_ALREADY_REGISTERED"] = "Chat command '%s' has already been registered, and is therefore being ignored. Callstack is %s"