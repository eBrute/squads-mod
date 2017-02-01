
Script.Load("lua/Marine_Order.lua")
Script.Load("lua/Alien_Order.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUISquadWaypoints' (GUIAnimatedScript)

local kMarineTextureName = PrecacheAsset("ui/marine_order.dds")
local kAlienTextureName = PrecacheAsset("ui/alien_order.dds")

local kArrowModel = PrecacheAsset("models/commander_tutorial/big_arrow.model")
local kArrowAlienModel = PrecacheAsset("models/commander_tutorial/big_arrow.model")
-- local kArrowAlienModel = PrecacheAsset("models/misc/effects/halo_wide_green.model")
-- local kArrowModel = PrecacheAsset("models/misc/speed/speed.model")
-- local kArrowAlienModel = PrecacheAsset("models/misc/sentry_arc/sentry_line.model")
-- local kArrowModel = PrecacheAsset("models/misc/commander_arrow.model")
-- local kArrowAlienModel = PrecacheAsset("models/misc/commander_arrow_aliens.model")
-- local kArrowModel = PrecacheAsset("models/misc/waypoint_arrow.model")
-- local kArrowAlienModel = PrecacheAsset("models/misc/waypoint_arrow_alien.model")
local kArrowScaleSpeed = 8
local kArrowMoveToleranceSquared = 6 * 6
-- This is the closest an arrow can be to the player.
local kArrowMinDistToPlayerSquared = 3 * 3
local kArrowMinDistToTargetSquared = 1.5 * 1.5


function GUISquadWaypoints:Initialize()

    -- UpdateItemsGUIScale(self) -- NOTE causes errors

    GUIAnimatedScript.Initialize(self, 0)


    self.nextUpdatePathTime = 0

    self.screenDiagonalLength = math.sqrt(Client.GetScreenHeight()/2) ^ 2 + (Client.GetScreenWidth()/2)


    self.line = Client.CreateRenderDynamicMesh(RenderScene.Zone_Default)
    self.line:SetMaterial(Commander.kMarineLineMaterialName)
    self.line:SetIsVisible(true)

    -- All arrow assets are stored here.
    self.arrows = table.array(8)
    -- The arrows currently being used in the world are stored here.
    self.worldArrows = table.array(8)
    self.hideArrows = table.array(8)

end


local function InitMarineTexture(self)

    self.arrowModelName = kArrowModel
    self.lightColor = Color(0.2, 0.2, 1, 1)
    self.marineWaypointLoaded = true

    self.usedTexture = kMarineTextureName

end


local function InitAlienTexture(self)

    self.arrowModelName = kArrowAlienModel
    self.lightColor = Color(1, 0.2, 0.2, 1) -- TODO get squad color
    self.marineWaypointLoaded = false

    self.usedTexture = kAlienTextureName

end

function GUISquadWaypoints:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    for a = 1, #self.arrows do

        Client.DestroyRenderModel(self.arrows[a].model)
        Client.DestroyRenderLight(self.arrows[a].light)

    end

    self.arrows = nil
    self.worldArrows = nil

    if self.line then
        Client.DestroyRenderDynamicMesh(self.line)
    end
end


local function FindClosestWorldArrow(self, toPoint, playerOrigin)

    local closestArrow = nil
    local closestDist = math.huge
    for a = 1, #self.worldArrows do
        local checkArrow = self.worldArrows[a]
        local arrowOrigin = checkArrow.model:GetCoords().origin
        local dist = (arrowOrigin - toPoint):GetLengthSquared()
        if dist < closestDist then
            closestArrow = checkArrow
            closestDist = dist
        end
    end


    if closestDist < kArrowMoveToleranceSquared then
        return closestArrow
    end

    return nil
end


local function GetFreeArrow(self)

    for a = 1, #self.arrows do

        local arrow = self.arrows[a]
        if not arrow.model:GetIsVisible() then

            arrow.model:SetIsVisible(false)
            arrow.light:SetIsVisible(false)
            return arrow

        end

    end

    local renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
    renderModel:SetModel(self.arrowModelName)
    renderModel:SetIsVisible(false)

    local renderLight = Client.CreateRenderLight()
    renderLight:SetType(RenderLight.Type_Point)
    renderLight:SetCastsShadows(false)
    renderLight:SetSpecular(false)
    renderLight:SetRadius(1)
    renderLight:SetIntensity(10)
    renderLight:SetColor(self.lightColor)
    renderLight:SetIsVisible(false)

    local arrow = { model = renderModel, light = renderLight }
    table.insert(self.arrows, arrow)

    return arrow

end


local function UpdateWorldArrows(self, dt)

    for a = #self.worldArrows, 1, -1 do
        local arrow = self.worldArrows[a]
        if not arrow.inWorld then
            table.remove(self.worldArrows, a)
            arrow.hideAmount = 0
            arrow.hideStartCoords = arrow.model:GetCoords()
            table.insert(self.hideArrows, arrow)
        else
            if arrow.showAmount < 1 then
                arrow.showAmount = math.min(1, arrow.showAmount + dt * kArrowScaleSpeed)
                local scaledCoords = Coords(arrow.showStartCoords)
                scaledCoords:Scale(arrow.showAmount)
                arrow.model:SetCoords(scaledCoords)
            end
        end
    end
end


local function UpdateHideArrows(self, dt)

    for a = #self.hideArrows, 1, -1 do

        local arrow = self.hideArrows[a]
        arrow.hideAmount = math.min(1, arrow.hideAmount + dt * kArrowScaleSpeed)

        local scaledCoords = Coords(arrow.hideStartCoords)
        scaledCoords:Scale(1 - arrow.hideAmount)
        arrow.model:SetCoords(scaledCoords)

        if arrow.hideAmount == 1 then
            arrow.model:SetIsVisible(false)
            arrow.light:SetIsVisible(false)
            table.remove(self.hideArrows, a)
        end
    end
end

local function GetPathToSquad()
    local player = Client.GetLocalPlayer()
    if player then
        local playerOrigin = player:GetOrigin()
        local targetLocation = Vector(0,0,0) -- TODO
        local points = PointArray()

        local isReachable = Pathing.GetPathPoints(playerOrigin, targetLocation, points)
        if isReachable then
            return points
        end
    end
end

local function UpdatePath(self, dt)

    PROFILE("UpdatePath")

    -- Assume the arrows will be removed from the world.
    for a = 1, #self.worldArrows do
        self.worldArrows[a].inWorld = false
    end

    self.lastGetOrderPathTime = self.lastGetOrderPathTime or 0
    local now = Shared.GetTime()
    if now - self.lastGetOrderPathTime >= 1 then

        self.lastGetOrderPathTime = now
        self.pathPoints = GetPathToSquad()

    end

    local visible = self.pathPoints ~= nil and #self.pathPoints > 1
    if visible then

        local targetPoint = self.pathPoints[#self.pathPoints]
        local lastPoint = PlayerUI_GetOrigin()
        local arrowDist = 0
        local totalDist = 0
        for p = 1, #self.pathPoints do

            local point = self.pathPoints[p]
            local direction = lastPoint - point
            local dist = direction:GetLength()
            arrowDist = arrowDist + dist

            -- Stop generating arrows when the path is big enough.
            totalDist = totalDist + dist
            if totalDist >= 30 then
                break
            end

            if arrowDist >= 5 then

                local trace = Shared.TraceRay(point, point - Vector(0, 100, 0), CollisionRep.Move, PhysicsMask.All)
                if trace.fraction ~= 1 then

                    -- Move the arrow a bit off the ground.
                    local arrowOrigin = trace.endPoint + Vector(0, 0.2, 0)

                    -- Find closest world arrow to this point.
                    local arrow = FindClosestWorldArrow(self, arrowOrigin, PlayerUI_GetOrigin())

                    -- If one cannot be found, create a new one.
                    if not arrow then

                        arrow = GetFreeArrow(self)
                        table.insert(self.worldArrows, arrow)

                        arrow.showAmount = 0
                        local arrowCoords = Coords.GetLookIn(arrowOrigin, direction, Vector(0, 1, 0))
                        arrow.showStartCoords = Coords(arrowCoords)
                        arrowCoords:Scale(arrow.showAmount)
                        arrow.model:SetCoords(arrowCoords)
                        arrow.light:SetCoords(Coords.GetTranslation(arrowOrigin))

                    end

                    -- Do not allow arrows to be too close to the player or target.
                    local distToPlayer = (PlayerUI_GetOrigin() - arrow.model:GetCoords().origin):GetLengthSquared()
                    local distToTarget = (targetPoint - arrow.model:GetCoords().origin):GetLengthSquared()
                    if distToPlayer > kArrowMinDistToPlayerSquared and distToTarget > kArrowMinDistToTargetSquared then

                        arrow.inWorld = true
                        arrow.model:SetIsVisible(true)
                        arrow.light:SetIsVisible(true)

                    end

                    arrowDist = 0

                end

            end

            lastPoint = point

        end

    end

    UpdateWorldArrows(self, dt)
    UpdateHideArrows(self, dt)

end


function GUISquadWaypoints:OnResolutionChanged(oldX, oldY, newX, newY)
    Log("GUISquadWaypoints:OnResolutionChanged")
    UpdateItemsGUIScale(self)

    self:Uninitialize()
    self:Initialize()

    local player = Client.GetLocalPlayer()
    if player then
        self:OnLocalPlayerChanged(player)
    end
end


local kPathUpdateInterval = kUpdateIntervalMedium
function GUISquadWaypoints:Update(deltaTime)

    PROFILE("GUISquadWaypoints:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    local player = Client.GetLocalPlayer()
    if player then
        local playerOrigin = player:GetOrigin()
        UpdateOrderLine(playerOrigin, Vector(0,0,0), self.line)
    end



    local now = Shared.GetTime()
    if now > self.nextUpdatePathTime then
        UpdatePath(self, deltaTime)
        self.nextUpdatePathTime = now + kPathUpdateInterval
    end
    -- AnimateFinalWaypoint(self)

end

function GUISquadWaypoints:OnLocalPlayerChanged(newPlayer)
    if newPlayer:GetTeamNumber() == kTeam1Index then
        InitMarineTexture(self)
    elseif newPlayer:GetTeamNumber() == kTeam2Index then
        InitAlienTexture(self)
    end
end

-- NOTE InfantryPortal.lua:413  calls player:ProcessRallyOrder(self)
