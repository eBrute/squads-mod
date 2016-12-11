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

                local waitLevel = self.parent:GetWaitLevel()
                if waitLevel > 1 then
                    self.parent:SetWaitLevel(math.ceil(0.5 * waitLevel))
                end

                self.parent.rating = i
                if i > 2 then
                    self.parent:SetState(_G.GUIFeedbackState_End)
                else
                    self.parent:SetState(_G.GUIFeedbackState_Reason)
                end

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
        for i, item in ipairs(self.stars) do

            if self:GetIsMouseOver(item.Button) then

                if not item.over then
                    StartSoundEffect(self.kSounds.hovar)
                    item.over = true
                end

                for j = 1, i do
                    local item = self.stars[j]
                    item.Highlight:SetIsVisible(true)
                end
            else
                item.Highlight:SetIsVisible(false)
                item.over = false
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
        graphicItem:SetPosition(GUIScale(Vector(50 + (self.kStarIconSize.y) * (i - 1),100, 0)))
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

class 'GUIFeedbackState_Reason' (GUIFeedbackState)

GUIFeedbackState_Reason.name = "GUIFeedbackState_Reason"

GUIFeedbackState_Reason.Reasons = {
    {11, "FEEDBACK_REASON_11"}, -- bad_teamwork_2
    {12, "FEEDBACK_REASON_12"}, -- inexp_com_2
    {13, "FEEDBACK_REASON_13"}, -- i_sucked_2
    {14, "FEEDBACK_REASON_14"}, -- uneven_teams_2
    {15, "FEEDBACK_REASON_15"}, -- not_fun_2
    {16, "FEEDBACK_REASON_16"}, -- other_reason_2
}

local function ShuffleSkipLast( tmp )
    for i = #tmp - 1, 2, -1 do
        local j = math.random( i )
        tmp[ i ], tmp[ j ] = tmp[ j ], tmp[ i ]
    end
end

GUIFeedbackState_Reason.reassonColor = Color(1, 1, 1, 0)
GUIFeedbackState_Reason.reassonActiveColor = Color(1, 1, 1, 1)

GUIFeedbackState_Reason.kTextColor = Color(kMarineFontColor)
GUIFeedbackState_Reason.kActiveTextColor = kAlienFontColor

