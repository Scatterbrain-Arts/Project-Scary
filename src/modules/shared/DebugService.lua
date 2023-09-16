local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local DebugService = {}
DebugService.ServiceName = "DebugService"

function DebugService:Init(serviceBag)
	assert(not self.serviceBag, "DebugService is already initialized...")
	self.serviceBag = assert(serviceBag, "ServiceBag is nil...")
	self.maid = Maid.new()

	self.targetRef = {
		target = nil,
		billboard = nil,
	}

	self.waypointsRef = {
		current = {},
		next = {},
	}

	self.workspaceFolder = nil
end


function DebugService:Start()
	self.workspaceFolder = Instance.new("Folder", game.Workspace)
	self.workspaceFolder.Name = "Debug"

	self.targetRef.billboard = self:CreateTargetIndicator()
	self.targetRef.billboard.Parent = nil

	local waypointsFolder = Instance.new("Folder", self.workspaceFolder)
	waypointsFolder.Name = "waypoints"

	local waypointsCurrentFolder = Instance.new("Folder", waypointsFolder)
	waypointsCurrentFolder.Name = "current"

	local waypointsNextFolder = Instance.new("Folder", waypointsFolder)
	waypointsNextFolder.Name = "next"
end


local function CreatePart(shape, size, color)
	local part = Instance.new("Part")
	part.Shape = shape
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 0
	part.CastShadow = false
	part.Anchored = true
	part.Size = Vector3.new(size*2, size*2, size*2)
	part.Color = color

	return part
end


function DebugService:CreatePathIndicator(waypoints, description)
	if #self.waypointsRef[description] > 0 then
		for _, v in self.waypointsRef[description] do
			v:Destroy()
		end
	end

	local color
	if description == "current" then
		color = Color3.fromHex("006969")
	else
		color = Color3.fromHex("690069")
	end

	for index, waypoint in waypoints do
		local part = CreatePart(Enum.PartType.Ball, 0.25, color)
		part.Name = description .. "Index0" .. index
		part.Parent = self.workspaceFolder.waypoints[description]
		part.Position = Vector3.new(waypoint.Position.X, waypoint.Position.Y + 0.5, waypoint.Position.Z)
	
		self.maid:GiveTask(part)

		table.insert(self.waypointsRef[description], part)
	end
end


function DebugService:CreateRangeIndicator(name, parent, root, size, color)
	local part = CreatePart(Enum.PartType.Ball, size, color)
	part.Transparency = 0.75
	part.Anchored = false
	part.Parent = parent
	part.Position = root.Position
	part.Name = name

	local weld = Instance.new("Weld", part)
	weld.Part0 = part
	weld.Part1 = root

	self.maid:GiveTask(part)
	self.maid:GiveTask(weld)
end


function DebugService:CreateTargetIndicator()
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromScale(2,0.5)
	billboard.ExtentsOffset = Vector3.new(0,2,0)
	billboard.AlwaysOnTop = true
	billboard.Name = "TargetBillboard"

	local textBox = Instance.new("TextBox", billboard)
	textBox.Size = UDim2.fromScale(1,1)
	textBox.BackgroundColor3 = Color3.fromRGB(255,0,0)
	textBox.TextColor3 = Color3.fromRGB(255,255,255)
	textBox.TextScaled = true
	textBox.Text = "Target"

	self.maid:GiveTask(billboard)
	self.maid:GiveTask(textBox)

	return billboard
end


function DebugService:TargetAddIndicator(player, adornee)
	if not self.targetRef.billboard then
		warn("BillboardGui is nil...")
		return
	end

	self.targetRef.target = player
	self.targetRef.billboard.Adornee = adornee
	self.targetRef.billboard.Parent = adornee
end


function DebugService:TargetRemoveIndicator()
	if not self.targetRef.billboard then
		warn("BillboardGui is nil...")
		return
	end

	if not self.targetRef.target then
		warn("Target is nil...")
		return
	end

	self.targetRef.target = nil
	self.targetRef.billboard.Adornee = nil
	self.targetRef.billboard.Parent = nil
end


function DebugService:Destroy()
	self.maid:DoCleaning()
end


return DebugService