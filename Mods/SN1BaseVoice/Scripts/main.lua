-- COMMON UTILITIES

local DEBUG = false
local MOD_NAME = "Subnautica1BaseVoice"
local VERSION = "1.0.0"

---@param message string
local function log(message)
    print(string.format("[%s v%s] %s\n", MOD_NAME, VERSION, message))
end

---@param message string
local function debugLog(message)
    if DEBUG then
        print(string.format("[%s v%s DEBUG] %s\n", MOD_NAME, VERSION, message))
    end
end

--[[MAIN MOD BELOW]]

--[[
The way this mod works is a bit confusing, and it only worked by pure luck.
It has two steps here:
1. Replace one of the game's FMOD bank files which seems to be fully unused. If that bank file goes away, the mod is cooked.
2. Replace the FMOD events
You will need a replaced bank file (base_general.bank), which is not packaged in this repository here
]]

-- REFERENCES

local KSL = StaticFindObject("/Script/Engine.KismetSystemLibrary")
local KSL_Conv_ObjectToSoftObjectReference = StaticFindObject("/Script/Engine.KismetSystemLibrary:Conv_ObjectToSoftObjectReference")

local base_voice_path = "/Game/FMOD/Events/sfx/base/base_voiceover/2D_only"

---@type table<string, UFMODEvent>
local sound_replacements = {}

-- FUNCTIONS

---Find an existing base voice sound of the given name
---@param name string
---@return UFMODEvent
local function loadBaseSound(name)
    ---@type UFMODEvent
    return StaticFindObject(string.format("%s/%s.%s", base_voice_path, name, name))
end

local sounds_loaded = false

---Loads relevant FMOD Events into the sound_replacements table
local function loadSoundReplacements()
    -- this is my lazy way around unnecessarily loading the assets over and over again
    if sounds_loaded == true and sound_replacements["BaseAI_PowerOffline"] then
        debugLog("Sounds already loaded. Skipping.")
        return
    end

    if DEBUG then
        debugLog("Loading FMOD events...")
    end

    sound_replacements = {
        -- ["???"] = loadBaseSound("base_vo_backupPowerActivated_2D"),
        ["BaseAI_PowerOffline"] = loadBaseSound("base_vo_powerOffline_2D"),
        -- ["???"] = loadBaseSound("base_vo_powerOn_2D"),
        ["BaseAI_PowerOverload"] = loadBaseSound("base_vo_powerOverload_2D"),
        ["BaseAI_PowerConnected"] = loadBaseSound("base_vo_powerRestored_2D"),
        ["BaseAI_WelcomeAboard"] = loadBaseSound("base_vo_welcomeAboard_2D"),
        ["BaseAI_WelcomeAboardCaptain"] = loadBaseSound("base_vo_welcomeAboard_2D")
    }
end

---Checks if the given dialogue sequence should be replaced with a custom one, and if so, replaces it
---@param sequence UUWEDialogueSequence
local function handleDialogueSequence(sequence)
    -- Check validity
    if not sequence.Lines[1] then
        debugLog("Invalid line - skipping")
        return
    end

    if not sequence.Lines[1].FMODEvent then
        debugLog("Invalid FMOD Event - skipping")
        return
    end

    -- Check the sound used by this line

    local event_key = sequence.Lines[1].EventKey:ToString()

    if DEBUG then
        debugLog("Checking EventKey: " .. event_key)
    end

    -- Check if the sound should be replaced

    loadSoundReplacements()

    local replacement_sound = sound_replacements[event_key]

    if replacement_sound == nil then
        debugLog("Failed to find replacement sound for EventKey " .. event_key)
        return
    end

    -- Create sound pointer
    ---@type TSoftObjectPtr<UFMODEvent>
    local replacement_pointer = KSL_Conv_ObjectToSoftObjectReference(KSL, replacement_sound)

    debugLog("REPLACING SOUND")

    -- REPLACE THE SOUND FINALLY!!!
    sequence.Lines[1].FMODEvent = replacement_pointer
end

-- MAIN HOOK
Pre, Post = RegisterHook("/Script/UWEDialogue.UWEDialogueStatics:PlayDialogueForPlayer", function(Context, Dialogue)
    ---@type UUWEDialogueNode
    local dialogue = Dialogue:get()

    -- Make sure this dialogue is valid to avoid some weird edge cases
    if not dialogue:IsValid() then
        return
    end

    local sequence = dialogue:GetDialogueSequenceToPlay()

    if sequence:IsValid() and #(sequence.Lines) > 0 then
        handleDialogueSequence(sequence)
    end
end)

log("Loaded!")