-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUISquadSelect.lua
--
-- Created by: Sebastian Schuck (sebastian@naturalselection2.com
--
-- Round Feedback UI to collect users feedback about the game after each play seesion or round.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIFeedbackState'

GUIFeedbackState.name = "GUIFeedbackState"

function GUIFeedbackState:Initialize(guiElement) end

function GUIFeedbackState:Update() end

function GUIFeedbackState:OnClick(mouseX, mouseY)
    return false
end

--
-- Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
--
function GUIFeedbackState:GetIsMouseOver(overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver

end


function GUIFeedbackState:UnInitialize() end



class 'GUIFeedbackState_Rating' (GUIFeedbackState)

GUIFeedbackState_Rating.name = "GUIFeedbackState_Rating"

function GUIFeedbackState_Rating:OnClick()

    if self.stars then
        for i = 1, #self.stars do

            local item = self.stars[i]
            if self:GetIsMouseOver(item.Button) then

                StartSoundEffect(self.kSounds.click)

                self.parent.rating = i
                self.parent:SetState(_G.GUIFeedbackState_End)

                return true
            end

        end
    end

    if self:GetIsMouseOver(self.close) then
        StartSoundEffect(self.kSounds.click)
        self.parent:Close()

        return true
    end

    return false

end

GUIFeedbackState_Rating.kSounds = {
    hovar = "sound/NS2.fev/common/hovar",
    click = "sound/NS2.fev/common/button_click"
}


function GUIFeedbackState_Rating:Initialize(guiElement)
    self.parent = guiElement

    self.mouseOverStates = { }

    self.parent.question:SetText(Locale.ResolveString("FEEDBACK_RATEROUND"))

    self.close = GUIManager:CreateGraphicItem()
    self.close:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.close:SetTexture(PrecacheAssetSafe("ui/menu/serverbrowser/close.dds"))
    self.close:SetSize(GUIScale(Vector(54 ,54 , 0)))
    self.close:SetPosition(GUIScale(Vector(-74 ,20 , 0)))
    self.close:SetColor(Color(0.92, 0.92, 0.92))

    self.parent.background:AddChild(self.close)

    self:InitializeStarButtons()
end


function GUIFeedbackState_Rating:Update()
    if self.stars then
        for i, star in ipairs(self.stars) do

            if self:GetIsMouseOver(star.Button) then

                if not star.over then
                    StartSoundEffect(self.kSounds.hovar)
                    star.over = true
                end

                for j = 1, i do
                    local item = self.stars[j]
                    item.Highlight:SetIsVisible(true)
                end
            else
                star.Highlight:SetIsVisible(false)
                star.over = false
            end

        end

        if self:GetIsMouseOver(self.close) then
            self.close:SetColor(Color(1, 1, 1))

            if not self.close.over then
                StartSoundEffect(self.kSounds.hovar)
                self.close.over = true
            end
        else
            self.close:SetColor(Color(0.92, 0.92, 0.92))
            self.close.over = false
        end
    end
end

GUIFeedbackState_Rating.kStarIcon = PrecacheAssetSafe("ui/feedback/star.dds")
GUIFeedbackState_Rating.kActiveStarIcon = PrecacheAssetSafe("ui/feedback/star_highlight.dds")
GUIFeedbackState_Rating.kStarIconSize = Vector(116, 110, 0)


function GUIFeedbackState_Rating:InitializeStarButtons()
    self.stars = {}

    for i = 1, 5 do
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIScale(self.kStarIconSize))
        graphicItem:SetPosition(GUIScale(Vector(50 + self.kStarIconSize.y * (i - 1),100, 0)))
        graphicItem:SetTexture(self.kStarIcon)

        self.parent.content:AddChild(graphicItem)

        local graphicItemActive = GUIManager:CreateGraphicItem()
        graphicItemActive:SetSize(GUIScale(self.kStarIconSize))
        graphicItemActive:SetTexture(self.kActiveStarIcon)
        graphicItemActive:SetIsVisible(false)

        graphicItem:AddChild(graphicItemActive)

        self.stars[i] = { Button = graphicItem, Highlight = graphicItemActive }
    end
end


function GUIFeedbackState_Rating:UnInitialize()
    if self.stars then
        for i = 1, 5 do
            GUI.DestroyItem(self.stars[i].Button)
            GUI.DestroyItem(self.stars[i].Highlight)
        end

        self.stars = nil
    end

    if self.close then
        GUI.DestroyItem(self.close)

        self.close = nil
    end
end


class 'GUIFeedbackState_End' (GUIFeedbackState)

GUIFeedbackState_End.name ="GUIFeedbackState_End"


function GUIFeedbackState_End:Initialize(guiElement)
    self.parent = guiElement

    self.closeTime = Shared.GetTime() + 2

    self.parent.question:SetText(Locale.ResolveString("FEEDBACK_THANKS"))

    self:InitializeStarButtons()

    Client.showFeedback = false
    Client.feedbackSend = true
end


function GUIFeedbackState_End:Update()
    if self.closeTime < Shared.GetTime() then
        self.parent:ResetState()
    end
end


GUIFeedbackState_End.kStarIcon = PrecacheAssetSafe("ui/feedback/star.dds")
GUIFeedbackState_End.kActiveStarIcon = PrecacheAssetSafe("ui/feedback/star_highlight.dds")
GUIFeedbackState_End.kStarIconSize = Vector(116, 110, 0)


function GUIFeedbackState_End:InitializeStarButtons()
    self.stars = {}

    local rating = self.parent.rating
    for i = 1, 5 do
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIScale(self.kStarIconSize))
        graphicItem:SetPosition(GUIScale(Vector(50 + self.kStarIconSize.y * (i - 1), 100, 0)))
        graphicItem:SetTexture(rating >= i and self.kActiveStarIcon or self.kStarIcon)

        self.parent.content:AddChild(graphicItem)

        self.stars[i] = graphicItem

    end
