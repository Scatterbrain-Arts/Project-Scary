local require = require(script.Parent.loader).load(script)

local Draw = require("Draw")

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


function GeneralUtil:GetNumber(instance, name, isDebug)
	assert(instance ~= nil, "instance is nil for", name)
	local number = instance:FindFirstChild(name)

	if not number then
		number = Instance.new("NumberValue")
		number.Name = name
		number.Value = 1
		number.Parent = instance
		warn(name, "was not found in", instance.Name , "created new with default value", number.Value, "...")
	end

	if isDebug then
		warn(instance.Name, "[", name, "] is set to ", number.Value)
	end

	return number
end


function GeneralUtil:GetString(instance, name, isDebug)
	assert(instance ~= nil, "instance is nil for", name)
	local string = instance:FindFirstChild(name)

	if string == nil then
		string = Instance.new("StringValue")
		string.Name = name
		string.Value = ""
		string.Parent = instance
		warn(name, "was not found in", instance.Name, "...")
	end

	if isDebug then
		warn(instance.Name, "[", name, "] is set to ", string.Value)
	end

	return string
end


function GeneralUtil:GetVector(instance, name, isDebug)
	assert(instance ~= nil, "instance is nil for", name)
	local vector = instance:FindFirstChild(name)

	if vector == nil then
		vector = Instance.new("Vector3Value")
		vector.Name = name
		vector.Value = Vector3.zero
		vector.Parent = instance
		warn(name, "was not found in", instance.Name, "...")
	end

	if isDebug then
		warn(instance.Name, "[", name, "] is set to ", vector.Value)
	end

	return vector
end


function GeneralUtil:GetBool(instance, name, isDebug)
	assert(instance ~= nil, "instance is nil for", name)
	local bool = instance:FindFirstChild(name)

	if bool == nil then
		bool = Instance.new("BoolValue")
		bool.Name = name
		bool.Value = false
		bool.Parent = instance
		warn(name, "was not found in", instance.Name, "...")
	end

	if isDebug then
		warn(instance.Name, "[", name, "] is set to ", bool.Value)
	end

	return bool
end


function GeneralUtil:Get(defaultClass, instance, name, isRecurisve)
	assert(instance ~= nil, "instance is nil for", name)
	local folder = instance:FindFirstChild(name, isRecurisve)

	if not folder and defaultClass ~= nil then
		folder = Instance.new(defaultClass)
		folder.Parent = instance
		folder.Name = name
		warn(name, "was not found in", instance.Name, "...")
	end

	return folder
end


function GeneralUtil:GetUI(playerGui, name)
	assert(playerGui ~= nil, "playerGui is nil for", name)
	local gui = playerGui:FindFirstChild(name, true)

	if not gui then
		error(name, "was not found in", playerGui.Name, "...")
	end

	return gui
end


function GeneralUtil:GetSound(root, name)
	assert(root ~= nil, "playerGui is nil for", name)
	local sfx = root:FindFirstChild(name)

	if not sfx then
		error(name, "was not found in", root.Name, "...")
	end

	return sfx
end


function GeneralUtil:SetNetworkOwner(entity, owner)
	owner = owner or nil
	for _, part in pairs(entity:GetChildren()) do
		if ( part:IsA("BasePart") or part:IsA("MeshPart") ) and part.Anchored == false then
			part:SetNetworkOwner(owner)
		end
	end
end


function GeneralUtil:CastRay(origin, direction, collisionGroup)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = collisionGroup
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = false

	return workspace:Raycast(origin, direction, raycastParams)
end


function GeneralUtil:CastSphere(origin, radius, direction, collisionGroup, isDraw, isCharacterOffset)
	local parameters = RaycastParams.new()
	parameters.CollisionGroup = collisionGroup
	parameters.IgnoreWater = true
	parameters.RespectCanCollide = false

	isCharacterOffset = isCharacterOffset or true
	if isCharacterOffset then
		origin += direction.Unit * -radius/1.5
	end

	if isDraw then
		Draw.sphereCast(origin, radius, direction, Color3.fromRGB(178, 31, 251), workspace)
	end


	return workspace:Spherecast(origin, radius, direction, parameters)
end


function GeneralUtil:QueryRadius(position, diameter, collisionGroup, isDraw)
	local parameters = OverlapParams.new()
	parameters.CollisionGroup = collisionGroup
	parameters.RespectCanCollide = false
	parameters.MaxParts = 20

	if isDraw then
		Draw.sphere(position, diameter/2, Color3.fromRGB(178, 31, 251), workspace)
	end

	return workspace:GetPartBoundsInRadius(position, diameter/2, parameters)
end


function GeneralUtil:QueryRegion(cframe, size, collisionGroup)
	local parameters = OverlapParams.new()
	parameters.CollisionGroup = collisionGroup
	parameters.RespectCanCollide = false
	parameters.MaxParts = 20

	return workspace:GetPartBoundsInBox(cframe, size, parameters)
end


function GeneralUtil:GetDistance(pos1, pos2, isIgnoreY)
	if isIgnoreY then
		pos1 = Vector3.new(pos1.X, 0, pos1.Z)
		pos2 = Vector3.new(pos2.X, 0, pos2.Z)
	end

	return (pos1 - pos2).Magnitude
end


function GeneralUtil:IsDistanceGreater(pos1, pos2, range, isIgnoreY)
	if isIgnoreY then
		pos1 = Vector3.new(pos1.X, 0, pos1.Z)
		pos2 = Vector3.new(pos2.X, 0, pos2.Z)
	end

	return GeneralUtil:GetDistance(pos1, pos2) >= range
end


function GeneralUtil:IsDistanceLess(pos1, pos2, range, isIgnoreY)
	if isIgnoreY then
		pos1 = Vector3.new(pos1.X, 0, pos1.Z)
		pos2 = Vector3.new(pos2.X, 0, pos2.Z)
	end

	return GeneralUtil:GetDistance(pos1, pos2) <= range
end


function GeneralUtil:GetConditonFromTable(table, condition)
	local desiredValue = math.huge
	local desiredIndex = nil
	for i, value in pairs(table) do
		if condition(desiredValue, value) then
			desiredValue = value
			desiredIndex = i
		end
	end

	return desiredIndex, desiredValue
end


return GeneralUtil