local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local BIND_MOVE_FOWARD = "moveForward"
local BIND_MOVE_BACKWARD = "moveBackward"
local BIND_MOVE_LEFT = "moveLeft"
local BIND_MOVE_RIGHT = "moveRight"
local BIND_ACTION_RUN = "actionRun"
local BIND_ACTION_SNEAK = "actionSneak"
local BIND_ACTION_BREATH = "actionBreath"

local PRIORITY_MOVEMENT = 1
local PRIORITY_ACTION = 2

local KEYBOARD_INPUT_MOVE_FOWARD = Enum.KeyCode.W
local KEYBOARD_INPUT_MOVE_BACKWARD = Enum.KeyCode.S
local KEYBOARD_INPUT_MOVE_LEFT = Enum.KeyCode.A
local KEYBOARD_INPUT_MOVE_RIGHT = Enum.KeyCode.D
local KEYBOARD_INPUT_ACTION_RUN = Enum.KeyCode.Space
local KEYBOARD_INPUT_ACTION_SNEAK = Enum.KeyCode.C
local KEYBOARD_INPUT_ACTION_BREATH = Enum.KeyCode.LeftShift

local ZERO_VECTOR3 = Vector3.new(0,0,0)

local MoveVector = ZERO_VECTOR3
local MoveFowardValue = 0
local MoveBackwardValue = 0
local MoveLeftValue = 0
local MoveRightValue = 0

local IsRunPressed  = false
local IsSneakToggle = false
local IsBreathHeld = false


local function UpdateMovement(inputState)
	if inputState == Enum.UserInputState.Cancel then
		MoveVector = ZERO_VECTOR3
	else
		MoveVector = Vector3.new(MoveLeftValue + MoveRightValue, 0, MoveFowardValue + MoveBackwardValue)
	end
end


local function KeyboardInputBind()
	local function handleMoveForward(actionName, inputState, inputObject)
		MoveFowardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
		UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveBackward(actionName, inputState, inputObject)
		MoveBackwardValue  = (inputState == Enum.UserInputState.Begin) and 1 or 0
		UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveLeft(actionName, inputState, inputObject)
		MoveLeftValue  = (inputState == Enum.UserInputState.Begin) and -1 or 0
		UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveRight(actionName, inputState, inputObject)
		MoveRightValue  = (inputState == Enum.UserInputState.Begin) and 1 or 0
		UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleActionRun(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			IsRunPressed = true
		end
		return Enum.ContextActionResult.Pass
	end

	local function handleActionSneak(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			IsSneakToggle = not IsSneakToggle
		end
		return Enum.ContextActionResult.Pass
	end

	local function handleActionBreath(actionName, inputState, inputObject)
		IsBreathHeld = inputState == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Pass
	end

	ContextActionService:BindActionAtPriority(BIND_MOVE_FOWARD,		handleMoveForward,	false, PRIORITY_MOVEMENT,	KEYBOARD_INPUT_MOVE_FOWARD)
	ContextActionService:BindActionAtPriority(BIND_MOVE_BACKWARD,	handleMoveBackward,	false, PRIORITY_MOVEMENT,	KEYBOARD_INPUT_MOVE_BACKWARD)
	ContextActionService:BindActionAtPriority(BIND_MOVE_LEFT,		handleMoveLeft,		false, PRIORITY_MOVEMENT,	KEYBOARD_INPUT_MOVE_LEFT)
	ContextActionService:BindActionAtPriority(BIND_MOVE_RIGHT,		handleMoveRight,	false, PRIORITY_MOVEMENT,	KEYBOARD_INPUT_MOVE_RIGHT)
	ContextActionService:BindActionAtPriority(BIND_ACTION_RUN,		handleActionRun,	false, PRIORITY_ACTION,		KEYBOARD_INPUT_ACTION_RUN)
	ContextActionService:BindActionAtPriority(BIND_ACTION_SNEAK,	handleActionSneak,	false, PRIORITY_ACTION,		KEYBOARD_INPUT_ACTION_SNEAK)
	ContextActionService:BindActionAtPriority(BIND_ACTION_BREATH,	handleActionBreath,	false, PRIORITY_ACTION,		KEYBOARD_INPUT_ACTION_BREATH)
end


local function KeyboardInputUnbind()
	ContextActionService:UnbindAction(BIND_MOVE_FOWARD)
	ContextActionService:UnbindAction(BIND_MOVE_BACKWARD)
	ContextActionService:UnbindAction(BIND_MOVE_LEFT)
	ContextActionService:UnbindAction(BIND_MOVE_RIGHT)
	ContextActionService:UnbindAction(BIND_ACTION_RUN)
	ContextActionService:UnbindAction(BIND_ACTION_SNEAK)
	ContextActionService:UnbindAction(BIND_ACTION_BREATH)
end

----------------------------------------------------------
local IsKeyboard = false
local IsGamepad = false

local function BindInput(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		if IsKeyboard then
			KeyboardInputUnbind()
			IsKeyboard = false
		end
	else
		if not IsKeyboard then
			KeyboardInputBind()
			IsKeyboard = true
		end
	end
end

UserInputService.InputBegan:Connect(BindInput)

----------------------------------------------------------

local Controller = {}


function Controller:GetMoveVector()
	return MoveVector
end


function Controller:GetIsRunPressed()
	if IsRunPressed then
		IsRunPressed = false
		IsSneakToggle = false
		return true
	end
	return false
end

function Controller:CancelSneakToggle()
	IsSneakToggle = false
end


function Controller:GetIsSneakToggle()
	return IsSneakToggle
end


function Controller:GetIsBreathHeld()
	return IsBreathHeld
end


return Controller
