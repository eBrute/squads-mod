Script.Load("lua/squads/Globals.lua")

if kSquadTeams[kTeam1Index] then
    AddClientUIScriptForTeam(kTeam1Index, 'squads/GUISquadWaypoints')
    AddClientUIScriptForTeam(kTeam1Index, 'squads/GUISquadMarineHUD')
end
if kSquadTeams[kTeam2Index] then
    AddClientUIScriptForTeam(kTeam2Index, 'squads/GUISquadWaypoints')
    AddClientUIScriptForTeam(kTeam2Index, 'squads/GUISquadAlienHUD')
end
