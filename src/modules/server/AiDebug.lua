local ServerStorage = game:GetService("ServerStorage")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local AiHelper = require("AiHelper")
local GeneralUtil = require("GeneralUtil")


local AiDebug = {}
AiDebug.__index = AiDebug
AiDebug.GROUND_OFFSET = 0.5

local function InitFolders(entityName)
	-- STORAGE FOLDERS --
	local storageRootFolder = ServerStorage:FindFirstChild("Debug") or Instance.new("Folder", ServerStorage)
	storageRootFolder.Name = "Debug"

	local storageFolder = Instance.new("Folder", storageRootFolder)
	storageFolder.Name = entityName
	

	-- WORSPACE FOLDERS --
	local workspaceRootFolder = workspace:FindFirstChild("Debug") or Instance.new("Folder", workspace)
	workspaceRootFolder.Name = "Debug"

	local workspaceFolder = Instance.new("Folder", workspaceRootFolder)
	workspaceFolder.Name = entityName


	-- WAYPOINTS FOLDER --
	local waypointsFolder = Instance.new("Folder", workspaceFolder)
	waypointsFolder.Name = "waypoints"

	local waypointsCurrentFolder = Instance.new("Folder", waypointsFolder)
	waypointsCurrentFolder.Name = "current"

	local waypointsNextFolder = Instance.new("Folder", waypointsFolder)
	waypointsNextFolder.Name = "next"


	-- TARGET FOLDER --
	local targetFolder = Instance.new("Folder", workspaceFolder)
	targetFolder.Name = "target"

	return  storageFolder, workspaceFolder
end


function AiDebug.new(entityName, serviceBag)
	local self = {}
	setmetatable(self, AiDebug)

	self.maid = Maid.new()
	self.entityName = entityName
	self.storageFolder, self.workspaceFolder = InitFolders(entityName)

	self.waypoints = {
		current = {},
		next = {},
	}

	self.target = {
		indicator = self:CreateTargetIndicator(),
		object = nil,
	}

	self.timer = os.clock()

	return self
end



function AiDebug:CreateAgentCylinder(name, parent, root, width, height, color)
	local cylinder = GeneralUtil:CreatePart(Enum.PartType.Cylinder, Vector3.new(height, width*2, width*2), color)
	cylinder.Transparency = 0.5
	cylinder.Anchored = false
	cylinder.Parent = parent
	cylinder.Name = name

	GeneralUtil:WeldTo(nil, cylinder, root)

	cylinder.Orientation = Vector3.new(0,0,90)
	cylinder.Position = root.Position - Vector3.new(0, parent.Humanoid.HipHeight/2 - AiDebug.GROUND_OFFSET, 0)

	self.maid:GiveTask(cylinder)
end


function AiDebug:CreateRangeSphere(name, parent, root, size, color)
	local sphere = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(size*2, size*2, size*2), color)
	sphere.Transparency = 0.75
	sphere.Anchored = false
	sphere.Parent = parent
	sphere.Position = root.Position
	sphere.Name = name

	GeneralUtil:WeldTo(nil, sphere, root)

	self.maid:GiveTask(sphere)
end


function AiDebug:CreatePathNext(waypoints)
	for index, waypoint in waypoints do
		local sphere = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5), Color3.fromHex("690069"))
		sphere.Material = Enum.Material.Neon
		sphere.Name = "nextIndex" .. index
		sphere.Parent = self.workspaceFolder.waypoints.next
		sphere.Position = Vector3.new(waypoint.Position.X, waypoint.Position.Y + 0.5, waypoint.Position.Z)

		self.maid:GiveTask(sphere)

		table.insert(self.waypoints.next, sphere)
	end
end


function AiDebug:CreatePathCurrent()
	if #self.waypoints.current > 0 then
		for _, waypointPart in self.waypoints.current do
			waypointPart:Destroy()
		end
		self.waypoints.current = {}
	end

	for index, waypointPart in self.waypoints.next do
		self.waypoints.current[index] = waypointPart
		waypointPart.Name = "currentIndex" .. index
		waypointPart.Color = Color3.fromHex("006969")
		waypointPart.Parent = self.workspaceFolder.waypoints.current
	end

	self.waypoints.next = {}
end


function AiDebug:CreateTargetIndicator()
	local block = GeneralUtil:CreatePart(Enum.PartType.Block , Vector3.new(1,1,1), Color3.fromRGB(255,0,0))
	block.Transparency = 1
	block.Parent = self.storageFolder
	block.Name = "TargetIndicator"

	local billboard = Instance.new("BillboardGui", block)
	billboard.Size = UDim2.fromScale(2,0.5)
	billboard.ExtentsOffset = Vector3.new(0,2,0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = block

	local textBox = Instance.new("TextBox", billboard)
	textBox.Size = UDim2.fromScale(1,1)
	textBox.BackgroundColor3 = Color3.fromRGB(255,0,0)
	textBox.TextColor3 = Color3.fromRGB(255,255,255)
	textBox.TextScaled = true
	textBox.Text = "Target"

	GeneralUtil:WeldTo(nil, block, nil)

	self.maid:GiveTask(block)

	return block
end


function AiDebug:TargetAddIndicator(position, object)
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Parent = self.workspaceFolder.target
	self.target.indicator.Position = position

	GeneralUtil:WeldTo(self.target.indicator:FindFirstChild("Weld"), self.target.indicator, object)
end


function AiDebug:TargetRemoveIndicator()
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Parent = self.storageFolder
	GeneralUtil:WeldTo(self.target.indicator:FindFirstChild("Weld"), self.target.indicator, nil)
end


function AiDebug:StartTimer()
	self.timer = os.clock()
end

function AiDebug:PrintTimer()
	print(os.clock() - self.timer)
end


return AiDebug