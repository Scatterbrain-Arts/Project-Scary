local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Head = Character:WaitForChild("Head")
Head.Transparency = 1

local Camera = game.Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CameraSubject = LocalPlayer
Camera.CFrame = Root.CFrame
Camera.Focus = Root.CFrame

local MouseRotationVec = Vector2.new(0,0)

local CameraPositionVec
local CameraRotationCF
local CameraCFrame

local RotateSpeed = 0.08

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


local function UpdateCameraControl(actionName, inputState, inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		MouseRotationVec -= UserInputService:GetMouseDelta() * math.rad(RotateSpeed)
	end
	return Enum.ContextActionResult.Pass
end


RunService:BindToRenderStep("camera", Enum.RenderPriority.Camera.Value, UpdateFirstPersonCamera)
ContextActionService:BindActionAtPriority("cameraControl", UpdateCameraControl, false, 1, Enum.UserInputType.MouseMovement)





LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Head = Character:WaitForChild("Head")
	Head.Transparency = 1

	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") then
			v:Destroy()
		end
	end
end)



return {}