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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")
local ConfigMove = GeneralUtil:Get(ConfigFolder, "move", "Configuration")
local ConfigStamina = GeneralUtil:Get(ConfigFolder, "stamina", "Configuration")
local ConfigSound = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebugMove = GeneralUtil:GetBool(ConfigMove, "_DEBUG", true)
local IsDebugStamina = GeneralUtil:GetBool(ConfigStamina, "_DEBUG", true)
local IsDebugSound = GeneralUtil:GetBool(ConfigSound, "_DEBUG", true)

local CONFIG = {
	speedRun = GeneralUtil:GetNumber(ConfigMove, "speed run", IsDebugMove.Value),
	speedWalk = GeneralUtil:GetNumber(ConfigMove, "speed walk", IsDebugMove.Value),
	speedSneak = GeneralUtil:GetNumber(ConfigMove, "speed sneak", IsDebugMove.Value),

	runTapdelay = GeneralUtil:GetNumber(ConfigMove, "run tap delay", IsDebugMove.Value),

	springDamper = GeneralUtil:GetNumber(ConfigMove, "spring damper", IsDebugMove.Value),
	springSpeed = GeneralUtil:GetNumber(ConfigMove, "spring speed", IsDebugMove.Value),
	springTurnMultiplier = GeneralUtil:GetNumber(ConfigMove, "spring turn multiplier", IsDebugMove.Value),

	costRun = GeneralUtil:GetNumber(ConfigStamina, "cost run", IsDebugStamina.Value),
	costHoldBreath = GeneralUtil:GetNumber(ConfigStamina, "cost hold breath", IsDebugStamina.Value),

	modifierRun = GeneralUtil:GetNumber(ConfigSound, "modifier run", IsDebugSound.Value),
	modifierWalk = GeneralUtil:GetNumber(ConfigSound, "modifier walk", IsDebugSound.Value),
	modifierSneak = GeneralUtil:GetNumber(ConfigSound, "modifier sneak", IsDebugSound.Value),
	modifierIdle = GeneralUtil:GetNumber(ConfigSound, 'modifier idle', IsDebugSound.Value),
	modifierHoldBreath = GeneralUtil:GetNumber(ConfigSound, "modifier hold breath", IsDebugSound.Value)
}

local StatusFolder = GeneralUtil:Get(Character, "status", "Folder")

local STATUS = {
	isBreathing = GeneralUtil:GetBool(StatusFolder, "isBreathing", IsDebugMove.Value),
	isIdle = GeneralUtil:GetBool(StatusFolder, "isIdle", IsDebugMove.Value),
	isSneaking = GeneralUtil:GetBool(StatusFolder, "isSneaking", IsDebugMove.Value),
	isRunning = GeneralUtil:GetBool(StatusFolder, "isRunning", IsDebugMove.Value),
	requestHoldBreath = GeneralUtil:GetBool(StatusFolder, "request hold breath", IsDebugMove.Value),
	requestRun = GeneralUtil:GetBool(StatusFolder, "request run", IsDebugMove.Value),
	isTappingRun = GeneralUtil:GetBool(StatusFolder, "isTappingRun", IsDebugMove.Value),

	stamina = GeneralUtil:GetNumber(StatusFolder, "stamina", IsDebugMove.Value),
	moveState = GeneralUtil:GetNumber(StatusFolder, "move state", IsDebugMove.Value),
}

local ZERO_VECTOR = Vector3.new(0,0,0)
local STATE_IDLE, STATE_IDLE_SNEAK, STATE_WALK_SNEAK, STATE_WALK, STATE_RUN = 1, 2, 3, 4, 5


local Signals = {
	animate = nil,
}

local MovementLinearSpring = Spring.new(0)
MovementLinearSpring.Damper = CONFIG.springDamper.Value
MovementLinearSpring.Speed = CONFIG.springSpeed.Value

local lastRunRequest = tick()
local MaxSpeed = CONFIG.speedWalk.Value
local MoveVectorCurrent = ZERO_VECTOR
local MoveVectorPrevious = ZERO_VECTOR


local function CanStaminaDecrease(value)
	return STATUS.stamina.Value - value > 0
end

local function UpdateAnimate(state)
	Signals.animate:Fire(state)
end

local function RequestRun(value)
	STATUS.requestRun.Value = value
end

local function RequestHoldBreath(value)
	STATUS.requestHoldBreath.Value = value
end


local function SetMaxSpeed()
	if STATUS.isRunning.Value then
		MaxSpeed = CONFIG.speedRun.Value
		ComponentSound:Update("move", CONFIG.modifierRun.Value)
	else
		if STATUS.isSneaking.Value then
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

		if STATUS.isTappingRun.Value then
			STATUS.moveState.Value = STATE_RUN
			UpdateAnimate(STATUS.moveState.Value)
			RequestRun(true)
		elseif STATUS.isSneaking.Value then
			STATUS.moveState.Value = STATE_WALK_SNEAK
			UpdateAnimate(STATUS.moveState.Value)
			RequestRun(false)
		else
			STATUS.moveState.Value = STATE_WALK
			UpdateAnimate(STATUS.moveState.Value)
			RequestRun(false)
		end

		if MoveVectorCurrent:Dot(MoveVectorPrevious) == -1 then
			MovementLinearSpring.Position = math.clamp(MovementLinearSpring.Position * CONFIG.springTurnMultiplier.Value, 0, MaxSpeed)
		end
		MoveVectorPrevious = MoveVectorCurrent
	else
		MovementLinearSpring.Target = 0
		ComponentSound:Update("move", CONFIG.modifierIdle.Value)
		
		if STATUS.isSneaking.Value then
			STATUS.moveState.Value = STATE_IDLE_SNEAK
			UpdateAnimate(STATUS.moveState.Value)
		else
			STATUS.moveState.Value = STATE_IDLE
			UpdateAnimate(STATUS.moveState.Value)
		end

		RequestRun(false)
	end

	if IsDebugMove then
		Debug:SetInputState(STATUS.moveState.Value)
	end

	Humanoid:Move(MoveVectorPrevious, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end



local function handleRun(deltaTime)
	STATUS.isTappingRun.Value = STATUS.isTappingRun.Value and (tick() - lastRunRequest) <= CONFIG.runTapdelay.Value

	if ComponentController:GetIsRunPressed() then
		STATUS.isTappingRun.Value = true
		lastRunRequest = tick()
		ComponentController:CancelSneakToggle()
	end
end


local function handleSneak(deltaTime)
	if ComponentController:GetIsSneakToggle() then
		STATUS.isSneaking.Value = true
	else
		STATUS.isSneaking.Value = false
	end
end


local function handleBreath(deltaTime)
	if ComponentController:GetIsBreathHeld() and CanStaminaDecrease(CONFIG.costHoldBreath.Value * deltaTime) then
		RequestHoldBreath(true)
	else
		RequestHoldBreath(false)
	end

	ComponentBreath:Toggle(STATUS.isBreathing.Value)
	ComponentSound:UpdateBreath(STATUS.isBreathing.Value and 1 or CONFIG.modifierHoldBreath.Value, STATUS.isBreathing.Value)

end


local function OnCharacterAdded(newCharacter)
	Character = newCharacter
	Humanoid = newCharacter:WaitForChild("Humanoid")
	Root = newCharacter:WaitForChild("HumanoidRootPart")
end


local function Init()
	Humanoid.WalkSpeed = CONFIG.speedWalk.Value
	STATUS.moveState.Value = STATE_IDLE
	STATUS.isRunning.Value = false
	STATUS.isSneaking.Value = false
	STATUS.isBreathing.Value = true

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