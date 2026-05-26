local CommandUtils = require("CommandUtils")
local UEHelpers = require("UEHelpers")

-- UUWEDynamicItemsManager:RegisterActor
local DynamicItemsManager = StaticFindObject("/Script/UWEDynamicItems.UWEDynamicItemsManager")
local DIM_RegisterActor = StaticFindObject("/Script/UWEDynamicItems.UWEDynamicItemsManager:RegisterActor")

---Loads a class into memory and then summons it.
---Comparable to the Summon command, but works more consistently.
---Examples:
---SummonAny /Game/Blueprints/AI/Agents/LargeCreature024_Waxmoon/BP_Waxmoon.BP_Waxmoon_C
---SummonAny /Game/Blueprints/AI/Agents/LargeCreature001_Hammerhead/BP_Hammerhead.BP_HammerHead_C
local function summonAny(args)
    if #args < 2 then
        CommandUtils.Log("This command expects a parameter for the blueprint path")
        return
    end
    local path = args[2]
    local class = CommandUtils.CorrectBlueprintPath(path)
    CommandUtils.Log("Summoning entity by path " .. class)
    ExecuteInGameThread(function()
        local loaded = CommandUtils.LoadClassByPath(class)
        local world = UEHelpers:GetWorld()
        local actor = world:SpawnActor(loaded, CommandUtils.GetSpawnPosition(500), {})
        DIM_RegisterActor(DynamicItemsManager, actor)
    end)
end

return summonAny