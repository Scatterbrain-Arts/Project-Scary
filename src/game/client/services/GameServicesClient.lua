local Players = game:GetService("Players")
local require = require(script.Parent.loader).load(script)
local ServiceBag = require("ServiceBag")

local GameServicesClient = {}
GameServicesClient.ServiceName = "GameServicesClient"


function GameServicesClient:Init(serviceBag)
	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	--Internal
	serviceBag:GetService(require("Globals"))
	serviceBag:GetService(require("ObjectService"))
end




return GameServicesClient