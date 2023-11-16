local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local GeneralUtil = require(packages.GeneralUtil)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local configFolder = GeneralUtil:Get("Folder", Character, "config")
local ConfigAnimate = GeneralUtil:Get("Configuration", configFolder, "animate")

local IsDebug = GeneralUtil:GetBool(ConfigAnimate, "_DEBUG", true)

local StatusFolder = GeneralUtil:Get("Folder", Character, "status")
local STATUS = {
	moveState = GeneralUtil:GetNumber(StatusFolder, "move state", IsDebug.Value),
}

local Animations = nil
local CurrentAnimation = nil


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

		CurrentAnimation = Animations[name]
		CurrentAnimation.track:Play()
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

	for _, animation in ConfigAnimate:GetChildren() do
		if animation:IsA("Animation") then
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Core

			Animations[animation.Name] = {}
			Animations[animation.Name].track = track
			Animations[animation.Name].animation = animation
			Animations[animation.Name].id = animation.AnimationId
			Animations[animation.Name].weight = animation.weight or 1

			if IsDebug.Value then
				warn("animation: [", animation.Name, "] added...")
			end
		end
	end
end


local function OnMoveState(newState)
	if newState == shared.states.move.idle then
		SwitchToAnimation("idle", 0.2)
	elseif newState == shared.states.move.idleCrouch then
		SwitchToAnimation("idleCrouch", 0.2)
	elseif newState == shared.states.move.walkCrouch then
		SwitchToAnimation("walkCrouch", 0.2)
	elseif newState == shared.states.move.walk then
		SwitchToAnimation("walk", 0.2)
	elseif newState == shared.states.move.run then
		SwitchToAnimation("run", 0.2)
	else
		StopAllAnimations()
	end
end


local function Init()
	Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")

	Animations = {}

	ConfigureAnimations()

	STATUS.moveState.Changed:Connect(OnMoveState)
end
Init()