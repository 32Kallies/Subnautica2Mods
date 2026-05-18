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

-- Copper ID
local item_on_scanning = "/Game/Blueprints/Items/Resources/BP_Copper.BP_Copper_C"

-- STATIC REFERENCES

local UWEScanData = StaticFindObject("/Script/UWEScanner.UWEScanData")
local UWEScanData_GetScanDataForActor = StaticFindObject("/Script/UWEScanner.UWEScanData:GetScanDataForActor")

-- SN2Statics:GetLocalPlayerInventory -- returns a UUWEInventoryComponent instance
local SN2Statics = StaticFindObject("/Script/Subnautica2.SN2Statics")
local SN2Statics_GetLocalPlayerInventory = StaticFindObject("/Script/Subnautica2.SN2Statics:GetLocalPlayerInventory")

local KismetSystemLibrary = StaticFindObject("/Script/Engine.KismetSystemLibrary")

local KSL_LoadAssetClass_Blocking = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadClassAsset_Blocking")
local KSL_MakeSoftClassPath = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftClassPath")
local KSL_Conv_SoftClassPathToSoftClassRef = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftClassPathToSoftClassRef")

-- STATIC VARIABLES
local scanning_completed_object = false
-- future idea: store specifically by actor

-- HELPER FUNCTIONS

---Loads a class by its path
---@param path string
---@return UClass
local function loadClassByPath(path)
    local soft_class_path = KSL_MakeSoftClassPath(KismetSystemLibrary, path)
    local pointer = KSL_Conv_SoftClassPathToSoftClassRef(KismetSystemLibrary, soft_class_path)
    local world = UEHelpers.GetWorld()

    local loaded = KSL_LoadAssetClass_Blocking(world, pointer)
    return loaded
end

---Adds an item by its path
---@param path string
local function addItemToInventory(path)
    ExecuteInGameThread(function ()
        debugPrint("Loading asset by path " .. path)

        -- This may take a moment
        local item_class = loadClassByPath(path)

        if not item_class then
            modPrint("Failed to load asset by path " .. path)
            return
        end

        ---@type UUWEInventoryComponent
        local local_inventory = SN2Statics_GetLocalPlayerInventory(SN2Statics, SN2Statics)

        if not local_inventory then
            modPrint("Local inventory not found")
            return
        end

    
        if local_inventory:IsFull() then
            modPrint("Inventory is full")
            return
        end

        debugPrint("Loaded asset: " .. tostring(item_class))
        local pos = { X = 0, Y = 0, Z = 0}
        local actor = UEHelpers.GetWorld():SpawnActor(item_class, pos, {})

        if not actor then
            modPrint("Failed to spawn actor")
            return
        end

        local_inventory:Pickup(actor, true)

        debugPrint("Item successfully given on scan")
    end)
end

-- HOOKS

Pre1, Post1 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:GetActorInstanceScannedProgressForPlayer",
function(Context, ScannedActor)
    debugPrint("Querying if should give copper")

    ---@type UUWEScannedActorsComponent
    local component = Context:get();

    ---@type AActor
    local scanned_actor = ScannedActor:get()

    ---@type UUWEScanData
    local scan_data = UWEScanData_GetScanDataForActor(UWEScanData, scanned_actor)
    
    if not scan_data then
        debugPrint("Failed to find valid ScanData")
        return
    end

    if DEBUG then
        debugPrint("Currently scanning: " .. scan_data.Name:ToString())
    end

    scanning_completed_object = component:IsScanDataProgressComplete(scan_data)

    if DEBUG then
        debugPrint("Complete: " .. tostring(scanning_completed_object))
    end
end
)

Pre2, Post2 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:ClientNotifyScannedInstanceCompleted",
function(Context, ScannedActor)
    debugPrint("On scan complete")

    ---@type AActor
    local scanned_actor = ScannedActor:get()

    debugPrint("Scanned " .. scanned_actor:GetFName():ToString())

    ---@type UUWEScanData
    local scan_data = UWEScanData_GetScanDataForActor(UWEScanData, scanned_actor)

    if DEBUG then
        debugPrint("Scan Data: " .. tostring(scan_data))
        debugPrint("Name: " .. scan_data.Name:ToString())
        debugPrint("Note: " .. scan_data.DeveloperNote:ToString())
        debugPrint("Num required: " .. tostring(scan_data.NumRequired))
    end

    if scanning_completed_object then
        modPrint("Giving item on scan")
        addItemToInventory(item_on_scanning)
    end

    -- Reset state!!
    scanning_completed_object = false
end)

modPrint("All hooks registered!")