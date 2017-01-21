local oldScoreboard_ReloadPlayerData = Scoreboard_ReloadPlayerData

function Scoreboard_ReloadPlayerData()

    oldScoreboard_ReloadPlayerData()

    for _, pie in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do

        local playerRecord = Scoreboard_GetPlayerRecord(pie.clientId) -- NOTE possible endless loop? (if playerData[clientIndex] == nil then Scoreboard_ReloadPlayerData())

        if playerRecord ~= nil then
            playerRecord.SquadNumber = pie.squadNumber
        end
    end
end
