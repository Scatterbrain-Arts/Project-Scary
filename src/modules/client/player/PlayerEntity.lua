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

local Signals = { animate = nil, stamina = nil}

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local StatusFolder = Character:FindFirstChild("status")
local StaminaInstance = StatusFolder:FindFirstChild("stamina")

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")
local MoveConfig = GeneralUtil:Get(ConfigFolder, "move", "Configuration")
local StaminaConfig = GeneralUtil:Get(ConfigFolder, "stamina", "Configuration")
local SoundConfig = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebugMove = GeneralUtil:GetBool(MoveConfig, "_DEBUG", true)
local IsDebugStamina = GeneralUtil:GetBool(StaminaConfig, "_DEBUG", true)
local IsDebugSound = GeneralUtil:GetBool(SoundConfig, "_DEBUG", true)

local CONFIG = {
	speedRun = GeneralUtil:GetNumber(MoveConfig, "speed run", 21, IsDebugMove.Value),
	speedWalk = GeneralUtil:GetNumber(MoveConfig, "speed walk", 14, IsDebugMove.Value),
	speedSneak = GeneralUtil:GetNumber(MoveConfig, "speed sneak", 7, IsDebugMove.Value),

	runTapdelay = GeneralUtil:GetNumber(MoveConfig, "run tap delay", 0.25, IsDebugMove.Value),

	springDamper = GeneralUtil:GetNumber(MoveConfig, "spring damper", 1, IsDebugMove.Value),
	springSpeed = GeneralUtil:GetNumber(MoveConfig, "spring speed", 8, IsDebugMove.Value),
	springTurnMultiplier = GeneralUtil:GetNumber(MoveConfig, "spring turn multiplier", 0.5, IsDebugMove.Value),

	costRun = GeneralUtil:GetNumber(StaminaConfig, "cost run", 50, IsDebugStamina.Value),
	costHoldBreath = GeneralUtil:GetNumber(StaminaConfig, "cost hold breath", 25, IsDebugStamina.Value),

	modifierRun = GeneralUtil:GetNumber(SoundConfig, "modifier run", 1.5, IsDebugSound.Value),
	modifierWalk = GeneralUtil:GetNumber(SoundConfig, "modifier walk", 1, IsDebugSound.Value),
	modifierSneak = GeneralUtil:GetNumber(SoundConfig, "modifier sneak", 0.75, IsDebugSound.Value),
	modifierIdle = GeneralUtil:GetNumber(SoundConfig, 'modifier idle', 0, IsDebugSound.Value),
	modifierHoldBreath = GeneralUtil:GetNumber(SoundConfig, "modifier hold breath", 0,IsDebugSound.Value)
}


local MovementLinearSpring = Spring.new(0)
MovementLinearSpring.Damper = CONFIG.springDamper.Value
MovementLinearSpring.Speed = CONFIG.springSpeed.Value

local IsRunning = false
local IsSneaking = false
local IsBreathing = true

local lastRunRequest = tick()

local MaxSpeed = CONFIG.speedWalk.Value
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
		MaxSpeed = CONFIG.speedRun.Value
		ComponentSound:Update("move", CONFIG.modifierRun.Value)
	else
		if IsSneaking then
			MaxSpeed = CONFIG.speedSneak.Value
			ComponentSound:Update("move", CONFIG.modifierSneak.Value)
		else
			MaxSpeed = CONFIG.speedWalk.Value
			ComponentSound:Update("move", CONFIG.modifierWalk.Value)
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
			UpdateStamina(CONFIG.costRun.Value * deltaTime)
		elseif IsSneaking then
			MoveState = STATE_WALK_SNEAK
			UpdateAnimate(MoveState)
		else
			MoveState = STATE_WALK
			UpdateAnimate(MoveState)
		end

		if MoveVectorCurrent:Dot(MoveVectorPrevious) == -1 then
			MovementLinearSpring.Position = math.clamp(MovementLinearSpring.Position * CONFIG.springTurnMultiplier.Value, 0, MaxSpeed)
		end
		MoveVectorPrevious = MoveVectorCurrent
	else
		MovementLinearSpring.Target = 0
		ComponentSound:Update("move", CONFIG.modifierIdle.Value)
		
		if IsSneaking then
			MoveState = STATE_IDLE_SNEAK
			UpdateAnimate(MoveState)
		else
			MoveState = STATE_IDLE
			UpdateAnimate(MoveState)
		end
	end

	if IsDebugMove then
		Debug:SetInputState(MoveState)
	end

	Humanoid:Move(MoveVectorPrevious, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end



local function handleRun(deltaTime)
	IsRunning = IsRunning and (tick() - lastRunRequest) < CONFIG.runTapdelay.Value

	if ComponentController:GetIsRunPressed() and CanStaminaDecrease(CONFIG.costRun.Value * deltaTime) then
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
	if ComponentController:GetIsBreathHeld() and CanStaminaDecrease(CONFIG.costHoldBreath.Value * deltaTime) then
		UpdateStamina(CONFIG.costHoldBreath.Value * deltaTime)
		IsBreathing = false
	else
		IsBreathing = true
	end

	ComponentBreath:Toggle(IsBreathing)
	ComponentSound:UpdateBreath(IsBreathing and 1 or CONFIG.modifierHoldBreath.Value, IsBreathing)

end


local function OnCharacterAdded(newCharacter)
	Character = newCharacter
	Humanoid = newCharacter:WaitForChild("Humanoid")
	Root = newCharacter:WaitForChild("HumanoidRootPart")
end


local function Init()
	Humanoid.WalkSpeed = CONFIG.speedWalk.Value
	MoveState = STATE_IDLE

	RunService:BindToRenderStep("bindMove", Enum.RenderPriority.Input.Value, handleMove)
	RunService:BindToRenderStep("bindRun", Enum.RenderPriority.Input.Value, handleRun)
	RunService:BindToRenderStep("bindSneak", Enum.RenderPriority.Input.Value, handleSneak)
	RunService:BindToRenderStep("bindBreath", Enum.RenderPriority.Input.Value, handleBreath)

	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

	Signals.animate = Signal.new()
	Signals.stamina = Signal.new()

	Debug:Toggle(IsDebugMove)

	return true
end
Init()


return Signals