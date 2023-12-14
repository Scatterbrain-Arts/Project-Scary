local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

-- Read place from file
local placeFile = fs.readFile("npc_behavior.rbxlx")
local game = roblox.deserializePlace(placeFile)

-- Get trees folder
local trees = game:GetService("ServerStorage").Trees

-- Write model to file
local placeFile = roblox.serializeModel({trees}, true)
fs.writeFile("./src/trees/Trees.rbxmx", placeFile)