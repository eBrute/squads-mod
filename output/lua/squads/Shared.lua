local function OnShowSquads()
    local teams = GetGamerules():GetTeams()
    for t = 1, #teams do
        Log("Squads for team %d", teams[t].teamNumber)
        Log("%s", teams[t].squads)
    end
end
Event.Hook("Console_show_squads", OnShowSquads)
