local MODELS        = lib.require('configs.models')
local EXPLOSIONS    = lib.require('modules.server.explosions')
local OX_INV        = exports.ox_inventory

local swapHook = OX_INV:registerHook('swapItems', function(payload)
    local timer = EXPLOSIONS.getPlayerTimer(payload.source)
    if timer then return false end

    if (payload.toInventory == payload.source) then
        local state = Player(payload.source).state
        local metadata = payload.fromSlot.metadata
        if state and metadata then
            state:set('stolenPackage', {
                hasPackage = true,
                model = metadata.model
            }, true)
        end
    else
        local state = Player(payload.source).state

        if state and (state.stolenPackage and state.stolenPackage.hasPackage) then
            state:set('stolenPackage', nil, true)
        end

        -- If player has another package, force into anim
        local playerItems = OX_INV:GetInventoryItems(payload.source)
        local fromSlot = type(payload.fromSlot) == 'number' and payload.fromSlot or payload.fromSlot.slot

        for slot, info in pairs(playerItems) do
            if info and fromSlot ~= slot then
                for i = 1, #MODELS do
                    if (info.metadata and info.metadata.model) and (info.metadata.model == MODELS[i].model) then
                        state:set('stolenPackage', {
                            hasPackage = true,
                            model = MODELS[i].model,
                            explode = false
                        }, true)
                        return true
                    end
                end
            end
        end
    end

    return true
end, {
    print = false,
    itemFilter = {
        stolen_package = true,
    },
})

local createHook = OX_INV:registerHook('createItem', function(payload)
    if payload.inventoryId and type(payload.inventoryId) == 'number' then
        local state = Player(payload.inventoryId).state
        local metadata = payload.metadata
        if state and metadata then
            state:set('stolenPackage', {
                hasPackage = true,
                model = metadata.model,
                explode = false
            }, true)
        end

        for x = 1, #MODELS do
            if metadata.model == MODELS[x].model then
                metadata.label = MODELS[x].label or 'Package'
                return metadata
            end
        end
    end

    return
end, {
    print = false,
    itemFilter = {
        stolen_package = true,
    }
})

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    OX_INV:removeHooks(swapHook)
    OX_INV:removeHooks(createHook)
end)
