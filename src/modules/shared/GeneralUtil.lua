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


function GeneralUtil:GetValue(entity, attributeName, isDebug)
	local attribute = entity:GetAttribute(attributeName)

	if isDebug then
		if attribute ~= nil then
			print(string.upper(attributeName), "set to", attribute, "for", entity.name, "...")
		else
			warn("Create attribute \"", attributeName, "\"; Using Default value...")
		end
	end

	return attribute
end


function GeneralUtil:GetCondition(entity, attributeName)
	local isAttribute = entity:GetAttribute(attributeName)

	if isAttribute then
		warn(attributeName, "enabled for", entity.name, "...")
	elseif isAttribute == false then
		warn(attributeName, "disabled for", entity.name, "...")
	elseif isAttribute == nil then
		warn("Create attribute \"", attributeName , "\" for", entity.name, "; Using Default value...")
	end

	return isAttribute
end


return GeneralUtil