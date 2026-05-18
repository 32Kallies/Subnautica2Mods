-- COMMON UTILITIES

local DEBUG = true
local mod_name = "ExtraPassiveBiomodSlots"
local version = "1.0.1"

---@param message string
local function modPrint(message)
    print(string.format("[%s v%s] %s\n", mod_name, version, message))
end

---@param message string
local function debugPrint(message)
    if DEBUG then
        print(string.format("[%s v%s DEBUG] %s\n", mod_name, version, message))
    end
end

--[[MAIN MOD BELOW]]

local config = require("config")

local base_slots = 1 -- this could change and therefore slightly break between updates

---@param tag string
---@return FGameplayTag
local function makeGameplayTag(tag)
    return { TagName = FName(tag) }
end

local function setPassiveBiomodSlots()
    modPrint("Setting passive biomod slots to " .. tostring(config.TotalPassiveSlots))
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    local get_event_tracker = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")

    ---@type UUWEEventTrackerComponent
    local tracker = get_event_tracker(context, context)

    local increase_passive_biomod_slots = makeGameplayTag("EventTracker.IncreasePassiveBiomodSlots")
    local permanent = makeGameplayTag("PermanentUpgrades.PassiveBiomodSlots")

    local current_extra_slots = tracker:GetValue(increase_passive_biomod_slots, permanent)
    local slots_to_add = config.TotalPassiveSlots - (base_slots + current_extra_slots)
    debugPrint("Slots to add: " .. tostring(slots_to_add))
    if slots_to_add ~= 0 then
        tracker:Notify(increase_passive_biomod_slots, permanent, slots_to_add)
        modPrint("Changed the number of unlocked biomod slots by " .. tostring(slots_to_add))
    else
        modPrint("Number of unlocked biomod slots did not change.")
    end
end

NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function()
    debugPrint("Player character created.")
    setPassiveBiomodSlots()
end)

modPrint("Mod fully registered.")