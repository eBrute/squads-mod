
Script.Load("lua/Marine_Order.lua")
Script.Load("lua/Alien_Order.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUISquadWaypoints' (GUIAnimatedScript)

GUISquadWaypoints.kMarineLineMaterialName = PrecacheAsset("ui/WaypointPath.material")
GUISquadWaypoints.kAlienLineMaterialName = PrecacheAsset("ui/WaypointPath_alien.material")

local kLineSegmentsUpdateInterval = kUpdateIntervalMedium
local kPathUpdateInterval = 5
local kLineWidth = 0.44
local kLineFadeInSpeed = 8
local kLineFadeOutSpeed = 2
local kMaxDistToPlayerSquared = 8 * 8
local kMinDistToPlayer = 3
local kMinDistToTarget = 1.5
local kMaxPathLength = 30

function GUISquadWaypoints:Initialize()
    GUIAnimatedScript.Initialize(self, 0)
    self.nextUpdatePathTime = 0
    self.lastUpdateLinesTime = 0
    self.pathPoints = {}
    self.lineSegments = table.array(40)
end


local function InitMarineTexture(self)
    self.lineMaterial = GUISquadWaypoints.kMarineLineMaterialName
    self.marineWaypointLoaded = true
end


local function InitAlienTexture(self)
    self.lineMaterial = GUISquadWaypoints.kAlienLineMaterialName
    self.marineWaypointLoaded = false
end


function GUISquadWaypoints:Uninitialize()
    GUIAnimatedScript.Uninitialize(self)
    self:DestroyLineSegments()
    self.lineSegments = nil
    self.pathPoints = nil
    self.nextUpdatePathTime = nil
    self.lastUpdateLinesTime = nil
end


local kSquareTexCoords = { 1,1, 0,1, 0,0, 1,0 }
local kSquareIndices = { 3, 0, 1, 1, 2, 3 }
local kSquareColors = { 1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1, }
local function UpdateMesh(line)

    local startPoint = line.startPoint
    local endPoint = line.endPoint
    local pathVector = endPoint - startPoint
    pathVector.y = 0
    local sideVector = pathVector:CrossProduct(Vector(0, 1, 0))

    sideVector:Normalize()
    sideVector:Scale(kLineWidth * line.scale)

    local meshVertices = {
        endPoint.x + sideVector.x, endPoint.y, endPoint.z + sideVector.z,
        endPoint.x - sideVector.x, endPoint.y, endPoint.z - sideVector.z,
        startPoint.x - sideVector.x, startPoint.y, startPoint.z - sideVector.z,
        startPoint.x + sideVector.x, startPoint.y, startPoint.z + sideVector.z,
    }

    line.mesh:SetIndices(kSquareIndices, 6) -- #kSquareIndices
    line.mesh:SetTexCoords(kSquareTexCoords, 8) -- #kSquareTexCoords
    line.mesh:SetVertices(meshVertices, 12) -- #meshVertices
    line.mesh:SetColors(kSquareColors, 16) -- #kSquareColors

end


function GUISquadWaypoints:CreateLineSegment(startPoint, endPoint, length, scale)
    local line = {}
    line.hasMesh = false
    line.scale = scale or 0
    line.startPoint = startPoint
    line.endPoint = endPoint
    line.length = length or (startPoint - endPoint):GetLength()
    return line
end


function GUISquadWaypoints:DestroyLineSegments()
    for a = 1, #self.lineSegments do
        local line = self.lineSegments[a]
        if line.hasMesh then
            Client.DestroyRenderDynamicMesh(line.mesh)
        end
    end
    self.lineSegments = table.array(40)
end


function GUISquadWaypoints:GetPathToSquad(fromHere)
    -- TODO dont update when player is near path and target hasnt moved much
    local targetLocation = Vector(0,0,0) -- TODO
    local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
    Shared.SortEntitiesByDistance(fromHere, techPoints)
    targetLocation = techPoints[1]:GetOrigin()
    local points = PointArray()

    local isReachable = Pathing.GetPathPoints(fromHere, targetLocation, points)
    if isReachable then
        return points
    end
    -- NOTE InfantryPortal.lua:413  calls player:ProcessRallyOrder(self)
end


function GUISquadWaypoints:GetClosestPathPoint(toPoint)
    local closestPointIndex = nil
    local closestPoint = nil
    local closestDistSquared = math.huge
    for a = 1, #self.pathPoints do
        local point = self.pathPoints[a]
        local distSquared = (point - toPoint):GetLengthSquared()
        if distSquared < closestDistSquared then
            closestPointIndex = a
            closestPoint = point
            closestDistSquared = distSquared
        end
    end
    return closestPointIndex, closestPoint, closestDistSquared
end


function GUISquadWaypoints:UpdatePath()
    Log("GUISquadWaypoints:UpdatePath")
    self:DestroyLineSegments()
    local player = Client.GetLocalPlayer()
    if not player then return end
    local playerOrigin = player:GetOrigin()
    local currentLocation = playerOrigin
    if self.pathPoints then
        local closestPointIndex, _, closestDistSquared = self:GetClosestPathPoint(playerOrigin)
        if closestPointIndex and closestPointIndex > 1 and closestDistSquared < kMaxDistToPlayerSquared then
            currentLocation = self.pathPoints[closestPointIndex-1] -- try to reuse old path
        end
    end
    self.pathPoints = self:GetPathToSquad(currentLocation)

    if not self.pathPoints or #self.pathPoints < 2 then return end

    local lastPoint = self.pathPoints[1]

    for p = 2, #self.pathPoints do

        local point = self.pathPoints[p]
        local length = (lastPoint - point):GetLength()

        -- Move the line a bit off the ground.
        local lineStart = lastPoint + Vector(0, -0.85, 0)
        local lineEnd = point + Vector(0, -0.85, 0) -- NOTE maybe trace down here

        local line = self:CreateLineSegment(lineStart, lineEnd, length)
        table.insert(self.lineSegments, line)

        lastPoint = point
    end

end


local function AddLine(self, line, dt)
    if line.hasMesh then
        if line.scale < 1 then
            line.scale = math.min(1, line.scale + dt * kLineFadeInSpeed)
            UpdateMesh(line)
        end
    else
        line.mesh = Client.CreateRenderDynamicMesh(RenderScene.Zone_Default)
        line.mesh:SetMaterial(self.lineMaterial)
        line.mesh:SetIsVisible(true)
        line.hasMesh = true
        if self.pathUpdated then
            line.scale = 1 -- prevents flickering
            UpdateMesh(line)
        end
    end
end


local function RemoveLine(line, dt)
    if line.hasMesh then
        if line.scale > 0 then
            line.scale = math.max(0, line.scale - dt * kLineFadeOutSpeed)
            UpdateMesh(line)
        else
            line.mesh:SetIsVisible(false)
            Client.DestroyRenderDynamicMesh(line.mesh)
            line.hasMesh = false
        end
    end
end


function GUISquadWaypoints:UpdateLineSegements(deltaTime)
    local playerOrigin = PlayerUI_GetOrigin()
    local targetPoint = self.pathPoints[#self.pathPoints]
    local nearestPathPointIndex, _, nearestPathPointDistanceSquared = self:GetClosestPathPoint(playerOrigin)
    -- if we stray too far away from the path, request a new one
    if nearestPathPointDistanceSquared > kMaxDistToPlayerSquared then
        Log("kMaxDistToPlayerSquared request new path, %s > %s", nearestPathPointDistanceSquared, kMaxDistToPlayerSquared)
        self.nextUpdatePathTime = 0
        --return -- TODO ?
    end

    local totalDist = 0
    for l = 1, #self.lineSegments do
        local line = self.lineSegments[l]

        -- we want to remove the lines behind us
        if l < nearestPathPointIndex then
            RemoveLine(line, deltaTime)
        else
            -- we want to see the lines ahead of us
            totalDist = totalDist + line.length
            if totalDist > kMaxPathLength then -- only add a part of the way
                RemoveLine(line, deltaTime)
            else
                -- local distToPlayer = GetDistanceToLineInPlane(playerOrigin, line) -- TODO
                -- if distToPlayer > kMinDistToPlayer and distToTarget > kMinDistToTargetSquared then
                AddLine(self, line, deltaTime)
            end
        end
    end
end


function GUISquadWaypoints:Update(deltaTime)
    PROFILE("GUISquadWaypoints:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    local now = Shared.GetTime()
    if now > self.nextUpdatePathTime then
        Log("kPathUpdateInterval exceeded")
        self:UpdatePath()
        self.pathUpdated = true
        self.nextUpdatePathTime = now + kPathUpdateInterval
    end
    if self.pathPoints and now > self.lastUpdateLinesTime + kLineSegmentsUpdateInterval then
        self:UpdateLineSegements(now - self.lastUpdateLinesTime)
        self.pathUpdated = false
        self.lastUpdateLinesTime = now
    end
end


function GUISquadWaypoints:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()

    local player = Client.GetLocalPlayer()
    if player then
        self:OnLocalPlayerChanged(player)
    end
end



function GUISquadWaypoints:OnLocalPlayerChanged(newPlayer)
    if newPlayer:GetTeamNumber() == kTeam1Index then
        InitMarineTexture(self)
    elseif newPlayer:GetTeamNumber() == kTeam2Index then
        InitAlienTexture(self)
    end
end
