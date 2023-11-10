local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)

local SignalUpdateStamina = require(packages.PlayerEntity).stamina
local ComponentSound = require(packages.PlayerComponentSound)

local STATE_MIN, STATE_LOW, STATE_MED, STATE_HIGH, STATE_MAX = 1, 2, 3, 4, 5
local STATES = { STATE_MIN, STATE_LOW, STATE_MED , STATE_HIGH, STATE_MAX }

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")
local StatusFolder = GeneralUtil:Get(Character, "status", "Folder")

local StaminaConfig = GeneralUtil:Get(ConfigFolder, "stamina", "Configuration")
local SoundConfig = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebugStamina = GeneralUtil:GetBool(StaminaConfig, "_DEBUG", true)
local IsDebugSound = GeneralUtil:GetBool(SoundConfig, "_DEBUG", true)

local CONFIG = {
	costRun = GeneralUtil:GetNumber(StaminaConfig, "cost run", 50, IsDebugStamina),
	costHoldBreath = GeneralUtil:GetNumber(StaminaConfig, "cost hold breath", 25, IsDebugStamina),
	regenAmount = GeneralUtil:GetNumber(StaminaConfig, "regen amount", 25, IsDebugStamina),
	regenDelay = GeneralUtil:GetNumber(StaminaConfig, "regen delay", 4, IsDebugStamina),
	staminaMax = GeneralUtil:GetNumber(StaminaConfig, "stamina max", 100, IsDebugStamina),
	staminaMin = GeneralUtil:GetNumber(StaminaConfig, "stamina min", 0, IsDebugStamina),

	rangeLow = GeneralUtil:GetVector(StaminaConfig, "range low", Vector3.new(1,34,0), IsDebugStamina),
	rangeMed = GeneralUtil:GetVector(StaminaConfig, "range med", Vector3.new(35,69,0), IsDebugStamina),
	rangeHigh = GeneralUtil:GetVector(StaminaConfig, "range high", Vector3.new(70,99,0), IsDebugStamina),

	modifierStaminaMin = GeneralUtil:GetNumber(SoundConfig, "modifier stamina min", 2, IsDebugSound),
	modifierStaminaLow = GeneralUtil:GetNumber(SoundConfig, "modifier stamina low", 1.6, IsDebugSound),
	modifierStaminaMed = GeneralUtil:GetNumber(SoundConfig, "modifier stamina med", 1.3, IsDebugSound),
	modifierStaminaHigh = GeneralUtil:GetNumber(SoundConfig, "modifier stamina high", 1, IsDebugSound),
	modifierStaminaMax = GeneralUtil:GetNumber(SoundConfig, "modifier stamina max", 0.7, IsDebugSound),
}

local RANGES = {
	[STATE_MIN] = {
		min = 0,
		max = 0,
		MODIFIER = CONFIG.modifierStaminaMin.Value,
	},
	[STATE_LOW] = {
		min = CONFIG.rangeLow.Value.X,
		max = CONFIG.rangeLow.Value.Y,
		MODIFIER = CONFIG.modifierStaminaLow.Value,
	},
	[STATE_MED] = {
		min = CONFIG.rangeMed.Value.X,
		max = CONFIG.rangeMed.Value.Y,
		MODIFIER = CONFIG.modifierStaminaMed.Value,
	},
	[STATE_HIGH] = {
		min = CONFIG.rangeHigh.Value.X,
		max = CONFIG.rangeHigh.Value.Y,
		MODIFIER = CONFIG.modifierStaminaHigh.Value,
	},
	[STATE_MAX] = {
		min = 100,
		max = 100,
		MODIFIER = CONFIG.modifierStaminaMax.Value,
	},
}

local StaminaGUi = LocalPlayer.PlayerGui:FindFirstChild("stamina")
local StaminaText = StaminaGUi.Frame.TextLabel

local Stamina = GeneralUtil:GetNumber(StatusFolder, "stamina", CONFIG.staminaMax)
Stamina.Value = CONFIG.staminaMax.Value
StaminaText.Text = Stamina.Value

local State = STATE_MAX
local LastTick = tick()

local function Increase(value)
	if Stamina.Value == CONFIG.staminaMax.Value then
		return false
	end

	Stamina.Value = math.clamp(Stamina.Value+value, CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)
	StaminaText.Text = Stamina.Value

	for i = State, STATE_MAX, 1 do
		if Stamina.Value >= RANGES[i].min and Stamina.Value <= RANGES[i].max then
			State = STATES[i]
			ComponentSound:Update("stamina", RANGES[State].MODIFIER)
			break
		end
	end

	return true
end


local function Update(deltaTime)
	if tick() - LastTick > CONFIG.regenDelay.Value then
		if Stamina.Value ~= CONFIG.staminaMax.Value then
			Increase(CONFIG.regenAmount.Value*deltaTime)
		end
	end
end


local function Decrease(value)
	if Stamina.Value - value < CONFIG.staminaMin.Value then
		return false
	end

	Stamina.Value -= value
	StaminaText.Text = Stamina.Value
	LastTick = tick()

	for i = State, STATE_MIN, -1 do
		if Stamina.Value >= RANGES[i].min and Stamina.Value <= RANGES[i].max then
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


RunService.Heartbeat:Connect(Update)
SignalUpdateStamina:Connect(OnStaminaSignal)