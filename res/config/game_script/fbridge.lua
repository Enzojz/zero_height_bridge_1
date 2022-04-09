local pipe = require "fbridge/pipe"
local func = require "fbridge/func"

local state = {
    window = false,
    use = false,
    useLabel = false,
    bridge = 1,
    fn = {}
}

local createWindow = function()
    local list = api.gui.comp.List.new(true, api.gui.util.Orientation.VERTICAL, true)

    state.window = api.gui.comp.Window.new(_("TITLE"), list)
    state.window:setId("fbridge.window")

    list:setId("fbridge.list")
    list:setVerticalScrollBarPolicy(api.gui.comp.ScrollBarPolicy.ALWAYS_ON)
    list:setHorizontalScrollBarPolicy(api.gui.comp.ScrollBarPolicy.ALWAYS_OFF)

    for index, name in pairs(api.res.bridgeTypeRep.getAll()) do
        local b = api.res.bridgeTypeRep.get(index)
        local view = api.gui.comp.ImageView.new(b.icon)
        view:setTooltip(b.name)
        view:setName(name)
        list:addItem(view)
        if (state.bridge == index) then
            list:select(list:getNumItems() - 1, false)
        end
    end

    local mSize = list:calcMinimumSize()
    local listSize = api.gui.util.Size.new()
    listSize.w = mSize.w
    listSize.h = 200
    list:setMaximumSize(listSize)

    list:onSelect(function(value)
        local listBridge = api.res.bridgeTypeRep.getAll()
        local name = listBridge[value]
        if name then
            local id = api.res.bridgeTypeRep.find(name)
            table.insert(state.fn, function()
                game.interface.sendScriptEvent("__fbridge__", "bridge", {id = id})
            end)
        end
    end)

    state.window:onClose(function()state.window:setVisible(false, false) end)
        
    local mainView = api.gui.util.getById("mainView"):getContentRect().h
    local mainMenuHeight = api.gui.util.getById("mainMenuTopBar"):getContentRect().h + api.gui.util.getById("mainMenuBottomBar"):getContentRect().h
    local x = api.gui.util.getById("fbridge.button"):getContentRect().x
    local y = mainView - mainMenuHeight - state.window:calcMinimumSize().h

    game.gui.window_setPosition("fbridge.window", x, y)
end

local createComponents = function()
    if (not state.useLabel) then
        local label = gui.textView_create("fbridge.lable", _("FBRIDGE"))
        local button = gui.button_create("fbridge.button", label)
        
        state.useLabel = gui.textView_create("fbridge.use.text", state.use and _("ON") or _("OFF"))
        local use = gui.button_create("fbridge.use", state.useLabel)
        
        game.gui.boxLayout_addItem("gameInfo.layout", gui.component_create("gameInfo.fbridge.sep", "VerticalLine").id)
        game.gui.boxLayout_addItem("gameInfo.layout", "fbridge.button")
        game.gui.boxLayout_addItem("gameInfo.layout", "fbridge.use")
        
        use:onClick(function()
            game.interface.sendScriptEvent("__fbridge__", "use", {})
            game.interface.sendScriptEvent("__edgeTool__", "off", {sender = "fbridge"})
        end)
        
        button:onClick(function()
            if state.window and state.use then
                state.window:setVisible(not state.window:isVisible(), false)
            elseif not state.window and state.use then
                table.insert(state.fn, createWindow)
            end
        end)
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
                state.bridge = param.id
            elseif (name == "init") then
                local bridgeList = api.res.bridgeTypeRep.getAll()
                if ((not state.bridge) or (not bridgeList[state.bridge])) then
                    state.bridge = api.res.bridgeTypeRep.find("stone.lua")
                end
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
                    local comp = api.engine.getComponent(edge, api.type.ComponentType.BASE_EDGE)
                    local trackEdge = api.engine.getComponent(edge, api.type.ComponentType.BASE_EDGE_TRACK)
                    local streetEdge = api.engine.getComponent(edge, api.type.ComponentType.BASE_EDGE_STREET)
                    
                    entity.entity = -edge
                    entity.playerOwned = {player = api.engine.util.getPlayer()}
                    
                    entity.comp.node0 = comp.node0
                    entity.comp.node1 = comp.node1
                    for i = 1, 3 do
                        entity.comp.tangent0[i] = comp.tangent0[i]
                        entity.comp.tangent1[i] = comp.tangent1[i]
                    end
                    entity.comp.type = 1
                    entity.comp.typeIndex = state.bridge
                    
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
                api.cmd.sendCommand(api.cmd.make.buildProposal(newProposal, nil, false), function(_) end)
            end
        end
    end,
    save = function()
        return state
    end,
    load = function(data)
        if data then
            state.bridge = data.bridge
            state.use = data.use
        end
    end,
    guiInit = function()
        game.interface.sendScriptEvent("__fbridge__", "init", {})
    end,
    guiUpdate = function()
        createComponents()
        
        if not state.use and state.window and state.window:isVisible() then
            state.window:close()
        end
        
        for _, fn in ipairs(state.fn) do fn() end
        state.fn = {}
        state.useLabel:setText(state.use and _("ON") or _("OFF"))
    end,
    guiHandleEvent = function(id, name, param)
        if state.use and name == "builder.apply" then
            local proposal = param and param.proposal and param.proposal.proposal
            local toRemove = param.proposal.toRemove
            local toAdd = param.proposal.toAdd
            if (not toAdd or #toAdd == 0)
                and (not toRemove or #toRemove == 0)
                and proposal
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
                            bridgeType = seg.comp.typeIndex
                        end
                        table.insert(edges, seg.entity)
                    end
                end
                if (#edges > 0) then
                    game.interface.sendScriptEvent("__fbridge__", "build", {edges = edges, bridgeType = bridgeType})
                end
            end
        end
    end
}

function data()
    return script
end
