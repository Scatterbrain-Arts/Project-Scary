-- Pathfinder
-- Stephen Leitnick
-- March 31, 2021

--[[

	This utilizes the nodes created with the Node Map V2 plugin.

	Pathfinder:FindPath(startPosition: Vector3, endPosition: Vector3): Vector3[]

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GeneralUtil = require("GeneralUtil")

local pathNodes = nil


local isDebug = true

local NodeMap = {}
NodeMap.__index = NodeMap


local function BuildNodes(nodeFolder, showBillboard, color3)
	if not nodeFolder then
		error("nodeFolder is nil...")
	end

	print("nodefolder:", nodeFolder)

	local nodes = {}
	local dict = {}

	-- Get nodes:
	for i, v in ipairs(nodeFolder:GetChildren()) do
		if (v:IsA("Folder")) then
			local node = {
				Position = v:GetAttribute("NodePosition");
				Neighbors = {};
				F = 0; --sort value
				G = 0; --weight
				H = 0; --maybe hueristic
				Parent = nil;
				Name = i
			}
			table.insert(nodes, node)
			dict[v:GetAttribute("NodeId")] = node
		end
	end

	-- Get node neighbors:
	for _,v in ipairs(nodeFolder:GetChildren()) do
		if (v:IsA("Folder")) then
			local links = v:GetAttribute("NodeLinks"):split(",")
			local node = dict[v:GetAttribute("NodeId")]
			for _,linkId in ipairs(links) do
				local neighborNode = dict[linkId]
				table.insert(node.Neighbors, neighborNode)
				table.insert(neighborNode.Neighbors, node)
			end
		end
	end

	if showBillboard then
		for i,v in nodes do
			GeneralUtil:CreateBillboardAtPosition(i, v.Position, UDim2.fromScale(0.5,0.5), color3, Color3.fromRGB(255,255,255))
		end
	end

	return nodes
end

local function FindNearestNode(nodeMap, position)
	local dist, nearest = math.huge, nil
	for _,node in ipairs(nodeMap) do
		local d = (position - node.Position).Magnitude
		if (d < dist) then
			dist, nearest = d, node
		end
	end
	return nearest
end




function NodeMap.new(npc)
    local self = {}
    setmetatable(self, NodeMap)

	self.maid = Maid.new()
	self.npc = npc

	self.Directory = ReplicatedStorage.NodeMapProjects
	self.Maps = {}

	for i, nodeFolder in self.Directory:GetChildren() do
		local nodeRoom = string.match(nodeFolder.Name, "(.-)_")  --word before first underscore
		if not nodeRoom then
			error("Node Room was not found...")
		end
		self.Maps[nodeRoom] = not self.Maps[nodeRoom] and {} or self.Maps[nodeRoom]

		local nodeType = string.match(nodeFolder.Name, "_(.-)_") --word after 2nd underscore, before 3rd underscore
		if not nodeType then
			error("Node Type was not found...")
		end
		self.Maps[nodeRoom][nodeType] = not self.Maps[nodeRoom][nodeType] and {} or self.Maps[nodeRoom][nodeType]

		table.insert(self.Maps[nodeRoom][nodeType], BuildNodes(nodeFolder, isDebug, Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))))
	end

	return self
end


function NodeMap:FindNearestMap(roomName, startPosition)
	local roomTable = self.Maps[roomName]
	if not roomTable then
		warn("Room map not found", roomName)
		return
	end

	local roomSearchTable = roomTable["Search"]
	if not roomSearchTable then
		warn("Room search not found", roomName)
		return
	end

	local dist, nearestNode, nearestMap = math.huge, nil, nil
	for _, nodeMap in pairs(roomSearchTable) do
		for _,node in ipairs(nodeMap) do
			local d = (startPosition - node.Position).Magnitude
			if (d < dist) then
				dist, nearestNode, nearestMap = d, node, nodeMap
			end
		end
	end

	return nearestMap, nearestNode
end


function NodeMap:FindSearchRoute(roomName, startPosition)
	local nearestMap, nearestNode = self:FindNearestMap(roomName, startPosition)
	if not nearestMap or not nearestNode then
		warn("NearestMap or NearestNode is nil...")
		return
	end

	print("searching", #nearestMap)

	local path = {}
	local humanReadablePath = {}
	local explored = {}
	
	local node = nearestNode
	table.insert(path, node)
	table.insert(humanReadablePath, node.Name)
	
	explored[node] = 2

	for i = 1, 8 do
		local smallestValue = math.huge
		local smallestNeighbor = nil
		for _, neighbor in ipairs(node.Neighbors) do
			local mod = explored[neighbor] or 1
			local rnd = math.random(1,10) * mod
			if rnd < smallestValue then
				smallestValue = rnd
				smallestNeighbor = neighbor
			end
		end
		smallestValue = math.huge

		node = smallestNeighbor
		table.insert(path, node)
		table.insert(humanReadablePath, node.Name)

		explored[node] = not explored[node] and 2 or explored[node]+1
	end

	return path, humanReadablePath
end





function NodeMap:FindPath(startPosition, goalPosition)

	if (not pathNodes) then
		self:Init()
	end

	local path = {}
	local pathFound = false

	local startNode = FindNearestNode(startPosition)
	local goalNode = FindNearestNode(goalPosition)

	local open = {[startNode] = true}
	local closed = {}

	-- Find node with lowest F score within the "open" list:
	local function FindLowestFNode()
		local lowestF, node = math.huge, nil
		for n in pairs(open) do
			if (n.F < lowestF) then
				lowestF, node = n.F, n
			end
		end
		return node
	end

	-- Find path via A* algorithm:
	while (next(open)) do

		-- Find node with lowest F score in open list.
		-- Switch that node from open list to closed list.
		local node = FindLowestFNode()
		open[node] = nil
		closed[node] = true

		-- If the node we just got is the goal node, we found the path!
		if (node == goalNode) then
			pathFound = true
			break
		end

		-- Scan through all neighbors of this node.
		for _,neighbor in ipairs(node.Neighbors) do
			-- If it's not closed, let's examine it.
			if (not closed[neighbor]) then
				-- If it's not in the open list, let's add it to the list and do some calculations on it.
				if (not open[neighbor]) then
					open[neighbor] = true
					neighbor.Parent = node
					neighbor.G = node.G + (neighbor.Position - node.Position).Magnitude
					neighbor.H = (neighbor.Position - goalNode.Position).Magnitude
					neighbor.F = (neighbor.G + neighbor.H)
				else
					-- If it is on the open list and is a good pick for the next path, let's redo some of the calculations
					if (neighbor.G < node.G) then
						neighbor.Parent = node
						neighbor.G = node.G + (neighbor.Position - node.Position).Magnitude
						neighbor.F = (neighbor.G + neighbor.H)
					end
				end
			end
		end

	end

	-- Backtrace path:
	if (pathFound) then
		local node = goalNode
		while (node) do
			table.insert(path, 1, node.Position)
			node = node.Parent
		end
	end

	-- Reset nodes:
	local function ResetNodeDictionary(dict)
		for node in pairs(dict) do
			node.F = 0
			node.G = 0
			node.H = 0
			node.Parent = nil
		end
	end
	ResetNodeDictionary(open)
	ResetNodeDictionary(closed)

	return (pathFound and path or nil)

end










return NodeMap