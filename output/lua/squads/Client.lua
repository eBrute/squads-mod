local function OnSelectSquads()
    if not gSquadSelect then
        gSquadSelect = GetGUIManager():CreateGUIScriptSingle("squads/GUISquadSelect")
        gSquadSelect:SetIsVisible(true)
    else
        GetGUIManager():DestroyGUIScriptSingle("squads/GUISquadSelect")
        gSquadSelect = nil
    end
end
Event.Hook("Console_select_squad", OnSelectSquads)
