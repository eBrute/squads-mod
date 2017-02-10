
Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Globals.lua")

class 'SquadOutlines'

function SquadOutlines.hasSquadOutline(thing, forPlayer)
    local playerIsCommander = forPlayer:isa("Commander")
    local playerIsAlien = forPlayer:isa("Alien") or forPlayer:isa("AlienSpectator")
    local playerIsMarine = forPlayer:isa("Marine") or forPlayer:isa("Exo") or forPlayer:isa("MarineSpectator")
    local playerIsSpectator = Client.GetLocalClientTeamNumber() == kSpectatorIndex

    local isInSquad = HasMixin(thing, "SquadMember") and thing:GetSquadNumber() > kSquadType.Unassigned
    local isInSameTeam = GetAreFriends(thing, forPlayer)
    local isInSameSquad = isInSameTeam and isInSquad and thing:GetSquadNumber() == forPlayer:GetSquadNumber()

    local playerCanSeeThisSquad = isInSameSquad and (playerIsAlien or playerIsMarine) -- NOTE probably we dont need to check the players class here
    local playerCanSeeAllSquads = isInSquad and (isInSameTeam and playerIsCommander or playerIsSpectator)

    local hasSquadOutline = playerCanSeeThisSquad or playerCanSeeAllSquads
    return hasSquadOutline
end


function SquadOutlines.getSquadOutlineColor(thing, visionType)
    local squadNumber = thing:GetSquadNumber()
    if visionType == kAlienTeamType then
        return SquadOutlines.HiveVision_GetSquadColor(squadNumber)
    end
    if visionType == kMarineTeamType then
        return SquadOutlines.EquipmentOutline_GetSquadColor(squadNumber)
    end
end

-- returns the color index as defined in HiveVision.lua
function SquadOutlines.HiveVision_GetSquadColor(squadNumber)
    return 1 + squadNumber -- NOTE first squad is squadNumber 2
end

-- returns the color index as defined in EquipmentOutline.lua
function SquadOutlines.EquipmentOutline_GetSquadColor(squadNumber)
    return 3 + squadNumber -- NOTE first squad is squadNumber 2
end
