local UEHelpers = require("UEHelpers")
local CommandUtils = require("CommandUtils")

-- WARP [X] [Y] [Z]
local function warp(args)
    local player = UEHelpers:GetPlayerController()
    local position = {
        X=tonumber(args[2]),
        Y=tonumber(args[3]),
        Z=tonumber(args[4])
    }
    
    CommandUtils.TeleportPlayer(position)
end

return warp