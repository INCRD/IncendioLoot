local _, addon = ...
local L = addon.L

if GetLocale() == "deDE" then
    L["YES"] = "Ja"
    L["NO"] = "Nein"

    L["NO_VOTE"] = "?"
    L["ASSIGN_ITEM"] = "Möchtest du das Item zuweisen"
    L["END_SESSION"] = "Möchtest du die Sitzung beenden?"
    L["WIPE_DATABASE"] = "Möchtest du WIRKLICH die Datenbank löschen?"
    L["IL_ACTIVATEADDONAUTOPASS"] = "Diese Option führt womöglich zu fehlern! Es wird nicht empfohlen, diese zu aktivieren. Fortfahren?"
    L["DATABASE_WIPED"] = "Die Lootdatenbank wurde gelöscht."
    L["DOUBLE_USE_WARNING"] = "WARNUNG, ein weiteres LootAddon ist aktiv! Dies kann zu Problemen führen."
    L["OUT_OF_DATE_ADDON"] = "Achtung, deine Version von IncendioLoot ist nicht aktuell. Aktuelle Version: %s"
    L["SELECT_PLAYER_FIRST"] = "Bitte erst einen Spieler auswählen!"
    L["ITEM_ALREADY_ASSIGNED"] = "Das Item wurde bereits zugewiesen."
    L["DO_AUTOPASS"] = "Möchtest du automatisch auf Loot passen, der durch das Standardinterface angeboten wird?"
    L["COUNCIL_FRAME_CHECK"] = "Das Council-Fenster ist bereits geöffnet oder es ist keine Session aktiv."
    L["DID_AUTO_PASS"] = "Automatisch gepasst"

    -- loot voting
    L["VOTE_TITLE"] = "IncendioLoot - Wir brauchen Meersälze!"
    L["VOTE_STATE_BIS"] = "BIS"
    L["VOTE_STATE_UPGRADE"] = "Upgrade"
    L["VOTE_STATE_SECOND"] = "Second-Spec"
    L["VOTE_STATE_TRANSMOG"] = "Transmog"
    L["VOTE_STATE_OTHER"] = "Anderes"
    L["VOTE_STATE_PASS"] = "Passen"

    -- Loot council
    L["COUNCIL_ASSIGNED_ITEM"] = "Das Item %s wurde an %s vergeben."
        
    -- loot history
    L["HISTORY"] = "Loot-Historie"
    L["HISTORY_FILTER_DATE"] = "Datum filtern:"
    L["HISTORY_FILTER_ITEM"] = "Gegenstand filtern:"
    L["HISTORY_FILTER_PLAYER"] = "Spieler filtern:"


    -- options
    L["OPTION_GENERAL"] = "Allgemein"

    L["OPTION_ENABLE"] = "Aktivieren"
    L["OPTION_ENABLE_DESCRIPTION"] = "Aktiviert / Deaktiviert das Addon"

    L["OPTION_DEBUGMODE"] = "Debug-Modus"
    L["OPTION_DEBUGMODE_DESCRIPTION"] = "Aktiviert / Deaktiviert den Debug-Modus"
    
    L["OPTION_AUTOPASS"] = "Autopass"
    L["OPTION_AUTOPASS_DESCRIPTION"] = "Aktiviert / Deaktiviert automatisches passen auf Loot, der durch WoW angeboten wird."
    
    L["OPTION_ADDONAUTOPASS"] = "Addon Autopass"
    L["OPTION_ADDONAUTOPASS_DESCRIPTION"] = "Aktiviert / Deaktiviert automatisches passen auf Loot, der durch IncendioLoot angeboten wird."
 
    L["OPTION_AUTOPASS_ASK"] = "Nach Autopass fragen"
    L["OPTION_AUTOPASS_ASK_DESCRIPTION"] = "Aktiviert / Deaktiviert die Frage beim betreten des Raids"

    L["OPTION_DATABASE"] = "Datenbank"
    L["OPTION_DATABASE_WIPE"] = "Datenbank zurücksetzen"

    L["OPTION_MASTER_LOOTER"] = "Master Looter"
    L["OPTION_MASTER_LOOTER_1"] = "Master Looter 1"
    L["OPTION_MASTER_LOOTER_2"] = "Master Looter 2"
    L["OPTION_MASTER_LOOTER_3"] = "Master Looter 3"
    L["OPTION_MASTER_LOOTER_4"] = "Master Looter 4"
    L["OPTION_MASTER_LOOTER_5"] = "Master Looter 5"

    -- commands
    L["COMMAND_HELP"] = "Zeigt diese Befehls-Liste an."
    L["COMMAND_COUNCIL"] = "Zeigt das Council-Fenster an."
    L["COMMAND_HISTORY"] = "Zeigt die Loothistorie an."
    L["COMMAND_SHOW"] = "Zeigt das Loot-Vote-Fenster an."
    L["COMMAND_OPTIONS"] = "Öffnet die AddOn-Einstellungen."

    -- errors etc
    L["ERROR_COMMAND_ALREADY_REGISTERED"] = "Chat-Befehl '%s' wurde bereits registriert, und wird daher ignoriert. Callstack ist %s"
end