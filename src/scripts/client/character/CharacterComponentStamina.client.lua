local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)

local SignalUpdateStamina = require(packages.PlayerEntity).stamina
local ComponentSound = require(packages.PlayerComponentSound)

local STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED, STATE_STAMINA_HIGH, STATE_STAMINA_MAX = 1, 2, 3, 4, 5
local STATES = { STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED , STATE_STAMINA_HIGH, STATE_STAMINA_MAX }

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")
local StatusFolder = GeneralUtil:Get(Character, "status", "Folder")

local StaminaConfig = GeneralUtil:Get(ConfigFolder, "stamina", "Configuration")
local SoundConfig = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebugStamina = GeneralUtil:GetBool(StaminaConfig, "_DEBUG", true)
local IsDebugSound = GeneralUtil:GetBool(SoundConfig, "_DEBUG", true)

local CONFIG = {
	costRun = GeneralUtil:GetNumber(StaminaConfig, "cost run", 50, IsDebugStamina.Value),
	costHoldBreath = GeneralUtil:GetNumber(StaminaConfig, "cost hold breath", 25, IsDebugStamina.Value),
	regenAmount = GeneralUtil:GetNumber(StaminaConfig, "regen amount", 25, IsDebugStamina.Value),
	regenDelay = GeneralUtil:GetNumber(StaminaConfig, "regen delay", 4, IsDebugStamina.Value),
	staminaMax = GeneralUtil:GetNumber(StaminaConfig, "stamina max", 100, IsDebugStamina.Value),
	staminaMin = GeneralUtil:GetNumber(StaminaConfig, "stamina min", 0, IsDebugStamina.Value),

	rangeLow = GeneralUtil:GetVector(StaminaConfig, "range low", Vector3.new(1,34,0), IsDebugStamina.Value),
	rangeMed = GeneralUtil:GetVector(StaminaConfig, "range med", Vector3.new(35,69,0), IsDebugStamina.Value),
	rangeHigh = GeneralUtil:GetVector(StaminaConfig, "range high", Vector3.new(70,99,0), IsDebugStamina.Value),

	modifierStaminaMin = GeneralUtil:GetNumber(SoundConfig, "modifier stamina min", 2, IsDebugSound.Value),
	modifierStaminaLow = GeneralUtil:GetNumber(SoundConfig, "modifier stamina low", 1.6, IsDebugSound.Value),
	modifierStaminaMed = GeneralUtil:GetNumber(SoundConfig, "modifier stamina med", 1.3, IsDebugSound.Value),
	modifierStaminaHigh = GeneralUtil:GetNumber(SoundConfig, "modifier stamina high", 1, IsDebugSound.Value),
	modifierStaminaMax = GeneralUtil:GetNumber(SoundConfig, "modifier stamina max", 0.7, IsDebugSound.Value),
}

local RANGES = {
	[STATE_STAMINA_MIN] = {
		min = 0,
		max = 0,
		MODIFIER = CONFIG.modifierStaminaMin.Value,
	},
	[STATE_STAMINA_LOW] = {
		min = CONFIG.rangeLow.Value.X,
		max = CONFIG.rangeLow.Value.Y,
		MODIFIER = CONFIG.modifierStaminaLow.Value,
	},
	[STATE_STAMINA_MED] = {
		min = CONFIG.rangeMed.Value.X,
		max = CONFIG.rangeMed.Value.Y,
		MODIFIER = CONFIG.modifierStaminaMed.Value,
	},
	[STATE_STAMINA_HIGH] = {
		min = CONFIG.rangeHigh.Value.X,
		max = CONFIG.rangeHigh.Value.Y,
		MODIFIER = CONFIG.modifierStaminaHigh.Value,
	},
	[STATE_STAMINA_MAX] = {
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

local State = STATE_STAMINA_MAX
local LastTick = tick()

local function Increase(value)
	if Stamina.Value == CONFIG.staminaMax.Value then
		return false
	end

	Stamina.Value = math.clamp(Stamina.Value+value, CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)
	StaminaText.Text = Stamina.Value

	for i = State, STATE_STAMINA_MAX, 1 do
		if Stamina.Value >= RANGES[i].min and Stamina.Value <= RANGES[i].max then
			State = STATES[i]
			ComponentSound:UpdateStamina(RANGES[State].MODIFIER, State, Stamina.Value)
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

	for i = State, STATE_STAMINA_MIN, -1 do
		if Stamina.Value >= RANGES[i].min and Stamina.Value <= RANGES[i].max then
			State = STATES[i]
			ComponentSound:UpdateStamina(RANGES[State].MODIFIER, State, Stamina.Value)
			break
		end
	end

	return true
end


local function OnStaminaSignal(value)
	Decrease(value)
end


math.randomseed(tick())
RunService.Heartbeat:Connect(function(deltaTime)
	if isHoldBreath then
		if not requestHoldBreath then
			isHoldBreath = false
			IsExhale = true
			IsInhale = false
			exhaleOffset = 0
		end
		return
	end

	if requestHoldBreath and not isHoldBreath then
		exhaleOffset = BreathLength
	end

	if tick() - lastTick >= BreathLength-exhaleOffset+math.random(0, 1) then
		if IsInhale then
			sound = GetInhaleSound()
		end
		
		if IsExhale then
			sound = SFXBreath.exhale
		end

		if requestHoldBreath then
			sound = SFXBreath.inhale
			isHoldBreath = true
		end
		
		Breathe()
		Tracks.breath = PlaySound(sound)
		lastTick = tick()
	end

end)







RunService.Heartbeat:Connect(Update)
SignalUpdateStamina:Connect(OnStaminaSignal)