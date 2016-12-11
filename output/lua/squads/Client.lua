local function ShowSquadSelectMenu()
    gSquadSelect = GetGUIManager():CreateGUIScriptSingle("squads/GUISquadSelect")
    gSquadSelect:SetIsVisible(true)
end

local function HideSquadSelectMenu()
    GetGUIManager():DestroyGUIScriptSingle("squads/GUISquadSelect")
    gSquadSelect = nil
end

local function ToggleSquadSelectMenu()
    if not gSquadSelect then
        ShowSquadSelectMenu()
    else
        HideSquadSelectMenu()
    end
end

Event.Hook("Console_select_squad", ToggleSquadSelectMenu)
Client.HookNetworkMessage("ShowSquadSelect", ShowSquadSelectMenu)
