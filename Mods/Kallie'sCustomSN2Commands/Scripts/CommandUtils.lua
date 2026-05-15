local CommandUtils = {}
local UEHelpers = require("UEHelpers")

---Teleports the players to the given coordinates (in centimeters)
---@param position FVector
function CommandUtils.TeleportPlayer(position)
    local player = UEHelpers:GetPlayerController()
    player.Pawn:K2_TeleportTo(position, {})
    player.Pawn:K2_SetActorLocation(position, false, {}, false)
    print(string.format(
        "Teleported player to (%.0f, %.0f, %.0f) for goto command\n",
        position.X,
        position.Y,
        position.Z
    ))
end

---Allows package paths from FModel to be directly understood, saving a lot of time!
---Example input A: Subnautica2/Content/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01
---Example input B: /Game/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01.BP_Cerathecan_01_C 
---Example output:  /Game/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01.BP_Cerathecan_01_C
---@param path string
---@return string
function CommandUtils.CorrectClassPath(path)
    -- remove .uasset, we don't want that
    path = path:gsub("%.uasset$", "")
    -- E.g.: Subnautica2/Content/path_to_asset_without.something_C
    local actual_path, bp_name = path:match("^Subnautica2/Content/(.+)/([^/]+)$")

    if actual_path and bp_name then
        return string.format(
            "/Game/%s/%s.%s_C",
            actual_path,
            bp_name,
            bp_name
        )
    end

    return path
end

---Loads a class by its path, even if it wasn't previously loaded into memory.
---Not sure if a better alternative exists.
---@param path string
---@return UClass
function CommandUtils.LoadClassByPath(path)
    local UEHelpers = require("UEHelpers")
    local load = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadClassAsset_Blocking")
    local kismet_library = StaticFindObject("/Script/Engine.KismetSystemLibrary")
    local make_soft = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftClassPath")
    local convert = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftClassPathToSoftClassRef")

    local soft_class_path = make_soft(kismet_library, path)
    local pointer = convert(kismet_library, soft_class_path)
    local world = UEHelpers.GetWorld()

    local loaded = load(world, pointer)
    return loaded
end

---Converts a rotation struct to an FVector in the same direction
---@param rot FRotator
---@return FVector
function CommandUtils.RotationToForward(rot)
    local pitch = math.rad(rot.Pitch)
    local yaw = math.rad(rot.Yaw)

    return {
        X = math.cos(pitch) * math.cos(yaw),
        Y = math.cos(pitch) * math.sin(yaw),
        Z = math.sin(pitch)
    }
end

return CommandUtils