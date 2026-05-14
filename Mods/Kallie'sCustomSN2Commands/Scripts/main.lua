-- COMMAND REGISTRY (See the Commands folder to add more)

local commands = {
    w = require("Commands.w"),
    ["goto"] = require("Commands.gotocmd"),
    warp = require("Commands.warp"),
    warpforward = require("Commands.warpforward"),
    warpme = require("Commands.warpme"),
    loadclass = require("Commands.loadclass")
}

-- BACKEND LOGIC & HOOKS BELOW

local function split(input)
    local parts = {}
    for token in string.gmatch(input, "%S+") do
        table.insert(parts, token)
    end
    return parts
end

local function callCommand(input)
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

local currentInput = ""

-- HOOKS
local Pre, Post = RegisterHook("/Script/Subnautica2.SN2CheatInput:GetTypedString",
    function(Context)
        -- SKIP PREFIX
    end,
    function(Context, ReturnValue)
        -- POSTFIX
        local newInput = ReturnValue:get():ToString()

        if newInput ~= currentInput then
            currentInput = newInput
        end
    end
)

-- KEYBINDS

-- on completing command input
RegisterKeyBindAsync(Key.RETURN, {}, function()
    if currentInput ~= "" then
        callCommand(currentInput)
        currentInput = ""
    end
    currentInput = ""
end)

-- reset input on closing the command console
RegisterKeyBindAsync(Key.ESCAPE, {}, function()
    currentInput = ""
end)