local CommandUtils = require("CommandUtils")
local UEHelpers = require("UEHelpers")

---@type UClass
local StaticMeshActor = StaticFindObject("/Script/Engine.StaticMeshActor")

---Loads a mesh and spawns it on a new actor.
---Comparable to the Summon command, but works with meshes instead of blueprints.
---Example:
---SummonMesh Subnautica2/Content/Art/Items/CopperWire/SM_CopperWire.uasset
local function summonMesh(args)
    if #args < 2 then
        CommandUtils.Log("This command expects a parameter for the mesh path")
        return
    end
    local path = args[2]
    local class = CommandUtils.CorrectClassPath(path)
    CommandUtils.Log("Summoning mesh by path " .. class)
    ExecuteInGameThread(function()
        ---@type UStaticMesh
        local loaded_mesh = CommandUtils.LoadAssetByPath(class)

        if not loaded_mesh or not loaded_mesh:IsValid() then
            CommandUtils.Log("Failed to load static mesh by path " .. path)
            return
        end

        CommandUtils.Log("Successfully loaded mesh " .. loaded_mesh:GetFullName())

        local world = UEHelpers:GetWorld()

        ---@type AStaticMeshActor
        local actor = world:SpawnActor(StaticMeshActor, CommandUtils.GetSpawnPosition(500), {})
        CommandUtils.Log("Completed spawning actor: " .. actor:GetFullName())

        actor:SetMobility(
            2 -- Moveable
        )
        
        actor.StaticMeshComponent:SetStaticMesh(loaded_mesh)
    end)
end

return summonMesh