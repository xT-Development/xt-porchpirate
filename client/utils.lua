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

function utils.attachBox(model)
    local coords = GetEntityCoords(cache.ped)
    local pos, rot = utils.getModelAttachInfo(model)

    Renewed:addObject({
        id = 'stolen_package',
        model = model,
        coords = coords,
        freeze = false,
        snapGround  = false,
        colissions = false,
    })

    local _, object = Renewed:getObject('stolen_package')

    while object and not object.object do
        _, object = Renewed:getObject('stolen_package')
        Wait(10)
    end

    AttachEntityToEntity(object.object, cache.ped, GetPedBoneIndex(cache.ped, 60309), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)

    return object.object
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