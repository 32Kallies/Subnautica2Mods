local KalliesCommandAPI = {}

-- COMMAND REGISTRY

local commands = {}

-- REQUIREMENTS

local CommandUtils = require("CommandUtils")

-- API FUNCTIONS

function KalliesCommandAPI.CallCommand(input)
    local args = CommandUtils.SplitBySpace(input)

    if #args == 0 then return end

    local cmd = string.lower(args[1])

    local handler = commands[cmd]
    if handler then
        handler(args)
    else
        CommandUtils.Log("Unknown command: " .. cmd)
    end
end

function KalliesCommandAPI.RegisterCommand(name, functionality)
    commands[string.lower(name)] = functionality
end

function KalliesCommandAPI.GetCommands()
    local names = {}

    for k, v in pairs(commands) do
        names[k] = v
    end

    return names
end

return KalliesCommandAPI