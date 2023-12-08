local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)
local Math = require(packages.Math)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local ConfigFolder = GeneralUtil:Get("Folder", Character, "config")
local ConfigSound = GeneralUtil:Get("Configuration", ConfigFolder, "sound")

local IsDebug = GeneralUtil:GetBool(ConfigSound, "_DEBUG", true)

local CONFIG = {
	intervalLength = GeneralUtil:GetNumber(ConfigSound, "emitter fire delay", IsDebug.Value),
}

local StatusFolder = GeneralUtil:Get("Folder", Character, "status")
local STATUS = {
	breathState = GeneralUtil:GetNumber(StatusFolder, "state breath", IsDebug.Value),
	moveState = GeneralUtil:GetNumber(StatusFolder, "state move", IsDebug.Value),
	staminaState = GeneralUtil:GetNumber(StatusFolder, "state stamina", IsDebug.Value),

	currentDecibel = GeneralUtil:GetNumber(StatusFolder, "current decibel", IsDebug.Value)
}

local STATE_BREATH = {
	[shared.states.breath.inhale] = {
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter breath scalar inhale", IsDebug.Value),
		sound = GeneralUtil:GetSound(Root, "breathIn"),
		playbackSpeed = {
			[shared.states.move.idleCrouch] = 0.90,
			[shared.states.move.idle] = 0.95,
			[shared.states.move.walkCrouch] = 1,
			[shared.states.move.walk] = 1.05,
			[shared.states.move.run] = 1.10,
		}
	},

	[shared.states.breath.inhaleToHoldBreath] = {
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter breath scalar inhaleToHoldBreath", IsDebug.Value),
		sound = GeneralUtil:GetSound(Root, "inhaleToHoldBreath"),
		playbackSpeed = {
			[shared.states.move.idleCrouch] = 0.90,
			[shared.states.move.idle] = 0.95,
			[shared.states.move.walkCrouch] = 1,
			[shared.states.move.walk] = 1.05,
			[shared.states.move.run] = 1.10,
		}
	},
	
	[shared.states.breath.exhale] = {
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter breath scalar exhale", IsDebug.Value),
		sound = GeneralUtil:GetSound(Root, "breathOut"),
		playbackSpeed = {
			[shared.states.move.idleCrouch] = 0.90,
			[shared.states.move.idle] = 0.95,
			[shared.states.move.walkCrouch] = 1,
			[shared.states.move.walk] = 1.05,
			[shared.states.move.run] = 1.10,
		}
	},
	[shared.states.breath.holding] = {
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter breath scalar hold breath", IsDebug.Value),
		sound = GeneralUtil:GetSound(Root, "breathOut"),
		playbackSpeed = {
			[shared.states.move.idleCrouch] = 0.90,
			[shared.states.move.idle] = 0.95,
			[shared.states.move.walkCrouch] = 1,
			[shared.states.move.walk] = 1.05,
			[shared.states.move.run] = 1.10,
		}
	},

	["base"] = GeneralUtil:GetNumber(ConfigSound, "emitter breath base weight", IsDebug.Value),
}

local STATE_MOVE = {
	[shared.states.move.idleCrouch] = {
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter move scalar idle crouch", IsDebug.Value)
	},
	[shared.states.move.idle] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter move scalar idle", IsDebug.Value)
	},
	[shared.states.move.walkCrouch] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter move scalar walk crouch", IsDebug.Value)
	},
	[shared.states.move.walk] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter move scalar walk", IsDebug.Value)
	},
	[shared.states.move.run] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter move scalar run", IsDebug.Value)
	},

	["base"] = GeneralUtil:GetNumber(ConfigSound, "emitter move base weight", IsDebug.Value),
}

local STATE_STAMINA = {
	[shared.states.stamina.min] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter stamina scalar min", IsDebug.Value)
	},
	[shared.states.stamina.low] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter stamina scalar low", IsDebug.Value)
	},
	[shared.states.stamina.med] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter stamina scalar med", IsDebug.Value)
	},
	[shared.states.stamina.high] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter stamina scalar high", IsDebug.Value)
	},
	[shared.states.stamina.max] ={
		scalar = GeneralUtil:GetNumber(ConfigSound, "emitter stamina scalar max", IsDebug.Value)
	},


	["base"] = GeneralUtil:GetNumber(ConfigSound, "emitter stamina base weight", IsDebug.Value),
}

local GuiSound = GeneralUtil:GetUI(LocalPlayer.PlayerGui, "sound")
local GuiSoundBar = GeneralUtil:GetUI(GuiSound, "fg")
local GuiSoundValue = GeneralUtil:GetUI(GuiSound, "Value")

local IntervalTimeStart = nil
local IntervalTimeElapsed = nil
local Decibel = nil


