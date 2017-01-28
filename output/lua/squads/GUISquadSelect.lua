Script.Load("lua/Globals.lua")

class 'GUISquadSelect' (GUIScript)

GUISquadSelect.kSquadNameFont = Fonts.kAgencyFB_Large_Bold
GUISquadSelect.kSquadPlayerFont = Fonts.kKartika_Medium
GUISquadSelect.kSquadActiveBackgrounds = {}
GUISquadSelect.kSquadInactiveBackgrounds = {}
for i, texture in pairs(kSquadMenuBackgroundTextures) do
    if texture and type(texture[1]) == "string" and not GUISquadSelect.kSquadActiveBackgrounds[i] then
        GUISquadSelect.kSquadActiveBackgrounds[i] = PrecacheAssetSafe(texture[1])
    end
    if texture and type(texture[2]) == "string" and not GUISquadSelect.kSquadInactiveBackgrounds[i] then
        GUISquadSelect.kSquadInactiveBackgrounds[i] = PrecacheAssetSafe(texture[2])
    end
end
GUISquadSelect.kSounds = {
    hovar = "sound/NS2.fev/common/hovar",
    click = "sound/NS2.fev/common/button_click"
}
for _, soundAsset in pairs(GUIFeedbackState_Reason.kSounds) do
    Client.PrecacheLocalSound(soundAsset)
end


local function ScaledCoords(x, y)
    return Vector( GUIScaleWidth(x), GUIScaleHeight(y), 0)
end


function GUISquadSelect:Initialize()
    GUIAnimatedScript.Initialize(self)
    self:_InitializeBackground()
    self:SetIsVisible(false)
end


function GUISquadSelect:GetIsVisible()
    return self.isVisible
end


function GUISquadSelect:SetIsVisible(visible)
    self.isVisible = visible
    for i = 1, #kSquadType do
        self.SquadRegions[i].background:SetIsVisible(visible) -- children inherit setting
    end
    MouseTracker_SetIsVisible(visible)
    SetKeyEventBlocker(visible and self or nil)
end


function GUISquadSelect:Close()
    self:SetIsVisible(false)
end


function GUISquadSelect:OnClick()
    for squad = 1 , #self.SquadRegions do
        local region = self.SquadRegions[squad]
        local mouseOver = GUIItemContainsPoint(region.background, Client.GetCursorPosScreen())
        if (mouseOver) then
            StartSoundEffect(GUISquadSelect.kSounds.click)
            local player = Client.GetLocalPlayer()
            if HasMixin(player, "SquadMember") then
                local currentSquadNumber = player:GetSquadNumber()
                if currentSquadNumber ~= squad then
                    Client.SendNetworkMessage("SelectSquad", {squadNumber = squad}, true)
                end
            end
            self:Close()
            return true
        end
    end
    return false
end


function GUISquadSelect:SendKeyEvent(key, down)
    local inputHandled = false
    if self.isVisible then
        if key == InputKey.MouseButton0 then
            if down then
                self:OnClick()
            end
            inputHandled = true -- No matter what, this menu consumes MouseButton0 clicks.
        end

        if key == InputKey.Escape and down then
            self:Close()
            inputHandled = true
        end
    end

    return inputHandled
end


function GUISquadSelect:OnResolutionChanged(oldX, oldY, newX, newY)
    local visible = self:GetIsVisible()

    self:Uninitialize()
    self:Initialize()

    self:SetIsVisible(visible)
end


function GUISquadSelect:Uninitialize()
    if self:GetIsVisible() then
        self:SetIsVisible(false)
    end

    self:_UninitializeBackground()
end


function GetSquadMaxPlayerSlots(squad)
    return  ConditionalValue(squad == kSquadType.Unassigned, 30, kMaxSquadsMembersPerSquad)
end


