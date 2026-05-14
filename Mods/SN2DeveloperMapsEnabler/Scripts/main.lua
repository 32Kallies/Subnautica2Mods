NotifyOnNewObject("/Game/Blueprints/UI/Lobby/WBP_MainLobbyScreen.WBP_MainLobbyScreen_C", function(Context)
    RegisterHook("/Game/Blueprints/UI/Lobby/WBP_MainLobbyScreen.WBP_MainLobbyScreen_C:Get_DeveloperGameButton_Visibility", function(Context2)
        return true
    end)
end)