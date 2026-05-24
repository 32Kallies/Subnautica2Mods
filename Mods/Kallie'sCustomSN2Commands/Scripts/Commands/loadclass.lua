local CommandUtils = require("CommandUtils")

---Kind of dumb but this works. Lets you load a class into memory to further search in the Live View. It seriously works.
---Example usage:
---LoadClass /Game/Blueprints/AI/Agents/CollectorLeviathan/BP_CollectorLeviathan.BP_CollectorLeviathan_C
local function loadClass(args)
    if #args < 2 then
        CommandUtils.Log("This command expects a parameter for the blueprint path")
        return
    end
    local path = args[2]
    local class = CommandUtils.CorrectClassPath(path)
    CommandUtils.Log("Loading entity by path " .. class)
    ExecuteInGameThread(function()
        CommandUtils.LoadClassByPath(class)
    end)
end

return loadClass