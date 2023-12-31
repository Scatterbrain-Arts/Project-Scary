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
shared.npc.states.perception = {}
shared.npc.states.perceptionNames = {"calm", "alert", "hostile"}
for i,v in shared.npc.states.perceptionNames do shared.npc.states.perception[v] = i end
for i = 1, #shared.npc.states.perceptionNames do shared.npc.states.perception[i] = i end

require(packages.PlayerEntity)
require(packages.NPCStarter)