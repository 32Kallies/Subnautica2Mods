local config = require("config")

local base_slots = 1 -- this could change and therefore slightly break between updates

---@param tag string
---@return FGameplayTag
local function makeGameplayTag(tag)
    return { TagName = FName(tag) }
end

local function setPassiveBiomodSlots()
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    local get_event_tracker = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")

    ---@type UUWEEventTrackerComponent
    local tracker = get_event_tracker(context, context)

    local increase_passive_biomod_slots = makeGameplayTag("EventTracker.IncreasePassiveBiomodSlots")
    local permanent = makeGameplayTag("PermanentUpgrades.PassiveBiomodSlots")

    local current_extra_slots = tracker:GetValue(increase_passive_biomod_slots, permanent)
    local slots_to_add = config.TotalPassiveSlots - (base_slots + current_extra_slots)
    if slots_to_add ~= 0 then
        tracker:Notify(increase_passive_biomod_slots, permanent, slots_to_add)
    end
end

NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function()
    setPassiveBiomodSlots()
end)