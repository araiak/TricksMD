# TricksMD

A World of Warcraft addon that automatically manages a macro for **Tricks of the Trade** (Rogue) or **Misdirection** (Hunter) targeting the current tank.

## Features

- Automatically detects tanks in your group/raid
- Creates and updates a macro called "TankTricks"
- Remembers your preferred tank selection
- Auto-switches to next tank if your selected tank leaves (and switches back if they rejoin)
- Notifications in chat and raid warning frame when tank target changes
- Simple popup menu for tank selection

## Installation

1. Download or clone this repository
2. Copy the `TricksMD` folder to your `World of Warcraft/_retail_/Interface/AddOns/` directory
3. Restart WoW or reload your UI

## Usage

| Command | Description |
|---------|-------------|
| `/md` | Open tank selection menu |
| `/md <name>` | Directly select a tank by name |

The addon will automatically create a macro called **TankTricks** that you can drag to your action bar.

## Supported Classes

- **Rogue** - Tricks of the Trade
- **Hunter** - Misdirection

Other classes will see a message when using `/md` indicating the addon doesn't apply to them. The addon runs silently in the background for unsupported classes.

## Tank Selection Behavior

| Scenario | Behavior |
|----------|----------|
| You select Tank A | Macro targets Tank A, preference saved |
| Tank A leaves group | Macro switches to next tank alphabetically, preference kept |
| Tank A rejoins | Macro switches back to Tank A automatically |
| You leave the group | Preference cleared |
| You log out while in group | Preference persists across sessions |

When the tank target changes, you'll receive:
- A chat message: `[TricksMD] Tank target: TankName`
- A raid warning notification at the top of your screen

## Requirements

- World of Warcraft Retail (12.0.0+)
- Rogue or Hunter class

## License

MIT