local function PlaySound(sound, playbackSpeed)
	assert(sound ~= nil, "Sound is nil...")
	sound.Looped  = false
	if not sound.IsPlaying then
		local pitchLerp = Math.lerp(1.35, 1, playbackSpeed)
		sound.PlaybackSpeed = playbackSpeed
		sound.pitch.Octave = pitchLerp

		sound:Play()

		if IsDebug.Value then
			print(sound.Name)
		end
	end

	return sound
end


local function FireSound(deltaTime)
	IntervalTimeElapsed = tick() - IntervalTimeStart
	if IntervalTimeElapsed > CONFIG.intervalLength.Value then
		IntervalTimeStart = tick()

		Decibel = (STATE_MOVE.base.Value * STATE_MOVE[STATUS.moveState.Value].scalar.Value)
			+ (STATE_BREATH.base.Value * STATE_BREATH[STATUS.breathState.Value].scalar.Value)
			+ (STATE_STAMINA.base.Value * STATE_STAMINA[STATUS.staminaState.Value].scalar.Value)

		local totalDecibel = (STATE_MOVE.base.Value * STATE_MOVE[shared.states.move.run].scalar.Value)
		+ (STATE_BREATH.base.Value * STATE_BREATH[shared.states.breath.inhale].scalar.Value)
		+ (STATE_STAMINA.base.Value * STATE_STAMINA[shared.states.stamina.min].scalar.Value)
		GuiSoundBar.Size = UDim2.fromScale(Decibel / totalDecibel, 1)
		GuiSoundValue.Text = math.floor(Decibel) .. " dB"

		STATUS.currentDecibel.Value = Decibel
	end
end



local function OnBreathState(newState)
	if newState == shared.states.breath.inhale or newState == shared.states.breath.inhaleToHoldBreath or newState == shared.states.breath.exhale then
		PlaySound(STATE_BREATH[newState].sound, STATE_BREATH[newState].playbackSpeed[newState])
	end
end


local function Init()
	STATE_BREATH[shared.states.breath.inhale].Looped = false
	STATE_BREATH[shared.states.breath.inhaleToHoldBreath].Looped = false
	STATE_BREATH[shared.states.breath.exhale].Looped = false

	IntervalTimeStart = tick()
	IntervalTimeElapsed = tick() - IntervalTimeStart
	Decibel = 0

	STATUS.breathState.Changed:Connect(OnBreathState)
	RunService.Heartbeat:Connect(FireSound)

	GuiSoundBar.Size = UDim2.fromScale(Decibel / Decibel > GuiSoundBar.Size.X.Scale and Decibel or GuiSoundBar.Size.X.Scale, 1)
	GuiSoundValue.Text = Decibel .. " dB"
	GuiSound.Enabled = true
end
Init()



-- local ThreadFadeOut = coroutine.create(function(sound, fadeStep, speed)
-- 	while true do
-- 		if sound.IsPlaying then
-- 			fadeStep = fadeStep or 1.25
-- 			speed = speed or 0.1

-- 			local prevVolume = sound.Volume
-- 			while sound.Volume > 0.1 do
-- 				sound.Volume = sound.Volume - fadeStep
-- 				task.wait(speed)
-- 				print(sound, sound.Volume)
-- 			end
-- 			sound:Stop()
-- 			sound.Volume = prevVolume
-- 		end

-- 		coroutine.yield()
-- 	end
-- end)


-- local ThreadFadeIn = coroutine.create(function(sound, fadeStep, speed)
-- 	while true do
-- 		if not sound.IsPlaying then
-- 			fadeStep = fadeStep or 1.25
-- 			speed = speed or 0.1

-- 			local volume = sound.Volume
-- 			sound.Volume = 0
-- 			sound:Play()
-- 			while sound.Volume < volume do
-- 				sound.Volume = sound.Volume + fadeStep
-- 				task.wait(speed)
-- 				print(sound, sound.Volume)
-- 			end
-- 		end

-- 		coroutine.yield()
-- 	end
-- end)


-- local function Fade(thread, sound, fadeStep)
-- 	coroutine.resume(thread, sound, fadeStep)
-- end


-- local function SwitchSounds(track, sound)
-- 	if track == sound then
-- 		return track
-- 	end

-- 	Fade(ThreadFadeIn, sound)
-- 	Fade(ThreadFadeOut, track)
	
-- 	print(track, sound)

-- 	return sound
-- end


-- local function AdjustTrack(track, value)
-- 	local playbackLerp = Math.lerp(1, 0.7, value/100)
-- 	local pitchLerp = Math.lerp(1, 1.35, value/100)

-- 	track.PlaybackSpeed = playbackLerp
-- 	track.pitch.Octave = pitchLerp
-- end