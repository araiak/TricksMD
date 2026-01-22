# TricksMD

A World of Warcraft addon that automatically manages a macro for **Tricks of the Trade** (Rogue) or **Misdirection** (Hunter) targeting the current tank.

## Features

- Automatically detects tanks in your group/raid
- Creates and updates a macro called "TankTricks"
- Remembers your preferred tank selection
- Auto-switches to next tank if your selected tank leaves
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

## Requirements

- World of Warcraft Retail (12.0.0+)
- Must be a Rogue or Hunter with the appropriate spell learned

## License

MIT
