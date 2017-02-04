
Script.Load("lua/Marine_Order.lua")
Script.Load("lua/Alien_Order.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUISquadWaypoints' (GUIAnimatedScript)

GUISquadWaypoints.kMarineLineMaterialName = PrecacheAsset("ui/squads/waypoint_path_marine.material")
GUISquadWaypoints.kAlienLineMaterialName = PrecacheAsset("ui/squads/waypoint_path_alien.material")

local kLineSegmentsUpdateInterval = kUpdateIntervalMedium
local kPathUpdateInterval = 5
local kLineWidth = 0.44
local kLineFadeInSpeed = 8
local kLineFadeOutSpeed = 1
local kMaxDistToPlayerSquared = 8 * 8
local kMinDistToTargetSquared = 1.5 * 1.5
local kMaxPathLength = 30

function GUISquadWaypoints:Initialize()
    GUIAnimatedScript.Initialize(self, 0)
    self.nextUpdatePathTime = 0
    self.lastUpdateLinesTime = 0
    self.pathPoints = {}
    self.lineSegments = table.array(40)
    self.colors = { 1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1 }
end


local function InitMarineTexture(self)
    self.lineMaterial = GUISquadWaypoints.kMarineLineMaterialName
    self.colors = { 0.725,0.921,0.949,1, 0.725,0.921,0.949,1, 0.725,0.921,0.949,1, 0.725,0.921,0.949,1, 0.725,0.921,0.949,1, } -- kMarineColor
    self.marineWaypointLoaded = true
end


local function InitAlienTexture(self)
    self.lineMaterial = GUISquadWaypoints.kAlienLineMaterialName
    self.colors = { 1,0.792,0.227,1, 1,0.792,0.227,1, 1,0.792,0.227,1, 1,0.792,0.227,1, 1,0.792,0.227,1, } -- kAlienColor
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


local kSquareIndices = { 0,1,4, 1,2,3, 3,4,1 }
local kSquareTexCoords = { 1,1, 0.5,1, 0,1, 0,0, 1,0 }
local function UpdateMesh(line)

    local startPoint = line.startPoint
    local endPoint = line.endPoint
    local pathVector = endPoint - startPoint
    pathVector.y = 0
    local sideVector = pathVector:CrossProduct(Vector(0, 1, 0))
    sideVector:Normalize()
    sideVector:Scale(kLineWidth * line.scale)
    local startSideVector = sideVector * (line.startWidthMultiplier or 1)
    local endSideVector = sideVector * (line.endWidthMultiplier or 1)

    local meshVertices = {
          endPoint.x + endSideVector.x,   endPoint.y,   endPoint.z + endSideVector.z,
          endPoint.x,                     endPoint.y,   endPoint.z,
          endPoint.x - endSideVector.x,   endPoint.y,   endPoint.z - endSideVector.z,
        startPoint.x - startSideVector.x, startPoint.y, startPoint.z - startSideVector.z,
        startPoint.x + startSideVector.x, startPoint.y, startPoint.z + startSideVector.z,
    }

    line.mesh:SetIndices(kSquareIndices, 9) -- #kSquareIndices
    line.mesh:SetTexCoords(kSquareTexCoords, 10) -- #kSquareTexCoords
    line.mesh:SetVertices(meshVertices, 15) -- #meshVertices
    line.mesh:SetColors(line.colors or kSquareColors, 20) -- #line.colors

end


function GUISquadWaypoints:CreateLineSegment(startPoint, endPoint, length, scale)
    local line = {}
    line.hasMesh = false
    line.scale = scale or 0
    line.startPoint = startPoint
    line.endPoint = endPoint
    line.length = length or (startPoint - endPoint):GetLength()
    line.colors = Client.squadSquareColors or self.colors
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
    self:DestroyLineSegments()
    local player = Client.GetLocalPlayer()
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
        local lineStart = lastPoint + Vector(0, -0.87, 0)
        local lineEnd = point + Vector(0, -0.87, 0) -- NOTE maybe trace down here
        local line = self:CreateLineSegment(lineStart, lineEnd, length)
        table.insert(self.lineSegments, line)

        lastPoint = point
    end

end


-- ads line if not exist, updates the line if it exists
local function AddLine(self, line, pathDistFromPlayer, pathDistFromStart, time, dt)
    if not line.hasMesh then
        line.mesh = Client.CreateRenderDynamicMesh(RenderScene.Zone_Default)
        line.mesh:SetMaterial(self.lineMaterial)
        line.mesh:SetIsVisible(true)
        line.hasMesh = true
        if self.pathUpdated then
            line.scale = 1 -- prevents flickering
            UpdateMesh(line)
        end
    end

    if line.scale < 1 then
        line.scale = math.min(1, line.scale + dt * kLineFadeInSpeed)
        UpdateMesh(line)
    end

    local freq = 1.5
    local invwavelength = 0.2
    local startWave = math.sin( (pathDistFromStart * invwavelength - time * freq) * math.pi)
    local endWave = math.sin( ((pathDistFromStart + line.length ) * invwavelength - time * freq) * math.pi)

    line.startWidthMultiplier = (Clamp(startWave, 0.7, 1) - 0.5) * 5 -- 1 <= value <= 2.5
    line.endWidthMultiplier = (Clamp(endWave, 0.7, 1) - 0.5) * 5 -- 1 <= value <= 2.5
    -- line.scale = 1
    UpdateMesh(line)

end


-- updates lines marked from removal, destroys lines when the animation is done
local function RemoveLine(line, dt)
    if line.hasMesh then
        if line.scale > 0 then
            line.startWidthMultiplier = nil
            line.endWidthMultiplier = nil
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
    if not playerOrigin then return end
    local now = Shared.GetTime()

    -- if we stray too far away from the path, request a new one
    local nearestPathPointIndex, _, nearestPathPointDistanceSquared = self:GetClosestPathPoint(playerOrigin)
    if nearestPathPointDistanceSquared > kMaxDistToPlayerSquared then
        self.nextUpdatePathTime = now + kUpdateIntervalMedium
    end

    local targetPoint = self.pathPoints[#self.pathPoints]
    local distToTargetSquared = (playerOrigin - targetPoint):GetLengthSquared()
    local pathDistFromStart = 0
    local pathDistFromPlayer = 0

    -- we want to remove the lines behind us
    for l = 1, nearestPathPointIndex-1 do -- TODO pathpoint index vs linesegment index
        local line = self.lineSegments[l]
        RemoveLine(line, deltaTime)
        pathDistFromStart = pathDistFromStart + line.length
    end

    -- we want to see the lines ahead of us
    for l = nearestPathPointIndex, #self.lineSegments do
        local line = self.lineSegments[l]
        if pathDistFromPlayer < kMaxPathLength  -- only add a part of the way
        and distToTargetSquared > kMinDistToTargetSquared -- dont show path if target is close
        -- and l == nearestPathPointIndex
        then
            AddLine(self, line, pathDistFromPlayer, pathDistFromStart, now, deltaTime)  -- TODO decrease width with distance?
        else
            RemoveLine(line, deltaTime)
        end
        pathDistFromPlayer = pathDistFromPlayer + line.length
        pathDistFromStart = pathDistFromStart + line.length
    end
end


function GUISquadWaypoints:Update(deltaTime)
    PROFILE("GUISquadWaypoints:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    local now = Shared.GetTime()
    if now > self.nextUpdatePathTime then
        -- Log("kPathUpdateInterval exceeded")
        local player = Client.GetLocalPlayer()
        if not player then
            self.pathPoints = {}
            return
        end
        self:UpdatePath()
        self.pathUpdated = true
        self.nextUpdatePathTime = now + kPathUpdateInterval
    end
    if self.pathPoints and #self.pathPoints > 1 and now > self.lastUpdateLinesTime + kLineSegmentsUpdateInterval then
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
