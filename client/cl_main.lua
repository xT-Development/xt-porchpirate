local lib = lib
local Renewed = exports['Renewed-Lib']
local packages = lib.load('client.packages')
local utils = lib.load('client.utils')

-- Localized
local AddExplosion = AddExplosion
local GetPlayerPed = GetPlayerPed
local ClearPedTasks = ClearPedTasks
local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist
local IsEntityPlayingAnim = IsEntityPlayingAnim
local globalState = GlobalState
local playerState = LocalPlayer.state

local createdPackages = {}

playerState:set('stolenPackage', nil, true)

-- Package Explodes
RegisterNetEvent('xt-porchpirate:client:unlucky', function()
    if not playerState.stolenPackage then return end

    local object = playerState.stolenPackage.object
    Entity(object).state:set('entityParticle', {
        offset = vec3(0,0, 0),
        rotation = vec3(0,0,0),
        dict = 'proj_xmas_firework',
        effect = 'scr_firework_xmas_burst_rgw',
        scale = 0.8
    }, true)

    local explosionCoords = GetEntityCoords(object)
    AddExplosion(explosionCoords.x, explosionCoords.y, explosionCoords.z, 70, 0.1, true, true, 1.0, false)
    Wait(500)
    playerState:set('stolenPackage', nil, true)
end)

-- Globalstate for packages
local function setPackageLocations(allPackages)
    if not allPackages then
        for x = 1, #createdPackages do
            Renewed:removeObject(createdPackages[x].id)
        end
        return
    end

    for x = 1, #allPackages do
        if createdPackages[x] then
            local _, object = Renewed:getObject(createdPackages[x].objectId)
            if (createdPackages[x].coords ~= allPackages[x].coords) then
                if (object and DoesEntityExist(object.object)) then
                    Renewed:removeObject(createdPackages[x].objectId)
                end

                createdPackages[x] = packages.createNewPackage(allPackages[x], x)
            end
        else
            createdPackages[x] = packages.createNewPackage(allPackages[x], x)
        end
    end
end

AddStateBagChangeHandler('porchPackages', nil, function(bagName, _, allPackages)
    if bagName ~= 'global' then return end
    setPackageLocations(allPackages)
end)

-- Player stolen package state
AddStateBagChangeHandler('stolenPackage', nil, function(bagName, _, value)
    local player = GetPlayerFromStateBagName(bagName)
    if player == 0 then return end
    if GetPlayerPed(player) ~= cache.ped then return end

    local _, object = Renewed:getObject('stolen_package')
    if not value then
        if object and DoesEntityExist(object.object) then
            Renewed:removeObject('stolen_package')
        end
        return
    else
        if not object then
            playerState:set('stolenPackage', {
                object = utils.attachBox(value.model),
                hasPackage = true,
                model = value.model
            }, true)
        end

        CreateThread(function()
            while playerState.stolenPackage do
                if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                    lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, false, false, false)
                end
                utils.disableControls()
                Wait(1)
            end
            ClearPedTasks(cache.ped)
        end)
    end
end)

-- Unload objects
local function unloadPackages()
    for x = 1, #createdPackages do
        Renewed:removeObject(createdPackages[x].objectId)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    unloadPackages()
end)

AddEventHandler('Renewed-Lib:client:PlayerLoaded', function()
    Wait(1000)
    setPackageLocations(globalState.porchPackages)
end)

AddEventHandler('Renewed-Lib:client:PlayerUnloaded', function()
    unloadPackages()
end)