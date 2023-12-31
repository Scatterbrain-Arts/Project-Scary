local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)

local Math = require(packages.Math)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ConfigFolder = GeneralUtil:Get("Folder", Character, "config")
local ConfigStamina = GeneralUtil:Get("Configuration", ConfigFolder, "stamina")

local IsDebugStamina = GeneralUtil:GetBool(ConfigStamina, "_DEBUG", true)

local CONFIG = {
	breathLength = GeneralUtil:GetNumber(ConfigStamina, "breath cycle delay", IsDebugStamina.Value),

	costRun = GeneralUtil:GetNumber(ConfigStamina, "stamina cost run per tick", IsDebugStamina.Value),
	costHoldBreath = GeneralUtil:GetNumber(ConfigStamina, "stamina cost hold breath per tick", IsDebugStamina.Value),
	staminaInhaleIncreaseAmount = GeneralUtil:GetNumber(ConfigStamina, "stamina inhale increase amount", IsDebugStamina.Value),
	staminaMax = GeneralUtil:GetNumber(ConfigStamina, "stamina max value", IsDebugStamina.Value),
	staminaMin = GeneralUtil:GetNumber(ConfigStamina, "stamina min value", IsDebugStamina.Value),

	rangeLow = GeneralUtil:GetVector(ConfigStamina, "state range low", IsDebugStamina.Value),
	rangeMed = GeneralUtil:GetVector(ConfigStamina, "state range med", IsDebugStamina.Value),
	rangeHigh = GeneralUtil:GetVector(ConfigStamina, "state range high", IsDebugStamina.Value),
}

local StatusFolder = GeneralUtil:Get("Folder", Character, "status")

local STATUS = {
	isBreathing = GeneralUtil:GetBool(StatusFolder, "breath isBreathing", IsDebugStamina.Value),
	isInhale = GeneralUtil:GetBool(StatusFolder, "breath isInhale", IsDebugStamina.Value),
	isExhale = GeneralUtil:GetBool(StatusFolder, "breath isExhale", IsDebugStamina.Value),
	requestHoldBreath = GeneralUtil:GetBool(StatusFolder, "breath request hold breath", IsDebugStamina.Value),

	isRunning = GeneralUtil:GetBool(StatusFolder, "move isRunning", IsDebugStamina.Value),
	requestRun = GeneralUtil:GetBool(StatusFolder, "move request run", IsDebugStamina.Value),

	breathState = GeneralUtil:GetNumber(StatusFolder, "state breath", IsDebugStamina.Value),
	staminaState = GeneralUtil:GetNumber(StatusFolder, "state stamina",IsDebugStamina.Value),
	stamina = GeneralUtil:GetNumber(StatusFolder, "current stamina", IsDebugStamina.Value),
}

local STATE_STAMINA = {
	[shared.states.stamina.min] = {
		min = CONFIG.staminaMin.Value,
		max = CONFIG.staminaMin.Value,
	},
	[shared.states.stamina.low] = {
		min = CONFIG.rangeLow.Value.X,
		max = CONFIG.rangeLow.Value.Y,
	},
	[shared.states.stamina.med] = {
		min = CONFIG.rangeMed.Value.X,
		max = CONFIG.rangeMed.Value.Y,
	},
	[shared.states.stamina.high] = {
		min = CONFIG.rangeHigh.Value.X,
		max = CONFIG.rangeHigh.Value.Y,
	},
	[shared.states.stamina.max] = {
		min = CONFIG.staminaMax.Value,
		max = CONFIG.staminaMax.Value,
	},
}


local GuiStamina = GeneralUtil:GetUI(LocalPlayer.PlayerGui, "stamina")

local GuiStaminaBar =  GeneralUtil:GetUI(GuiStamina, "fg")
local GuiStaminaIsInhale = GeneralUtil:GetUI(GuiStamina, "inhale")
local GuiStaminaIsExhale = GeneralUtil:GetUI(GuiStamina, "exhale")
local GuiStaminaIsholding = GeneralUtil:GetUI(GuiStamina, "Holding")
local GuiStaminaPercent = GeneralUtil:GetUI(GuiStamina, "Percent")

local TickLastBreath = nil
local StaminaAdd = nil
local StaminaRemove = nil
local OverrideHoldBreath = nil


local function BeginHoldBreath(deltaTime)
	if (STATUS.stamina.Value - CONFIG.costHoldBreath.Value * deltaTime)  >= CONFIG.staminaMin.Value then
		OverrideHoldBreath = CONFIG.breathLength.Value
	end
end


local function EndHoldBreath()
	STATUS.isBreathing.Value = true
	STATUS.isInhale.Value = false
	STATUS.isExhale.Value = true

	OverrideHoldBreath = 0
end


