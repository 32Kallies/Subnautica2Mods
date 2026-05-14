local UEHelpers = require("UEHelpers")
local CommandUtils = require("CommandUtils")

local METERS_TO_CM <const> = 100

-- like warpforward, but this shorthand uses meters
-- w [METERS]
local function w(args)
    local player = UEHelpers:GetPlayerController()
    local pawn = player.Pawn

    local distance = (tonumber(args[2]) or 5) * METERS_TO_CM

    local camera_rotation = player:GetControlRotation()
    local forward = CommandUtils.RotationToForward(camera_rotation)

    local current_pos = pawn:K2_GetActorLocation()

    local position = {
        X = current_pos.X + forward.X * distance,
        Y = current_pos.Y + forward.Y * distance,
        Z = current_pos.Z + forward.Z * distance
    }

    CommandUtils.TeleportPlayer(position)
end

return w