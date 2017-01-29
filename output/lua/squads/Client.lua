gSquadSelect = nil

local function CreatequadSelectMenuIfNotExists()
    if not gSquadSelect then
        gSquadSelect = GetGUIManager():CreateGUIScriptSingle("squads/GUISquadSelect")
    end
end

local function DestroySquadSelectMenu()
    if gSquadSelect then
        GetGUIManager():DestroyGUIScriptSingle("squads/GUISquadSelect")
    end
    gSquadSelect = nil
end

local function ShowSquadSelectMenu()
    CreatequadSelectMenuIfNotExists()
    local player = Client.GetLocalPlayer()
    if player:GetIsOnPlayingTeam() and not gSquadSelect:GetIsVisible() then
        gSquadSelect:SetIsVisible(true)
    end
end

local function HideSquadSelectMenu()
    if gSquadSelect and gSquadSelect:GetIsVisible() then
        gSquadSelect:SetIsVisible(false)
    end
end

Client.HookNetworkMessage("SquadMemberJoinedSquad", HideSquadSelectMenu)


local function ToggleSquadSelectMenu()
    if gSquadSelect and gSquadSelect:GetIsVisible() then
        HideSquadSelectMenu()
    else
        ShowSquadSelectMenu()
    end
end

Event.Hook("Console_squad_menu", ToggleSquadSelectMenu)


local function ToggleSquadSelectMenuOnTeamChange()
    local player = Client.GetLocalPlayer()
    if player:GetIsOnPlayingTeam() then
        ShowSquadSelectMenu()
    elseif not player:GetIsOnPlayingTeam() then
        -- NOTE when you join right after the map is loaded, player reports team 0
        HideSquadSelectMenu()
    end
end

Client.HookNetworkMessage("SquadMemberJoinedTeam", ToggleSquadSelectMenuOnTeamChange)


local function SelectSquad(squadNumber)
    Client.SendNetworkMessage("SelectSquad", {squadNumber = squadNumber}, true)
end

Event.Hook("Console_select_squad", SelectSquad)
