-- Hook to handle squad select menu loading and closing
Script.Load("lua/squads/SquadOutlines.lua")

gSquadSelect = nil

local function GetTeamHasSquads(team)
    return kSquadTeams[team]
end

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
    if not gSquadSelect:GetIsVisible() then
        gSquadSelect:SetIsVisible(true)
    end
end

local function HideSquadSelectMenu()
    if gSquadSelect and gSquadSelect:GetIsVisible() then
        gSquadSelect:SetIsVisible(false)
    end
end

local function SetSquadSquareColors(squadNumber)
    local c = kSquadColors[squadNumber]
    Client.squadSquareColors = { c.r,c.g,c.b,c.a, c.r,c.g,c.b,c.a, c.r,c.g,c.b,c.a, c.r,c.g,c.b,c.a, c.r,c.g,c.b,c.a, }
end

local function OnSquadMemberJoinedSquad(message)
    if message.success then
        local player = Client.GetLocalPlayer()
        if player then
            SetSquadSquareColors(message.squadNumber)
            if HasMixin(player, "SquadMember") then
                player:OnSquadNumberChange(message.squadNumber)
            end
        end

        if gSquadSelect then
            StartSoundEffect(GUISquadSelect.kSounds.click)
            HideSquadSelectMenu()
        end
    else
        if gSquadSelect then
            StartSoundEffect(GUISquadSelect.kSounds.invalid)
        end
    end
end

Client.HookNetworkMessage("SquadMemberJoinedSquad", OnSquadMemberJoinedSquad)


local function ToggleSquadSelectMenu()
    if gSquadSelect and gSquadSelect:GetIsVisible() then
        HideSquadSelectMenu()
    else
        local player = Client.GetLocalPlayer()
        if GetTeamHasSquads(player:GetTeamNumber()) then
            ShowSquadSelectMenu()
        end
    end
end

Event.Hook("Console_squad_menu", ToggleSquadSelectMenu)


local function ToggleSquadSelectMenuOnTeamChange(message)
    if GetTeamHasSquads(message.newTeam) then
        ShowSquadSelectMenu()
    else
        HideSquadSelectMenu()
    end
end

Client.HookNetworkMessage("SquadMemberJoinedTeam", ToggleSquadSelectMenuOnTeamChange)


local function SelectSquad(squadNumber)
    Client.SendNetworkMessage("SelectSquad", {squadNumber = squadNumber}, true)
end

Event.Hook("Console_select_squad", SelectSquad)
