-- COMMON UTILITIES

local DEBUG = true
local mod_name = "CopperFromScanning"

local UEHelpers = require("UEHelpers")

---@param message string
local function modPrint(message)
    print(string.format("[%s] %s\n", mod_name, message))
end

---@param message string
local function debugPrint(message)
    if DEBUG then
        print(string.format("[%s-DEBUG] %s\n", mod_name, message))
    end
end

-- MOD LOGIC

local item_on_scanning = "Copper"

-- STATIC FUNCTIONS
local UWEScanData = StaticFindObject("/Script/UWEScanner.UWEScanData")
local UWEScanData_GetScanDataForActor = StaticFindObject("/Script/UWEScanner.UWEScanData:GetScanDataForActor")

-- SN2Statics:GetLocalPlayerInventory -- returns a UUWEInventoryComponent instance
local SN2Statics = StaticFindObject("/Script/Subnautica2.SN2Statics")
local SN2Statics_GetLocalPlayerInventory = StaticFindObject("/Script/Subnautica2.SN2Statics:GetLocalPlayerInventory")

-- UUWEInventoryStatics:GetItemTypeFromName(ItemName, bPartial, bOutFound)
local UWEInventoryStatics = StaticFindObject("/Script/UWEInventory.UWEInventoryStatics")
local UWEInventoryStatics_GetItemTypeFromName = StaticFindObject("/Script/UWEInventory.UWEInventoryStatics:GetItemTypeFromName")

-- STATIC VARIABLES
local scanning_completed_object = false

-- HOOKS

Pre1, Post1 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:GetActorInstanceScannedProgressForPlayer",
function(Context, ScannedActor)
    debugPrint("Querying if should give copper")

    ---@type UUWEScannedActorsComponent
    local component = Context:get();

    ---@type AActor
    local scannedActor = ScannedActor:get()

    ---@type UUWEScanData
    local scanData = UWEScanData_GetScanDataForActor(UWEScanData, scannedActor)
    
    if DEBUG then
        debugPrint("Currently scanning: " .. scanData.Name:ToString())
    end

    scanning_completed_object = component:IsScanDataProgressComplete(scanData)

    if DEBUG then
        debugPrint("Complete: " .. tostring(scanning_completed_object))
    end
end
)

---Adds an item by its name
---@param item string
local function addItemToInventory(item)
    ---@type UUWEInventoryComponent
    local local_inventory = SN2Statics_GetLocalPlayerInventory(SN2Statics, SN2Statics)

    if local_inventory:IsFull() then
        modPrint("Inventory is full")
        return
    end

    -- contains a bOutFound boolean property
    local found_out = {}

    ---@type UUWEItemType
    local itemType = UWEInventoryStatics_GetItemTypeFromName(UWEInventoryStatics, item, false, found_out)

    if not (found_out.bOutFound) then
        modPrint("Failed to find ItemType by name " .. item)
        return
    end

    debugPrint("Adding item type to inventory: " .. itemType.Name:ToString())

    local_inventory:AddItemTypeToInventory(itemType, 1)
    debugPrint("Item successfully given on scan")
end

Pre2, Post2 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:ClientNotifyScannedInstanceCompleted",
function(Context, ScannedActor)
    debugPrint("On scan complete")

    ---@type AActor
    local scannedActor = ScannedActor:get()

    debugPrint("Scanned " .. scannedActor:GetFName():ToString())

    ---@type UUWEScanData
    local scanData = UWEScanData_GetScanDataForActor(UWEScanData, scannedActor)

    if DEBUG then
        debugPrint("Scan Data: " .. tostring(scanData))
        debugPrint("Name: " .. scanData.Name:ToString())
        debugPrint("Note: " .. scanData.DeveloperNote:ToString())
        debugPrint("Num required: " .. tostring(scanData.NumRequired))
    end

    if scanning_completed_object then
        modPrint("Giving item on scan")
        addItemToInventory(item_on_scanning)
    end

    -- Reset state!!
    scanning_completed_object = false
end)

modPrint("All hooks registered!")