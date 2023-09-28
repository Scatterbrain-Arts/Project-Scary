local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")

local Step = 3
local StepLast = tick()


--RunService.Heartbeat:Connect(function(deltaTime)
	-- if tick() - StepLast > Step then
	-- 	StepLast = tick()
	-- 	PlayerMoveSoundEvent:FireServer()
	-- end
--end)

Humanoid.Running:Connect(function(speed)
	print(speed)
end)


LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end)





local PlayerSound = {}



return PlayerSound