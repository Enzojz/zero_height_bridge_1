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
    local bridgeImage = gui.imageView_create("fbridge.bridge.image", api.res.bridgeTypeRep.get(state.bridge - 1).icon)
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
            end
        elseif (id == "__fbridge__") then
            if (name == "bridge") then
                state.bridge = state.bridge < #state.bridgeList and state.bridge + 1 or 1
            elseif (name == "init") then
                state = func.with(state, param)
            elseif (name == "use") then
                state.use = not state.use
            elseif (name == "build") then
                local edges = param.edges
                if param.bridgeType then
                    state.bridge = param.bridgeType
                end

                local newProposal = api.type.SimpleProposal.new()
                for i, edge in ipairs(edges) do
                    
                    local entity = api.type.SegmentAndEntity.new()
                    local comp = api.engine.getComponent(edge,  api.type.ComponentType.BASE_EDGE)
                    local trackEdge = api.engine.getComponent(edge,  api.type.ComponentType.BASE_EDGE_TRACK)
                    local streetEdge = api.engine.getComponent(edge,  api.type.ComponentType.BASE_EDGE_STREET)
                    
                    entity.entity = -edge
                    entity.playerOwned = { player = api.engine.util.getPlayer() }
                    
                    entity.comp.node0 = comp.node0
                    entity.comp.node1 = comp.node1
                    for i = 1, 3 do
                        entity.comp.tangent0[i] = comp.tangent0[i]
                        entity.comp.tangent1[i] = comp.tangent1[i]
                    end
                    entity.comp.type = 1
                    entity.comp.typeIndex = state.bridge - 1
                    
                    if trackEdge ~= nil then
                        entity.type = 1
                        entity.trackEdge.trackType = trackEdge.trackType
                        entity.trackEdge.catenary = trackEdge.catenary
                    elseif streetEdge ~= nil then
                        entity.type = 0
                        entity.streetEdge.streetType = streetEdge.streetType
                        entity.streetEdge.hasBus = streetEdge.hasBus
                        entity.streetEdge.tramTrackType = streetEdge.tramTrackType
                        entity.streetEdge.precedenceNode0 = streetEdge.precedenceNode0
                        entity.streetEdge.precedenceNode1 = streetEdge.precedenceNode1
                    end
                    
                    newProposal.streetProposal.edgesToAdd[i] = entity
                    newProposal.streetProposal.edgesToRemove[i] = edge
                end
                api.cmd.sendCommand(api.cmd.make.buildProposal(newProposal, nil), function(_) end)
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
        local bridgeList = {}
        for _, bridgeName in pairs(api.res.bridgeTypeRep.getAll()) do
            local index = api.res.bridgeTypeRep.find(bridgeName)
            if (api.res.bridgeTypeRep.isVisible(index)) then
                table.insert(bridgeList, bridgeName:match("(.+).lua"))
            end
        end
        game.interface.sendScriptEvent("__fbridge__", "init", { bridgeList = bridgeList })
    end,
    guiUpdate = function()
        createComponents()
        if (state.showWindow and not state.windows.window) then
            showWindow()
        elseif (not state.showWindow and state.windows.window) then
            state.windows.window:close()
        end
        if state.windows.window then
            state.windows.bridge:setImage(api.res.bridgeTypeRep.get(state.bridge - 1).icon)
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
                proposal 
                and proposal.addedSegments and #proposal.addedSegments > 0 
                and proposal.removedSegments and proposal.addedNodes
                and #proposal.removedSegments < #proposal.addedSegments
                and (proposal.edgeObjectsToAdd and proposal.edgeObjectsToRemove and #proposal.edgeObjectsToAdd == #proposal.edgeObjectsToRemove)
            then
                local edges = {}
                local renewedSegements = {}
                for _, v in pairs(proposal.old2newSegments) do
                    for _, seg in ipairs(v) do
                        table.insert(renewedSegements, seg)
                    end
                end
                local bridgeType = false
                for i = 1, #proposal.addedSegments do
                    local seg = proposal.addedSegments[i]
                    if not func.contains(renewedSegements, seg.entity) then
                        if (seg.comp.type == 1) then
                            bridgeType = seg.comp.typeIndex + 1
                        end
                        table.insert(edges, seg.entity)
                    end
                end
                if (#edges > 0) then
                    game.interface.sendScriptEvent("__fbridge__", "build", { edges = edges, bridgeType = bridgeType })
                end
            end
        end
    end
}

function data()
    return script
end
