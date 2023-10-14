local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")
local Signal = require("Signal")
local Maid = require("Maid")

local AIService = {}
AIService.ServiceName = "AIService"

local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")
local MoveAISignal = Signal.new()

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1

function AIService:Init(serviceBag)
	assert(not self.serviceBag, "AIService is already initialized...")
	self.serviceBag = assert(serviceBag, "ServiceBag is nil...")
	self.maid = Maid.new()

	self.moveAISignal = MoveAISignal
end

function AIService:Start(serviceBag)
	
end

function AIService:Move(payload)
	MoveAISignal:Fire(payload)
end


PlayerMoveSoundEvent.OnServerEvent:Connect(function(player, payload)
	local data = {
		priority = PRIORITY_MED,
		sense = "sound",
		position = payload.position,
		isPlayer = true,
		isSearched = false,
		object = nil,
	}

	AIService:Move(data)
end)

return AIService