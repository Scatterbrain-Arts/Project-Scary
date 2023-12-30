local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

shared.states = {}
shared.states.move = {}
shared.states.moveNames = { "idle", "idleCrouch", "walkCrouch", "walk", "run" }
for i,v in shared.states.moveNames do shared.states.move[v] = i end
for i = 1, #shared.states.moveNames do shared.states.move[i] = i end

shared.states.stamina = {}
shared.states.staminaNames = { "min", "low", "med", "high", "max" }
for i,v in shared.states.staminaNames do shared.states.stamina[v] = i end
for i = 1, #shared.states.staminaNames do shared.states.stamina[i] = i end

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
shared.npc.states.behavior.calmNames = {"hungry", "mourning", "angry", "patrol"}
for i,v in shared.npc.states.behavior.calmNames do shared.npc.states.behavior.calm[v] = i end
for i = 1, #shared.npc.states.behavior.calmNames do shared.npc.states.behavior.calm[i] = i end


require(packages.PlayerEntity)
require(packages.NPCStarter)
require(packages.ObjectStarter)