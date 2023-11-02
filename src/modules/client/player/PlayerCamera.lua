local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local ControllerService = require("Controller")
local Spring = require("Spring")

local ZERO_VECTOR = Vector3.new(0,0,0)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Head = Character:WaitForChild("Head")




local Camera = game.Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CameraSubject = LocalPlayer
Camera.CFrame = Root.CFrame
Camera.Focus = Root.CFrame

local MouseRotationVec = Vector2.new(0,0)

local CameraToggle3rd = false

local CameraPositionVec
local CameraRotationCF
local CameraCFrame

local RotateSpeed = 0.08
local OverShoulderOffset = Vector3.new(-3, 0, 2)

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("Accessory") then
		v:Destroy()
	end
end


local function UpdateFirstPersonCamera()
	CameraPositionVec = Head.Position
	CameraRotationCF = CFrame.Angles(0, MouseRotationVec.X, 0) * CFrame.Angles(MouseRotationVec.Y, 0, 0)
	CameraCFrame = CameraRotationCF + CameraPositionVec
	Camera.CFrame = CameraCFrame
	Camera.Focus = CameraCFrame
end

local center
local offset = CFrame.new(2,0,4)
local function UpdateOverShoulderCamera()
	center = CFrame.new(Head.Position)

	CameraCFrame = center * CFrame.Angles(0, MouseRotationVec.X, 0) * offset
	Camera.CFrame = CameraCFrame
	Camera.Focus = CameraCFrame
end


local function UpdateCameraControl(actionName, inputState, inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		MouseRotationVec -= UserInputService:GetMouseDelta() * math.rad(RotateSpeed)
	end
	return Enum.ContextActionResult.Pass
end


local function handleCamera()
	if CameraToggle3rd then
		Head.Transparency = 0
		UpdateOverShoulderCamera()
	else
		Head.Transparency = 1
		UpdateFirstPersonCamera()
	end
end

local function CameraToggle3rdfn(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		CameraToggle3rd = not CameraToggle3rd
	end
	return Enum.ContextActionResult.Pass
	
end

RunService:BindToRenderStep("camera", Enum.RenderPriority.Camera.Value, handleCamera)
ContextActionService:BindActionAtPriority("cameraControl", UpdateCameraControl, false, 2, Enum.UserInputType.MouseMovement)
ContextActionService:BindActionAtPriority("toogleCamera", CameraToggle3rdfn, false, 1, Enum.KeyCode.T)





LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Head = Character:WaitForChild("Head")

	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") then
			v:Destroy()
		end
	end
end)



return {}