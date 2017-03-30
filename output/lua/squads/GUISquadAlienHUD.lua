Script.Load("lua/GUIUtility.lua")
Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Globals.lua")
Script.Load("lua/GUINotifications.lua")

class 'GUISquadAlienHUD' (GUIScript)

function GUIItem:AddAsChildTo(item)
    item:AddChild(self)
end


local function ScaledCoords(x, y)
    return Vector( GUIScaleWidth(x), GUIScaleHeight(y), 0)
end


function GUISquadAlienHUD:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetPosition( Vector(0, 0, 0) )
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )

    self.locationText = GUIManager:CreateTextItem()
    self.locationText:SetFontName(GUINotifications.kMarineFont) -- NOTE same as kAlienFont but global
    self.locationText:SetTextAlignmentX(GUIItem.Align_Min)
    self.locationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.locationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.locationText:SetLayer(kGUILayerLocationText)
    self.locationText:SetFontIsBold(true)
    self.locationText:AddAsChildTo(self.background)
    GUIMakeFontScale(self.locationText)

    self:Reset()
    self:SetIsVisible(true)
    self:Update(0)
end


function GUISquadAlienHUD:GetIsVisible()
    return self.isVisible
end


function GUISquadAlienHUD:SetIsVisible(visible)
    self.isVisible = visible
    self.background:SetIsVisible(visible)
end


function GUISquadAlienHUD:OnResolutionChanged(oldX, oldY, newX, newY)
    local visible = self:GetIsVisible()

    self:Reset()

    self:Uninitialize()
    self:Initialize()

    self:SetIsVisible(visible)
end


function GUISquadAlienHUD:Reset()
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetPosition(GUIScale(Vector(20, 20, 0)))
    self.locationText:SetFontName(GUINotifications.kMarineFont)
    GUIMakeFontScale(self.locationText)
    self.lastLocationId = nil
    self.lastRallyLocationId = nil
end


function GUISquadAlienHUD:Uninitialize()
    if self:GetIsVisible() then
        self:SetIsVisible(false)
    end

    GUI.DestroyItem(self.locationText)
    GUI.DestroyItem(self.background)
    self.lastLocationId = nil
    self.lastRallyLocationId = nil
end


function GUISquadAlienHUD:Update(deltaTime)

    PROFILE("GUISquadAlienHUD:Update")

    local player = Client.GetLocalPlayer()

    local script = ClientUI.GetScript("GUINotifications")
    if not script then return end
    if not HasMixin(player, "SquadMember") then return end

    -- local teamNumber = player:GetTeamNumber()
    local squadNumber = player:GetSquadNumber()
    local rallyPointLocationId, rallyPoint = player:GetSquadRallyPoint()
    local currentLocationId = player:GetLocationId()

    if self.lastRallyLocationId ~= rallyPointLocationId or self.lastLocationId ~= currentLocationId then

        local locationName

        -- get name of the room we are headed for
        if rallyPointLocationId ~= -1 then
            local location = GetLocationForPoint(rallyPoint)
            if location then
                locationName = location:GetName()
                if locationName ~= "" then
                    -- locationName = string.upper("Squad at " .. locationName)
                    locationName = "Squad at " .. locationName
                end
            end
        end

        -- dont show when we reached the target room already
        -- TODO show always? "Meet with others here" ?
        if currentLocationId == rallyPointLocationId then
            locationName = ""
        end

        local currentLocationTextGUIItem = script.locationText
        if not currentLocationTextGUIItem then return end
        local currentLocationText = currentLocationTextGUIItem:GetText()
        local width = self.locationText:GetTextWidth(currentLocationText)
        self.locationText:SetPosition(GUIScale(Vector(20, 20, 0)) + Vector(width, 0, 0))

        self.locationText:SetText(locationName or "Alienators")
        self.locationText:SetColor(kSquadColors[squadNumber])

        self.lastRallyLocationId = rallyPointLocationId
        self.lastLocationId = currentLocationId
    end
end
