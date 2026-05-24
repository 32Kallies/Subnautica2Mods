# Kallie's Custom Subnautica 2 Commands Mod

This mod adds multiple new custom commands for Subnautica 2.

# Installation

1. Download UE4SS for Subnautica 2.
   - Place the `ue4ss` folder in `...\Subnautica2\Subnautica2\Binaries\Win64`
2. Place the mod folder (Kallie'sCustomSN2Commands) into `ue4ss\Mods`
3. Make sure you have other required mods to reenable the command console. Otherwise, this will not work.

# Usage

If cheats are enabled properly (through other mods), simply press Enter in-game to open the console and type one of the
custom commands. Custom commands will not be autocompleted and may give on-screen warnings, but they are usable.

Note that standard units in Unreal Engine are centimeters, unlike Unity, which uses meters. 

# Commands list:

|              Command | Description                                                                | Example                                                                                                 |
|---------------------:|----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
|       `Goto Lifepod` | Sends the player to the Lifepod.                                           | `goto lifepod`                                                                                          |
|   `Warp [x] [y] [z]` | Teleports the player to the coordinates.                                   | `warp -170568 314929 0`                                                                                 |
|              `W [m]` | Teleports the player forward `m` meters.                                   | `w 5`                                                                                                   |
|   `Warpforward [cm]` | Teleports the player forward `cm` centimeters.                             | `warpforward 500`                                                                                       |
|             `Warpme` | Teleports the player to the lifepod.                                       | `warpme`                                                                                                |
|   `LoadClass [path]` | Loads an asset into memory (generally useless outside some modding tools.) | `loadclass /Game/Blueprints/AI/Agents/CollectorLeviathan/BP_CollectorLeviathan.BP_CollectorLeviathan_C` |
|   `SummonAny [path]` | Spawns an asset by its path. Much more reliable than Summon.               | `summonany /Game/Blueprints/AI/Agents/LargeCreature024_Waxmoon/BP_Waxmoon.BP_Waxmoon_C`                 |
| `PlaySound2D [guid]` | Plays a 2D sound by its FMOD Event GUID.                                   | `PlaySound2D 8429A379-54374E08-B506FAC9-307FDCCB`                                                       |

> [!NOTE]
> Commands such as SummonAny can also directly take package paths, e.g. those directly from FModel. Both `Subnautica2/Content/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01` and `/Game/Blueprints/AI/Agents/LargeCreature014_Cerathecan/BP_Cerathecan_01.BP_Cerathecan_01_C` are valid parameters.
