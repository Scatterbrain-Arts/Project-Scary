local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GeneralUtil = require("GeneralUtil")


local function InitFolders(entityName)
	-- STORAGE FOLDERS --
	local storageRootFolder = GeneralUtil:Get("Folder", ReplicatedStorage, "NPCDebug")
	local storageFolder = GeneralUtil:Get("Folder", storageRootFolder, entityName)

	-- WORSPACE FOLDERS --
	local workspaceRootFolder = GeneralUtil:Get("Folder", workspace, "NPCDebug")
	local workspaceFolder = GeneralUtil:Get("Folder", workspaceRootFolder, entityName)

	-- WAYPOINTS FOLDER --
	GeneralUtil:Get("Folder", workspaceFolder, "waypoints")

	-- TARGET FOLDER --
	GeneralUtil:Get("Folder", workspaceFolder, "target")

	return storageFolder, workspaceFolder
end

local NPCDebug = {}
NPCDebug.__index = NPCDebug
NPCDebug.GROUND_OFFSET = 0.5

function NPCDebug.new(npc)
	local self = {}
	setmetatable(self, NPCDebug)

	self.npc = npc
	self.maid = Maid.new()

	self.storageFolder, self.workspaceFolder = InitFolders(self.npc.name)
	self.root = self.npc.root

	self.target = {
		indicator = self:CreateTargetIndicator(),
		object = nil,
		weld = nil,
	}

	self.behaviorTree = {
		indicator = self:CreateBehaviorTreeIndicator(),
		currentTask = "",
	}

	self.timer = os.clock()

	return self
end



function NPCDebug:CreateAgentCylinder(name, root, width, height, color)
	local cylinder = GeneralUtil:CreatePart(Enum.PartType.Cylinder, Vector3.new(height, width*2, width*2), color)
	cylinder.Transparency = 0.5
	cylinder.Anchored = false
	cylinder.Parent = root.Parent
	cylinder.Name = name

	GeneralUtil:WeldTo(cylinder, root)

	cylinder.Orientation = Vector3.new(0,0,90)
	cylinder.Position = root.Position - Vector3.new(0, root.Parent.Humanoid.HipHeight/2 - NPCDebug.GROUND_OFFSET, 0)

	self.maid:GiveTask(cylinder)
end


function NPCDebug:CreateRangeSphere(name, root, size, color)
	local sphere = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(size*2, size*2, size*2), color)
	sphere.Transparency = 0.75
	sphere.Anchored = false
	sphere.Parent = root.Parent
	sphere.Position = root.Position
	sphere.Name = name

	GeneralUtil:WeldTo(sphere, root)

	self.maid:GiveTask(sphere)
end



function NPCDebug:CreateTargetIndicator()
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


function NPCDebug:AddTargetIndicator(position, object, isPlayer)
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Anchored = not isPlayer
	self.target.indicator.Parent = self.workspaceFolder.target
	self.target.indicator.Position = position

	self.target.weld = self.target.weld or self.target.indicator:FindFirstChild("Weld")
	GeneralUtil:WeldTo(self.target.indicator, object, self.target.weld)
end


function NPCDebug:RemoveTargetIndicator()
	if not self.target.indicator then
		warn("Target indicator is nil for ", self.entityName, "...")
		return
	end

	self.target.indicator.Parent = self.storageFolder

	self.target.weld = self.target.weld or self.target.indicator:FindFirstChild("Weld")
	GeneralUtil:WeldTo(self.target.indicator, nil, self.target.weld)
end

function NPCDebug:CreateBehaviorTreeIndicator()
	local block = GeneralUtil:CreatePart(Enum.PartType.Block , Vector3.new(1,1,1), Color3.fromRGB(255, 255, 0))
	block.Transparency = 1
	block.Parent = self.npc.character
	block.Anchored = false
	block.Name = "BehaviorTreeIndicator"

	local billboard = GeneralUtil:CreateBillboard(UDim2.fromScale(10,2.5), Vector3.new(0,2,0))
	billboard.Parent = block
	billboard.Adornee = block

	local textBox = GeneralUtil:CreateTextBox(UDim2.fromScale(1,1), Color3.fromRGB(0, 255, 157), Color3.fromRGB(0, 0, 0))
	textBox.Parent = billboard
	textBox.Text = ""

	GeneralUtil:WeldTo(block, self.npc.character.Head)

	self.maid:GiveTask(block)

	return block
end

function NPCDebug:UpdateBehaviorTreeIndicator(updatedText, isPrint)
	if not self.behaviorTree.indicator then
		warn("Behavior Tree indicator is nil for ", self.entityName, "...")
		return
	end

	if self.behaviorTree.indicator.BillboardGui.TextBox.Text ~= updatedText then
		self.behaviorTree.indicator.BillboardGui.TextBox.Text = updatedText

		if isPrint then print(updatedText) end
	end

end

function NPCDebug:StartTimer()
	self.timer = os.clock()
end

function NPCDebug:PrintTimer()
	print(os.clock() - self.timer)
end


return NPCDebug