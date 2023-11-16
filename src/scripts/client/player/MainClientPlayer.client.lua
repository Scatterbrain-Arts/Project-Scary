local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

shared.states = {}
shared.states.move = {
	idle = 1,
	idleCrouch = 2,
	walkCrouch = 3,
	walk = 4,
	run = 5,
}
for i,v in shared.states.move do shared.states.move[v] = v end


shared.states.stamina = {
	min = 1,
	low = 2,
	med = 3,
	high = 4,
	max = 5,
}
for i,v in shared.states.stamina do shared.states.stamina[v] = v end

shared.states.breath = {
	inhale = 1,
	exhale = 2,
	inhaleToHoldBreath = 3,
	holding = 4,
}
for i,v in shared.states.breath do shared.states.breath[v] = v end




require(packages.PuppetActivator)
require(packages.PlayerEntity)