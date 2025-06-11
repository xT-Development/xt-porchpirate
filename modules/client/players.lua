local playersCarrying = {}

local DeleteObject = DeleteObject

local playerUtils = {}

-- get players currently carrying packages
function playerUtils.getPlayersCarrying()
    return playersCarrying
end

-- get spawned package by player id
function playerUtils.getPlayerPackage(serverId)
    return playersCarrying[serverId] or false
end

-- remove player package
function playerUtils.removePlayerPackage(serverId)
    local packageEntity = playersCarrying[serverId]

    if packageEntity then
        DeleteObject(packageEntity)
        playersCarrying[serverId] = nil
    end
end

function playerUtils.setPlayerPackage(serverId, packageEntity)
    playersCarrying[serverId] = packageEntity
end

return playerUtils