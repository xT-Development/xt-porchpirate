<div align="center">
  <h1>xt-porchpirate</h1>
  <a href="https://dsc.gg/xtdev"> <img align="center" src="https://github.com/xT-Development/.github/assets/101474430/d2fbd286-a0d5-4056-95cd-22cb3f526283" /></a><br>
</div>

## [Preview](https://streamable.com/14b8bu)

# Features:
- Steal packages from houses around the city
- Global state to sync locations across players
- Performant usage of Renewed-Lib to ensure proper creation and removal of props within a distance
- Random chance package blows up when stolen
- Receive random loot from packages when opened
- Forced anim loops to force players to carry the boxes when they are holding them. Shows prop model as well

# Install
- Add item to ox_inventory
```lua
["stolen_package"] = {
    label = "Stolen Package",
    weight = 100,
    stack = false,
    close = false,
    description = "Could be valuable?",
    client = {
        usetime = 3000,
    },
    server = {
        export = 'xt-porchpirate.stolen_package'
    }
},
```

# Dependencies:
- [ox_lib](https://github.com/overextended/ox_lib/releases)
- [ox_inventory](https://github.com/overextended/ox_inventory/releases)
- [ox_target](https://github.com/overextended/ox_target/releases)
- [Renewed-Lib](https://github.com/Renewed-Scripts/Renewed-Lib/tree/main)

# Supported Frameworks:
- 🟩 | QB / QBX
- 🟩 | ESX
- 🟩 | OX
- 🟩 | ND