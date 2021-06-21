-- local dump = require "luadump"

function data()
    return {
        info = {
            minorVersion = 2,
            severityAdd = "NONE",
            severityRemove = "NONE",
            name = _("MOD_NAME"),
            description = _("MOD_DESC"),
            authors = {
                {
                    name = "Enzojz",
                    role = "CREATOR",
                    text = "Idea, Scripting",
                    steamProfile = "enzojz",
                    tfnetId = 27218,
                }
            },
            tags = {"Track", "Bridge", "Street", "Script Mod"},
        }
    }
end
