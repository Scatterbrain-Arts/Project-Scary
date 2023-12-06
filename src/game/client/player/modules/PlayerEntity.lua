local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Spring = require("Spring")
local GeneralUtil = require("GeneralUtil")

local ComponentCamera = require("PlayerComponentCamera")
local ComponentController = require("PlayerComponentController")
local PlayerDebug = require("PlayerDebug")
local OverrideNPC = require("OverrideNPC")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local ConfigFolder = GeneralUtil:Get("Folder", Character, "config")
local ConfigMove = GeneralUtil:Get("Configuration", ConfigFolder, "move")

local IsDebug = GeneralUtil:GetBool(ConfigMove, "_DEBUG", true)

local CONFIG = {
	speedRun = GeneralUtil:GetNumber(ConfigMove, "speed run", IsDebug.Value),
	speedWalk = GeneralUtil:GetNumber(ConfigMove, "speed walk", IsDebug.Value),
	speedCrouch = GeneralUtil:GetNumber(ConfigMove, "speed crouch", IsDebug.Value),

	runTapdelay = GeneralUtil:GetNumber(ConfigMove, "run tap delay", IsDebug.Value),

	springDamper = GeneralUtil:GetNumber(ConfigMove, "spring damper", IsDebug.Value),
	springSpeed = GeneralUtil:GetNumber(ConfigMove, "spring speed", IsDebug.Value),
	springTurnMultiplier = GeneralUtil:GetNumber(ConfigMove, "spring turn multiplier", IsDebug.Value),
}

local StatusFolder = GeneralUtil:Get("Folder", Character, "status")

local STATUS = {
	isBreathing = GeneralUtil:GetBool(StatusFolder, "breath isBreathing", IsDebug.Value),
	requestHoldBreath = GeneralUtil:GetBool(StatusFolder, "breath request hold breath", IsDebug.Value),

	isCrouching = GeneralUtil:GetBool(StatusFolder, "move isCrouching", IsDebug.Value),
	isRunning = GeneralUtil:GetBool(StatusFolder, "move isRunning", IsDebug.Value),
	isTappingRun = GeneralUtil:GetBool(StatusFolder, "move isTappingRun", IsDebug.Value),
	requestRun = GeneralUtil:GetBool(StatusFolder, "move request run", IsDebug.Value),

	moveState = GeneralUtil:GetNumber(StatusFolder, "state move", IsDebug.Value),
}

local ZERO_VECTOR = Vector3.new(0,0,0)

local MovementLinearSpring = nil
local RunRequestLastTick = nil
local MaxSpeed = nil
local MoveVectorCurrent = ZERO_VECTOR
local MoveVectorPrevious = ZERO_VECTOR


-- state is set by CharacterComponentStamina
-- TRUE if enough stamina
local function RequestRun(value)
	STATUS.requestRun.Value = value
end


-- state is set by CharacterComponentStamina
-- TRUE after inhaling to hold breath
local function RequestHoldBreath(value)
	STATUS.requestHoldBreath.Value = value
end


local function IsDirectionPressed()
	MoveVectorCurrent = ComponentController:GetMoveVector()
	return MoveVectorCurrent ~= ZERO_VECTOR
end


local function HasPlayerTurned()
	if MoveVectorCurrent:Dot(MoveVectorPrevious) == -1 then
		MovementLinearSpring.Position = math.clamp(MovementLinearSpring.Position * CONFIG.springTurnMultiplier.Value, 0, MaxSpeed)
	end
	MoveVectorPrevious = MoveVectorCurrent
end


local function SetState(state, speed)
	STATUS.moveState.Value = state
	MaxSpeed = speed
end


local function handleMove(deltaTime)
	if IsDirectionPressed() then
		HasPlayerTurned()

		if STATUS.isRunning.Value then
			SetState(shared.states.move.run, CONFIG.speedRun.Value)
		elseif STATUS.isCrouching.Value then
			SetState(shared.states.move.walkCrouch, CONFIG.speedCrouch.Value)
		else
			SetState(shared.states.move.walk, CONFIG.speedWalk.Value)
		end

	else
		if STATUS.isCrouching.Value then
			SetState(shared.states.move.idleCrouch, 0)
		else
			SetState(shared.states.move.idle, 0)
		end
	end

	MovementLinearSpring.Target = MaxSpeed
	Humanoid:Move(MoveVectorPrevious, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end


local function handleRun(deltaTime)
	STATUS.isTappingRun.Value = STATUS.isTappingRun.Value and (tick() - RunRequestLastTick) <= CONFIG.runTapdelay.Value

	if ComponentController:GetIsRunPressed() then
		STATUS.isTappingRun.Value = true
		RunRequestLastTick = tick()
		ComponentController:CancelCrouchToggle()

		if ComponentController:GetMoveVector() then
			RequestRun(true)
		end
	end

	if not STATUS.isTappingRun.Value then
		RequestRun(false)
	end
end


local function handleCrouch(deltaTime)
	if ComponentController:GetIsCrouchToggle() then
		STATUS.isCrouching.Value = true
	else
		STATUS.isCrouching.Value = false
	end
end


local function handleBreath(deltaTime)
	if ComponentController:GetIsBreathHeld() then
		RequestHoldBreath(true)
	else
		RequestHoldBreath(false)
	end
end


local function OnCharacterAdded(newCharacter)
	Character = newCharacter
	Humanoid = newCharacter:WaitForChild("Humanoid")

	MaxSpeed = CONFIG.speedWalk.Value
	Humanoid.WalkSpeed = CONFIG.speedWalk.Value

	STATUS.moveState.Value = shared.states.move.walk
	STATUS.isRunning.Value = false
	STATUS.isCrouching.Value = false
	STATUS.isBreathing.Value = true
end


local function Init()
	MovementLinearSpring = Spring.new(0)
	MovementLinearSpring.Damper = CONFIG.springDamper.Value
	MovementLinearSpring.Speed = CONFIG.springSpeed.Value

	MaxSpeed = CONFIG.speedWalk.Value
	Humanoid.WalkSpeed = CONFIG.speedWalk.Value

	STATUS.moveState.Value = shared.states.move.walk
	STATUS.isRunning.Value = false
	STATUS.isCrouching.Value = false
	STATUS.isBreathing.Value = true

	RunService:BindToRenderStep("bindBreath", Enum.RenderPriority.Input.Value+1, handleBreath)
	RunService:BindToRenderStep("bindRun", Enum.RenderPriority.Input.Value+2, handleRun)
	RunService:BindToRenderStep("bindCrouch", Enum.RenderPriority.Input.Value+3, handleCrouch)
	RunService:BindToRenderStep("bindMove", Enum.RenderPriority.Input.Value+4, handleMove)

	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

	return true
end



return Init()