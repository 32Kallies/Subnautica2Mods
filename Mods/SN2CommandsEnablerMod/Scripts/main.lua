local Hooked = false

NotifyOnNewObject("/Game/Blueprints/UI/HUD/WBP_TopHud.WBP_TopHud_C", function(Context)
    if Hooked == true then
        return
    end

    print("Loading in game. Preparing hooks for commands.\n")

    Pre1, Post1 = RegisterHook("/Script/UWEUtilities.UWEBuildInfo:IsDevelopmentBuild", function(Context)
        return true
    end)

    Pre2, Post2 = RegisterHook("/Script/UWEUtilities.UWEBuildInfo:IsFinalShippingBuild", function(Context)
        return false
    end)

    --[[
    -- This doesn't even prevent the crash sadly
    RegisterHook("/Game/Blueprints/UI/Lobby/WBP_SaveBeforeExitScreen.WBP_SaveBeforeExitScreen_C:ExitGame", function(Context)
        print("ON QUIT\n")
        UnregisterHook("/Script/UWEUtilities.UWEBuildInfo:IsDevelopmentBuild", Pre1, Post1)
        UnregisterHook("/Script/UWEUtilities.UWEBuildInfo:IsFinalShippingBuild", Pre2, Post2)
        end)
    ]]

    print("Subnautica 2 commands enabled.\n")

    Hooked = true
end)