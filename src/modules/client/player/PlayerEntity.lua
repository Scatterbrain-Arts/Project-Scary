local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Signal = require("Signal")
local Spring = require("Spring")
local GeneralUtil = require("GeneralUtil")

local ComponentCamera = require("PlayerComponentCamera")
local ComponentController = require("PlayerComponentController")
local ComponentSound = require("PlayerComponentSound")
local ComponentBreath = require("PlayerComponentBreath")

local Debug = require("PlayerDebug")

local ZERO_VECTOR = Vector3.new(0,0,0)
local STATE_IDLE, STATE_IDLE_SNEAK, STATE_WALK_SNEAK, STATE_WALK, STATE_RUN = "idle", "idle_sneak", "walk_sneak", "walk", "run"

local Signals = { animate = nil, stamina = nil, }

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local IsDebug = GeneralUtil:GetCondition(Character, "_DEBUG") or false

local StatusFolder = Character:FindFirstChild("status")
local StaminaInstance = StatusFolder:FindFirstChild("stamina")

local ConfigFolder = Character:FindFirstChild("config")
local Config = {
	speedRun = GeneralUtil:GetValue(Character, "moveSpeedRun", IsDebug) or 21,
	speedWalk = GeneralUtil:GetValue(Character, "moveSpeedWalk", IsDebug) or 14,
	speedSneak = GeneralUtil:GetValue(Character, "moveSpeedSneak", IsDebug) or 7,

	runTapSpeed = GeneralUtil:GetValue(Character, "moveRunTapSpeed", IsDebug) or 0.25,

	springDamper = GeneralUtil:GetValue(Character, "springDamper", IsDebug) or 1,
	springSpeed = GeneralUtil:GetValue(Character, "springSpeed", IsDebug) or 8,
	springTurnMultiplier = GeneralUtil:GetValue(Character, "springTurnMultiplier", IsDebug) or 0.5,

	runCost = 50,
	breathCost = 25,
}

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

local function CanStaminaDecrease(value)
	return StaminaInstance.Value - value > 0
end

local function UpdateAnimate(state)
	Signals.animate:Fire(state)
end

local function UpdateStamina(value)
	Signals.stamina:Fire(value)
end



local function SetMaxSpeed()
	if IsRunning then
		MaxSpeed = Config.speedRun
		ComponentSound:Update("move", 1.5)
	else
		if IsSneaking then
			MaxSpeed = Config.speedSneak
			ComponentSound:Update("move", 0.75)
		else
			MaxSpeed = Config.speedWalk
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
			MoveState = STATE_RUN
			UpdateAnimate(MoveState)
			UpdateStamina(Config.runCost * deltaTime)
		elseif IsSneaking then
			MoveState = STATE_WALK_SNEAK
			UpdateAnimate(MoveState)
		else
			MoveState = STATE_WALK
			UpdateAnimate(MoveState)
		end

		if MoveVectorCurrent:Dot(MoveVectorPrevious) == -1 then
			MovementLinearSpring.Position = math.clamp(MovementLinearSpring.Position * Config.springTurnMultiplier, 0, MaxSpeed)
		end
		MoveVectorPrevious = MoveVectorCurrent
	else
		MovementLinearSpring.Target = 0
		ComponentSound:Update("move", 0)
		
		if IsSneaking then
			MoveState = STATE_IDLE_SNEAK
			UpdateAnimate(MoveState)
		else
			MoveState = STATE_IDLE
			UpdateAnimate(MoveState)
		end
	end

	if IsDebug then
		Debug:SetInputState(MoveState)
	end

	Humanoid:Move(MoveVectorPrevious, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end



local function handleRun(deltaTime)
	IsRunning = IsRunning and (tick() - lastRunRequest) < Config.runTapSpeed

	if ComponentController:GetIsRunPressed() and CanStaminaDecrease(Config.runCost * deltaTime) then
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
	if ComponentController:GetIsBreathHeld() and CanStaminaDecrease(Config.runCost * deltaTime) then
		UpdateStamina(Config.breathCost * deltaTime)
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

	Signals.animate = Signal.new()
	Signals.stamina = Signal.new()

	Debug:Toggle(IsDebug)

	return true
end
Init()


return Signals