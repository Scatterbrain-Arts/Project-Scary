local Stamina = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local SignalUpdateStamina = require(packages.PlayerEntity).stamina
local ComponentSound = require(packages.PlayerComponentSound)

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

local StatusFolder = Character:FindFirstChild("status") or Instance.new("Folder", Character)
StatusFolder.Name = "status"

local STATE_MIN, STATE_LOW, STATE_MED, STATE_HIGH, STATE_MAX = 1, 2, 3, 4, 5
local STATES = { STATE_MIN, STATE_LOW, STATE_MED , STATE_HIGH, STATE_MAX }
local RANGES = {
	[STATE_MIN] = {
		MIN = 0,
		MAX = 0,
		MODIFIER = 2,
	},
	[STATE_LOW] = {
		MIN = 1,
		MAX = 34,
		MODIFIER = 1.6,
	},
	[STATE_MED] = {
		MIN =35,
		MAX = 69,
		MODIFIER = 1.3,
	},
	[STATE_HIGH] = {
		MIN = 70,
		MAX = 99,
		MODIFIER = 1,
	},
	[STATE_MAX] = {
		MIN = 100,
		MAX = 100,
		MODIFIER = 0.7,
	},
}


local LastTick = tick()
local TimeToRegen = 4


local State = STATE_MAX
local StaminaValue = StatusFolder:FindFirstChild("stamina") or Instance.new("NumberValue")
StaminaValue.Name = "stamina"

StaminaValue.Value = STAMINA_MAX
StaminaText.Text = StaminaValue.Value


local function Increase(value)
	if StaminaValue.Value == STAMINA_MAX then
		return false
	end

	StaminaValue.Value = math.clamp(StaminaValue.Value+value, STAMINA_MIN, STAMINA_MAX)
	StaminaText.Text = StaminaValue.Value

	for i = State, STATE_MAX, 1 do
		if StaminaValue.Value >= RANGES[i].MIN and StaminaValue.Value <= RANGES[i].MAX then
			State = STATES[i]
			ComponentSound:Update("stamina", RANGES[State].MODIFIER)
			break
		end
	end

	return true
end


local function Update(deltaTime)
	if tick() - LastTick > TimeToRegen then
		if StaminaValue.Value ~= STAMINA_MAX then
			Increase(STAMINA_REGEN*deltaTime)
		end
	end
end


local function Decrease(value)
	if StaminaValue.Value - value < STAMINA_MIN then
		return false
	end

	StaminaValue.Value -= value
	StaminaText.Text = StaminaValue.Value
	LastTick = tick()

	for i = State, STATE_MIN, -1 do
		if StaminaValue.Value >= RANGES[i].MIN and StaminaValue.Value <= RANGES[i].MAX then
			State = STATES[i]
			ComponentSound:Update("stamina", RANGES[State].MODIFIER)
			break
		end
	end

	return true
end


local function OnStaminaSignal(value)
	Decrease(value)
end


local function Init()
	Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()


	RunService.Heartbeat:Connect(Update)
	SignalUpdateStamina:Connect(OnStaminaSignal)
end
Init()