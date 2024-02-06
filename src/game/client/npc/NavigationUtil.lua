local require = require(script.Parent.loader).load(script)
local next = next

local GeneralUtil = require("GeneralUtil")

local NavigationUtil = {}


function NavigationUtil:GetRegions(rooms)
    local regions = {
        rooms = {},
        totalWeight = 0,
    }

    local largestArea = 0
    for index, room in rooms do
        local regionFolder = GeneralUtil:Get("Folder", room.NavMesh, "Region"):GetChildren()

        if #regionFolder ~= 2 then
            error("Region folders must have 2 corner parts...")
        end

        local corner1 = regionFolder[1]
        local corner2 = regionFolder[2]

        local regionData = {}
        regionData.lowerbound = Vector3.new(
            math.min(corner1.Position.X, corner2.Position.X),
            math.min(corner1.Position.Y, corner2.Position.Y),
            math.min(corner1.Position.Z, corner2.Position.Z)
        )
        regionData.upperbound = Vector3.new(
            math.max(corner1.Position.X, corner2.Position.X),
            math.max(corner1.Position.Y, corner2.Position.Y),
            math.max(corner1.Position.Z, corner2.Position.Z)
        )

        regionData.lowerboundFloor = Vector3.new(
            math.floor(regionData.lowerbound.X),
            math.floor(regionData.lowerbound.Y),
            math.floor(regionData.lowerbound.Z)
        )
        regionData.upperboundFloor = Vector3.new(
            math.floor(regionData.upperbound.X),
            math.floor(regionData.upperbound.Y),
            math.floor(regionData.upperbound.Z)
        )

        regionData.region = Region3.new(regionData.lowerbound, regionData.upperbound)
        regionData.area = regionData.region.Size.X * regionData.region.Size.Z

        if regionData.area > largestArea then
            largestArea = regionData.area
        end

        regions.rooms[room.Name] = regionData
    end

    local totalWeight = 0
    for i, regionData in regions.rooms do
        local ratio = (regionData.area/largestArea) * 10
        regionData.weight = math.floor( math.clamp(ratio, 1, 10) )
        totalWeight += regionData.weight
    end

    regions.totalWeight = totalWeight

    return regions
end


function NavigationUtil:FindRoomFromPosition(regions, position)
    position = Vector3.new(position.X, math.floor(position.Y), position.Z)

    for roomName, regionData in pairs(regions) do

        local lowerBound = regionData.lowerbound
        local upperBound = regionData.upperbound

        -- print(roomName)

        -- print(position.X, lowerBound.X, upperBound.X, position.X >= lowerBound.X and position.X <= upperBound.X)
        -- print(position.Y, lowerBound.Y, upperBound.Y, position.Y >= lowerBound.Y and position.Y <= upperBound.Y)
        -- print(position.Z, lowerBound.Z, upperBound.Z, position.Z >= lowerBound.Z and position.Z <= upperBound.Z)


        if position.X >= lowerBound.X and position.X <= upperBound.X and
           position.Y >= math.floor(lowerBound.Y) and position.Y <= math.floor(upperBound.Y) and
           position.Z >= lowerBound.Z and position.Z <= upperBound.Z then
            return roomName -- The position is within this room's bounds
        end
    end

    return nil
end


function NavigationUtil:FindWalkablePosition(startPosition, targetPosition, partSize, maxRadius)
    local angle = 0
    local radius = partSize
	local step = partSize / 2

    -- Calculate initial direction from NPC to sound
    local directionVector = (targetPosition - startPosition).unit
    local initialAngle = math.atan2(directionVector.X, directionVector.Z)

    while radius <= maxRadius do
        -- Convert polar coordinates (angle, radius) to Cartesian coordinates (x, y)
        local x = radius * math.cos(initialAngle + angle)
        local z = radius * math.sin(initialAngle + angle)
        local checkPosition = targetPosition + Vector3.new(x, 0, z) -- Adjust Y coordinate as needed

		local partsInRegion = GeneralUtil:QueryRadius(checkPosition, partSize, "RayFindWalkPos", true)
        if not next(partsInRegion) then -- If no parts are found in the region, it's a potential spot
            return checkPosition
        end

        -- Update angle and radius for the next iteration
        angle += math.asin(step/radius)

        if angle >= (2 * math.pi) then
            angle -= (2 * math.pi)
            radius += step
        end
    end

    return nil
end


function NavigationUtil:FindRegionWithPart(regions, searchCollisionGroup, partCollisionGroup)
	local currentRegion = nil
    for index, regionData in pairs(regions) do
        local objects = GeneralUtil:QueryRegion(regionData.region.CFrame, regionData.region.Size + Vector3.new(0,5,0), searchCollisionGroup)
        if next(objects) then
            for _, object in ipairs(objects) do
                if object:IsA("BasePart") or object:IsA("MeshPart") then
                    if object.CollisionGroup == partCollisionGroup then
                        currentRegion = index
                        break
                    end
                else
                    warn("unknown type to reference...")
                end
            end
        end
    end
	return currentRegion
end


local function GetRandomPointInRegion(regionData)
    local point = Vector3.new(
        math.random(regionData.lowerbound.X, regionData.upperbound.X),
        math.random(regionData.lowerbound.Y, regionData.upperbound.Y),
        math.random(regionData.lowerbound.Z, regionData.upperbound.Z)
    )

    return point
end
NavigationUtil.RandomPointInRegion = GetRandomPointInRegion

local last = "Large"
local function GetRandomPointInAnyRegion(regions)
    local rnd = math.random() * regions.totalWeight
    local selectedRegion = nil

    local cumulativeWeight = 0
    for index, regionData in regions.rooms do
        cumulativeWeight += regionData.weight

        if rnd <= cumulativeWeight then
            selectedRegion = index
            break
        end
    end

    --selectedRegion = last == "Large" and "Small" or "Large" --testing remove later
	--last = selectedRegion

    return GetRandomPointInRegion(regions.rooms[selectedRegion])