function GUISquadSelect:Update(deltaTime)
    PROFILE("GUISquadSelect:Update")

    local player = Client.GetLocalPlayer()
    local teamNumber = player:GetTeamNumber()
    -- local gameInfo = GetGameInfoEntity()

    if self.isVisible then
        local players = GetScoreData({ teamNumber })

        for squad = 1 , #self.SquadRegions do

            local region = self.SquadRegions[squad]
            local mouseOver = GUIItemContainsPoint(region.background, Client.GetCursorPosScreen())
            if (mouseOver) then
                if mouseOver ~= region.mouseOverState then
                    StartSoundEffect(GUISquadSelect.kSounds.hovar)
                    region.background:SetTexture( self.kSquadActiveBackgrounds[squad] )
                end

                for p = 1, GetSquadMaxPlayerSlots(squad) do
                    region.players[p]:SetColor( kSquadMenuPlayerColors[squad] )
                end

                region.mouseOverState = true
            else
                if mouseOver ~= region.mouseOverState then
                    region.background:SetTexture( self.kSquadInactiveBackgrounds[squad] )
                end

                for p = 1, GetSquadMaxPlayerSlots(squad) do
                    region.players[p]:SetColor( kSquadMenuPlayerColors[0] )
                end

                region.mouseOverState = false
            end

            -- add all playerslots in reverse order
            local unusedPlayerSlots = {}
            for i = #region.players, 1, -1 do
                table.insert(unusedPlayerSlots, region.players[i])
            end

            -- add all players of this squad
            for p = 1, #players do
                -- Log("name %s, team %s, squad %s", players[p].Name, players[p].EntityTeamNumber, players[p].SquadNumber )
                if players[p].EntityTeamNumber == teamNumber and players[p].SquadNumber == squad and #unusedPlayerSlots > 0 then
                    unusedPlayerSlots[#unusedPlayerSlots]:SetText(players[p].Name)
                    -- IsCommander
                    -- IsSteamFriend
                    table.remove(unusedPlayerSlots)
                end
            end

            -- remove unused players from list
            for i = 1, #unusedPlayerSlots do
                unusedPlayerSlots[i]:SetText('')
            end
        end

        if not MouseTracker_GetIsVisible() then
            MouseTracker_SetIsVisible(true)
        end
    end
end


function GUISquadSelect:_InitializeBackground()

    local margin = {top = 42, bottom = 42, left = 42, right = 42}
    local gap = 20
    local numColumns = math.ceil( (#kSquadType + 1) / 2)  -- for 2 rows
    local columnWidth = (1920 - margin.left - margin.right - (numColumns-1) * gap) / numColumns -- margin + col + gap + ... + col + gap + col + margin = 1920
    local fullHeight =   1080 - margin.top - margin.bottom
    local halfHeight =  (1080 - margin.top - margin.bottom - gap) / 2
    -- Log("colWidth:%s, halfHeight:%s, fullHeight:%s", columnWidth, halfHeight, fullHeight)

    local squadNamePosition = {top = 40, left = 26}
    local contentMargin = {top = 72, bottom = 26, left = 26, right = 28}

    self.SquadRegions = {}
    for i = 1, #kSquadType do
        local row = ConditionalValue(i <= (#kSquadType+1) / 2, 0, 1)
        local col = ConditionalValue(row == 0, i-1, i-1-((#kSquadType-1) / 2))
        local xOffset = margin.left + col * (columnWidth + gap)
        local yOffset = margin.top + row * (halfHeight + gap)

        self.SquadRegions[i] = {}
        self.SquadRegions[i].mouseOverState = false

        self.SquadRegions[i].background = GUIManager:CreateGraphicItem()
        self.SquadRegions[i].background:SetLayer( kGUILayerMainMenuDialogs )
        self.SquadRegions[i].background:SetAnchor( GUIItem.Left, GUIItem.Top )
        self.SquadRegions[i].background:SetPosition( ScaledCoords(xOffset, yOffset) )
        self.SquadRegions[i].background:SetSize( ScaledCoords( columnWidth, ConditionalValue(i==kSquadType.Unassigned, fullHeight, halfHeight)) )
        self.SquadRegions[i].background:SetTexture( self.kSquadInactiveBackgrounds[i] )

        self.SquadRegions[i].name = GetGUIManager():CreateTextItem()
        self.SquadRegions[i].name:SetLayer( kGUILayerMainMenuDialogs )
        self.SquadRegions[i].name:SetFontName( GUISquadSelect.kSquadNameFont )
        self.SquadRegions[i].name:SetScale( GetScaledVector() )
        GUIMakeFontScale(self.SquadRegions[i].name)
        self.SquadRegions[i].name:SetFontIsBold( true )
        self.SquadRegions[i].name:SetPosition( ScaledCoords(squadNamePosition.left,squadNamePosition.top) )
        self.SquadRegions[i].name:SetAnchor( GUIItem.Left, GUIItem.Top )
        self.SquadRegions[i].name:SetTextAlignmentX( GUIItem.Align_Min )
        self.SquadRegions[i].name:SetTextAlignmentY( GUIItem.Align_Center )
        self.SquadRegions[i].name:SetColor( kSquadColors[i] )
        self.SquadRegions[i].name:SetText( kSquadNames[i] )
        self.SquadRegions[i].name:SetInheritsParentAlpha( false )
        self.SquadRegions[i].background:AddChild( self.SquadRegions[i].name )

        self.SquadRegions[i].content = GUIManager:CreateGraphicItem()
        self.SquadRegions[i].content:SetLayer( kGUILayerMainMenuDialogs )
        self.SquadRegions[i].content:SetAnchor( GUIItem.Left, GUIItem.Top)
        self.SquadRegions[i].content:SetPosition( ScaledCoords(contentMargin.left, contentMargin.top))
        self.SquadRegions[i].content:SetSize( ScaledCoords(columnWidth - contentMargin.left - contentMargin.right, ConditionalValue(i==kSquadType.Unassigned, fullHeight, halfHeight) - contentMargin.top - contentMargin.bottom) )
        self.SquadRegions[i].content:SetColor(Color(1,1,1,0))
        self.SquadRegions[i].content:SetInheritsParentAlpha( false )
        self.SquadRegions[i].background:AddChild( self.SquadRegions[i].content )

        self.SquadRegions[i].players = {}
        for j = 1, GetSquadMaxPlayerSlots(i) do
            self.SquadRegions[i].players[j] = GetGUIManager():CreateTextItem()
            self.SquadRegions[i].players[j]:SetLayer( kGUILayerMainMenuDialogs )
            self.SquadRegions[i].players[j]:SetFontName( GUISquadSelect.kSquadPlayerFont )
            self.SquadRegions[i].players[j]:SetScale( GetScaledVector() )
            GUIMakeFontScale(self.SquadRegions[i].players[j])
            self.SquadRegions[i].players[j]:SetFontIsBold( true )
            self.SquadRegions[i].players[j]:SetPosition( ScaledCoords(10,(j-1)*30) )
            self.SquadRegions[i].players[j]:SetAnchor( GUIItem.Left, GUIItem.Top )
            self.SquadRegions[i].players[j]:SetTextAlignmentX( GUIItem.Align_Min )
            self.SquadRegions[i].players[j]:SetTextAlignmentY( GUIItem.Align_Min )
            self.SquadRegions[i].players[j]:SetColor( kSquadMenuPlayerColors[0] )
            self.SquadRegions[i].players[j]:SetInheritsParentAlpha( false )
            self.SquadRegions[i].content:AddChild( self.SquadRegions[i].players[j] )
        end

        -- Log("x:%s y:%s, colWidth:%s, halfHeight:%s, fullHeight:%s", xOffset, yOffset, columnWidth, halfHeight, fullHeight)
        -- Log("ScreenPosition: %s", self.SquadRegions[i]:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight()))
        -- Log("ScaledSize: %s",self.SquadRegions[i]:GetScaledSize())
    end

end


function GUISquadSelect:_UninitializeBackground()
    for i = 1, #kSquadType do
        for j = 1, GetSquadMaxPlayerSlots(i) do
            GUI.DestroyItem(self.SquadRegions[i].players[j])
        end
        GUI.DestroyItem(self.SquadRegions[i].name)
        GUI.DestroyItem(self.SquadRegions[i].content)
        GUI.DestroyItem(self.SquadRegions[i].background)
    end
end
