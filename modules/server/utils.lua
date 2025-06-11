local config = lib.require('configs.server')

local utils = {}

function utils.getRandomCoords(table)
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

return utils