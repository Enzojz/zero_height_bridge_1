-- local dump = require "luadump"

function data()
    return {
        info = {
            -- minorVersion = 2,
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
            tags = {"Track", "Bridge", "Script Mod"},
        },
        runFn = function()
            local bridgeList = {}
            addModifier("loadBridge",
                function(fileName, data)
                    local yearFrom = data.yearFrom or 0
                    local yearTo = data.yearTo or 0
                    if yearFrom >= 1850 or yearTo >= 1850 or (yearFrom == 0 and yearTo == 0) then
                        local fname = string.match(fileName, "res/config/bridge/(.+).lua")
                        if fname then
                            pcall(function()
                                table.insert(bridgeList, fname)
                                local file = io.open("fbridge.rec", "w")
                                file:write(table.concat(bridgeList, "\n"))
                                file:close()
                            end)
                        end
                    end
                    return data
                end)
        end
    }
end
