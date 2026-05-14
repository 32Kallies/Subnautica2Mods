local CommandUtils = require("CommandUtils")
local UEHelpers = require("UEHelpers")

---Gets a spawn position for an entity in front of the player
---@param centimeters_forward integer
---@return FVector
local function getSpawnPosition(centimeters_forward)
    local player = UEHelpers:GetPlayerController()
    local pawn = player.Pawn

    local camera_rotation = player:GetControlRotation()
    local forward = CommandUtils.RotationToForward(camera_rotation)

    local currentPos = pawn:K2_GetActorLocation()

    return {
        X = currentPos.X + forward.X * centimeters_forward,
        Y = currentPos.Y + forward.Y * centimeters_forward,
        Z = currentPos.Z + forward.Z * centimeters_forward
    }
end

---Loads a class into memory and then summons it.
---Comparable to the Summon command, but works more consistently.
---Examples:
---SafeSummon /Game/Blueprints/AI/Agents/LargeCreature024_Waxmoon/BP_Waxmoon.BP_Waxmoon_C
---SafeSummon /Game/Blueprints/AI/Agents/LargeCreature001_Hammerhead/BP_Hammerhead.BP_HammerHead_C
local function safeSummon(args)
    if #args < 2 then
        print("This command expects a parameter for the blueprint path")
    end
    local class = args[2]
    print("Summoning entity by path " .. class .. "\n")
    ExecuteInGameThread(function()
        local loaded = CommandUtils.LoadClassByPath(class)
        local world = UEHelpers:GetWorld()
        world:SpawnActor(loaded, getSpawnPosition(500), {})
    end)
end

return safeSummon