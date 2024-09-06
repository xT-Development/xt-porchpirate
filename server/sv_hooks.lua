local models = lib.load('configs.models')

local swapHook = exports.ox_inventory:registerHook('swapItems', function(payload)
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
        local playerItems = exports.ox_inventory:GetInventoryItems(payload.source)
        local fromSlot = type(payload.fromSlot) == 'number' and payload.fromSlot or payload.fromSlot.slot

        for slot, info in pairs(playerItems) do
            if info and fromSlot ~= slot then
                for i = 1, #models do
                    if (info.metadata and info.metadata.model) and (info.metadata.model == models[i].model) then
                        state:set('stolenPackage', {
                            hasPackage = true,
                            model = models[i].model
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

local createHook = exports.ox_inventory:registerHook('createItem', function(payload)
    if payload.inventoryId and type(payload.inventoryId) == 'number' then
        local state = Player(payload.inventoryId).state
        local metadata = payload.metadata
        if state and metadata then
            state:set('stolenPackage', {
                hasPackage = true,
                model = metadata.model
            }, true)
        end

        for x = 1, #models do
            if metadata.model == models[x].model then
                metadata.label = models[x].label or 'Package'
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
    exports.ox_inventory:removeHooks(swapHook)
    exports.ox_inventory:removeHooks(createHook)
end)