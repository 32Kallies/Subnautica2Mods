-- CORE INFO

local mod_name = "Kallie's Custom Commands"
local version = "1.3.0"

-- Using

local CommandUtils = {}
local UEHelpers = require("UEHelpers")

local ksl = StaticFindObject("/Script/Engine.KismetSystemLibrary")
local ksl_load_blocking = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadClassAsset_Blocking")
local ksl_make_soft = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftClassPath")
local ksl_convert_path_to_soft_ref = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftClassPathToSoftClassRef")

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
    ---@type FSoftClassPath
    local soft_class_path = ksl_make_soft(ksl, path)
    ---@type TSoftClassPtr<UObject>
    local pointer = ksl_convert_path_to_soft_ref(ksl, soft_class_path)
    local world = UEHelpers.GetWorld()

    ---@type UClass
    local loaded = ksl_load_blocking(world, pointer)
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