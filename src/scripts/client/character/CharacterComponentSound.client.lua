local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)
local PlayerComponentSound = require(packages.PlayerComponentSound)
local Math = require(packages.Math)

local STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED, STATE_STAMINA_HIGH, STATE_STAMINA_MAX = 1, 2, 3, 4, 5
local STATES_STAMINA = { STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED , STATE_STAMINA_HIGH, STATE_STAMINA_MAX }

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local SFXBreath = {
	staminaMin = Root:FindFirstChild("breathStaminaMin"),
	staminaHighLow = Root:FindFirstChild("breathStaminaHighLow"),
	staminaMax = Root:FindFirstChild("breathStaminaMax"),

	staminaMinGasp = Root:FindFirstChild("breathStaminaMinGasp"),
	staminaMaxInhale = Root:FindFirstChild("breathStaminaMaxInhale"),
	staminaMaxExhale = Root:FindFirstChild("breathStaminaMaxExhale"),

	inhale = Root:FindFirstChild("breathIn"),
	exhale = Root:FindFirstChild("breathOut"),
	inhaleToHoldBreath = Root:FindFirstChild("inhaleToHoldBreath")
}

local StatusFolder = GeneralUtil:Get(Character, "status", "Folder")

local STATUS = {
	requestHoldBreath = GeneralUtil:GetBool(StatusFolder, "request hold breath", false),
	requestRun = GeneralUtil:GetBool(StatusFolder, "request run", false),

	breathState = GeneralUtil:GetNumber(StatusFolder, "breath state", false),
	moveState = GeneralUtil:GetNumber(StatusFolder, "move state", false),
	staminaState = GeneralUtil:GetNumber(StatusFolder, "stamina state", false),
}

local STATE_IDLE, STATE_IDLE_SNEAK, STATE_WALK_SNEAK, STATE_WALK, STATE_RUN = 1, 2, 3, 4, 5
local STATE_BREATH_INHALE, STATE_BREATH_INHALE_TO_HOLD_BREATH, STATE_BREATH_EXHALE = 1,2,3

local STATE = {
	[STATE_BREATH_INHALE] = {
		sound = Root:FindFirstChild("breathIn"),
		playbackSpeed = {
			[STATE_IDLE_SNEAK] = 0.90,
			[STATE_IDLE] = 0.95,
			[STATE_WALK_SNEAK] = 1,
			[STATE_WALK] = 1.05,
			[STATE_RUN] = 1.10,
		}
	},

	[STATE_BREATH_INHALE_TO_HOLD_BREATH] = {
		sound = Root:FindFirstChild("breathIn"),
		playbackSpeed = {
			[STATE_IDLE_SNEAK] = 0.90,
			[STATE_IDLE] = 0.95,
			[STATE_WALK_SNEAK] = 1,
			[STATE_WALK] = 1.05,
			[STATE_RUN] = 1.10,
		}
	},
	
	[STATE_BREATH_EXHALE] = {
		sound = Root:FindFirstChild("breathOut"),
		playbackSpeed = {
			[STATE_IDLE_SNEAK] = 0.90,
			[STATE_IDLE] = 0.95,
			[STATE_WALK_SNEAK] = 1,
			[STATE_WALK] = 1.05,
			[STATE_RUN] = 1.10,
		}
	},
}

SFXBreath.staminaMin.Looped = true
SFXBreath.staminaHighLow.Looped = true
SFXBreath.staminaMax.Looped = true

SFXBreath.staminaMinGasp.Looped = false
SFXBreath.staminaMaxInhale.Looped = false
SFXBreath.staminaMaxExhale.Looped = false

local IsBreathing = false

local BreathingTracks = {
	mainTrack = nil,
}

local Tracks = {
	breath = nil,
	move = nil,
}

local function PlayEffect(sfx)
	if sfx.IsPlaying then
		return
	end
	sfx:Play()
end

local function SwitchBreathingMainTrack(newTrack)
	if BreathingTracks.mainTrack and BreathingTracks.mainTrack == newTrack then
		return
	end

	if BreathingTracks.mainTrack and BreathingTracks.mainTrack.IsPlaying then
		BreathingTracks.mainTrack:Stop()
	end

	BreathingTracks.mainTrack = newTrack
	BreathingTracks.mainTrack:Play()
