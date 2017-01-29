Script.Load("lua/Globals.lua")

class 'GUISquadSelect' (GUIScript)

GUISquadSelect.kSquadNameFont = Fonts.kAgencyFB_Large_Bold
GUISquadSelect.kSquadPlayerFont = Fonts.kKartika_Medium
GUISquadSelect.kSquadArrow = PrecacheAssetSafe("ui/squads/arrow.dds")
GUISquadSelect.kSquadFriends = PrecacheAssetSafe("ui/squads/friends.dds")
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
    self.isVisible = false
    self.screen:SetIsVisible(false) -- children inherit setting
end


function GUISquadSelect:GetIsVisible()
    return self.isVisible
end


function GUISquadSelect:SetIsVisible(visible)
    self.isVisible = visible
    self.screen:SetIsVisible(visible) -- children inherit setting
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
                    region.playerSlots[p].playerName:SetColor( kSquadMenuPlayerColors[squad] )
                end

                region.mouseOverState = true
            else
                if mouseOver ~= region.mouseOverState then
                    region.background:SetTexture( self.kSquadInactiveBackgrounds[squad] )
                end

                for p = 1, GetSquadMaxPlayerSlots(squad) do
                    region.playerSlots[p].playerName:SetColor( kSquadMenuPlayerColors[0] )
                end

                region.mouseOverState = false
            end

            -- add all playerslots in reverse order
            local unusedPlayerSlots = {}
            for i = #region.playerSlots, 1, -1 do
                table.insert(unusedPlayerSlots, region.playerSlots[i])
            end

            -- add all players of this squad
            for p = 1, #players do
                if players[p].EntityTeamNumber == teamNumber and players[p].SquadNumber == squad and #unusedPlayerSlots > 0 then

                    local playerSlot = unusedPlayerSlots[#unusedPlayerSlots]
                    local slotUsed = true

                    if players[p].SteamId == Client.GetSteamId() then
                        playerSlot.playerIcon:SetIsVisible(true)
                        playerSlot.playerIcon:SetTexture(GUISquadSelect.kSquadArrow)
                    elseif players[p].IsCommander then
                        slotUsed = false
                    elseif players[p].IsSteamFriend then
                        playerSlot.playerIcon:SetIsVisible(true)
                        playerSlot.playerIcon:SetTexture(GUISquadSelect.kSquadFriends)
                    else
                        playerSlot.playerIcon:SetIsVisible(false)
                    end

                    if slotUsed then
                        playerSlot.playerName:SetText(players[p].Name)
                        table.remove(unusedPlayerSlots)
                    end
                end
            end

            -- remove unused players from list
            for i = 1, #unusedPlayerSlots do
                unusedPlayerSlots[i].playerName:SetText('')
                unusedPlayerSlots[i].playerIcon:SetIsVisible(false)
            end
        end

        -- restore mouse if some other mod/gui decided to remove it
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

    local squadNamePosition = {top = 40, left = 26}
    local contentMargin = {top = 72, bottom = 22, left = 16, right = 16}

    self.screen = GUIManager:CreateGraphicItem()
    self.screen:SetLayer( kGUILayerMainMenuDialogs )
    self.screen:SetAnchor( GUIItem.Left, GUIItem.Top )
    self.screen:SetPosition( ScaledCoords(0, 0) )
    self.screen:SetSize( ScaledCoords(1920, 1080) )
    self.screen:SetColor( Color(0,0,0,0.8) )

    self.SquadRegions = {}
    for i = 1, #kSquadType do
        local row = ConditionalValue(i <= (#kSquadType+1) / 2, 0, 1)
        local col = ConditionalValue(row == 0, i-1, i-1-((#kSquadType-1) / 2))
        local xOffset = margin.left + col * (columnWidth + gap)
        local yOffset = margin.top + row * (halfHeight + gap)

        local squadRegion = {}
        squadRegion.mouseOverState = false

        squadRegion.background = GUIManager:CreateGraphicItem()
        squadRegion.background:SetLayer( kGUILayerMainMenuDialogs )
        squadRegion.background:SetAnchor( GUIItem.Left, GUIItem.Top )
        squadRegion.background:SetPosition( ScaledCoords(xOffset, yOffset) )
        squadRegion.background:SetSize( ScaledCoords( columnWidth, ConditionalValue(i==kSquadType.Unassigned, fullHeight, halfHeight)) )
        squadRegion.background:SetTexture( self.kSquadInactiveBackgrounds[i] )
        squadRegion.background:SetInheritsParentAlpha( true )
        self.screen:AddChild( squadRegion.background )

        squadRegion.squadName = GetGUIManager():CreateTextItem()
        squadRegion.squadName:SetLayer( kGUILayerMainMenuDialogs )
        squadRegion.squadName:SetFontName( GUISquadSelect.kSquadNameFont )
        squadRegion.squadName:SetScale( GetScaledVector() )
        GUIMakeFontScale(squadRegion.squadName)
        squadRegion.squadName:SetFontIsBold( true )
        squadRegion.squadName:SetPosition( ScaledCoords(squadNamePosition.left,squadNamePosition.top) )
        squadRegion.squadName:SetAnchor( GUIItem.Left, GUIItem.Top )
        squadRegion.squadName:SetTextAlignmentX( GUIItem.Align_Min )
        squadRegion.squadName:SetTextAlignmentY( GUIItem.Align_Center )
        squadRegion.squadName:SetColor( kSquadColors[i] )
        squadRegion.squadName:SetText( kSquadNames[i] )
        squadRegion.squadName:SetInheritsParentAlpha( false )
        squadRegion.background:AddChild( squadRegion.squadName )

        squadRegion.content = GUIManager:CreateGraphicItem()
        squadRegion.content:SetLayer( kGUILayerMainMenuDialogs )
        squadRegion.content:SetAnchor( GUIItem.Left, GUIItem.Top)
        squadRegion.content:SetPosition( ScaledCoords(contentMargin.left, contentMargin.top))
        squadRegion.content:SetSize( ScaledCoords(columnWidth - contentMargin.left - contentMargin.right, ConditionalValue(i==kSquadType.Unassigned, fullHeight, halfHeight) - contentMargin.top - contentMargin.bottom) )
        squadRegion.content:SetColor(Color(1,1,1,0))
        squadRegion.content:SetInheritsParentAlpha( false )
        squadRegion.background:AddChild( squadRegion.content )

        squadRegion.playerSlots = {}
        for j = 1, GetSquadMaxPlayerSlots(i) do
            squadRegion.playerSlots[j] = {}

            local playerSlot = {}

            playerSlot.content = GetGUIManager():CreateGraphicItem()
            playerSlot.content:SetLayer( kGUILayerMainMenuDialogs )
            playerSlot.content:SetAnchor( GUIItem.Left, GUIItem.Top)
            playerSlot.content:SetPosition( ScaledCoords(0, (j-1)*30))
            playerSlot.content:SetSize( ScaledCoords(columnWidth - contentMargin.left - contentMargin.right, 28) )
            playerSlot.content:SetColor(Color(1,1,1,0))
            playerSlot.content:SetInheritsParentAlpha( false )
            squadRegion.content:AddChild( playerSlot.content )

            playerSlot.playerIcon = GetGUIManager():CreateGraphicItem()
            playerSlot.playerIcon:SetLayer( kGUILayerMainMenuDialogs )
            playerSlot.playerIcon:SetAnchor( GUIItem.Left, GUIItem.Center)
            playerSlot.playerIcon:SetPosition( ScaledCoords(0, -14))
            playerSlot.playerIcon:SetSize( ScaledCoords(28, 28) )
            playerSlot.playerIcon:SetIsVisible( false )
            playerSlot.playerIcon:SetInheritsParentAlpha( false )
            playerSlot.content:AddChild( playerSlot.playerIcon )

            playerSlot.playerName = GetGUIManager():CreateTextItem()
            playerSlot.playerName:SetLayer( kGUILayerMainMenuDialogs )
            playerSlot.playerName:SetFontName( GUISquadSelect.kSquadPlayerFont )
            playerSlot.playerName:SetScale( GetScaledVector() )
            GUIMakeFontScale(playerSlot.playerName)
            playerSlot.playerName:SetFontIsBold( true )
            playerSlot.playerName:SetAnchor( GUIItem.Left, GUIItem.Center )
            playerSlot.playerName:SetPosition( ScaledCoords(32,0) )
            playerSlot.playerName:SetTextAlignmentX( GUIItem.Align_Min )
            playerSlot.playerName:SetTextAlignmentY( GUIItem.Align_Center )
            playerSlot.playerName:SetTextClipped(true, playerSlot.content:GetSize().x - GUIScaleWidth(64), 40) -- these numbers kind of work, no idea why
            playerSlot.playerName:SetColor( kSquadMenuPlayerColors[0] )
            playerSlot.playerName:SetInheritsParentAlpha( false )
            playerSlot.content:AddChild( playerSlot.playerName )

            squadRegion.playerSlots[j] = playerSlot
        end

        self.SquadRegions[i] = squadRegion
    end

end


function GUISquadSelect:_UninitializeBackground()
    for i = 1, #kSquadType do
        for j = 1, GetSquadMaxPlayerSlots(i) do
            GUI.DestroyItem(self.SquadRegions[i].playerSlots[j].playerIcon)
            GUI.DestroyItem(self.SquadRegions[i].playerSlots[j].playerName)
            GUI.DestroyItem(self.SquadRegions[i].playerSlots[j].content)
        end
        GUI.DestroyItem(self.SquadRegions[i].squadName)
        GUI.DestroyItem(self.SquadRegions[i].content)
        GUI.DestroyItem(self.SquadRegions[i].background)
    end
    GUI.DestroyItem(self.screen)
end
