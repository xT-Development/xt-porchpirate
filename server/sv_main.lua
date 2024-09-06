local config = lib.load('configs.server')
local models = lib.load('configs.models')
local globalState = GlobalState
local explosionTimers = {}

-- Get random location
local function getRandomCoords(table)
    local randomCoords = config.locations[math.random(#config.locations)]

    if table then
        for i = 1, #table do
            if table[i].coords == randomCoords then
                while randomCoords == table[i].coords do
                    randomCoords = config.locations[math.random(#config.locations)]
                    Wait(10)
                end
                break
            end
        end
    end

    return randomCoords
end

-- Start timer until explosion
local function initUnluckyTimer(source)
    if explosionTimers[source] then return end

    explosionTimers[source] = lib.timer(math.random(config.timeUntilExplosion.min, config.timeUntilExplosion.max) * 1000, function()
        local state = Player(source).state
        if state and state.stolenPackage then
            local model = state.stolenPackage.model
            if exports.ox_inventory:RemoveItem(source, 'stolen_package', 1) then
                TriggerClientEvent('xt-porchpirate:client:unlucky', source)
                explosionTimers[source] = nil
            end
        end
    end, true)
end

-- Receive item and create new location in globalstate
lib.callback.register('xt-porchpirate:server:pickupPackage', function(source, info)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local pickedUp = false

    local setLocations = {}
    for x = 1, #globalState.porchPackages do
        if (info.coords == globalState.porchPackages[x].coords) and #(globalState.porchPackages[x].coords - playerCoords) <= 2 then
            if exports.ox_inventory:AddItem(source, 'stolen_package', 1, { model = info.model }) then -- Add item, set model metadata
                local coords = getRandomCoords(setLocations)
                while coords == info.coords do
                    coords = getRandomCoords(setLocations)
                    Wait(10)
                end

                setLocations[x] = {
                    coords = coords,
                    model = models[math.random(#models)].model
                }

                pickedUp = true
            else
                setLocations[x] = globalState.porchPackages[x]
            end
        else
            setLocations[x] = globalState.porchPackages[x]
        end
    end

    globalState.porchPackages = setLocations

    if pickedUp then
        local state = Player(source).state
        if state then
            state:set('stolenPackage', {
                model = info.model,
                hasPackage = true
            }, true)
        end

        local unluckyChance = math.random(1, 100)
        if unluckyChance <= config.chanceOfExplosion then
            initUnluckyTimer(source)
        end
    end

    return pickedUp
end)

-- Useable item
exports('stolen_package', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local randomItem = config.packageItems[math.random(#config.packageItems)]
        if exports.ox_inventory:AddItem(inventory.id, randomItem[1], randomItem[2]) then
            local state = Player(inventory.id).state
            if state then
                state:set('stolenPackage', nil, true)
            end
            return true
        end
        return
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(1000)

    local setLocations = {}
    local max = (config.maxPackages < #config.locations) and config.maxPackages or #config.locations

    for x = 1, max do
        local randomCoords = getRandomCoords(setLocations)

        setLocations[x] = {
            coords = randomCoords,
            model = models[math.random(#models)].model
        }
    end

    globalState.porchPackages = setLocations

    lib.print.info(setLocations)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    globalState.porchPackages = false
end)