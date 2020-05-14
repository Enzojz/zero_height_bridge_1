-- local dump = require "luadump"
local pipe = require "fbridge/pipe"
local func = require "fbridge/func"

local defBridgeList = {"cement", "iron", "stone"}

local state = {
    windows = {
        window = false,
        bridge = false,
    },
    button = false,
    use = false,
    useLabel = false,
    bridge = 1,
    showWindow = false,
    bridgeList = defBridgeList
}

local showWindow = function()
    local vLayout = gui.boxLayout_create("fbridge.window.vLayout", "VERTICAL")
    state.windows.window = gui.window_create("fbridge.window", _("TITLE"), vLayout)
    
    local bridgeLabel = gui.textView_create("fbridge.bridge.text", _("BRIDGE_TYPE"), 200)
    local bridgeImage = gui.imageView_create("fbridge.bridge.image", "ui/bridges/" .. state.bridgeList[state.bridge] .. ".tga")
    local bridgeButton = gui.button_create("fbridge.bridge.btn", bridgeImage)
    local bridgeLayout = gui.boxLayout_create("fbridge.bridge.layout", "HORIZONTAL")
    local bridgeComp = gui.component_create("fbridge.bridge", "a")
    bridgeComp:setLayout(bridgeLayout)
    bridgeLayout:addItem(bridgeLabel)
    bridgeLayout:addItem(bridgeButton)
    state.windows.bridge = bridgeImage
        
    bridgeButton:onClick(function()game.interface.sendScriptEvent("__fbridge__", "bridge", {}) end)
    
    vLayout:addItem(bridgeComp)
    
    local mainView = game.gui.getContentRect("mainView")
    local mainMenuHeight = game.gui.getContentRect("mainMenuTopBar")[4] + game.gui.getContentRect("mainMenuBottomBar")[4]
    local buttonX = game.gui.getContentRect("fbridge.button")[1]
    local size = game.gui.calcMinimumSize(state.windows.window.id)
    local y = mainView[4] - size[2] - mainMenuHeight
    
    state.windows.window:onClose(function()
        state.windows = {
            window = false,
            bridge = false,
            signal = false,
            distance = false,
            side = false
        }
        state.showWindow = false
    end)
    game.gui.window_setPosition(state.windows.window.id, buttonX, y)
end

local createComponents = function()
    if (not state.button) then
        local label = gui.textView_create("fbridge.lable", _("FBRIDGE"))
        state.button = gui.button_create("fbridge.button", label)
        
        state.useLabel = gui.textView_create("fbridge.use.text", state.use and _("ON") or _("OFF"))
        state.use = gui.button_create("fbridge.use", state.useLabel)
        
        game.gui.boxLayout_addItem("gameInfo.layout", gui.component_create("gameInfo.fbridge.sep", "VerticalLine").id)
        game.gui.boxLayout_addItem("gameInfo.layout", "fbridge.button")
        game.gui.boxLayout_addItem("gameInfo.layout", "fbridge.use")
        
        state.use:onClick(function()
            if state.use then state.showWindow = false end
            game.interface.sendScriptEvent("__fbridge__", "use", {})
            game.interface.sendScriptEvent("__edgeTool__", "off", { sender = "fbridge" })
        end)
        state.button:onClick(function()state.showWindow = not state.showWindow end)
    end
end

