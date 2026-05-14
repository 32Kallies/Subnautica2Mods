local base_slots = 5 -- this very well could change and therefore slightly break between updates

local config = require("config")

---@param tag string
---@return FGameplayTag
local function makeGameplayTag(tag)
    return { TagName = FName(tag) }
end

--- The toolbar space can be increased multiple times (there seems to be no limit)
---@param desired_slots integer
local function setQuickSlots(desired_slots)
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    local get_event_tracker = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")

    ---@type UUWEEventTrackerComponent
    local tracker = get_event_tracker(context, context)

    local increase_toolbar = makeGameplayTag("EventTracker.IncreaseToolbar")
    local permanent = makeGameplayTag("PermanentUpgrades.Toolbar")

    local current_extra_slots = tracker:GetValue(increase_toolbar, permanent)
    local slots_to_add = desired_slots - (base_slots + current_extra_slots)
    if slots_to_add ~= 0 then
        tracker:Notify(increase_toolbar, permanent, slots_to_add)
    end
end

NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function()
    setQuickSlots(config.DesiredQuickSlots)
end)