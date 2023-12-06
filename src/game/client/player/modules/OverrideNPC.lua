local UserInputService = game:GetService("UserInputService")

local require = require(script.Parent.loader).load(script)

local OverrideNPC = {}

local npc = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode== Enum.KeyCode.O then
		npc = npc or workspace:FindFirstChild("Pepe 0.4")
		npc.config["_OVERRIDE"].Value = not npc.config["_OVERRIDE"].Value

		if npc.config["_OVERRIDE"].Value then
			warn("NPC Override ENABLED...")
		else
			warn("NPC Override DISABLED...")
		end
	end
end)


return OverrideNPC