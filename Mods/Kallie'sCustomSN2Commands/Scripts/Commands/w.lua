local UEHelpers = require("UEHelpers")

local METERS_TO_CM <const> = 100

local function rotationToForward(rot)
    local pitch = math.rad(rot.Pitch)
    local yaw = math.rad(rot.Yaw)

    return {
        X = math.cos(pitch) * math.cos(yaw),
        Y = math.cos(pitch) * math.sin(yaw),
        Z = math.sin(pitch)
    }
end

-- like warpforward, but this shorthand uses meters
-- w [METERS]
local function w(args)
    local player = UEHelpers:GetPlayerController()
    local pawn = player.Pawn

    local distance = (tonumber(args[2]) or 5) * METERS_TO_CM

    local camera_rotation = player:GetControlRotation()
    local forward = rotationToForward(camera_rotation)

    local current_pos = pawn:K2_GetActorLocation()

    local position = {
        X = current_pos.X + forward.X * distance,
        Y = current_pos.Y + forward.Y * distance,
        Z = current_pos.Z + forward.Z * distance
    }

    -- Both functions seem to be necessary to move the player, for some reason
    pawn:K2_TeleportTo(position, {})
    pawn:K2_SetActorLocation(position, false, {}, false)
end

return w