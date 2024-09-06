local Renewed = exports['Renewed-Lib']
local models = lib.load('configs.models')

local utils = {}

function utils.getModelAttachInfo(model)
    for x = 1, #models do
        if models[x].model == model then
            return models[x].pos, models[x].rot
        end
    end
end

function utils.attachBoxToPlayer(model, package, ped)
    local pos, rot = utils.getModelAttachInfo(model)
    AttachEntityToEntity(package, ped, GetPedBoneIndex(ped, 60309), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
end

function utils.createCarryingModel(model)
    lib.requestModel(model, 1000)
    local newPackage = CreateObject(model, 0.0, 0.0, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(model)
    return newPackage
end

-- Credit: https://github.com/Renewed-Scripts/Renewed-Weaponscarry/blob/main/modules/utils.lua#L150
function utils.getEntityFromStateBag(bagName, keyName)

    if bagName:find('entity:') then
        local netId = tonumber(bagName:gsub('entity:', ''), 10)

        local entity =  lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then return NetworkGetEntityFromNetworkId(netId) end
        end, ('%s received invalid entity! (%s)'):format(keyName, bagName), 10000)

        return entity
    elseif bagName:find('player:') then
        local serverId = tonumber(bagName:gsub('player:', ''), 10)
        local playerId = GetPlayerFromServerId(serverId)

        local entity = lib.waitFor(function()
            local ped = GetPlayerPed(playerId)
            if ped > 0 then return ped end
        end, ('%s received invalid entity! (%s)'):format(keyName, bagName), 10000)

        return serverId, entity
    end

end

local DisableControlAction = DisableControlAction
function utils.disableControls()
    DisableControlAction(0, 22, true) -- Jump
    DisableControlAction(0, 23, true) -- F / Enter
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 36, true) -- Duck
    DisableControlAction(0, 47, true) -- G
    DisableControlAction(0, 58, true) -- G
    DisableControlAction(0, 140, true) -- Light melee
    DisableControlAction(0, 141, true) -- Heavy melee
    DisableControlAction(0, 142, true) -- Melee alt
    DisableControlAction(0, 143, true) -- Melee block
    DisableControlAction(0, 257, true) -- Attack 2
    DisableControlAction(0, 263, true) -- R Melee
    DisableControlAction(0, 264, true) -- Q Melee
end

return utils