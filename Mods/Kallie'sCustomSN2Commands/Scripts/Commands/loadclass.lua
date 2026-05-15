local CommandUtils = require("CommandUtils")

---Kind of dumb but this works. Lets you load a class into memory to further search in the Live View. It seriously works.
---Example usage:
---LoadClass /Game/Blueprints/AI/Agents/CollectorLeviathan/BP_CollectorLeviathan.BP_CollectorLeviathan_C
local function loadClass(args)
    if #args < 2 then
        print("This command expects a parameter for the blueprint path")
    end
    local path = args[2]
    local class = CommandUtils.CorrectClassPath(path)
    print("Loading entity by path " .. class .. "\n")
    ExecuteInGameThread(function()
        CommandUtils.LoadClassByPath(class)
    end)
end

return loadClass