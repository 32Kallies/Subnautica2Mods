-- CORE INFO

local mod_name = "Kallie's Custom Commands"
local version = "1.4.0"

-- Using

local CommandUtils = {}
local UEHelpers = require("UEHelpers")

local ksl = StaticFindObject("/Script/Engine.KismetSystemLibrary")
local ksl_load_class_blocking = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadClassAsset_Blocking")
local ksl_load_asset_blocking = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadAsset_Blocking")
local ksl_make_soft_class = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftClassPath")
local ksl_make_soft_object = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftObjectPath")
local ksl_convert_class_path_to_soft_ref = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftClassPathToSoftClassRef")
local ksl_convert_object_ref_to_obj_ref = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftObjPathToSoftObjRef")

---@type UClass
local fmod_event_class = StaticFindObject("/Script/FMODStudio.FMODEvent")

--[[FUNCTIONS]]

---Logs the given message.
---@param message string
function CommandUtils.Log(message)
    print(string.format("[%s v%s] %s\n", mod_name, version, message))
end

---Splits a string by spaces
---@param input string
---@return table
function CommandUtils.SplitBySpace(input)
    local parts = {}
    for token in string.gmatch(input, "%S+") do
        table.insert(parts, token)
    end
    return parts
end

---Splits a string by a pattern
---@param input string
---@param pattern string
---@return table
function CommandUtils.Split(input, pattern)
    local parts = {}
    for token in string.gmatch(input, pattern) do
        table.insert(parts, token)
    end
    return parts
end

---Teleports the players to the given coordinates (in centimeters)
---@param position FVector
function CommandUtils.TeleportPlayer(position)
    local player = UEHelpers:GetPlayerController()
    player.Pawn:K2_TeleportTo(position, {})
    player.Pawn:K2_SetActorLocation(position, false, {}, false)
    CommandUtils.Log(string.format(
        "Teleported player to (%.0f, %.0f, %.0f) for goto command",
        position.X,
        position.Y,
        position.Z
    ))
end

---Allows package paths from FModel to be directly understood, saving a lot of time!
---Example input A: Subnautica2/Content/Art/Items/CopperWire/SM_CopperWire
---Example input B: /Game/Art/Items/CopperWire/SM_CopperWire
---Example output:  /Game/Art/Items/CopperWire/SM_CopperWire
---@param path string
---@return string
function CommandUtils.CorrectClassPath(path)
    -- remove .uasset, we don't want that
    path = path:gsub("%.uasset$", "")
    -- E.g.: Subnautica2/Content/path_to_asset_without.something_C
    local actual_path, bp_name = path:match("^Subnautica2/Content/(.+)/([^/]+)$")

    if actual_path and bp_name then
        return string.format(
            "/Game/%s/%s.%s",
            actual_path,
            bp_name,
            bp_name
        )
    end

    return path
end

---Allows package paths from FModel to be directly understood, saving a lot of time!
---Example input A: Subnautica2/Content/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01
---Example input B: /Game/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01.BP_Cerathecan_01_C 
---Example output:  /Game/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01.BP_Cerathecan_01_C
---@param path string
---@return string
function CommandUtils.CorrectBlueprintPath(path)
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
    ---@type FSoftClassPath
    local soft_class_path = ksl_make_soft_class(ksl, path)
    ---@type TSoftClassPtr<UObject>
    local pointer = ksl_convert_class_path_to_soft_ref(ksl, soft_class_path)
    local world = UEHelpers.GetWorld()

    ---@type UClass
    local loaded = ksl_load_class_blocking(world, pointer)
    return loaded
end

---Loads a UObject by its path, even if it wasn't previously loaded into memory.
---@generic T: UObject
---@param path string
---@return T
function CommandUtils.LoadAssetByPath(path)
    ---@type FSoftObjectPath
    local soft_object_path = ksl_make_soft_object(ksl, path)

    ---@type TSoftObjectPtr<UObject>
    local pointer = ksl_convert_object_ref_to_obj_ref(ksl, soft_object_path)
    local world = UEHelpers.GetWorld()

    ---@type UObject
    local loaded = ksl_load_asset_blocking(world, pointer)
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

---Gets a spawn position for an entity in front of the player
---@param centimeters_forward integer
---@return FVector
function CommandUtils.GetSpawnPosition(centimeters_forward)
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

---Converts a GUID string such as 8429A379-54374E08-B506FAC9-307FDCCB into a 128-bit GUID
---@param guid_string string
---@return FGuid
function CommandUtils.ParseGuid(guid_string)
    local separated = CommandUtils.Split(guid_string, "%x+")
    if #separated ~= 4 then
        CommandUtils.Log("Invalid GUID: " .. guid_string)
        return {}
    end

    ---@type FGuid
    local guid = {
        A = tonumber(separated[1], 16),
        B = tonumber(separated[2], 16),
        C = tonumber(separated[3], 16),
        D = tonumber(separated[4], 16)
   }

   return guid
end

---Creates an FMOD Asset with the given sound GUID
---@param guid FGuid
---@return UFMODEvent
function CommandUtils.CreateFMODAsset(guid)
    local world = UEHelpers.GetWorld()
    ---@type UFMODEvent
    local fmod_event = StaticConstructObject(fmod_event_class, world)
    fmod_event.AssetGuid = guid
    return fmod_event
end

return CommandUtils