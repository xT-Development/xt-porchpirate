local Renewed = exports['Renewed-Lib']
local utils = lib.load('client.utils')
local config = lib.load('configs.client')
local playerState = LocalPlayer.state

local packages = {}

function packages.pickupPackage(info)
    lib.playAnim(cache.ped, 'veh@common@bicycle@ds', 'pickup', 8.0, 8.0, 300)
    Wait(300)
    local pickedUp = lib.callback.await('xt-porchpirate:server:pickupPackage', false, info)
    if pickedUp then
        local coords = GetEntityCoords(cache.ped)
        local policeChance = math.random(100)
        if policeChance <= config.chanceOfPolice then
            config.dispatch(coords)
        end
    end
end

function packages.createNewPackage(info, id)
    local newPackage = Renewed:addObject({
        id = ('porch_package_%s'):format(id),
        model = info.model,
        coords = info.coords,
        heading = 0,
        freeze = true,
        snapGround  = true,
        target = {
            {
                label = 'Steal Package',
                icon = 'fas fa-box',
                onSelect = function()
                    packages.pickupPackage(info)
                end
            }
        }
    })

    local _, object = Renewed:getObject(('porch_package_%s'):format(id))

    return object
end

return packages