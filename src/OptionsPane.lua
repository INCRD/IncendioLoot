local addonName, addon = ...
local IncendioLoot = _G[addonName]
local IncendioLootOptions = IncendioLoot:NewModule("OptionsPane", "AceEvent-3.0", "AceConsole-3.0")
local OptionsAceConfig = LibStub("AceConfig-3.0")
local OptionsAceConfDialog = LibStub("AceConfigDialog-3.0")

function IncendioLootOptions:OnEnable()
    local IncendioLootOptions = {
        type = "group",
        args = {
            general = {
                type = "group",
                name = "Allgemein",
                args = {
                    enable = {
                        name = "Aktivieren",
                        desc = "Aktiviert / Deaktiviert IncendioLoot",
                        type = "toggle",
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.general.active = value
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.general.active
                        end
                    },
                    debug = {
                        name = "Debug Mode",
                        desc = "Aktiviert / Deaktiviert den Debug Modus",
                        type = "toggle",
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.general.debug = value
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.general.debug
                        end
                    },
                    autopass = {
                        name = "Autopass",
                        desc = "Aktiviert / Deaktiviert automatisches passen",
                        type = "toggle",
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.general.autopass = value
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.general.autopass
                        end
                    }
                }
            },
            masterlooter = {
                type = "group",
                name = "Master Looter",
                args = {
                    ML1 = {
                        name = "Master Looter 1",
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
                        name = "Master Looter 2",
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
                        name = "Master Looter 3",
                        type = "input",
                        multiline = false,
                        set = function (info, value)
                            IncendioLoot.ILOptions.profile.options.masterlooters.ml3 = value
                            IncendioLootDataHandler.BuildAndSetMLTable()
                        end,
                        get = function (info)
                            return IncendioLoot.ILOptions.profile.options.masterlooters.ml3
                        end
                    }
                }
            }
        },
    }

    OptionsAceConfig:RegisterOptionsTable(addonName,IncendioLootOptions)
    OptionsAceConfDialog:AddToBlizOptions(addonName,addonName,nil)
end