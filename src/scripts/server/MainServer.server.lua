local ServerScriptService = game:GetService("ServerScriptService")
local Loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local Packages = require(Loader).bootstrapGame(ServerScriptService.NevermoreEngine)




local ServiceBag = require(Packages.ServiceBag).new()
ServiceBag:GetService(Packages.DebugService)

ServiceBag:Init()
ServiceBag:Start()

local Binder = require(Packages.Binder)
local Puppet = require(Packages.Puppet)


Puppet.BINDER = Binder.new(Puppet.TAG_NAME, Puppet, ServiceBag)
Puppet.BINDER:Start()