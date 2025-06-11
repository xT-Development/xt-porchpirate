local config            = lib.require('configs.client')
local PLAYER_PACKAGES   = lib.require('modules.client.players')

local playerState = LocalPlayer.state
local createdPackages = {}

local DeleteObject = DeleteObject
local GetEntityCoords = GetEntityCoords

local packages = {}

-- get all spawned packages
function packages.getAllPackages()
    return createdPackages or false
end

-- pick up a spawned package
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

-- spawns a new package
function packages.createNewPackage(info, id)
    local newPackage = Renewed.addObject({
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

    local _, object = Renewed.getObject(('porch_package_%s'):format(id))

    return object
end

-- remove all spawned packages
function packages.removeAllPackages()
    for x = 1, #createdPackages do
        Renewed.removeObject(createdPackages[x].objectId)
    end

    local playersCarrying = PLAYER_PACKAGES.getPlayersCarrying()
    if not playersCarrying or not next(playersCarrying) then return end -- No players carrying, nothing to remove

    for serverId in pairs(playersCarrying) do
        PLAYER_PACKAGES.removePlayerPackage(serverId)
    end
end

-- get spawned package by id
function packages.getPackage(id)
    return createdPackages[id] or false
end

return packages