local npcstarter = {}

local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)
local AiEntity = require("AiEntity")

local npcModel = CollectionService:GetTagged("Entity")[1]
local npc = AiEntity.new(npcModel)


return npcstarter