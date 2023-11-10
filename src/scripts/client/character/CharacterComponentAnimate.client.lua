local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local SignalUpdateAnimate = require(packages.PlayerEntity).animate

local STATE_IDLE, STATE_IDLE_SNEAK, STATE_WALK_SNEAK, STATE_WALK, STATE_RUN = "idle", "idle_sneak", "walk", "walk_sneak", "run"

local Character = nil
local Humanoid = nil

local State = nil
local Animations = {}
local CurrentAnimation = nil


local function OnAnimateSignal(state)
	State = state
end


local function StopAllAnimations()
	if CurrentAnimation and CurrentAnimation.track then
		CurrentAnimation.track:Stop()
		CurrentAnimation = nil
	end
end


local function SwitchToAnimation(name, transitionTime, humanoid)
	if not Animations[name] then
		return
	end

	if not CurrentAnimation or Animations[name].animation ~= CurrentAnimation.animation then

		if CurrentAnimation and CurrentAnimation.track then
			CurrentAnimation.track:Stop(transitionTime)
		end

		CurrentAnimation = Animations[State]
		CurrentAnimation.track:Play()
	end
end


local function Update(deltaTime)
	if not Character.Parent then return end

	if State == STATE_IDLE then
		SwitchToAnimation(State, 0.2)
	elseif State == STATE_IDLE_SNEAK then
		SwitchToAnimation(State, 0.2)
	elseif State == STATE_WALK_SNEAK then
		SwitchToAnimation(State, 0.2)
	elseif State == STATE_WALK then
		SwitchToAnimation(State, 0.2)
	elseif State == STATE_RUN then
		SwitchToAnimation(State, 0.2)
	else
		StopAllAnimations()
	end
end


local function ConfigureAnimations()
	local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator") or nil
	if animator then
		local tracks = animator:GetPlayingAnimationTracks()
		for _, track in ipairs(tracks) do
			track:Stop(0)
			track:Destroy()
		end
	end

	local configFolder = Character:FindFirstChild("config") or Instance.new("Folder")
	configFolder.Name = "config"
	assert(configFolder ~= nil, "Config folder not found...")

	local animations = configFolder.Animations:GetChildren()
	assert(animations ~= nil, "Animations not found...")

	for _, animation in animations do
		if animation:IsA("Animation") then
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Core

			Animations[animation.Name] = {}
			Animations[animation.Name].track = track
			Animations[animation.Name].animation = animation
			Animations[animation.Name].id = animation.AnimationId
			Animations[animation.Name].weight = animation.weight or 1
		end
	end

	State = STATE_IDLE
end


local function Init()
	Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")

	ConfigureAnimations()

	RunService.Heartbeat:Connect(Update)
	SignalUpdateAnimate:Connect(OnAnimateSignal)
end
Init()