end


function GUIFeedbackState_End:UnInitialize()
    if self.stars then
        for i = 1, 5 do
            GUI.DestroyItem(self.stars[i])
        end
    end

    self.stars = nil
end



class 'GUISquadSelect' (GUIAnimatedScript)

GUISquadSelect.kFont = Fonts.kAgencyFB_Large_Bold

GUISquadSelect.kTextColor = kMarineFontColor
GUISquadSelect.kActiveTextColor = kAlienFontColor

GUISquadSelect.kBackgroundTexture = PrecacheAssetSafe("ui/feedback/background.dds")
GUISquadSelect.kFeedbackIconTexture = PrecacheAssetSafe("ui/feedback/feedback_icon.dds")

function GUISquadSelect:GetIsVisible()
    return self.isVisible
end


function GUISquadSelect:OnResolutionChanged(oldX, oldY, newX, newY)
    local visible = self:GetIsVisible()

    self:Uninitialize()
    self:Initialize()

    self:SetIsVisible(visible)
end


function GUISquadSelect:Initialize()

    GUIAnimatedScript.Initialize(self)

    self:_InitializeBackground()

    self:SetState(_G.GUIFeedbackState_Rating)

    self:SetIsVisible(false)
end


function GUISquadSelect:ResetState()
    self:SetIsVisible(false)

    self:SetState(_G.GUIFeedbackState_Rating)
end


function GUISquadSelect:Close()
    self.rating = -1

    self:SetState(_G.GUIFeedbackState_End)
    self:SetIsVisible(false)
end


function GUISquadSelect:SetIsVisible(visible)
    self.isVisible = visible

    self.background:SetIsVisible(visible)

    MouseTracker_SetIsVisible(visible)

    SetKeyEventBlocker(visible and self or nil)
end


function GUISquadSelect:SetState(state)
    if self.state == state then return end

    if self.state then
        self.state:UnInitialize(self)
    end

    self.state = state

    self.state:Initialize(self)
end


function GUISquadSelect:GetState()
    return self.state and self.state.parent.state --Todo: find out why this is needed
end


function GUISquadSelect:SendKeyEvent(key, down)

    local inputHandled = false

    if self.isVisible then

        if key == InputKey.MouseButton0 and self.mousePressed ~= down then

            self.mousePressed = down

            local state =  self:GetState()

            if down and state then
                inputHandled = state:OnClick()
            end
        end


        if key == InputKey.Escape and down then
            self:Close()
            inputHandled = true
        end

        -- No matter what, this menu consumes MouseButton0 clicks.
        if key == InputKey.MouseButton0 and down then
            inputHandled = true
        end

    end

    return inputHandled
end


function GUISquadSelect:Update(deltaTime)
    PROFILE("GUISquadSelect:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    if not self.isVisible then
        local player = Client.GetLocalPlayer()
        local gameInfo = GetGameInfoEntity()

        if gameInfo.isDedicated and not Client.feedbackSend and not self.shown
                and player:GetPlayTime() > 3 * 60 and (Client.showFeedback or gameInfo:GetState() >= kGameState.Started) then
            self:SetIsVisible(true)

            self.shown = true
        end
    else
        --Some mods may interfere with us
        if not MouseTracker_GetIsVisible() then
            MouseTracker_SetIsVisible(true)
        end

        if self:GetState() then
            self:GetState():Update()
        end
    end
end


function GUISquadSelect:Uninitialize()

    if self:GetIsVisible() then
        self:SetIsVisible(false)
    end

        GUIAnimatedScript.Uninitialize(self)

    local state = self:GetState()
    if state then
        state:UnInitialize()
    end

    self:_UninitializeBackground()
end


function GUISquadSelect:_InitializeBackground()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(GUIScale(Vector(762, 389, 0)))
    self.background:SetPosition(GUIScale(Vector(-381, -295, 0)))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetTexture(self.kBackgroundTexture)
    self.background:SetColor(Color(0.85, 0.85, 0.85, 0.85))
    self.background:SetLayer(kGUILayerMainMenuDialogs)

    self.feedbackicon = GUIManager:CreateGraphicItem()
    self.feedbackicon:SetSize(GUIScale(Vector(150, 129, 0)))
    self.feedbackicon:SetPosition(GUIScale(Vector(-40, -30, 0)))
    self.feedbackicon:SetTexture(self.kFeedbackIconTexture)
    self.background:AddChild(self.feedbackicon)

    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(GUIScale(Vector(662, 300, 0)))
    self.content:SetPosition(GUIScale(Vector(50,50, 0)))
    self.content:SetColor(Color(1,1,1,0))
    self.background:AddChild(self.content)

    self.question = GetGUIManager():CreateTextItem()
    self.question:SetFontName(GUISquadSelect.kFont)
    self.question:SetScale(GetScaledVector())
    GUIMakeFontScale(self.question)
    self.question:SetFontIsBold(true)
    self.question:SetPosition(GUIScale(Vector(0,30,0)))
    self.question:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.question:SetTextAlignmentX(GUIItem.Align_Center)
    self.question:SetTextAlignmentY(GUIItem.Align_Center)
    self.question:SetColor(GUISquadSelect.kTextColor)
    self.content:AddChild(self.question)

end


function GUISquadSelect:_UninitializeBackground()
    GUI.DestroyItem(self.background)
    self.background = nil
    self.content = nil
end
