local PlayerSound = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local PlayerGui = LocalPlayer.PlayerGui
local SoundGui = PlayerGui:FindFirstChild("sound")
local SoundGuiText = SoundGui.Frame.TextLabel


local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")


local UpdatePeriod = 0.5
local UpdateTimeStart = tick()
local UpdateTimeElapsed = tick() - UpdateTimeStart

local IntervalPeriod = 1
local IntervalTimeStart = tick()
local IntervalTimeElapsed = tick() - IntervalTimeStart
local Decibel = 0

PlayerSound.names = {
	[1] = "breath",
	[2] = "move",
}

local Sounds = {
	["breath"] = {
		value = 30,
		modifier = 1,
	},
	["stamina"] = {
		modifier = 1,
	},
	["move"] = {
		value = 70,
		modifier = 1,
	}
}

PlayerSound.test = 1
function PlayerSound:Test()
	PlayerSound.test = 1.5
end


local function FireSound(deltaTime)
	IntervalTimeElapsed = tick() - IntervalTimeStart
	if IntervalTimeElapsed > IntervalPeriod then
		IntervalTimeStart = tick()

		Decibel = (Sounds.move.value * Sounds.move.modifier) + (Sounds.breath.value * Sounds.breath.modifier * Sounds.stamina.modifier)

		SoundGuiText.Text = Decibel
	end
end


RunService.Heartbeat:Connect(FireSound)


LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end)



function PlayerSound:Update(type, modifier)
	assert(not PlayerSound[type], "type not found...")
	assert(typeof(modifier) == "number", "modifier is not a number...")

	Sounds[type].modifier = modifier or Sounds[type].modifier
end





return PlayerSound