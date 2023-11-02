local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")
local Signal = require("Signal")
local Maid = require("Maid")

local AiService = {}
AiService.ServiceName = "AiService"

local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")
local MoveAISignal = Signal.new()

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1

function AiService:Init(serviceBag)
	assert(not self.serviceBag, "AIService is already initialized...")
	self.serviceBag = assert(serviceBag, "ServiceBag is nil...")
	self.maid = Maid.new()

	self.moveAISignal = MoveAISignal
end

function AiService:Start(serviceBag)
	
end

function AiService:Move(payload)
	MoveAISignal:Fire(payload)
end


PlayerMoveSoundEvent.OnServerEvent:Connect(function(player, payload)
	local data = {
		position = payload.position,
		object = nil,
	}

	AiService:Move(data)
end)

return AiService