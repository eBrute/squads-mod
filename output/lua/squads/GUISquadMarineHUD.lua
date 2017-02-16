Script.Load("lua/GUIUtility.lua")
Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Globals.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUD.lua")

class 'GUISquadMarineHUD' (GUIAnimatedScript)


function GUIItem:AddAsChildTo(item)
    item:AddChild(self)
end


local function ScaledCoords(x, y)
    return Vector( GUIScaleWidth(x), GUIScaleHeight(y), 0)
end


function GUISquadMarineHUD:Initialize()

    GUIAnimatedScript.Initialize(self, 0)

    self.scale =  Client.GetScreenHeight() / kBaseScreenHeight

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetPosition( Vector(0, 0, 0) )
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetIsScaling(false)
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )

    self.locationText = self:CreateAnimatedTextItem()
    self.locationText:SetFontName(GUIMarineHUD.kTextFontName)
    self.locationText:SetTextAlignmentX(GUIItem.Align_Min)
    self.locationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.locationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.locationText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.locationText:SetFontIsBold(true)
    -- self.locationText:AddAsChildTo(self.background)

    self:Reset()
    self:SetIsVisible(true)
    self:Update(0)
end


function GUISquadMarineHUD:GetIsVisible()
    return self.isVisible
end


function GUISquadMarineHUD:SetIsVisible(visible)
    self.isVisible = visible
    self.background:SetIsVisible(visible)
end


function GUISquadMarineHUD:OnResolutionChanged(oldX, oldY, newX, newY)
    local visible = self:GetIsVisible()

    self.scale = newY / kBaseScreenHeight

    self:Reset()

    self:Uninitialize()
    self:Initialize()

    self:SetIsVisible(visible)
end


function GUISquadMarineHUD:Reset()
    self.locationText:SetUniformScale(self.scale)
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetPosition(GUIMarineHUD.kLocationTextOffset)
    self.locationText:SetFontName(GUIMarineHUD.kTextFontName)
    GUIMakeFontScale(self.locationText)
    self.lastLocationId = nil
    self.lastRallyLocationId = nil
end


function GUISquadMarineHUD:Uninitialize()
    if self:GetIsVisible() then
        self:SetIsVisible(false)
    end

    GUIAnimatedScript.Uninitialize(self)
    self.lastLocationId = nil
    self.lastRallyLocationId = nil
end


function GUISquadMarineHUD:Update(deltaTime)

    PROFILE("GUISquadMarineHUD:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    local player = Client.GetLocalPlayer()

    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
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
                    locationName = string.upper("Squad at " .. locationName)
                end
            end
        end

        -- dont show when we reached the target room already
        if currentLocationId == rallyPointLocationId then
            locationName = ""
        end

        local currentLocationTextGUIItem = script.locationText.guiItem
        if not currentLocationTextGUIItem then return end
        local currentLocationText = currentLocationTextGUIItem:GetText()
        local width = self.locationText:GetTextWidth(currentLocationText)
        self.locationText:SetPosition(GUIMarineHUD.kLocationTextOffset + Vector(width, 0, 0))

        self.locationText:SetText(locationName or "")
        self.locationText:SetColor(kSquadColors[squadNumber])

        self.lastRallyLocationId = rallyPointLocationId
        self.lastLocationId = currentLocationId
    end
end
