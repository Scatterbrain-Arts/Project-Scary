local ServerStorage = game:GetService("ServerStorage")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local DebugService = {}
DebugService.ServiceName = "DebugService"

DebugService.GROUND_OFFSET = 0.5

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
	self.timer = nil
end


function DebugService:Start()
	self.workspaceFolder = Instance.new("Folder", game.Workspace)
	self.workspaceFolder.Name = "Debug"

	self.targetRef.billboard = self:CreateTargetIndicator()
	self.targetRef.billboard.Parent = ServerStorage

	local targetFolder = Instance.new("Folder", self.workspaceFolder)
	targetFolder.Name = "target"

	local waypointsFolder = Instance.new("Folder", self.workspaceFolder)
	waypointsFolder.Name = "waypoints"

	local waypointsCurrentFolder = Instance.new("Folder", waypointsFolder)
	waypointsCurrentFolder.Name = "current"

	local waypointsNextFolder = Instance.new("Folder", waypointsFolder)
	waypointsNextFolder.Name = "next"

	self.timer = os.clock()
end


function DebugService:Destroy()
	self.maid:DoCleaning()
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
	part.Size = size
	part.Color = color

	return part
end

local function WeldTo(weldRef, folder, attachRoot, attachTo)
	weldRef = weldRef or Instance.new("Weld")

	weldRef.Parent = folder
	weldRef.Part0 = attachRoot
	weldRef.Part1 = attachTo

	return weldRef
end


function DebugService:CreateAgentIndicator(name, parent, root, width, height, color)
	local part = CreatePart(Enum.PartType.Cylinder, Vector3.new(height, width*2, width*2), color)
	part.Transparency = 0.5
	part.Anchored = false
	part.Parent = parent
	part.Name = name

	local weld = nil
	weld = WeldTo(weld, part, part, root)

	part.Orientation = Vector3.new(0,0,90)
	part.Position = root.Position - Vector3.new(0, parent.Humanoid.HipHeight/2 - DebugService.GROUND_OFFSET, 0)
	self.maid:GiveTask(part)
	self.maid:GiveTask(weld)
end


function DebugService:CreateRangeIndicator(name, parent, root, size, color)
	local part = CreatePart(Enum.PartType.Ball, Vector3.new(size*2, size*2, size*2), color)
	part.Transparency = 0.75
	part.Anchored = false
	part.Parent = parent
	part.Position = root.Position
	part.Name = name

	local weld = nil
	weld = WeldTo(weld, part, part, root)

	self.maid:GiveTask(part)
	self.maid:GiveTask(weld)
end


function DebugService:CreatePathNextIndicator(waypoints)
	for index, waypoint in waypoints do
		local part = CreatePart(Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5), Color3.fromHex("690069"))
		part.Material = Enum.Material.Neon
		part.Name = "nextIndex" .. index
		part.Parent = self.workspaceFolder.waypoints.next
		part.Position = Vector3.new(waypoint.Position.X, waypoint.Position.Y + 0.5, waypoint.Position.Z)

		self.maid:GiveTask(part)

		table.insert(self.waypointsRef.next, part)
	end
end


function DebugService:CreatePathCurrentIndicator()
	if #self.waypointsRef.current > 0 then
		for _, waypointPart in self.waypointsRef.current do
			waypointPart:Destroy()
		end
		self.waypointsRef.current = {}
	end

	for index, waypointPart in self.waypointsRef.next do
		self.waypointsRef.current[index] = waypointPart
		waypointPart.Name = "currentIndex" .. index
		waypointPart.Color = Color3.fromHex("006969")
		waypointPart.Parent = self.workspaceFolder.waypoints.current
	end

	self.waypointsRef.next = {}
end


function DebugService:CreateTargetIndicator()
	local part = CreatePart(Enum.PartType.Ball, Vector3.new(1,1,1), Color3.fromRGB(255,0,0))
	part.Transparency = 1

	local billboard = Instance.new("BillboardGui", part)
	billboard.Size = UDim2.fromScale(2,0.5)
	billboard.ExtentsOffset = Vector3.new(0,2,0)
	billboard.AlwaysOnTop = true
	billboard.Name = "TargetBillboard"
	billboard.Adornee = part

	local textBox = Instance.new("TextBox", billboard)
	textBox.Size = UDim2.fromScale(1,1)
	textBox.BackgroundColor3 = Color3.fromRGB(255,0,0)
	textBox.TextColor3 = Color3.fromRGB(255,255,255)
	textBox.TextScaled = true
	textBox.Text = "Target"

	local weld = nil
	weld = WeldTo(weld, part, part, nil)

	self.maid:GiveTask(part)
	self.maid:GiveTask(billboard)
	self.maid:GiveTask(textBox)
	self.maid:GiveTask(weld)

	return part
end


function DebugService:TargetAddIndicator(position, parent)
	if not self.targetRef.billboard then
		warn("BillboardGui is nil...")
		return
	end

	self.targetRef.billboard.Parent = self.workspaceFolder.target
	self.targetRef.billboard.Position = position

	if parent then
		local weld = self.targetRef.billboard:FindFirstChild("Weld")
		weld = WeldTo(weld, self.targetRef.billboard, self.targetRef.billboard, parent)
	end
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

	self.targetRef.billboard.Parent = ServerStorage
	
	local weld = self.targetRef.billboard:FindFirstChild("Weld")
	if weld then
		weld = WeldTo(weld, self.targetRef.billboard, self.targetRef.billboard, nil)
	end
end


function DebugService:StartTimer()
	self.timer = os.clock()
end

function DebugService:PrintTimer()
	print(os.clock() - self.timer)
end


return DebugService