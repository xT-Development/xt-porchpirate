local config        = lib.load('configs.server')
local MODELS        = lib.load('configs.models')
local UTILS         = lib.load('modules.server.utils')
local EXPLOSIONS    = lib.load('modules.server.explosions')
local OX_INV        = exports.ox_inventory
local globalState   = GlobalState

-- Receive item and create new location in globalstate
lib.callback.register('xt-porchpirate:server:pickupPackage', function(source, info)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local pickedUp = false

    local setLocations = {}
    for x = 1, #globalState.porchPackages do
        if (info.coords == globalState.porchPackages[x].coords) and #(globalState.porchPackages[x].coords - playerCoords) <= 2 then
            if OX_INV:AddItem(source, 'stolen_package', 1, { model = info.model }) then -- Add item, set model metadata
                local coords = UTILS.getRandomCoords(setLocations)
                while coords == info.coords do
                    coords = UTILS.getRandomCoords(setLocations)
                    Wait(10)
                end

                setLocations[x] = {
                    coords = coords,
                    model = MODELS[math.random(#MODELS)].model
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
                hasPackage = true,
                explode = false
            }, true)
        end

        local unluckyChance = math.random(1, 100)
        if unluckyChance <= config.chanceOfExplosion then
            EXPLOSIONS.startTimer(source)
        end
    end

    return pickedUp
end)

-- delete package w/ elevated perms
lib.callback.register('xt-porchpirate:server:deletePackage', function(source, info)
    if not IsPlayerAceAllowed(source, config.managePackagesPermission) then return end

    local removed = false
    local setLocations = {}
    for x = 1, #globalState.porchPackages do
        if x == info.id and info.coords == globalState.porchPackages[x].coords then
            local setCoords = UTILS.getRandomCoords(setLocations)
            while info.coords == setCoords do
                setCoords = UTILS.getRandomCoords(setLocations)
                Wait(10)
            end

            setLocations[x] = {
                coords = setCoords,
                model = MODELS[math.random(#MODELS)].model
            }

            removed = true
        else
            setLocations[x] = globalState.porchPackages[x]
        end
    end

    globalState.porchPackages = setLocations

    return removed
end)

-- Useable item
exports('stolen_package', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local randomItem = config.packageItems[math.random(#config.packageItems)]
        if OX_INV:AddItem(inventory.id, randomItem[1], randomItem[2]) then
            local state = Player(inventory.id).state
            if state then
                state:set('stolenPackage', nil, true)
            end

            return true
        end

        return
    end
end)

-- create random packages
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(1000)

    local setLocations = {}
    local max = (config.maxPackages < #config.locations) and config.maxPackages or #config.locations

    for x = 1, max do
        local randomCoords = UTILS.getRandomCoords(setLocations)

        setLocations[x] = {
            coords = randomCoords,
            model = MODELS[math.random(#MODELS)].model
        }
    end

    globalState.porchPackages = setLocations
end)

-- remove all packages
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    globalState.porchPackages = false
end)

lib.addCommand('porchpirate', {
    help = '[ADMIN] View/manage porch pirate packages',
    params = {},
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent('xt-porchpirate:client:openMenu', source)
end)