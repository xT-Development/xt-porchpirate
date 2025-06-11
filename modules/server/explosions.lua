local config = lib.require('configs.server')
local explosionTimers = {}

local explosions = {}

-- start player explosion timer
function explosions.startTimer(source)
    explosionTimers[source] = lib.timer(math.random(config.timeUntilExplosion.min, config.timeUntilExplosion.max) * 1000, function()
        local state = Player(source).state
        if state and state.stolenPackage then
            local model = state.stolenPackage.model
            if exports.ox_inventory:RemoveItem(source, 'stolen_package', 1) then
                local state = Player(source).state
                if state then
                    state:set('entityParticle', { -- need to rework this to play particle on package entity, rather than the player
                        offset = vec3(0, 0, 0),
                        rotation = vec3(0,0,0),
                        dict = 'proj_xmas_firework',
                        effect = 'scr_firework_xmas_burst_rgw',
                        scale = 0.8
                    }, true)

                    state:set('stolenPackage', {
                        model = state.stolenPackage.model,
                        hasPackage = true,
                        explode = true -- set to true, trigger explosion
                    }, true)

                    Wait(1000)
                    state:set('stolenPackage', nil, true)
                end
                explosionTimers[source] = nil
            end
        end
    end, true)
end

-- get player timer
function explosions.getPlayerTimer(source)
    return explosionTimers[source] or false
end

return explosions