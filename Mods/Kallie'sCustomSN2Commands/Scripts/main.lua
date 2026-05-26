local KalliesCommandAPI = require("KalliesCommandAPI")

KalliesCommandAPI.RegisterCommand("w", require("Commands.w"))
KalliesCommandAPI.RegisterCommand("goto", require("Commands.gotocmd"))
KalliesCommandAPI.RegisterCommand("warp", require("Commands.warp"))
KalliesCommandAPI.RegisterCommand("warpforward", require("Commands.warpforward"))
KalliesCommandAPI.RegisterCommand("warpme", require("Commands.warpme"))
KalliesCommandAPI.RegisterCommand("loadclass", require("Commands.loadclass"))
KalliesCommandAPI.RegisterCommand("summonany", require("Commands.summonany"))
KalliesCommandAPI.RegisterCommand("playsound2d", require("Commands.playsound2d"))
KalliesCommandAPI.RegisterCommand("summonmesh", require("Commands.summonmesh"))

-- HOOKS
local currentInput = ""

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
        KalliesCommandAPI.CallCommand(currentInput)
        currentInput = ""
    end
    currentInput = ""
end)

-- reset input on closing the command console
RegisterKeyBindAsync(Key.ESCAPE, {}, function()
    currentInput = ""
end)