-- COMMON UTILITIES

local DEBUG = false
local mod_name = "CopperFromScanning"
local version = "1.0.0"

local UEHelpers = require("UEHelpers")

---@param message string
local function log(message)
    print(string.format("[%s v%s] %s\n", mod_name, version, message))
end

---@param message string
local function debugLog(message)
    if DEBUG then
        print(string.format("[%s v%s DEBUG] %s\n", mod_name, version, message))
    end
end

--[[MAIN MOD BELOW]]

local item_on_scanning = "/Game/Blueprints/Items/Resources/BP_Copper.BP_Copper_C"

-- STATIC REFERENCES

local UWEScanData = StaticFindObject("/Script/UWEScanner.UWEScanData")
local UWEScanData_GetScanDataForActor = StaticFindObject("/Script/UWEScanner.UWEScanData:GetScanDataForActor")

local SN2Statics = StaticFindObject("/Script/Subnautica2.SN2Statics")
local SN2Statics_GetLocalPlayerInventory = StaticFindObject("/Script/Subnautica2.SN2Statics:GetLocalPlayerInventory")

local KismetSystemLibrary = StaticFindObject("/Script/Engine.KismetSystemLibrary")
local KSL_LoadAssetClass_Blocking = StaticFindObject("/Script/Engine.KismetSystemLibrary:LoadClassAsset_Blocking")
local KSL_MakeSoftClassPath = StaticFindObject("/Script/Engine.KismetSystemLibrary:MakeSoftClassPath")
local KSL_Conv_SoftClassPathToSoftClassRef = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_SoftClassPathToSoftClassRef")

-- STATIC VARIABLES

local scanning_completed_object = false
-- future idea: store this per-actor

-- HELPER FUNCTIONS

---Loads a class by its path (must be executed in the game thread)
---@param path string
---@return UClass
local function loadClassByPath(path)
    local soft_class_path = KSL_MakeSoftClassPath(KismetSystemLibrary, path)
    local pointer = KSL_Conv_SoftClassPathToSoftClassRef(KismetSystemLibrary, soft_class_path)
    local world = UEHelpers.GetWorld()

    local loaded = KSL_LoadAssetClass_Blocking(world, pointer)
    return loaded
end

---Adds an item to the player's inventory by its path
---@param path string
local function addItemToInventory(path)
    ExecuteInGameThread(function ()
        debugLog("Loading asset by path " .. path)

        -- This may take a moment
        local item_class = loadClassByPath(path)

        if not item_class then
            log("Failed to load asset by path " .. path)
            return
        end

        ---@type UUWEInventoryComponent
        local local_inventory = SN2Statics_GetLocalPlayerInventory(SN2Statics, SN2Statics)

        if not local_inventory then
            log("Local inventory not found")
            return
        end

    
        if local_inventory:IsFull() then
            log("Inventory is full")
            return
        end

        debugLog("Loaded asset: " .. tostring(item_class))
        local pos = { X = 0, Y = 0, Z = 0}
        local actor = UEHelpers.GetWorld():SpawnActor(item_class, pos, {})

        if not actor then
            log("Failed to spawn actor")
            return
        end

        local_inventory:Pickup(actor, true)

        debugLog("Item successfully given on scan")
    end)
end

--[[HOOKS]]

-- Hook #1: Check if the item that is currently being scanned is already unlocked, then store that information for later
Pre1, Post1 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:GetActorInstanceScannedProgressForPlayer",
function(Context, ScannedActor)
    debugLog("Querying if should give copper")

    ---@type UUWEScannedActorsComponent
    local component = Context:get();

    ---@type AActor
    local scanned_actor = ScannedActor:get()

    ---@type UUWEScanData
    local scan_data = UWEScanData_GetScanDataForActor(UWEScanData, scanned_actor)
    
    if not scan_data then
        debugLog("Failed to find valid ScanData")
        return
    end

    scanning_completed_object = component:IsScanDataProgressComplete(scan_data)

    if DEBUG then
        debugLog("Currently scanning: " .. scan_data.Name:ToString())
        debugLog("Complete: " .. tostring(scanning_completed_object))
    end
end
)

-- Hook #2: When an object is fully scanned, check if its state was already marked as complete, then give the player copper
Pre2, Post2 = RegisterHook("/Script/UWEScanner.UWEScannedActorsComponent:ClientNotifyScannedInstanceCompleted",
function(Context, ScannedActor)
    debugLog("On scan complete")

    ---@type AActor
    local scanned_actor = ScannedActor:get()

    debugLog("Scanned " .. scanned_actor:GetFName():ToString())

    ---@type UUWEScanData
    local scan_data = UWEScanData_GetScanDataForActor(UWEScanData, scanned_actor)

    if DEBUG then
        debugLog("Scan Data: " .. tostring(scan_data))
        debugLog("Name: " .. scan_data.Name:ToString())
        debugLog("Note: " .. scan_data.DeveloperNote:ToString())
        debugLog("Num required: " .. tostring(scan_data.NumRequired))
    end

    if scanning_completed_object then
        log("Giving item on scan")
        addItemToInventory(item_on_scanning)
    end

    -- Reset state!!
    scanning_completed_object = false
end)

log("All hooks registered!")