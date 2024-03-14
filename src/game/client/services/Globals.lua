local require = require(script.Parent.loader).load(script)
local ServiceBag = require("ServiceBag")

local Globals = {}
Globals.ServiceName = "Globals"


function Globals:Init(serviceBag)
	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	shared.states = {}
	shared.states.move = {}
	shared.states.moveNames = { "idle", "idleCrouch", "walkCrouch", "walk", "run" }
	for i,v in shared.states.moveNames do shared.states.move[v] = i end
	for i = 1, #shared.states.moveNames do shared.states.move[i] = i end

	shared.states.stamina = {}
	shared.states.staminaNames = { "min", "low", "med", "high", "max" }
	for i = 1, #shared.states.staminaNames do shared.states.stamina[i] = i end
	for i,v in shared.states.staminaNames do shared.states.stamina[v] = i end

	shared.states.breath = {}
	shared.states.breathNames = { "inhale", "exhale", "inhaleToHoldBreath", "holding" }
	for i,v in shared.states.breathNames do shared.states.breath[v] = i end
	for i = 1, #shared.states.breathNames do shared.states.breath[i] = i end


	shared.npc = {}
	shared.npc.states = {}
	shared.npc.states.detection = {}
	shared.npc.states.detectionNames = {"calm", "alert", "hostile"}
	for i,v in shared.npc.states.detectionNames do shared.npc.states.detection[v] = i end
	for i = 1, #shared.npc.states.detectionNames do shared.npc.states.detection[i] = i end

	shared.npc.states.behavior = {}
	shared.npc.states.behavior.calm = {}
	shared.npc.states.behavior.calmNames = {"investigate", "hungry", "patrol"}
	for i,v in shared.npc.states.behavior.calmNames do shared.npc.states.behavior.calm[v] = i end
	for i = 1, #shared.npc.states.behavior.calmNames do shared.npc.states.behavior.calm[i] = i end

	shared.npc.states.behavior.alert = {}
	shared.npc.states.behavior.alertNames = {"search"}
	for i,v in shared.npc.states.behavior.alertNames do shared.npc.states.behavior.alert[v] = i end
	for i = 1, #shared.npc.states.behavior.alertNames do shared.npc.states.behavior.alert[i] = i end

	shared.npc.states.behavior.hostile = {}
	shared.npc.states.behavior.hostileNames = {"kill"}
	for i,v in shared.npc.states.behavior.hostileNames do shared.npc.states.behavior.hostile[v] = i end
	for i = 1, #shared.npc.states.behavior.hostileNames do shared.npc.states.behavior.hostile[i] = i end
end




return Globals