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

local function AdjustTrack(track, value)
	local playbackLerp = Math.lerp(1, 0.7, value/100)
	local pitchLerp = Math.lerp(1, 1.35, value/100)
	
	track.PlaybackSpeed = playbackLerp
	track.pitch.Octave = pitchLerp
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


local function PlaySound(sound)
	assert(sound ~= nil, "Sound is nil...")
	sound.Looped  = false
	if not sound.IsPlaying then
		print(sound)
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
	BreathLength = Math.lerp(0.8,1.5,  staminaValue/100)
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



local lastTick = tick()
local IsInhale = math.random(0,1) == 1
local IsExhale = not IsInhale
local exhaleOffset = 0

local function Breathe()
	IsInhale = IsExhale
	IsExhale = not IsInhale
end

local function GetInhaleSound()
	if StaminaState == STATE_STAMINA_MAX then
		
	end
end

math.randomseed(tick())
RunService.Heartbeat:Connect(function(deltaTime)
	if isHoldBreath then
		if not requestHoldBreath then
			isHoldBreath = false
			IsExhale = true
			IsInhale = false
			exhaleOffset = 0
		end
		return
	end

	if requestHoldBreath and not isHoldBreath then
		exhaleOffset = BreathLength
	end

	if tick() - lastTick >= BreathLength-exhaleOffset+math.random(0, 1) then
		if IsInhale then
			sound = GetInhaleSound()
		end
		
		if IsExhale then
			sound = SFXBreath.exhale
		end

		if requestHoldBreath then
			sound = SFXBreath.inhale
			isHoldBreath = true
		end
		
		Breathe()
		Tracks.breath = PlaySound(sound)
		lastTick = tick()
	end

end)