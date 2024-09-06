local lib = lib
local Renewed = exports['Renewed-Lib']
local packages = lib.load('client.packages')
local utils = lib.load('client.utils')

-- Localized
local DeleteObject = DeleteObject
local AddExplosion = AddExplosion
local DeleteEntity = DeleteEntity
local ClearPedTasks = ClearPedTasks
local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist
local IsEntityPlayingAnim = IsEntityPlayingAnim
local globalState = GlobalState
local playerState = LocalPlayer.state

local createdPackages = {}
local PlayersCarrying = {}

playerState:set('stolenPackage', nil, true)

-- Removes package from stored players
local function removePlayerPackage(serverId)
    local packageEntity = PlayersCarrying[serverId]

    if packageEntity then
        DeleteObject(packageEntity)
        PlayersCarrying[serverId] = nil
    end
end

-- Carry Loop
local function initCarryLoop(ped)
    if ped ~= cache.ped then return end

    CreateThread(function()
        while playerState.stolenPackage and playerState.stolenPackage?.hasPackage do
            if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
                lib.playAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, false, false, false)
            end
            utils.disableControls()
            Wait(1)
        end
        ClearPedTasks(ped)
    end)
end

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

-- Package Explodes
RegisterNetEvent('xt-porchpirate:client:unlucky', function()
    if not playerState.stolenPackage then return end

    local packageEntity = PlayersCarrying[cache.serverId]
    local state = Entity(packageEntity).state
    if state then
        Entity(packageEntity).state:set('entityParticle', {
            offset = vec3(0,0, 0),
            rotation = vec3(0,0,0),
            dict = 'proj_xmas_firework',
            effect = 'scr_firework_xmas_burst_rgw',
            scale = 0.8
        }, true)
    end

    local explosionCoords = GetEntityCoords(packageEntity)
    AddExplosion(explosionCoords.x, explosionCoords.y, explosionCoords.z, 70, 0.1, true, true, 1.0, false)
    Wait(500)
    playerState:set('stolenPackage', nil, true)
end)

AddStateBagChangeHandler('porchPackages', nil, function(bagName, _, allPackages)
    if bagName ~= 'global' then return end
    setPackageLocations(allPackages)
end)

-- Player stolen package state
AddStateBagChangeHandler('stolenPackage', nil, function(bagName, keyName, value)
    local player = GetPlayerFromStateBagName(bagName)
    if player == 0 then return end
    local serverId, pedHandle = utils.getEntityFromStateBag(bagName, keyName)

    if serverId and not value then
        return removePlayerPackage(serverId)
    end

    local newPackage
    if pedHandle > 0 then
        local attachedPackage = PlayersCarrying[serverId]
        if attachedPackage and DoesEntityExist(attachedPackage) then
            DeleteEntity(attachedPackage)
        end

        newPackage = utils.createCarryingModel(value.model)
        if newPackage then
            utils.attachBoxToPlayer(value.model, newPackage, pedHandle)
            initCarryLoop(pedHandle)
        end
    end

    PlayersCarrying[serverId] = newPackage
end)

-- Unload objects
local function unloadPackages()
    for x = 1, #createdPackages do
        Renewed:removeObject(createdPackages[x].objectId)
    end

    for serverId in pairs(PlayersCarrying) do
        removePlayerPackage(serverId)
    end
end

RegisterNetEvent('onPlayerDropped', function(serverId)
    removePlayerPackage(serverId)
end)

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