end





local ThreadFadeOut = coroutine.create(function(sound, fadeStep, speed)
	while true do
		if sound.IsPlaying then
			fadeStep = fadeStep or 1.25
			speed = speed or 0.1

			local prevVolume = sound.Volume
			while sound.Volume > 0.1 do
				sound.Volume = sound.Volume - fadeStep
				task.wait(speed)
				print(sound, sound.Volume)
			end
			sound:Stop()
			sound.Volume = prevVolume
		end

		coroutine.yield()
	end
end)


local ThreadFadeIn = coroutine.create(function(sound, fadeStep, speed)
	while true do
		if not sound.IsPlaying then
			fadeStep = fadeStep or 1.25
			speed = speed or 0.1

			local volume = sound.Volume
			sound.Volume = 0
			sound:Play()
			while sound.Volume < volume do
				sound.Volume = sound.Volume + fadeStep
				task.wait(speed)
				print(sound, sound.Volume)
			end
		end

		coroutine.yield()
	end
end)


local function Fade(thread, sound, fadeStep)
	coroutine.resume(thread, sound, fadeStep)
end


local function SwitchSounds(track, sound)
	if track == sound then
		return track
	end

	Fade(ThreadFadeIn, sound)
	Fade(ThreadFadeOut, track)
	
	print(track, sound)

	return sound
end


local function AdjustTrack(track, value)
	local playbackLerp = Math.lerp(1, 0.7, value/100)
	local pitchLerp = Math.lerp(1, 1.35, value/100)

	track.PlaybackSpeed = playbackLerp
	track.pitch.Octave = pitchLerp
end


local function PlaySound(sound, playbackSpeed)
	assert(sound ~= nil, "Sound is nil...")
	sound.Looped  = false
	if not sound.IsPlaying then
		local pitchLerp = Math.lerp(1.35, 1, playbackSpeed)
		sound.PlaybackSpeed = playbackSpeed
		sound.pitch.Octave = pitchLerp

		print(sound.Name)

		sound:Play()
	end

	return sound
end


local BreathLength = 1.8
local StaminaValue = 0
local StaminaState = nil
PlayerComponentSound.Signals.playBreathing:Connect(function(state, staminaValue)
	-- if not IsBreathing then
	-- 	return
	-- end
	--print(staminaValue)
	BreathLength = Math.lerp(0.4,1.8,  staminaValue/100)
	StaminaValue = staminaValue
	StaminaState = state
	-- if state == STATE_STAMINA_MAX then
	-- 	PlayEffect(SFXBreath.staminaMaxExhale)
	-- 	Tracks.breath = SwitchSounds(Tracks.breath, SFXBreath.staminaMax)

	-- elseif state == STATE_STAMINA_MIN then
	-- 	-- PlayEffect(SFXBreath.staminaMinGasp)
	-- 	-- Tracks.breath = SwitchSounds(Tracks.breath, SFXBreath.staminaMin)
	-- else
	-- 	Tracks.breath = SwitchSounds(Tracks.breath, SFXBreath.staminaHighLow)
	-- 	--AdjustTrack(SFXBreath.staminaHighLow, staminaValue)
	-- end
end)
-- Tracks.breath = SFXBreath.staminaHighLow
-- Tracks.breath:Play()

local isHoldBreath = false
local requestHoldBreath = false
PlayerComponentSound.Signals.playHoldBreath:Connect(function(state)
	requestHoldBreath = not state
end)




STATUS.breathState.Changed:Connect(function(newState)
	if newState == STATE_BREATH_INHALE then
		PlaySound(SFXBreath.inhale, STATE[STATE_BREATH_INHALE].playbackSpeed[STATUS.moveState.Value])
	elseif newState == STATE_BREATH_INHALE_TO_HOLD_BREATH then
		PlaySound(SFXBreath.inhaleToHoldBreath, STATE[STATE_BREATH_INHALE_TO_HOLD_BREATH].playbackSpeed[STATUS.moveState.Value])
	elseif newState == STATE_BREATH_EXHALE then
		PlaySound(SFXBreath.exhale, STATE[STATE_BREATH_EXHALE].playbackSpeed[STATUS.moveState.Value])
	end
end)