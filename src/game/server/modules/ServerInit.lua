local Lighting = game:GetService("Lighting")

local require = require(script.Parent.loader).load(script)

local function Init()
	Lighting.ClockTime = 0

	local house = workspace:FindFirstChild("GreyBox_House")
	if house then
		local roof = house:FindFirstChild("Roof")
		local ceilingBasement = house:FindFirstChild("Ceiling_1&Basement")
		local ceiling = house:FindFirstChild("Ceiling_1&2")

		if roof then
			for i,v in roof:GetChildren() do
				v.Transparency = 0
			end
		end

		if ceilingBasement then
			for i,v in ceilingBasement:GetChildren() do
				v.Transparency = 0
			end
		end

		if ceiling then
			for i,v in ceiling:GetChildren() do
				v.Transparency = 0
			end
		end
	end

	return true
end


return Init()