function GUIFeedbackState_Reason:Initialize(guiElement)
    self.parent = guiElement

    self.mouseOverStates = {}

    self.parent.background:SetSize(GUIScale(Vector(762, 725, 0)))
    self.parent.content:SetSize(GUIScale(Vector(662, 650, 0)))
    self.parent.reasons = {}

    self.parent.question:SetText(Locale.ResolveString("FEEDBACK_REASSON"))

    self.reasonButtons = {}

    ShuffleSkipLast(self.Reasons) -- keeps "other reason" at bottom

    local yOffset = GUIScale(70)
    for i, data in ipairs(self.Reasons) do
        local text = data[2]
        local i = data[1]

        local buttonData = self:CreateButton(yOffset, text, i)
        self.reasonButtons[#self.reasonButtons + 1] = buttonData

        yOffset = yOffset + buttonData.height + GUIScale(10)
    end

end

function GUIFeedbackState_Reason:CreateButton(topOffset, text, id)
    local buttonBackground = GUIManager:CreateGraphicItem()
    buttonBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.parent.content:AddChild(buttonBackground)

    local buttontext = GetGUIManager():CreateTextItem()
    buttontext:SetFontName(GUISquadSelect.kFont)
    buttontext:SetColor(GUISquadSelect.kTextColor)

    text = Locale.ResolveString(text)
    buttontext:SetText(text)
    buttontext:SetScale(GetScaledVector())
    GUIMakeFontScale(buttontext)

    local width = buttontext:GetTextWidth(text) * GetScaledVector().x
    local height = buttontext:GetTextHeight(text) * GetScaledVector().y

    buttonBackground:SetSize(Vector(width, height, 0))
    buttonBackground:SetPosition(Vector(-width/2, topOffset, 0))
    buttonBackground:SetColor(self.reassonColor)
    buttonBackground:AddChild(buttontext)

    return { button = buttonBackground, buttontext = buttontext , id = id, height = height, clicked = false}
end

GUIFeedbackState_Reason.kSounds = {
    invalid =  "sound/NS2.fev/common/invalid",
    on = "sound/NS2.fev/common/checkbox_on",
    off =  "sound/NS2.fev/common/checkbox_off",
    hovar = "sound/NS2.fev/common/hovar",
    click = "sound/NS2.fev/common/button_click"
}
for _, soundAsset in pairs(GUIFeedbackState_Reason.kSounds) do
    Client.PrecacheLocalSound(soundAsset)
end


function GUIFeedbackState_Reason:Update()
    if self.reasonButtons then
        for _, item in ipairs(self.reasonButtons) do

            if self:GetIsMouseOver(item.button) then
                item.buttontext:SetColor(item.active and self.kTextColor or self.kActiveTextColor)
                if not item.over then
                    StartSoundEffect(self.kSounds.hovar)
                    item.over = true
                end
            else
                item.buttontext:SetColor(self.kTextColor)
                item.over = false
            end

        end
    end
end

function GUIFeedbackState_Reason:OnClick()

    if self.reasonButtons then
        for  _, item in ipairs(self.reasonButtons) do
            if self:GetIsMouseOver(item.button) then

                StartSoundEffect(self.kSounds.click)
                item.buttontext:SetColor(item.active and self.kActiveTextColor or self.kTextColor)

                table.insert(self.parent.reasons, item.id)
                self.parent:SetState(_G.GUIFeedbackState_End)

                return true
            end

        end
    end

    return false

end

function GUIFeedbackState_Reason:UnInitialize()
    for _, data in ipairs(self.reasonButtons) do
        GUI.DestroyItem(data.button)
    end
    self.reasonButtons = nil

    self.parent.background:SetSize(GUIScale(Vector(762, 389, 0)))
    self.parent.content:SetSize(GUIScale(Vector(662, 300, 0)))

end

class 'GUIFeedbackState_End' (GUIFeedbackState)

GUIFeedbackState_End.name ="GUIFeedbackState_End"

function GUIFeedbackState_End:Initialize(guiElement)
    self.parent = guiElement

    self.closeTime = Shared.GetTime() + 2

    self.parent.question:SetText(Locale.ResolveString("FEEDBACK_THANKS"))

    self:InitializeStarButtons()

    self:SendReport()
end

function GUIFeedbackState_End:Update()
    if self.closeTime < Shared.GetTime() then
        self.parent:ResetState()
    end
end

local function GetTeamSkills()
    local averagePlayerSkills = {
        [kMarineTeamType] = {},
        [kAlienTeamType] = {},
        [3] = {},
    }

    for _, player in ipairs(GetEntitiesWithMixin("Scoring")) do

        local skill = player:GetPlayerSkill() and math.max(player:GetPlayerSkill(), 0)
        -- DebugPrint("%s skill: %s", ToString(player:GetName()), ToString(skill))

        if skill then

            local teamType = HasMixin(player, "Team") and player:GetTeamType() or -1
            if teamType == kMarineTeamType or teamType == kAlienTeamType then
                table.insert(averagePlayerSkills[teamType], skill)
            end

            table.insert(averagePlayerSkills[3], skill)

        end

    end

    averagePlayerSkills[kMarineTeamType].mean = table.mean(averagePlayerSkills[kMarineTeamType])
    averagePlayerSkills[kAlienTeamType].mean = table.mean(averagePlayerSkills[kAlienTeamType])
    averagePlayerSkills[3].mean = table.mean(averagePlayerSkills[3])

    averagePlayerSkills[kMarineTeamType].median = table.median(averagePlayerSkills[kMarineTeamType])
    averagePlayerSkills[kAlienTeamType].median = table.median(averagePlayerSkills[kAlienTeamType])
    averagePlayerSkills[3].median = table.median(averagePlayerSkills[3])

    averagePlayerSkills[kMarineTeamType].standardDeviation = table.standardDeviation(averagePlayerSkills[kMarineTeamType])
    averagePlayerSkills[kAlienTeamType].standardDeviation = table.standardDeviation(averagePlayerSkills[kAlienTeamType])
    averagePlayerSkills[3].standardDeviation = table.standardDeviation(averagePlayerSkills[3])

    return averagePlayerSkills
end

function GUIFeedbackState_End:SendReport()
    local rating = self.parent.rating -- int, 1 to 5
    local reasons = self.parent.reasons

    local player = Client.GetLocalPlayer()
    local gameInfo = GetGameInfoEntity()

    local playerSkills = gameInfo.prevTeamsSkills or GetTeamSkills() --table with floats
    local playerSkill = player:GetPlayerSkill()
    local playerLevel = player:GetPlayerLevel()

    local marineCount = #playerSkills[kMarineTeamType] --int
    local alienCount = #playerSkills[kAlienTeamType] --int

    local gameEnded = Client.showFeedback or gameInfo:GetGameEnded() --boolean
    local winner = gameInfo.prevWinner or 0 -- int, refers to kTeamTypes
    local gameTime = PlayerUI_GetGameLengthTime() --int

    local steamid = Client.GetSteamId() --int
    local playtime = player:GetPlayTime()

    local servername = Client.GetConnectedServerName() --string
    local serverip = gameInfo.serverIp --string
    local serverport = gameInfo.serverPort --string

    local mapname = Shared.GetMapName() --string
    local gamemode = GetGamemode and GetGamemode() or "unknown" --string

    local playerteam = player:GetLastTeam() --int

    local data =
    {
        server = {
            ip = serverip,
            port = serverport,
            name = servername
        },
        player = {
            steamid = steamid,
            skill = playerSkill,
            level = playerLevel,
            team = playerteam,
            play_time = playtime
        },
        round = {
            map = mapname,
            gamemode = gamemode,
            ended = gameEnded,
            winner = winner,
            length = gameTime,
            marines = {
                count = marineCount,
                skill = playerSkills[kMarineTeamType].median,
                standardDeviation = playerSkills[kMarineTeamType].standardDeviation
            },
            aliens = {
                count = alienCount,
                skill = playerSkills[kAlienTeamType].median,
                standardDeviation = playerSkills[kAlienTeamType].standardDeviation
            }
        },
        feedback = {
            rating = rating,
            reasons = reasons
        }
    }

    Analytics.RecordFeedback( data )

    --flag player to have send the report for this round
    Client.showFeedback = false
    Client.feedbackSend = true
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
        graphicItem:SetPosition(GUIScale(Vector(50 + (self.kStarIconSize.y) * (i - 1), 100, 0)))
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


    self:SetWaitLevel(Client.GetOptionInteger("feedback/wait_level", 1))
    self:SetWaitTime(Client.GetOptionInteger("feedback/wait_time", 0))

    self:SetState(_G.GUIFeedbackState_Rating)

    self:SetIsVisible(false)
end

function GUISquadSelect:ResetState()
    self:SetIsVisible(false)

    self:SetState(_G.GUIFeedbackState_Rating)
end

function GUISquadSelect:Close()
    self.rating = -1

    local waitLevel = self:GetWaitLevel()
    self:SetWaitLevel(waitLevel + 1)

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

GUISquadSelect.kMinPlayTime =  3 * 60 --3 minutes

function GUISquadSelect:Update(deltaTime)
    PROFILE("GUISquadSelect:Update")

    GUIAnimatedScript.Update(self, deltaTime)

    if not self.isVisible then
        local player = Client.GetLocalPlayer()
        local gameInfo = GetGameInfoEntity()

        if gameInfo.isDedicated and not Client.feedbackSend and not self.shown
                and ClientUI.GetScript("GUIGameEnd") and not ClientUI.GetScript("GUIGameEnd"):GetIsVisible()
                and player:GetPlayTime() > self.kMinPlayTime and (Client.showFeedback or gameInfo:GetState() >= kGameState.Started) then
            if self:GetWaitTime() == 0 then
                self:SetIsVisible(true)
            else
                self:SetWaitTime(self:GetWaitTime() - 1)
                self.rating = -1
                self:SetState(_G.GUIFeedbackState_End)
            end

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

function GUISquadSelect:SetWaitLevel(level)
    self.waitLevel = level

    self:ResetWaitTime()
end

function GUISquadSelect:SetWaitTime(time)
    self.waitTime = time
end

function GUISquadSelect:GetWaitLevel()
    return self.waitLevel
end

function GUISquadSelect:GetWaitTime(time)
    if self.waitTime < 0 then
        self:ResetWaitTime()
    end

    return self.waitTime
end

function GUISquadSelect:ResetWaitTime()
    local level = self:GetWaitLevel()

    self.waitTime = level * level - level
end


function GUISquadSelect:Uninitialize()

    if self:GetIsVisible() then
        self:SetIsVisible(false)
    end

    Client.SetOptionInteger("feedback/wait_level", self:GetWaitLevel())
    Client.SetOptionInteger("feedback/wait_time", self:GetWaitTime())

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
