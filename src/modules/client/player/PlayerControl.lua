local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local ControllerService = require("Controller")
local Spring = require("Spring")
local Stamina = require("Stamina")

local ZERO_VECTOR = Vector3.new(0,0,0)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local PlayerControls = {}

local Controller = ControllerService.new()
Controller:BindActions()

local MovementLinearSpring = Spring.new(0)
MovementLinearSpring.Damper = 1
MovementLinearSpring.Speed = 8

local RunSpeed = 21
local WalkSpeed = 14
local SneakSpeed = 7

local IsRunning = false

local lastDirection = ZERO_VECTOR
local lastRunRequest = tick()
local RunTimer = 0.25

Humanoid.WalkSpeed = 0

local PlayerGui = LocalPlayer.PlayerGui
local BreathGui = PlayerGui:FindFirstChild("breath")
local BreathGuiText = BreathGui.Frame.TextLabel

local InputGui = PlayerGui:FindFirstChild("input")
local InputGuiText = InputGui.Frame.TextLabel

local function GetMaxSpeed()
	local speed
	if Controller:GetIsSneaking() then
		InputGuiText.Text = " SNEAK "
		speed = SneakSpeed
	else
		InputGuiText.Text = " WALK "
		speed = WalkSpeed
	end

	return speed
end


local function move(deltaTime)
	IsRunning = (tick() - lastRunRequest) < RunTimer

	if Controller:GetMoveVector() ~= ZERO_VECTOR then
		if Controller:GetIsRunPressed() and Stamina:Can(Stamina.COST_RUNNING * deltaTime) then
			IsRunning = true
			lastRunRequest = tick()
			Controller:SetIsSneaking(false)
		end

		MovementLinearSpring.Target = IsRunning and RunSpeed or GetMaxSpeed()

		local currentDirection = Controller:GetMoveVector()

		if currentDirection:Dot(lastDirection) == -1 then
			MovementLinearSpring.Position /= 2
		end
		lastDirection = currentDirection
	else
		MovementLinearSpring.Target = 0
	end

	if IsRunning then
		Stamina:Decrease(Stamina.COST_RUNNING * deltaTime)
		InputGuiText.Text = " RUN "
	end

	Humanoid:Move(lastDirection, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end

local function breathHold(deltaTime)
	if Controller:GetIsBreath() and Stamina:Decrease(Stamina.COST_BREATH_HOLD * deltaTime) then
		BreathGuiText.Text = "BREATH"
	else
		BreathGuiText.Text = ""
	end
end


RunService:BindToRenderStep("move", Enum.RenderPriority.Input.Value, move)
RunService:BindToRenderStep("breathHold", Enum.RenderPriority.Character.Value, breathHold)

LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end)


return PlayerControls