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

function GeneralUtil:CreateBillboard(size, offset)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = size
	billboard.ExtentsOffset = offset
	billboard.AlwaysOnTop = true

	return billboard
end

function GeneralUtil:CreateTextBox(size, bgColor, txtColor)
	local textBox = Instance.new("TextBox")
	textBox.Size = size
	textBox.BackgroundColor3 = bgColor
	textBox.TextColor3 = txtColor
	textBox.TextScaled = true

	return textBox
end

function GeneralUtil:WeldTo(source, target, weld)
	weld = weld or Instance.new("Weld")

	weld.Parent = source
	weld.Part0 = source
	weld.Part1 = target

	return weld
end


return GeneralUtil