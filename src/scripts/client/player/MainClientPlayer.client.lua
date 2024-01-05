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


local Doors = require(Packages.Doors)
Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors, ServiceBag)
Doors.BINDER:Start()

local Food = require(Packages.Food)
Food.BINDER = Binder.new(Food.TAG_NAME, Food, ServiceBag)
Food.BINDER:Start()

local NPC = require(Packages.NPC)
NPC.BINDER = Binder.new(NPC.TAG_NAME, NPC, ServiceBag)
NPC.BINDER:Start()