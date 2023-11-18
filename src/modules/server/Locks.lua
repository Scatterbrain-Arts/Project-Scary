local require = require(script.Parent.loader).load(script)

local Signal = require("Signal")
local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")

local LockEvent = GetRemoteEvent("LockEvent")

local Locks = {}
Locks.__index = Locks
Locks.TAG_NAME = "Lock"
Locks.KEYS = {}
Locks.Signals = {
	unlock = Signal.new()
}

function Locks.new(lockInstance, serviceBag)
    local self = {}
    setmetatable(self, Locks)

	self.maid = Maid.new()
	self.entity = lockInstance
	self.name = lockInstance.Name
	self.prompt = lockInstance:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt", lockInstance.GlassRoot)

	self.lockNumber = tonumber(string.match(self.name, "%d+"))

	self.lock = true
	self.debounce = false
	self.prompt.ActionText = "Open Lock"

	self.prompt.Triggered:Connect(function(player)
		self.debounce = true
		if not self.lock then
			self.prompt.Enabled = false
			for i,v in self.entity:GetChildren() do
				if v:IsA("BasePart") then
					v.Transparency = 1
					v.CanCollide = false
				end
			end
		end
		self.debounce = false
	end)

	Locks.Signals.unlock:Connect(function(keyNumber)
		if self.lockNumber == keyNumber then
			self.lock = false
		end
	end)

	LockEvent.OnServerEvent:Connect(function()
		Locks.Signals.unlock:Fire(self.lockNumber)
	end)

	self.prompt.Enabled = self.lockNumber ~= nil
	return self
end



return Locks