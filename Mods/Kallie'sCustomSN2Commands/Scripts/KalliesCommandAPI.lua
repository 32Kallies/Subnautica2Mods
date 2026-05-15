local KalliesCommandAPI = {}

-- COMMAND REGISTRY

local commands = {}

-- UTILS

local function split(input)
    local parts = {}
    for token in string.gmatch(input, "%S+") do
        table.insert(parts, token)
    end
    return parts
end

-- API FUNCTIONS

function KalliesCommandAPI.CallCommand(input)
    local args = split(input)

    if #args == 0 then return end

    local cmd = string.lower(args[1])

    local handler = commands[cmd]
    if handler then
        handler(args)
    else
        print("Unknown command: " .. cmd .. "\n")
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