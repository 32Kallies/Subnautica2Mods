---@param tag string
---@return FGameplayTag
local function makeGameplayTag(tag)
    return { TagName = FName(tag) }
end

--- The inventory space can be increased up to 5 times
---@param times integer
local function increaseInventorySize(times)
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    local get_event_tracker = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")

    ---@type UUWEEventTrackerComponent
    local tracker = get_event_tracker(context, context)

    local increase_inventory = makeGameplayTag("EventTracker.IncreaseInventory")
    local permanent_inventory = makeGameplayTag("PermanentUpgrades.Inventory")

    tracker:Notify(increase_inventory, permanent_inventory, times)
end

NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function()
    increaseInventorySize(5)
end)