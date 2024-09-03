local config = lib.load('configs.server')
local models = lib.load('configs.models')
local globalState = GlobalState

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

lib.callback.register('xt-porchpirate:server:pickupPackage', function(source, info)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local pickedUp = false

    local setLocations = {}
    for x = 1, #globalState.porchPackages do
        if info.coords == globalState.porchPackages[x].coords and #(globalState.porchPackages[x].coords - playerCoords) <= 2 then
            if exports.ox_inventory:AddItem(source, config.packageName, 1) then
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

    return pickedUp
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