local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local ServiceBag = require(Packages.ServiceBag).new()

ServiceBag:GetService(Packages.GameServicesClient)

ServiceBag:Init()
ServiceBag:Start()


local Players = game:GetService("Players")
local Binder = require(Packages.Binder)

-- force wait for character + gui to load
repeat
	task.wait(0.1)
until Players.LocalPlayer:HasAppearanceLoaded()



require(Packages.PlayerEntity)
--require(Packages.ObjectBinder)
--require(Packages.NPCStarter)

local Doors = require(Packages.Doors)
Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors, ServiceBag)
Doors.BINDER:Start()
