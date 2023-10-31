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


function AiDebug.new(entity, isPrint)
	local self = {}
	setmetatable(self, AiDebug)

	self.maid = Maid.new()
	self.entity = entity
	self.storageFolder, self.workspaceFolder = InitFolders(entity.name)
	self.isPrint = isPrint


	self.waypoints = {
		current = {},
		next = {},
	}

	self.target = {
		indicator = self:CreateTargetIndicator(),
		object = nil,
		weld = nil,
	}

	self.behaviorTree = {
		indicator = self:CreateBehaviorTreeIndicator(true),
		currentTask = "",
	}

	self.timer = os.clock()

	return self
end



function AiDebug:CreateAgentCylinder(name, root, width, height, color)
	local cylinder = GeneralUtil:CreatePart(Enum.PartType.Cylinder, Vector3.new(height, width*2, width*2), color)
	cylinder.Transparency = 0.5
	cylinder.Anchored = false
	cylinder.Parent = root.Parent
	cylinder.Name = name

	GeneralUtil:WeldTo(cylinder, root)

	cylinder.Orientation = Vector3.new(0,0,90)
	cylinder.Position = root.Position - Vector3.new(0, root.Parent.Humanoid.HipHeight/2 - AiDebug.GROUND_OFFSET, 0)

	self.maid:GiveTask(cylinder)
end


function AiDebug:CreateRangeSphere(name, root, size, color)
	local sphere = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(size*2, size*2, size*2), color)
	sphere.Transparency = 0.75
	sphere.Anchored = false
	sphere.Parent = root.Parent
	sphere.Position = root.Position
	sphere.Name = name

	GeneralUtil:WeldTo(sphere, root)

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

	local billboard = GeneralUtil:CreateBillboard(UDim2.fromScale(2,0.5), Vector3.new(0,2,0))
	billboard.Parent = block
	billboard.Adornee = block

	local textBox = GeneralUtil:CreateTextBox(UDim2.fromScale(1,1), Color3.fromRGB(255,0,0), Color3.fromRGB(255,255,255))
	textBox.Parent = billboard
	textBox.Text = "Target"

	GeneralUtil:WeldTo(block)

	self.maid:GiveTask(block)

	return block
end


function AiDebug:AddTargetIndicator(position, object)
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Parent = self.workspaceFolder.target
	self.target.indicator.Position = position

	self.target.weld = self.target.weld or self.target.indicator:FindFirstChild("Weld")
	GeneralUtil:WeldTo(self.target.indicator, object, self.target.weld)
end


function AiDebug:RemoveTargetIndicator()
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Parent = self.storageFolder

	self.target.weld = self.target.weld or self.target.indicator:FindFirstChild("Weld")
	GeneralUtil:WeldTo(self.target.indicator, nil, self.target.weld)
end

function AiDebug:CreateBehaviorTreeIndicator()
	local block = GeneralUtil:CreatePart(Enum.PartType.Block , Vector3.new(1,1,1), Color3.fromRGB(255, 255, 0))
	block.Transparency = 1
	block.Parent = self.entity.character
	block.Anchored = false
	block.Name = "BehaviorTreeIndicator"

	local billboard = GeneralUtil:CreateBillboard(UDim2.fromScale(10,2.5), Vector3.new(0,2,0))
	billboard.Parent = block
	billboard.Adornee = block

	local textBox = GeneralUtil:CreateTextBox(UDim2.fromScale(1,1), Color3.fromRGB(0, 255, 157), Color3.fromRGB(0, 0, 0))
	textBox.Parent = billboard
	textBox.Text = ""

	GeneralUtil:WeldTo(block, self.entity.character.Head)

	self.maid:GiveTask(block)

	return block
end

function AiDebug:UpdateBehaviorTreeIndicator(updatedText)
	if not self.behaviorTree.indicator then
		warn("Behavior Tree indicator is nil for ", self.entityName, "...")
		return
	end

	if self.behaviorTree.indicator.BillboardGui.TextBox.Text ~= updatedText then
		self.behaviorTree.indicator.BillboardGui.TextBox.Text = updatedText

		if self.isPrint then print(updatedText) end
	end

end

function AiDebug:StartTimer()
	self.timer = os.clock()
end

function AiDebug:PrintTimer()
	print(os.clock() - self.timer)
end


return AiDebug