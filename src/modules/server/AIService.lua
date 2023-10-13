local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")
local Signal = require("Signal")
local Maid = require("Maid")

local AIService = {}
AIService.ServiceName = "AIService"

local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")
local MoveAISignal = Signal.new()

function AIService:Init(serviceBag)
	assert(not self.serviceBag, "AIService is already initialized...")
	self.serviceBag = assert(serviceBag, "ServiceBag is nil...")
	self.maid = Maid.new()

	self.moveAISignal = MoveAISignal
end

function AIService:Start(serviceBag)
	
end

function AIService:Move()
	MoveAISignal:Fire()
end


PlayerMoveSoundEvent.OnServerEvent:Connect(function(player, payload)
	AIService:Move(payload.position)
end)

return AIService