local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)


local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local ConfigFolder = GeneralUtil:Get("Folder", Character, "config")

local IsDebug = GeneralUtil:GetNumber(ConfigFolder, "_DEBUG", true)

local StatusFolder = GeneralUtil:Get("Folder", Character, "status")

local STATUS = {
	moveState = GeneralUtil:GetNumber(StatusFolder, "state move", IsDebug.Value),
	breathState = GeneralUtil:GetNumber(StatusFolder, "state breath", IsDebug.Value),
	staminaState = GeneralUtil:GetNumber(StatusFolder, "state stamina",IsDebug.Value),
	stamina = GeneralUtil:GetNumber(StatusFolder, "current stamina", IsDebug.Value),
}

local Gui = GeneralUtil:GetUI(LocalPlayer.PlayerGui.debug, "gui")
local GuiCurentStamina = GeneralUtil:GetUI(Gui, "current stamina")
local GuiStateMove = GeneralUtil:GetUI(Gui, "state move")
local GuiStateStamina = GeneralUtil:GetUI(Gui, "state stamina")
local GuiStateBreath = GeneralUtil:GetUI(Gui, "state breath")




local function OnChangedStamina(newValue)
	if not newValue then return end
	local stam = newValue - newValue % 0.1
	GuiCurentStamina.Text = "current stamina: " .. stam
end


local function OnChangedStateMove(newValue)
	if not newValue then return end
	GuiStateMove.Text = "state move: " .. shared.states.moveNames[newValue]
end


local function OnChangedStateStamina(newValue)
	if not newValue then return end
	GuiStateStamina.Text = "state stamina: " .. shared.states.staminaNames[newValue]
end


local function OnChangedStateBreath(newValue)
	if not newValue then return end
	GuiStateBreath .Text = "state breath: " .. shared.states.breathNames[newValue]
end


local function OnKeyPressed(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P then
		IsDebug.Value = not IsDebug.Value
	end
end


local function OnDebug(newValue)
	Gui.Enabled = newValue
end



STATUS.stamina.Changed:Connect(OnChangedStamina)
STATUS.moveState.Changed:Connect(OnChangedStateMove)
STATUS.staminaState.Changed:Connect(OnChangedStateStamina)
STATUS.breathState.Changed:Connect(OnChangedStateBreath)

UserInputService.InputBegan:Connect(OnKeyPressed)
IsDebug.Changed:Connect(OnDebug)

return {}