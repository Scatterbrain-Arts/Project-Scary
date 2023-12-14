local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Locks = require("Locks")

local Keys = {}
Keys.__index = Keys
Keys.TAG_NAME = "Key"


function Keys.new(keyInstance, serviceBag)
    local self = {}
    setmetatable(self, Keys)

	self.maid = Maid.new()
	self.entity = keyInstance
	self.name = keyInstance.Name
	self.prompt = keyInstance:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt", keyInstance)
	self.keyNumber = tonumber(string.match(self.name, "%d+"))

	self.debounce = false
	self.prompt.ActionText = "Collect Key"

	self.prompt.Triggered:Connect(function(player)
		self.debounce = true
		self.entity.Transparency = 1
		self.prompt.Enabled = false
		Locks.Signals.unlock:Fire(self.keyNumber)
		self.debounce = false
	end)

	self.prompt.Enabled = self.keyNumber ~= nil
	return self
end


return Keys