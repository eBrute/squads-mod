class 'SquadUtils'

function SquadUtils.isInSquad(entity)
    return HasMixin(entity, "SquadMember") and entity:GetSquadNumber() > kSquadType.Unassigned
end


function SquadUtils.isInSameTeam(player, entity)
    return GetAreFriends(player, entity)
end


function SquadUtils.isInSameSquad(player, entity)
    return SquadUtils.isInSquad(player) and SquadUtils.isInSquad(entity) and SquadUtils.isInSameTeam(player, entity) and entity:GetSquadNumber() == player:GetSquadNumber()
end


function SquadUtils.canPlayerSeeSquad(player, entity)
    local playerIsAlien = player:isa("Alien") or player:isa("AlienSpectator")
    local playerIsMarine = player:isa("Marine") or player:isa("Exo") or player:isa("MarineSpectator")
    local playerIsCommander = player:isa("Commander")
    local playerIsSpectator = player:GetTeamNumber() == kSpectatorIndex -- Client.GetLocalClientTeamNumber()

    local isInSquad = SquadUtils.isInSquad(entity)
    local isInSameTeam = SquadUtils.isInSameTeam(player, entity)
    local isInSameSquad = SquadUtils.isInSameSquad(player, entity)

    local playerCanSeeThisSquad = isInSameSquad and (playerIsAlien or playerIsMarine) -- NOTE probably we dont need to check the players class here
    local playerCanSeeAllSquads = isInSquad and (isInSameTeam and playerIsCommander or playerIsSpectator)
    return playerCanSeeThisSquad or playerCanSeeAllSquads
end