local script = {
    handleEvent = function(src, id, name, param)
        if (id == "__edgeTool__" and param.sender ~= "fbridge") then
            if (name == "off") then
                state.use = false
            elseif (name == "init") then
                state = func.with(state, param)
            end
        elseif (id == "__fbridge__") then
            if (name == "bridge") then
                state.bridge = state.bridge < #state.bridgeList and state.bridge + 1 or 1
            elseif (name == "use") then
                state.use = not state.use
            elseif (name == "build") then
                local edges = table.unpack(param)
                for i, edge in ipairs(edges) do
                    if not edge.isTrack then
                        local e = game.interface.getEntity(edge.id)
                        edges[i].street = e.streetType
                        edges[i].tram = e.hasTram
                    end
                    game.interface.bulldoze(edge.id)
                end
                local id = game.interface.buildConstruction(
                    "fbridge.con",
                    {
                        edges = edges,
                        bridge = state.bridgeList[state.bridge],
                    },
                    {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
                )
                game.interface.upgradeConstruction(
                    id,
                    "fbridge.con",
                    {
                        edges = edges,
                        bridge = state.bridgeList[state.bridge],
                        isFinal = true
                    }
                )
                game.interface.bulldoze(id)
            end
        end
    end,
    save = function() 
        if (not state.bridgeList) then state.signalList = defBridgeList end
        if (#state.bridgeList == 0) then state.bridgeList = defBridgeList end
        return state 
    end,
    load = function(data)
        if data then
            if (not data.bridgeList) then data.bridgeList = defBridgeList end
            if (#data.bridgeList == 0) then data.bridgeList = defBridgeList end
            state.bridge = data.bridge <= #data.bridgeList and data.bridge or 1
            state.use = data.use
            state.bridgeList = data.bridgeList
        end
    end,
    guiInit = function()
        local bridgeList = defBridgeList
        
        pcall(function()
            local sList = {}
            local file = io.open("fbridge.rec", "r+")
            for line in file:lines() do
                table.insert(sList, line)
            end
            file:close()
            if #sList > 0 then bridgeList = sList end
        end)

        game.interface.sendScriptEvent("__edgeTool__", "init", { bridgeList = bridgeList })
    end,
    guiUpdate = function()
        createComponents()
        if (state.showWindow and not state.windows.window) then
            showWindow()
        elseif (not state.showWindow and state.windows.window) then
            state.windows.window:close()
        end
        if state.windows.window then
            state.windows.bridge:setImage("ui/bridges/" .. state.bridgeList[state.bridge] .. ".tga")
        end
        state.useLabel:setText(state.use and _("ON") or _("OFF"))
    end,
    guiHandleEvent = function(id, name, param)
        if state.use and name == "builder.apply" then
            local proposal = param and param.proposal and param.proposal.proposal
            local toRemove = param.proposal.toRemove
            local toAdd = param.proposal.toAdd
            if
            (not toAdd or #toAdd == 0) and
                (not toRemove or #toRemove == 0) and
                proposal and proposal.addedSegments and #proposal.addedSegments > 1 and proposal.removedSegments and proposal.addedNodes
                and #proposal.removedSegments < #proposal.addedSegments
                -- and (not proposal.removedSegments or #proposal.removedSegments == 0)
                and (proposal.edgeObjectsToAdd and proposal.edgeObjectsToRemove and #proposal.edgeObjectsToAdd == #proposal.edgeObjectsToRemove)
            then
                local nodes = {}
                local edges = {}
                for i = 1, #proposal.addedNodes do
                    local node = proposal.addedNodes[i]
                    local id = node.entity
                    nodes[id] = {
                        node.comp.position[1],
                        node.comp.position[2],
                        node.comp.position[3]
                    }
                end
                local renewedSegements = {}
                for _, v in pairs(proposal.old2newSegments) do
                    for _, seg in ipairs(v) do
                        table.insert(renewedSegements, seg)
                    end
                end
                for i = 1, #proposal.addedSegments do
                    local seg = proposal.addedSegments[i]
                    if not (pipe.contains(seg.entity)(renewedSegements)) then
                        local isTrack = seg.type == 1
                        local node0 = nodes[seg.comp.node0]
                        local node1 = nodes[seg.comp.node1]
                        local snap0 = not node0
                        local snap1 = not node1
                        
                        local edge = {
                            {
                                node0 or (game.interface.getEntity(seg.comp.node0).position),
                                {
                                    seg.comp.tangent0[1],
                                    seg.comp.tangent0[2],
                                    seg.comp.tangent0[3]
                                }
                            },
                            {
                                node1 or (game.interface.getEntity(seg.comp.node1).position),
                                {
                                    seg.comp.tangent1[1],
                                    seg.comp.tangent1[2],
                                    seg.comp.tangent1[3]
                                }
                            }
                        }
                        local edgeType = seg.comp.type + 1
                        local catenary = seg.params.catenary
                        local trackType = seg.params.trackType == 0 and 1 or 2
                        
                        table.insert(edges, {
                            id = seg.entity,
                            edge = edge,
                            edgeType = edgeType,
                            catenary = catenary,
                            snap0 = snap0,
                            snap1 = snap1,
                            trackType = trackType,
                            isTrack = isTrack
                        })
                    end
                end
                if (#edges > 0) then
                    game.interface.sendScriptEvent("__fbridge__", "build", { edges })
                end
            end
        end
    end
}

function data()
    return script
end
