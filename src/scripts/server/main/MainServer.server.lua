local ServerScriptService = game:GetService("ServerScriptService")
local Loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local Packages = require(Loader).bootstrapGame(ServerScriptService.src)

local ServiceBag = require(Packages.ServiceBag).new()

ServiceBag:Init()
ServiceBag:Start()

require(Packages.ServerInit)
require(Packages.NPCStarter)

local Binder = require(Packages.Binder)
local Locks = require(Packages.Locks)
local Keys = require(Packages.Keys)
local Talismans = require(Packages.Talismans)

Locks.BINDER = Binder.new(Locks.TAG_NAME, Locks, ServiceBag)
Locks.BINDER:Start()

Keys.BINDER = Binder.new(Keys.TAG_NAME, Keys, ServiceBag)
Keys.BINDER:Start()

Talismans.BINDER = Binder.new(Talismans.TAG_NAME, Talismans, ServiceBag)
Talismans.BINDER:Start()