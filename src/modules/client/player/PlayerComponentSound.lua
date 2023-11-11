local PlayerSound = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")
local GeneralUtil = require("GeneralUtil")
local Signal = require("Signal")

local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local SoundGui = LocalPlayer.PlayerGui:FindFirstChild("sound")
local SoundGuiText = SoundGui.Frame.TextLabel

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")
local SoundConfig = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebug = GeneralUtil:GetBool(SoundConfig, "_DEBUG", true)
local CONFIG = {
	intervalLength = GeneralUtil:GetNumber(SoundConfig, "interval length", 1, IsDebug.Value),
	weightBreath = GeneralUtil:GetNumber(SoundConfig, "weight breath", 30, IsDebug.Value),
	weightMove = GeneralUtil:GetNumber(SoundConfig, "weight move", 70, IsDebug.Value  ),
}

local IntervalTimeStart = tick()
local IntervalTimeElapsed = tick() - IntervalTimeStart
local Decibel = 0

PlayerSound.names = {
	[1] = "breath",
	[2] = "move",
}

local Sounds = {
	["breath"] = {
		value = CONFIG.weightBreath.Value,
		modifier = 1,
	},
	["stamina"] = {
		modifier = 1,
	},
	["move"] = {
		value = CONFIG.weightMove.Value,
		modifier = 1,
	}
}


local function FireSound(deltaTime)
	IntervalTimeElapsed = tick() - IntervalTimeStart
	if IntervalTimeElapsed > CONFIG.intervalLength.Value then
		IntervalTimeStart = tick()

		Decibel = (Sounds.move.value * Sounds.move.modifier) + (Sounds.breath.value * Sounds.breath.modifier * Sounds.stamina.modifier)

		SoundGuiText.Text = Decibel
		PlayerMoveSoundEvent:FireServer({
			position = Root.position,
			decibel = Decibel,
		})
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

function PlayerSound:UpdateBreath(modifier, state)
	Sounds["breath"].modifier = modifier or Sounds["breath"].modifier

	PlayerSound.Signals.playHoldBreath:Fire(state)
end

function PlayerSound:UpdateStamina(modifier, value, state)
	Sounds["stamina"].modifier = modifier or Sounds["stamina"].modifier

	PlayerSound.Signals.playBreathing:Fire(value, state)
end

PlayerSound.Signals = {
	playBreathing = Signal.new(),
	playHoldBreath = Signal.new()
}


return PlayerSound