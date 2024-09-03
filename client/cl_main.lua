local config = lib.load('configs.client')
local models = lib.load('configs.models')
local globalState = GlobalState
local createdPackages = {}
local carryingPackage, packageEntity = false, nil

local function getModelAttachInfo(model)
    for x = 1, #models do
        if models[x].model == model then
            return models[x].pos, models[x].rot
        end
    end
end

local function attachBox(model)
    local coords = GetEntityCoords(cache.ped)
    local pos, rot = getModelAttachInfo(model)

    packageEntity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(packageEntity, false, false)
    AttachEntityToEntity(packageEntity, cache.ped, GetPedBoneIndex(cache.ped, 60309), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
end

local function pickupPackage(info)
    carryingPackage = true

    lib.playAnim(cache.ped, 'veh@common@bicycle@ds', 'pickup', 8.0, 8.0, 500)
    Wait(500)
    local pickedUp = lib.callback.await('xt-porchpirate:server:pickupPackage', false, info)
    if pickedUp then
        attachBox(info.model)

        local unluckyChance = math.random(1, 100)
        if unluckyChance <= config.chanceOfExplosion then
            local timer = lib.timer(5000, function()
                local playerCoords = GetEntityCoords(packageEntity)
                AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 70, 0.1, false, false, false, false)

                if packageEntity and DoesEntityExist(packageEntity) then
                    DeleteEntity(packageEntity)
                    carryingPackage = false
                end
            end, true)
        end
        CreateThread(function()
            while carryingPackage do
                if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                    lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, false, false, false)
                end
                Wait(1)
            end
            ClearPedTasks(cache.ped)
        end)
    end
end

local function createNewPackage(info)
    lib.requestModel(info.model)

    local newPackage = CreateObjectNoOffset(info.model, info.coords.x, info.coords.y, info.coords.z, false, true, false)

    SetModelAsNoLongerNeeded(info.model)
    PlaceObjectOnGroundProperly(newPackage)
    SetDisableFragDamage(newPackage, true)

    exports.ox_target:addLocalEntity(newPackage, {
        {
            label = 'Steal Package',
            icon = 'fas fa-box',
            onSelect = function()
                pickupPackage(info)
            end
        }
    })

    return newPackage
end

AddStateBagChangeHandler('porchPackages', nil, function(bagName, _, packages)
    if bagName ~= 'global' then return end

    if not packages then
        for x = 1, #createdPackages do
            if DoesEntityExist(createdPackages[x].entity) then
                DeleteEntity(createdPackages[x].entity)
            end
        end
        return
    end

    for x = 1, #packages do
        if createdPackages[x] then
            if createdPackages[x].coords ~= packages[x].coords and DoesEntityExist(createdPackages[x].entity) then
                DeleteEntity(createdPackages[x].entity)

                createdPackages[x] = {
                    coords = packages[x].coords,
                    entity = createNewPackage(packages[x])
                }
            end
        else
            createdPackages[x] = {
                coords = packages[x].coords,
                entity = createNewPackage(packages[x])
            }
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for x = 1, #createdPackages do
        if DoesEntityExist(createdPackages[x].entity) then
            DeleteEntity(createdPackages[x].entity)
        end
    end

    if packageEntity and DoesEntityExist(packageEntity) then
        DeleteEntity(packageEntity)
    end
end)