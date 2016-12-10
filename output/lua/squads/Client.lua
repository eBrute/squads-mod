
Event.Hook("LoadComplete", function()
function GUIScoreboard:SendKeyEvent(key, down)

    if ChatUI_EnteringChatMessage() then
        return false
    end

    if GetIsBinding(key, "Scoreboard") then
        self.visible = down
        if not down then
            self.hoverMenu:Hide()
        else
            self.updateInterval = 0
        end
    end

    if not self.visible then
        return false
    end

    if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down and down and not MainMenu_GetIsOpened() then
        HandlePlayerTextClicked(self)

        local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex) or 0
        if self.hoverMenu.background:GetIsVisible() then
            return false
        -- Display the menu for bots if dev mode is on (steamId is 0 but they have a proper clientIndex)
        elseif steamId ~= 0 or self.hoverPlayerClientIndex ~= 0 and Shared.GetDevMode() then
            local isTextMuted = ChatUI_GetSteamIdTextMuted(steamId)
            local isVoiceMuted = ChatUI_GetClientMuted(self.hoverPlayerClientIndex)
            local function openSteamProf()
                Client.ShowWebpage(string.format("%s[U:1:%s]", kSteamProfileURL, steamId))
            end
            local function openHiveProf()
                Client.ShowWebpage(string.format("%s%s", kHiveProfileURL, steamId))
            end
            local function muteText()
                ChatUI_SetSteamIdTextMuted(steamId, not isTextMuted)
            end
            local function muteVoice()
                ChatUI_SetClientMuted(self.hoverPlayerClientIndex, not isVoiceMuted)
            end

            self.hoverMenu:ResetButtons()

            local teamColorBg
            local teamColorHighlight
            local playerName = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "Name")
            local teamNumber = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "EntityTeamNumber")
            local isCommander = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "IsCommander") and GetIsVisibleTeam(teamNumber)

            local textColor = Color(1, 1, 1, 1)
            local nameBgColor = Color(0, 0, 0, 0)

            if isCommander then
                teamColorBg = GUIScoreboard.kCommanderFontColor
            elseif teamNumber == 1 then
                teamColorBg = GUIScoreboard.kBlueColor
            elseif teamNumber == 2 then
                teamColorBg = GUIScoreboard.kRedColor
            else
                teamColorBg = GUIScoreboard.kSpectatorColor
            end

            local bgColor = teamColorBg * 0.1
            bgColor.a = 0.9

            teamColorHighlight = teamColorBg * 0.75
            teamColorBg = teamColorBg * 0.5

            self.hoverMenu:SetBackgroundColor(bgColor)
            self.hoverMenu:AddButton(playerName, nameBgColor, nameBgColor, textColor)
            --self.hoverMenu:AddButton(Locale.ResolveString("SB_MENU_STEAM_PROFILE"), teamColorBg, teamColorHighlight, textColor, openSteamProf)
            --self.hoverMenu:AddButton(Locale.ResolveString("SB_MENU_HIVE_PROFILE"), teamColorBg, teamColorHighlight, textColor, openHiveProf)

            if Client.GetSteamId() ~= steamId then
                self.hoverMenu:AddSeparator("muteOptions")
                self.hoverMenu:AddButton(ConditionalValue(isVoiceMuted, Locale.ResolveString("SB_MENU_UNMUTE_VOICE"), Locale.ResolveString("SB_MENU_MUTE_VOICE")), teamColorBg, teamColorHighlight, textColor, muteVoice)
                self.hoverMenu:AddButton(ConditionalValue(isTextMuted, Locale.ResolveString("SB_MENU_UNMUTE_TEXT"), Locale.ResolveString("SB_MENU_MUTE_TEXT")), teamColorBg, teamColorHighlight, textColor, muteText)
            end

            self.hoverMenu:Show()
            self.badgeNameTooltip:Hide(0)
        end
    end

    if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down then

        self.mousePressed["LMB"]["Down"] = down
        if down then
            local mouseX, mouseY = Client.GetCursorPosScreen()
            self.isDragging = GUIItemContainsPoint(self.slidebarBg, mouseX, mouseY)

            if not MouseTracker_GetIsVisible() then
                SetMouseVisible(self, true)
            else
                HandlePlayerVoiceClicked(self)
            end

            return true
        end
    end

    if self.slidebarBg:GetIsVisible() then
        if key == InputKey.MouseWheelDown then
            self.slidePercentage = math.min(self.slidePercentage + 5, 100)
            return true
        elseif key == InputKey.MouseWheelUp then
            self.slidePercentage = math.max(self.slidePercentage - 5, 0)
            return true
        elseif key == InputKey.PageDown and down then
            self.slidePercentage = math.min(self.slidePercentage + 10, 100)
            return true
        elseif key == InputKey.PageUp and down then
            self.slidePercentage = math.max(self.slidePercentage - 10, 0)
            return true
        elseif key == InputKey.Home then
            self.slidePercentage = 0
            return true
        elseif key == InputKey.End then
            self.slidePercentage = 100
            return true
        end
    end

end
end);
