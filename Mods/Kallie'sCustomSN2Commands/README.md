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

| Command            | Description                                                       | Example                 |
|--------------------|-------------------------------------------------------------------|-------------------------|
| `goto lifepod`     | Sends the player to the Lifepod.                                  | `goto lifepod`          |
| `warp [x] [y] [z]` | Teleports the player to the coordinates. Units are in centimeters. | `warp -170568 314929 0` |
| `w [m]`            | Teleports the player forward `m` meters.                          | `w 5`                   |
| `warpforward [cm]` | Teleports the player forward `cm` centimeters.                    | `warpforward 500`       |
| `warpme`           | Teleports the player to the lifepod.                              | `warpme`                |
