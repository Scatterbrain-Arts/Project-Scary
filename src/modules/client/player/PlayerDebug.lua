local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui

local InputGui = PlayerGui:FindFirstChild("input")
local InputGuiText = InputGui.Frame.TextLabel

local Debug = {}

function Debug:Toggle(bool)
	InputGui.Enabled = bool
end

function Debug:SetInputState(type)
	InputGuiText.Text = type
end

return Debug