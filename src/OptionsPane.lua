local addonName, addon = ...
local IncendioLoot = _G[addonName]
local IncendioLootOptions = IncendioLoot:NewModule("OptionsPane", "AceEvent-3.0", "AceConsole-3.0")
local OptionsAceConfig = LibStub("AceConfig-3.0")
local OptionsAceConfDialog = LibStub("AceConfigDialog-3.0")
local L = addon.L

StaticPopupDialogs["IL_WIPEDATABASE"] = {
    text = L["WIPE_DATABASE"],
    button1 = L["YES"],
    button2 = L["NO"],
    OnAccept = function(self)
        IncendioLoot.ILHistory:ResetDB()
        print(L["DATABASE_WIPED"])
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["IL_ACTIVATEADDONAUTOPASS"] = {
    text = L["IL_ACTIVATEADDONAUTOPASS"],
    button1 = L["YES"],
    button2 = L["NO"],
    OnAccept = function(self, data)
        IncendioLoot.ILOptions.profile.options.general.addonAutopass = data
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function IncendioLootOptions:OnEnable()
    local IncendioLootOptions = {
        type = "group",
        args = {
            general = {
                type = "group",
                name = L["OPTION_GENERAL"],
                args = {
                    Basics = {
                        type = "group",
                        name = "Basics",
                        args = {
                            enable = {
                                name = L["OPTION_ENABLE"],
                                desc = L["OPTION_ENABLE_DESCRIPTION"],
                                type = "toggle",
                                set = function (info, value)
                                    IncendioLoot.ILOptions.profile.options.general.active = value
                                end,
                                get = function (info)
                                    return IncendioLoot.ILOptions.profile.options.general.active
                                end
                            },
                            debug = {
                                name = L["OPTION_DEBUGMODE"],
                                desc = L["OPTION_DEBUGMODE_DESCRIPTION"],
                                type = "toggle",
                                set = function (info, value)
                                    IncendioLoot.ILOptions.profile.options.general.debug = value
                                end,
                                get = function (info)
                                    return IncendioLoot.ILOptions.profile.options.general.debug
                                end
                            },
                            autopass = {
                                name = L["OPTION_AUTOPASS"],
                                desc = L["OPTION_AUTOPASS_DESCRIPTION"],
                                type = "toggle",
                                set = function (info, value)
                                    IncendioLoot.ILOptions.profile.options.general.autopass = value
                                end,
                                get = function (info)
                                    return IncendioLoot.ILOptions.profile.options.general.autopass
                                end
                            },
                            AskForautopass = {
                                name =  L["OPTION_AUTOPASS_ASK"],
                                desc = L["OPTION_AUTOPASS_ASK_DESCRIPTION"],
                                type = "toggle",
                                set = function (info, value)
                                    IncendioLoot.ILOptions.profile.options.general.askForAutopass = value
                                    print("Bla")
                                end,
                                get = function (info)
                                    return IncendioLoot.ILOptions.profile.options.general.askForAutopass
                                end
                            },
                            AddonAutopass = {
                                name =  L["OPTION_ADDONAUTOPASS"],
                                desc = L["OPTION_ADDONAUTOPASS_DESCRIPTION"],
                                type = "toggle",
                                set = function (info, value)
                                    if value == true then
                                        local ActivateAutopassDialog = StaticPopup_Show("IL_ACTIVATEADDONAUTOPASS")
                                        ActivateAutopassDialog.data = value
                                    else
                                        IncendioLoot.ILOptions.profile.options.general.addonAutopass = value
                                    end
                                end,
                                get = function (info)
                                    return IncendioLoot.ILOptions.profile.options.general.addonAutopass
                                end
                            }
                        }
                    },
                    Database = {
                        type = "group",
                        name =  L["OPTION_DATABASE"],
                        args = {
                            WipeDatabase = {
                                name = L["OPTION_DATABASE_WIPE"],
                                type = "execute",
                                func = function ()
                                    StaticPopup_Show("IL_WIPEDATABASE")
                                end
                            }
                        }
                    }
                }
            },
            masterlooter = {
                type = "group",
                name = L["OPTION_MASTER_LOOTER"],
                args = {
                    ML1 = {
                        name = L["OPTION_MASTER_LOOTER_1"],
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml1 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml1
                        end
                    },
                    ML2 = {
                        name = L["OPTION_MASTER_LOOTER_2"],
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml2 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml2
                        end
                    },
                    ML3 = {
                        name = L["OPTION_MASTER_LOOTER_3"],
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml3 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml3
                        end
                    },
                    ML4 = {
                        name = L["OPTION_MASTER_LOOTER_4"],
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml4 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml4
                        end
                    },
                    ML5 = {
                        name = L["OPTION_MASTER_LOOTER_5"],
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml5 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml5
                        end
                    }
                }
            }
        },
    }

    OptionsAceConfig:RegisterOptionsTable(addonName,IncendioLootOptions)
    OptionsAceConfDialog:AddToBlizOptions(addonName,addonName,nil)
end