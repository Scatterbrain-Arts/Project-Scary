
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local Stamina = {}
Stamina.COST_RUNNING = 50
Stamina.COST_BREATH_HOLD = 25

local STAMINA_MAX = 100
local STAMINA_MIN = 0
local STAMINA_NAME = "stamina"
local STAMINA_REGEN = 25

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")


local PlayerGui = LocalPlayer.PlayerGui
local StaminaGUi = PlayerGui:FindFirstChild(STAMINA_NAME)
local StaminaText = StaminaGUi.Frame.TextLabel


local ConfigFolder = Character:FindFirstChild("config") or Instance.new("Folder", Character)
ConfigFolder.Name = "config"

local StaminaValue = ConfigFolder:FindFirstChild(STAMINA_NAME) or Instance.new("NumberValue", ConfigFolder)
StaminaValue.Name = STAMINA_NAME


local LastTick = tick()
local TimeToRegen = 4


StaminaValue.Changed:Connect(function(newValue)
	StaminaText.Text = newValue
end)
StaminaValue.Value = STAMINA_MAX

RunService.Heartbeat:Connect(function(deltaTime)
	if tick() - LastTick > TimeToRegen then
		Stamina:Increase(STAMINA_REGEN*deltaTime)
	end
end)


function Stamina:Can(value)
	return StaminaValue.Value - value > STAMINA_MIN
end


function Stamina:Get()
	return StaminaValue.Value
end


function Stamina:Increase(value)
	if StaminaValue.Value == STAMINA_MAX then
		return false
	end

	StaminaValue.Value = math.clamp(StaminaValue.Value+value, STAMINA_MIN, STAMINA_MAX)

	return true
end


function Stamina:Decrease(value)
	if StaminaValue.Value - value < STAMINA_MIN then
		return false
	end

	StaminaValue.Value -= value
	LastTick = tick()

	return true
end


return Stamina