end
NavigationUtil.RandomPointAnyRegion = GetRandomPointInAnyRegion


local function ComputePath(path, startPosition, targetPosition)
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPosition, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        return true
    else
        return false
    end
end


function NavigationUtil:FindPath(path, startPosition, targetPosition)
    local tries = 0
    local isPath = false

    repeat
        isPath = ComputePath(path, startPosition, targetPosition)

        if tries >= 1 then
            task.wait()
        end
        tries+=1
    until isPath or tries > 3

    if not isPath then
        warn("No Path Found...")
        return false
    end

    return true
end


function NavigationUtil:FindPathRandom(path, startPosition, randomizer, regions)
    local tries = 0
    local isPath = false
    local targetPosition = nil

    repeat
        targetPosition = randomizer(regions)
        isPath = ComputePath(path, startPosition, targetPosition)

        if tries >= 1 then
            task.wait()
        end
        tries+=1
    until isPath or tries > 3

    if not isPath then
        warn("No Path Found...")
        return false
    end

    return targetPosition
end


function NavigationUtil:EndService(service)
    if service.connection then
        service.connection:Disconnect()
        service.connection = nil
    end
end


-- Fill in paths in the opposite direction to the stated edges
function NavigationUtil:GraphComplete(graph)
    for node, edges in pairs(graph) do
        for edge, distance in pairs(edges) do
            if not graph[edge] then graph[edge] = {} end
            graph[edge][node] = distance
        end
    end
end


-- Create path string from table of previous nodes
function NavigationUtil:GraphFollow(trail, destination)
    local path, nextStep = destination, trail[destination]
    local reverseTable = {}
    table.insert(reverseTable, path)
    while nextStep do
        path = nextStep .. " " .. path
        table.insert(reverseTable, nextStep)
        nextStep = trail[nextStep]
    end

    -- local result = {}
    -- for i = #t, 1, -1 do
    --     table.insert(result, t[i])
    -- end

    return reverseTable
end


-- Find the shortest path between the current and destination nodes
function NavigationUtil:GraphDijkstra(graph, current, destination, directed)
    print(graph)

    if not directed then NavigationUtil:GraphComplete(graph) end

    local unvisited, distanceTo, trail = {}, {}, {}
    local nearest, nextNode, tentative

    for node, edgeDists in pairs(graph) do
        if node == current then
            distanceTo[node] = 0
            trail[current] = false
        else
            distanceTo[node] = math.huge
            unvisited[node] = true
        end
    end

    repeat
        nearest = math.huge
        for neighbour, pathDist in pairs(graph[current]) do
            if unvisited[neighbour] then
                tentative = distanceTo[current] + pathDist
                if tentative < distanceTo[neighbour] then
                    distanceTo[neighbour] = tentative
                    trail[neighbour] = current
                end
                if tentative < nearest then
                    nearest = tentative
                    nextNode = neighbour
                end
            end
        end

        unvisited[current] = false
        current = nextNode
    until unvisited[destination] == false or nearest == math.huge

    return NavigationUtil:GraphFollow(trail, destination), distanceTo[destination]
end


return NavigationUtil






-- local Axis8Directions = {
--     north = Vector3.new(0, 0, -1), east = Vector3.new(1, 0, 0), northeast = Vector3.new(1, 0, -1), southwest = Vector3.new(-1, 0, 1),
--     south = Vector3.new(0, 0, 1), west = Vector3.new(-1, 0, 0), southeast = Vector3.new(1, 0, 1), northwest = Vector3.new(-1, 0, -1),
-- }

-- local ThreadLookDirection = coroutine.create(function(npcRoot, targetDirection)
-- 	while true do
--         while true do
--             local targetCFrame = CFrame.new(npcRoot.Position, npcRoot.Position + targetDirection)
            
--             npcRoot.CFrame = npcRoot.CFrame:Lerp(targetCFrame, 0.1)
--             if (targetCFrame.LookVector - npcRoot.CFrame.LookVector).Magnitude <= 0.1 then
--                 break
--             end

--           -- print(npcRoot.CFrame.LookVector)

--             task.wait()
--         end
-- 		coroutine.yield()
-- 	end
-- end)


-- function Navigation:FaceTo(targetDirection)
--     coroutine.resume(ThreadLookDirection, self.root, targetDirection)
-- end


-- function Navigation:FindDirectionToFace()
--     local partsInRadius = GeneralUtil:QueryRadius(self.root.Position, 8, "RayNPC", false)
--     if not partsInRadius then
--         return
--     end

--     local directionScores = {
--         north = 0, east = 0,
--         south = 0, west = 0,
--     }

--     for _, part in pairs(partsInRadius) do
--         local directionToPart = (part.Position - self.root.Position).Unit
--         local angle = math.deg(math.atan2(directionToPart.X, directionToPart.Z))

--         angle = angle % 360

--         if angle >= 135.6 and angle <= 225.4 then
--             directionScores.north += 1

--         elseif angle >= 225.6 and angle <= 315.4 then
--             directionScores.west += 1

--         elseif angle >= 315.6 and angle <= 360 or angle >= 0 and angle <= 45.4 then
--             directionScores.south += 1

--         elseif angle >= 45.6 and angle <= 135.4 then
--             directionScores.east += 1
--         end
--     end

--     local i, v = GeneralUtil:GetConditonFromTable(directionScores, function(a,b) return a > b end)

--     print("final direction:", i)

--     return Axis8Directions[i]
-- end