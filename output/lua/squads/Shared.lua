local function OnDumpSquads()
    local teams = GetGamerules():GetTeams()
    for t = 1, #teams do
        Log("Squads for team %d", teams[t].teamNumber)
        for i = 1, #teams[t].squads do
            teams[t].squads[i]:Dump()
        end
    end
end
Event.Hook("Console_dump_squads", OnDumpSquads)

Shared.RegisterNetworkMessage("ShowSquadSelect")