local function BeginRun(deltaTime)
	if (STATUS.stamina.Value - CONFIG.costRun.Value * deltaTime)  >= CONFIG.staminaMin.Value then
		STATUS.isRunning.Value = true
	else
		STATUS.isRunning.Value = false
	end
end


local function EndRun()
	STATUS.isRunning.Value = false
end


local function Inhale()
	StaminaAdd += CONFIG.staminaInhaleIncreaseAmount.Value
	STATUS.breathState.Value = shared.states.breath.inhale
end


local function Exhale()
	StaminaRemove = 0
	STATUS.breathState.Value = shared.states.breath.exhale
end


local function InhaleToHoldBreath()
	StaminaAdd += CONFIG.staminaInhaleIncreaseAmount.Value
	STATUS.breathState.Value = shared.states.breath.inhaleToHoldBreath
end


local function IncreaseStamina(staminaTotal)
	STATUS.stamina.Value = math.clamp(STATUS.stamina.Value+staminaTotal, CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)

	for i = STATUS.staminaState.Value, shared.states.stamina.high, 1 do
		if STATUS.stamina.Value >= STATE_STAMINA[i].min and STATUS.stamina.Value <= STATE_STAMINA[i].max then
			STATUS.staminaState.Value = shared.states.stamina[i]
			break
		end
	end

	if STATUS.staminaState.Value == CONFIG.staminaMax then
		STATUS.staminaState.Value = shared.states.stamina.max
	end
end


local function DecreaseStamina(staminaTotal)
	STATUS.stamina.Value = math.clamp(STATUS.stamina.Value-(staminaTotal), CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)

	for i = STATUS.staminaState.Value, shared.states.stamina.min, -1 do
		if STATUS.stamina.Value >= STATE_STAMINA[i].min and STATUS.stamina.Value <= STATE_STAMINA[i].max then
			STATUS.staminaState.Value = shared.states.stamina[i]
			break
		end
	end

	if STATUS.staminaState.Value == CONFIG.staminaMin then
		STATUS.staminaState.Value = shared.states.stamina.min
	end
end


local function Breathe(deltaTime)
	STATUS.isInhale.Value = STATUS.isExhale.Value
	STATUS.isExhale.Value = not STATUS.isInhale.Value

	local staminaTotal = (StaminaAdd - StaminaRemove)
	IncreaseStamina(staminaTotal)

	if STATUS.requestHoldBreath.Value then
		STATUS.isBreathing.Value = false
		STATUS.breathState.Value = shared.states.breath.holding
	end

	StaminaAdd, StaminaRemove = 0, 0
	TickLastBreath = tick()
end


local function Update(deltaTime)

	CONFIG.breathLength.Value = Math.lerp(0.4,1.8,  STATUS.stamina.Value/100)

	if STATUS.requestHoldBreath.Value and STATUS.isBreathing.Value then
		BeginHoldBreath(deltaTime)
	end

	if not STATUS.isBreathing.Value then
		if not STATUS.requestHoldBreath.Value then
			EndHoldBreath()
		end
	end

	if STATUS.requestRun.Value then
		BeginRun(deltaTime)
	else
		EndRun()
	end

	if STATUS.isBreathing.Value and tick() - TickLastBreath >= (CONFIG.breathLength.Value-OverrideHoldBreath)+math.random(0, 1) then
		if STATUS.requestHoldBreath.Value then
			InhaleToHoldBreath()
		elseif STATUS.isInhale.Value then
			Inhale()
		elseif STATUS.isExhale.Value  then
			Exhale()
		end

		Breathe(deltaTime)
	end

	if STATUS.isRunning.Value or not STATUS.isBreathing.Value then
		local staminaTotal  = (( CONFIG.costRun.Value ) + ( CONFIG.costHoldBreath.Value )) * deltaTime
		DecreaseStamina(staminaTotal)
	end
end



local function OnStamina(newStamina)
	local value = math.floor(newStamina)
	GuiStaminaPercent.Text = value .. "%"
	GuiStaminaBar.Size = UDim2.fromScale(newStamina/100, 1)
end

local function OnBreathState(newBreath)
	GuiStaminaIsInhale.Visible = newBreath == shared.states.breath.inhale or newBreath == shared.states.breath.inhaleToHoldBreath
	GuiStaminaIsExhale.Visible = newBreath == shared.states.breath.exhale
	GuiStaminaIsholding.Visible = newBreath == shared.states.breath.holding
end


local function Init()
	TickLastBreath = tick()
 	StaminaAdd = 0
 	StaminaRemove = 0
 	OverrideHoldBreath = 0

	STATUS.staminaState.Value = shared.states.stamina.min
	STATUS.stamina.Value = CONFIG.staminaMin.Value

	math.randomseed(tick())
	STATUS.breathState.Changed:Connect(OnBreathState)
	STATUS.stamina.Changed:Connect(OnStamina)

	RunService.Heartbeat:Connect(Update)

	GuiStamina.Enabled = true
end
Init()