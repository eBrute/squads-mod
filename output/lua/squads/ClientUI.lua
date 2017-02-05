Script.Load("lua/squads/Globals.lua")

if kSquadTeams[kTeam1Index] then
    AddClientUIScriptForTeam(kTeam1Index, 'squads/GUISquadWaypoints')
end
if kSquadTeams[kTeam2Index] then
    AddClientUIScriptForTeam(kTeam2Index, 'squads/GUISquadWaypoints')
end
