local UEHelpers = require("UEHelpers")

-- WARP [X] [Y] [Z]
local function warp(args)
    local player = UEHelpers:GetPlayerController()
    local position = {
        X=tonumber(args[2]),
        Y=tonumber(args[3]),
        Z=tonumber(args[4])
    }
    
    -- Both of these functions seem to be necessary to move the player
    player.Pawn:K2_TeleportTo(position, {})
    player.Pawn:K2_SetActorLocation(position, false, {}, false)
end

return warp