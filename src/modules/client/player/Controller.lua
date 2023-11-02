local ContextActionService = game:GetService("ContextActionService")

local require = require(script.Parent.loader).load(script)


local ZERO_VECTOR3: Vector3 = Vector3.new(0,0,0)

local Controller = {}
Controller.__index = Controller

function Controller.new()
	local self = setmetatable({}, Controller)
	self.moveVector = ZERO_VECTOR3
	self.isRunPressed = false
	self.isSneaking = false
	self.isBreath = false

	self.forwardValue = 0
	self.backwardValue = 0
	self.leftValue = 0
	self.rightValue = 0

	return self
end


function Controller:GetMoveVector()
	return self.moveVector
end

function Controller:GetIsSneaking()
	return self.isSneaking
end

function Controller:SetIsSneaking(bool)
	self.isSneaking = bool
end

function Controller:GetIsRunPressed()
	if self.isRunPressed then
		self.isRunPressed = false
		return true
	end
	return false
end

function Controller:GetIsBreath()
	return self.isBreath
end

function Controller:UpdateMovement(inputState)
	if inputState == Enum.UserInputState.Cancel then
		self.moveVector = ZERO_VECTOR3
	else
		self.moveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
	end
end


function Controller:BindActions()
	local function handleMoveForward(actionName, inputState, inputObject)
		self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
		self:UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveBackward(actionName, inputState, inputObject)
		self.backwardValue  = (inputState == Enum.UserInputState.Begin) and 1 or 0
		self:UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveLeft(actionName, inputState, inputObject)
		self.leftValue  = (inputState == Enum.UserInputState.Begin) and -1 or 0
		self:UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleMoveRight(actionName, inputState, inputObject)
		self.rightValue  = (inputState == Enum.UserInputState.Begin) and 1 or 0
		self:UpdateMovement(inputState)
		return Enum.ContextActionResult.Pass
	end

	local function handleSneakMove(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			self.isSneaking = not self.isSneaking
		end
		return Enum.ContextActionResult.Pass
	end

	local function handleRunMove(actionName, inputState, inputObject)
		self.isRunPressed = inputState == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Pass
	end

	local function handleBreathHold(actionName, inputState, inputObject)
		self.isBreath = inputState == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Pass
	end

	ContextActionService:BindActionAtPriority("breathAction", handleBreathHold, false, 2, Enum.KeyCode.LeftShift)
	ContextActionService:BindActionAtPriority("runAction", handleRunMove, false, 2, Enum.KeyCode.Space)
	ContextActionService:BindActionAtPriority("sneakAction", handleSneakMove, false, 2, Enum.KeyCode.C)
	ContextActionService:BindActionAtPriority("moveForwardAction", handleMoveForward, false, 1, Enum.KeyCode.W)
	ContextActionService:BindActionAtPriority("moveBackwardAction", handleMoveBackward, false, 1, Enum.KeyCode.S)
	ContextActionService:BindActionAtPriority("moveLeftAction", handleMoveLeft, false, 1, Enum.KeyCode.A)
	ContextActionService:BindActionAtPriority("moveRightAction", handleMoveRight, false, 1, Enum.KeyCode.D)
end




return Controller
