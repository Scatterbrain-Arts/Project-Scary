local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Spring = require("Spring")
local GeneralUtil = require("GeneralUtil")

local ComponentCamera = require("PlayerComponentCamera")
local ComponentController = require("PlayerComponentController")
local ComponentSound = require("PlayerComponentSound")
local ComponentStamina = require("CharacterComponentStamina")
local ComponentBreath = require("PlayerComponentBreath")

local Debug = require("PlayerDebug")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local IsDebug = GeneralUtil:GetCondition(Character, "_DEBUG") or false

local Config = {
	speedRun = GeneralUtil:GetValue(Character, "moveSpeedRun", IsDebug) or 21,
	speedWalk = GeneralUtil:GetValue(Character, "moveSpeedWalk", IsDebug) or 14,
	speedSneak = GeneralUtil:GetValue(Character, "moveSpeedSneak", IsDebug) or 7,

	runTapSpeed = GeneralUtil:GetValue(Character, "moveRunTapSpeed", IsDebug) or 0.25,

	springDamper = GeneralUtil:GetValue(Character, "springDamper", IsDebug) or 1,
	springSpeed = GeneralUtil:GetValue(Character, "springSpeed", IsDebug) or 8,
	springTurnMultiplier = GeneralUtil:GetValue(Character, "springTurnMultiplier", IsDebug) or 0.5,
}

local ZERO_VECTOR = Vector3.new(0,0,0)
local STATE_IDLE, STATE_SNEAK, STATE_WALK, STATE_RUN = "idle", "sneak", "walk", "run"

local MovementLinearSpring = Spring.new(0)
MovementLinearSpring.Damper = Config.springDamper
MovementLinearSpring.Speed = Config.springSpeed

local IsRunning = false
local IsSneaking = false
local IsBreathing = true

local lastRunRequest = tick()

local MaxSpeed = Config.speedWalk
local MoveVectorCurrent = ZERO_VECTOR
local MoveVectorPrevious = ZERO_VECTOR
local MoveState = STATE_IDLE

local function SetMaxSpeed()
	if IsRunning then
		MaxSpeed = Config.speedRun
		MoveState = STATE_RUN
		ComponentSound:Update("move", 1.5)
	else
		if IsSneaking then
			MaxSpeed = Config.speedSneak
			MoveState = STATE_SNEAK
			ComponentSound:Update("move", 0.75)
		else
			MaxSpeed = Config.speedWalk
			MoveState = STATE_WALK
			ComponentSound:Update("move", 1)
		end
	end
end


local function handleMove(deltaTime)
	MoveVectorCurrent = ComponentController:GetMoveVector()
	SetMaxSpeed()

	if MoveVectorCurrent ~= ZERO_VECTOR then
		MovementLinearSpring.Target = MaxSpeed

		if IsRunning then
			ComponentStamina:Decrease(ComponentStamina.COST_RUNNING * deltaTime)
		end

		if MoveVectorCurrent:Dot(MoveVectorPrevious) == -1 then
			MovementLinearSpring.Position = math.clamp(MovementLinearSpring.Position * Config.springTurnMultiplier, 0, MaxSpeed)
		end
		MoveVectorPrevious = MoveVectorCurrent
	else
		MovementLinearSpring.Target = 0
		MoveState = STATE_IDLE
		ComponentSound:Update("move", 0)
	end

	if IsDebug then
		Debug:SetInputState(MoveState)
	end

	Humanoid:Move(MoveVectorPrevious, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end



local function handleRun(deltaTime)
	IsRunning = IsRunning and (tick() - lastRunRequest) < Config.runTapSpeed

	if ComponentController:GetIsRunPressed() and ComponentStamina:Can(ComponentStamina.COST_RUNNING * deltaTime) then
		IsRunning = true
		lastRunRequest = tick()
		ComponentController:CancelSneakToggle()
	end
end


local function handleSneak(deltaTime)
	if ComponentController:GetIsSneakToggle() then
		IsSneaking = true
	else
		IsSneaking = false
	end
end


local function handleBreath(deltaTime)
	if ComponentController:GetIsBreathHeld() and ComponentStamina:Decrease(ComponentStamina.COST_BREATH_HOLD * deltaTime) then
		IsBreathing = false
	else
		IsBreathing = true
	end

	ComponentBreath:Toggle(IsBreathing)
	ComponentSound:Update("breath", IsBreathing and 1 or 0)
end


local function OnCharacterAdded(newCharacter)
	Character = newCharacter
	Humanoid = newCharacter:WaitForChild("Humanoid")
	Root = newCharacter:WaitForChild("HumanoidRootPart")
end


local function Init()
	Humanoid.WalkSpeed = Config.speedWalk
	MoveState = STATE_IDLE

	RunService:BindToRenderStep("bindMove", Enum.RenderPriority.Input.Value, handleMove)
	RunService:BindToRenderStep("bindRun", Enum.RenderPriority.Input.Value, handleRun)
	RunService:BindToRenderStep("bindSneak", Enum.RenderPriority.Input.Value, handleSneak)
	RunService:BindToRenderStep("bindBreath", Enum.RenderPriority.Input.Value, handleBreath)

	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

	Debug:Toggle(IsDebug)

	return true
end



return Init()