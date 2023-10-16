local GeneralUtil = {}

function GeneralUtil:CreatePart(shape, size, color)
	local part = Instance.new("Part")
	part.Shape = shape
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 0
	part.CastShadow = false
	part.Anchored = true
	part.Size = size
	part.Color = color

	return part
end

function GeneralUtil:WeldTo(weld, source, target)
	weld = weld or Instance.new("Weld")

	weld.Parent = source
	weld.Part0 = source
	weld.Part1 = target

	return weld
end


return GeneralUtil