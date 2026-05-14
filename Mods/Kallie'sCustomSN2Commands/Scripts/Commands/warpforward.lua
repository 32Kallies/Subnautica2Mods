local UEHelpers = require("UEHelpers")
local CommandUtils = require("CommandUtils")

-- WARPFORWARD [CENTIMETERS]
local function warpforward(args)
    local player = UEHelpers:GetPlayerController()
    local pawn = player.Pawn

    local distance = tonumber(args[2]) or 500

    local camera_rotation = player:GetControlRotation()
    local forward = CommandUtils.RotationToForward(camera_rotation)

    local currentPos = pawn:K2_GetActorLocation()

    local position = {
        X = currentPos.X + forward.X * distance,
        Y = currentPos.Y + forward.Y * distance,
        Z = currentPos.Z + forward.Z * distance
    }

   CommandUtils.TeleportPlayer(position)
end

return warpforward