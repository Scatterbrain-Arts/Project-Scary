local ServerScriptService = game:GetService("ServerScriptService")
local Loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local Packages = require(Loader).bootstrapGame(ServerScriptService.NevermoreEngine)

local ServiceBag = require(Packages.ServiceBag).new()
ServiceBag:GetService(Packages.AiService)

ServiceBag:Init()
ServiceBag:Start()

local Binder = require(Packages.Binder)
local AiEntity = require(Packages.AiEntity)

AiEntity.BINDER = Binder.new(AiEntity.TAG_NAME, AiEntity, ServiceBag)
AiEntity.BINDER:Start()