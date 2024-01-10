local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local GeneralUtil = require(packages.GeneralUtil)
local GetRemoteEvent = require(packages.GetRemoteEvent)

-- local LockEvent = GetRemoteEvent("LockEvent")
-- local GameOverEvent = GetRemoteEvent("GameOverEvent")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Inventory = {}

-- local GuiGameOver = GeneralUtil:GetUI(LocalPlayer:WaitForChild("PlayerGui"), "game")
-- GuiGameOver.Enabled = false

-- local function OnLockOverride(input, gameProcessed)
-- 	if input.KeyCode == Enum.KeyCode.I then
-- 		LockEvent:FireServer()
-- 	end
-- end

-- local function OnGameOver()
-- 	GuiGameOver.Enabled = true
-- 	task.spawn(function()
-- 		task.wait(5)
-- 		GuiGameOver.Enabled = false
-- 	end)

-- end

-- local function Init()
-- 	GameOverEvent.OnClientEvent:Connect(OnGameOver)
-- 	UserInputService.InputBegan:Connect(OnLockOverride)
-- 	return true
-- end
-- Init()
