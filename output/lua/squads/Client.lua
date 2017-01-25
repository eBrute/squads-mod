local function CreatequadSelectMenu()
    local player = Client.GetLocalPlayer()
    if player:GetIsOnPlayingTeam() then
        gSquadSelect = GetGUIManager():CreateGUIScriptSingle("squads/GUISquadSelect")
        gSquadSelect:SetIsVisible(true)
    end
end

local function DestroySquadSelectMenu()
    GetGUIManager():DestroyGUIScriptSingle("squads/GUISquadSelect")
    gSquadSelect = nil
end

local function ShowSquadSelectMenu()
    if not gSquadSelect then
        CreatequadSelectMenu()
    end
    if gSquadSelect then
        gSquadSelect:SetIsVisible(true)
    end
end

local function HideSquadSelectMenu()
    if gSquadSelect then
        gSquadSelect:SetIsVisible(false)
    end
end

local function ToggleSquadSelectMenu()
    if gSquadSelect and gSquadSelect:GetIsVisible() then
        HideSquadSelectMenu()
    else
        ShowSquadSelectMenu()
    end
end

Event.Hook("Console_squad_menu", ToggleSquadSelectMenu)
Client.HookNetworkMessage("ShowSquadSelect", ShowSquadSelectMenu)


local function GetIsPlayingTeam(teamNumber)
    return teamNumber == kTeam1Index or teamNumber == kTeam2Index
end

local function ShowSquadSelectOnTeamChange(message)
    if gSquadSelect then
        DestroySquadSelectMenu()
    end
    if GetIsPlayingTeam(message.teamNumber) then
        gSquadSelect = GetGUIManager():CreateGUIScriptSingle("squads/GUISquadSelect")
        gSquadSelect:SetIsVisible(true)
    end
end

Client.HookNetworkMessage("SetClientTeamNumber", ShowSquadSelectOnTeamChange)


local function SelectSquad(squadNumber)
    Client.SendNetworkMessage("SelectSquad", {squadNumber = squadNumber}, true)
end

Event.Hook("Console_select_squad", SelectSquad)
