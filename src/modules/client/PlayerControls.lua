local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local ControllerService = require("Controller")
local Spring = require("Spring")

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
MovementLinearSpring.Speed = 10

local MaxSpeed = 16

local lastDirection = ZERO_VECTOR

Humanoid.WalkSpeed = 0
local function move(deltaTime)
	if Controller:GetMoveVector() ~= ZERO_VECTOR then
		MovementLinearSpring.Target = MaxSpeed

		local currentDirection = Controller:GetMoveVector()

		if currentDirection:Dot(lastDirection) == -1 then
			MovementLinearSpring.Position /= 2
		end
		lastDirection = currentDirection
	else
		MovementLinearSpring.Target = 0
	end

	Humanoid:Move(lastDirection, true)
	Humanoid.WalkSpeed = MovementLinearSpring.Position
end


RunService:BindToRenderStep("move", Enum.RenderPriority.Input.Value, move)


return PlayerControls