local Hooked = false

NotifyOnNewObject("/Game/Blueprints/UI/HUD/WBP_TopHud.WBP_TopHud_C", function()
    if Hooked == true then
        return
    end

    print("Loading in game. Preparing hooks for commands.\n")

    RegisterHook("/Script/UWEUtilities.UWEBuildInfo:IsDevelopmentBuild", function(Context)
        return true
    end)

    RegisterHook("/Script/UWEUtilities.UWEBuildInfo:IsFinalShippingBuild", function(Context)
        return false
    end)

    print("Subnautica 2 commands enabled.\n")

    Hooked = true
end)