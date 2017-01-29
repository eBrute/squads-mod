local function OnDumpSquads()
    if Server then
        local teams = GetGamerules():GetTeams()
        for t = 1, #teams do
            local team = teams[t]
            if HasMixin(team, "SquadTeam") then
                Log("Squads for team %d", teams[t].teamNumber)
                teams[t]:DumpSquads()
            end
        end
    end
end
Event.Hook("Console_dump_squads", OnDumpSquads)

Shared.RegisterNetworkMessage("SquadMemberJoinedTeam")
Shared.RegisterNetworkMessage("SquadMemberJoinedSquad")
Shared.RegisterNetworkMessage("SelectSquad", { squadNumber = "integer" })
