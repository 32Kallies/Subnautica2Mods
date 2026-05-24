local UEHelpers = require("UEHelpers")
local CommandUtils = require("CommandUtils")

local fmod_statics = StaticFindObject("/Script/FMODStudio.FMODBlueprintStatics")
local fmod_statics_play_2d = StaticFindObject("/Script/FMODStudio.FMODBlueprintStatics:PlayEvent2D")

---Plays a 2D sound by its GUID.
---Example usage:
---PlaySound2D 8429A379-54374E08-B506FAC9-307FDCCB
local function playSound2D(args)
    if #args < 2 then
        CommandUtils.Log("This command expects a parameter for the sound GUID")
        return
    end
    local guid_string = args[2]
    local guid = CommandUtils.ParseGuid(guid_string)
    local fmod_event = CommandUtils.CreateFMODAsset(guid)
    ExecuteInGameThread(function()
        fmod_statics_play_2d(fmod_statics, UEHelpers.GetPlayerController(), fmod_event, true)
    end)
end

return playSound2D