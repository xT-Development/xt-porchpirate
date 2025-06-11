local lib = lib
local PACKAGE_UTILS     = lib.require('modules.client.packages')
local PLAYER_UTILS      = lib.require('modules.client.players')
local UTILS             = lib.require('modules.client.utils')
local MENUS             = lib.require('modules.client.menus')
local globalState       = GlobalState
local playerState       = LocalPlayer.state

local AddExplosion = AddExplosion
local DeleteEntity = DeleteEntity
local ClearPedTasks = ClearPedTasks
local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist
local IsEntityPlayingAnim = IsEntityPlayingAnim

playerState:set('stolenPackage', nil, true)

-- Globalstate for packages
local function setPackageLocations(allPackages)
    local createdPackages = PACKAGE_UTILS.getAllPackages()

    if not allPackages or not next(allPackages) then -- if false/nil, remove all packages
        if createdPackages and next(createdPackages) then
            for x = 1, #createdPackages do
                Renewed.removeObject(createdPackages[x].id)
            end

            return
        end
    end

    -- create all packages from statebag
    for x = 1, #allPackages do
        if createdPackages[x] then
            local _, object = Renewed.getObject(createdPackages[x].objectId)
            if (createdPackages[x].coords ~= allPackages[x].coords) then -- Change coords of package if needed
                if (object and DoesEntityExist(object.object)) then
                    Renewed.removeObject(createdPackages[x].objectId) -- Delete
                end

                createdPackages[x] = PACKAGE_UTILS.createNewPackage(allPackages[x], x) -- Recreate
            end
        else -- Create new package
            createdPackages[x] = PACKAGE_UTILS.createNewPackage(allPackages[x], x)
        end
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
            UTILS.disableControls()

            Wait(1)
        end

        ClearPedTasks(ped)
    end)
end

-- open admin menu
RegisterNetEvent('xt-porchpirate:client:openMenu', function()
    if GetInvokingResource() then return end

    MENUS.viewAllPackages()
end)

--statebags

-- global statebag for all packages
AddStateBagChangeHandler('porchPackages', nil, function(bagName, _, allPackages)
    if bagName ~= 'global' then return end

    setPackageLocations(allPackages)
end)

-- Player stolen package state
AddStateBagChangeHandler('stolenPackage', nil, function(bagName, keyName, value)
    local player = GetPlayerFromStateBagName(bagName)
    if player == 0 then return end
    local serverId, pedHandle = UTILS.getEntityFromStateBag(bagName, keyName)

    if serverId and (not value?.model and not value?.hasPackage) then -- remove player package
        return PLAYER_UTILS.removePlayerPackage(serverId)
    end

    local newPackage
    if pedHandle > 0 then
        local attachedPackage = PLAYER_UTILS.getPlayerPackage(serverId)
        if attachedPackage and DoesEntityExist(attachedPackage) then
            if value.explode then -- explode package and return
                local explosionCoords = GetEntityCoords(attachedPackage)
                AddExplosion(explosionCoords.x, explosionCoords.y, explosionCoords.z, 70, 0.1, true, true, 1.0, false)
                DeleteEntity(attachedPackage)
                PLAYER_UTILS.removePlayerPackage(serverId)

                return
            else -- remove package and continue
                DeleteEntity(attachedPackage)
            end
        end

        newPackage = UTILS.createCarryingModel(value.model)
        if newPackage then
            UTILS.attachBoxToPlayer(value.model, newPackage, pedHandle)
            initCarryLoop(pedHandle)
        end
    end

    PLAYER_UTILS.setPlayerPackage(serverId, newPackage)
end)

-- handlers
RegisterNetEvent('onPlayerDropped', function(serverId)
    PLAYER_UTILS.removePlayerPackage(serverId)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    PACKAGE_UTILS.removeAllPackages()
end)

AddEventHandler('Renewed-Lib:client:PlayerLoaded', function()
    Wait(1000)
    setPackageLocations(globalState.porchPackages)
end)

AddEventHandler('Renewed-Lib:client:PlayerUnloaded', function()
    PACKAGE_UTILS.removeAllPackages()
end)