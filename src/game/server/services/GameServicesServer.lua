local require = require(script.Parent.loader).load(script)
local ServiceBag = require("ServiceBag")

local GameServicesServer = {}
GameServicesServer.ServiceName = "GameServicesServer"

function GameServicesServer:Init(serviceBag)
	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	--Internal
	serviceBag:GetService(require("ObjectOwnershipService"))
end



return GameServicesServer