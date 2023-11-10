local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local BreathGui = PlayerGui:FindFirstChild("breath")
local BreathGuiText = BreathGui.Frame.TextLabel


local Breath = {}

function Breath:Toggle(bool)
	if bool then
		BreathGuiText.Text = "Breathing"
	else
		BreathGuiText.Text = "Holding"
	end
end


return Breath