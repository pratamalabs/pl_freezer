# ❄️ pl_freezer
- stash slows down the decline in item durability ox_inventory
- Full integration with [ox_inventory](https://github.com/overextended/ox_inventory)

# 🛠️ Feature
* slow down the decline in item durability
* prevent item durability degradation

# 📖 How to use
- open your ox_inventory/data/stash.lua file then add freezer = "normal", or freezer = "hard", in the order of the label 
```
{
    coords = vec3(4907.875, -4943.7573, 3.4574),
    target = {
        loc = vec3(4907.875, -4943.7573, 3.4574),
        length = 0.6,
        width = 1.8,
        heading = 340,
        minZ = 90.69,
        maxZ = 91.69,
        label = 'police refrigerator'
    },
    name = 'police_freezer',
    label = 'police refrigerator',
    freezer = "normal", --THIS ONE
    owner = false,
    slots = 200,
    weight = 10000000,
    groups = {['police'] = 0}
},
```

# 📖 for unregistered stashes via ox_inventory
- register stash ID or stash name in config.lua
```
RegisterFreezer = {
    {stashName = "kulkas_rs", freezer = "hard"},
    {stashName = "kulkas_rs_private", freezer = "normal"},
}

```

# ❄️ freezer type
```
freezer = "hard" = prevents spoilage completely
freezer = "normal" = it just slows down decay
```