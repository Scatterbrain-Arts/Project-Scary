local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")

local PuppetActivator = {}

local PuppetManuelOverrideEvent = GetRemoteEvent("PuppetManuelOverrideEvent")

local LocalPlayer = Players.LocalPlayer

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode== Enum.KeyCode.O then
		PuppetManuelOverrideEvent:FireServer()
	end
end)


return PuppetActivator