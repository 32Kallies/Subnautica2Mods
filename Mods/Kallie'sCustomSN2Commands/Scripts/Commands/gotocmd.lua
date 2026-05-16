local CommandUtils = require("CommandUtils")

-- custom goto commands
--[[
- goto lifepod
]]
local function gotocmd(args)
    if #args < 2 then
        print("Invalid command (location expected, e.g. 'goto lifepod')\n")
        return
    end

    if args[2] == "lifepod" then
        local func = StaticFindObject("/Game/Blueprints/Vehicle/Lifepod/BP_LifepodManager.BP_LifepodManager_C:GetRelevantLifepod")
        local lifepod_class = FindAllOf("BP_LifepodManager_C")[1]
        local func_out = {}
        func(lifepod_class, func_out)
        local lifepod = func_out.lifepod
        local lifepod_pos = lifepod:K2_GetActorLocation();
        -- exactly the same offset as LifepodGotoOffset from BP_SN2CheatManager.uasset!
        local position = {
            X = lifepod_pos.X,
            Y = lifepod_pos.Y,
            Z = lifepod_pos.Z + 150
        }
        CommandUtils.TeleportPlayer(position)
        return
    end

    print("Location '" .. args[2] .. "' not recognized!\n")
end

return gotocmd