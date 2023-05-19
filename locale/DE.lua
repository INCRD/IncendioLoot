local _, addon = ...
local L = addon.L

if GetLocale() == "deDE" then
    L["YES"] = "Ja"
    L["NO"] = "Nöl"
    L["HISTORY_NOT_AVAILABLE"] = "Es ist keine Historie vorhanden"
    L["OK"] = "OK"
    L["Cancel"] = "Cancel"

    L["NO_VOTE"] = "?"
    L["ASSIGN_ITEM"] = "Möchtest du das Item zuweisen"
    L["END_SESSION"] = "Möchtest du die Sitzung beenden?"
    L["WIPE_DATABASE"] = "Möchtest du WIRKLICH die Datenbank löschen?"
    L["DATABASE_WIPED"] = "Die Lootdatenbank wurde gelöscht."
    L["DOUBLE_USE_WARNING"] = "WARNUNG, ein weiteres LootAddon ist aktiv! Dies kann zu Problemen führen."
    L["OUT_OF_DATE_ADDON"] = "Achtung, deine Version von IncendioLoot ist nicht aktuell. Aktuelle Version: %s"
    L["SELECT_PLAYER_FIRST"] = "Bitte erst einen Spieler auswählen!"
    L["ITEM_ALREADY_ASSIGNED"] = "Das Item wurde bereits zugewiesen."
    L["DO_AUTOPASS"] = "Möchtest du automatisch auf Loot passen, der durch das Standardinterface angeboten wird?"
    L["COUNCIL_FRAME_CHECK"] = "Das Council-Fenster ist bereits geöffnet oder es ist keine Session aktiv."
    L["DID_AUTO_PASS"] = "Automatisch gepasst"
    L["CANNOT_ADD_ITEM"] = "Das Item kann nicht hinzugefügt werden, da noch eine Session aktiv ist."

    -- loot voting
    L["VOTE_TITLE"] = "IncendioLoot - Wir brauchen Meersälze!"
    L["VOTE_STATE_BIS"] = "BIS"
    L["VOTE_STATE_UPGRADE"] = "Upgrade"
    L["VOTE_STATE_SECOND"] = "Second-Spec"
    L["VOTE_STATE_TRANSMOG"] = "Transmog"
    L["VOTE_STATE_OTHER"] = "Anderes"
    L["VOTE_STATE_PASS"] = "Passen"

    -- Loot council
    L["COUNCIL_ASSIGNED_ITEM"] = "Das Item %s wurde an %s vergeben. %s"
        
    -- loot history
    L["HISTORY"] = "Loot-Historie"
    L["HISTORY_FILTER_DATE"] = "Datum filtern:"
    L["HISTORY_FILTER_ITEM"] = "Gegenstand filtern:"
    L["HISTORY_FILTER_PLAYER"] = "Spieler filtern:"
    L["DELETE_ENTRY"] = "Möchtest du den Eintrag löschen?"
    L["CAPTION_DELETE_ENTRY"] = "Einträg löschen"
    L["CAPTION_CHANGE_ROLLTYPE"] = "Antwort ändern"
    L["CAPTION_DELETE_PLAYER_ENTRY"] = "Spielerdaten löschen"
    L["DELETE_PLAYER_ENTRY"] = "Möchtest du alle Datensätze des Spielers löschen?"

    --Loot database
    L["SYNC_NOT_ACTIVATED"] = "Jemand hat versucht eine Datenbank zu synchronisieren. Doch die Funktkion ist nicht aktiv."
    L["SYNC_SUCCESS"] = "%s wurde in die Datenbank synchronisiert"

    --Session Window
    L["TITLE_SESSION_WINDOW"] = "Loot Session"

    -- options
    L["OPTION_GENERAL"] = "Allgemein"

    L["OPTION_ENABLE"] = "Aktivieren"
    L["OPTION_ENABLE_DESCRIPTION"] = "Aktiviert / Deaktiviert das Addon"

    L["OPTION_DEBUGMODE"] = "Debug-Modus"
    L["OPTION_DEBUGMODE_DESCRIPTION"] = "Aktiviert / Deaktiviert den Debug-Modus"
    
    L["OPTION_AUTOPASS"] = "Autopass"
    L["OPTION_AUTOPASS_DESCRIPTION"] = "Aktiviert / Deaktiviert automatisches passen auf Loot, der durch WoW angeboten wird."
 
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

    L["OPTION_ALLOW_DBSYNC"] = "Datenbanksync zulassen"

    -- commands
    L["COMMAND_HELP"] = "Zeigt diese Befehls-Liste an."
    L["COMMAND_COUNCIL"] = "Zeigt das Council-Fenster an."
    L["COMMAND_HISTORY"] = "Zeigt die Loothistorie an."
    L["COMMAND_ADDHISTORY"] = "Fügt der Loothistorie ein Item hinzu."
    L["COMMAND_SHOW"] = "Zeigt das Loot-Vote-Fenster an."
    L["COMMAND_OPTIONS"] = "Öffnet die AddOn-Einstellungen."
    L["COMMAND_SYNCDB"] = "Synchronisiert die Datenbank. WIP"
    L["COMMAND_ADDITEM"] = "Fügt ein Item zum verollen hinzu."
    L["COMMAND_VERSION_CHECK"] = "Führt die IncendioLoot-Addon-Version deiner Gruppe auf."

    -- errors etc
    L["ERROR_COMMAND_ALREADY_REGISTERED"] = "Chat-Befehl '%s' wurde bereits registriert, und wird daher ignoriert. Callstack ist %s"

    --RandomAssignMessages
    L["RANDOM_ASSIGN_MESSAGE_1"] = "Juhu!"
    L["RANDOM_ASSIGN_MESSAGE_2"] = "Leider Geil!"
    L["RANDOM_ASSIGN_MESSAGE_3"] = "Ist das denn die Möglichkeit?!"
    L["RANDOM_ASSIGN_MESSAGE_4"] = "Hier könnte Ihre Werbung stehen!"
    L["RANDOM_ASSIGN_MESSAGE_5"] = "Wubdidooh!"
    L["RANDOM_ASSIGN_MESSAGE_6"] = "Absolut Klasse!"
    L["RANDOM_ASSIGN_MESSAGE_7"] = "Megakrass!"
    L["RANDOM_ASSIGN_MESSAGE_8"] = "Digga!"
    
    -- Version Check
    L["VCHK_NAME"] = "Spieler"
    L["VCHK_VERSION"] = "Version"
    L["VCHK_ACTIVE"] = "Aktiv"

    L["DATABASEINPUT_CONFIRMED"] = "Der folgende Datensatz wurde eingefügt:"
end