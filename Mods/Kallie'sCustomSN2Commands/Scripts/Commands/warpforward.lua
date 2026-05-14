local UEHelpers = require("UEHelpers")

local function rotationToForward(rot)
    local pitch = math.rad(rot.Pitch)
    local yaw = math.rad(rot.Yaw)

    return {
        X = math.cos(pitch) * math.cos(yaw),
        Y = math.cos(pitch) * math.sin(yaw),
        Z = math.sin(pitch)
    }
end

-- WARPFORWARD [CENTIMETERS]
local function warpforward(args)
    local player = UEHelpers:GetPlayerController()
    local pawn = player.Pawn

    local distance = tonumber(args[2]) or 500

    local camera_rotation = player:GetControlRotation()
    local forward = rotationToForward(camera_rotation)

    local currentPos = pawn:K2_GetActorLocation()

    local position = {
        X = currentPos.X + forward.X * distance,
        Y = currentPos.Y + forward.Y * distance,
        Z = currentPos.Z + forward.Z * distance
    }

    -- Both functions seem to be necessary to move the player, for some reason
    pawn:K2_TeleportTo(position, {})
    pawn:K2_SetActorLocation(position, false, {}, false)
end

return warpforward