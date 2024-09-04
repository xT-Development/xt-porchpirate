# xt-porchpirate
Porch Pirating for FiveM


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
    }
    ,server = {
        export = 'xt-porchpirate.stolen_package'
    }
},
```
