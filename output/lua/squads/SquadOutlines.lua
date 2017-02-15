Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Globals.lua")
Script.Load("lua/squads/SquadUtils.lua")

class 'SquadOutlines'

function SquadOutlines.hasSquadOutline(thing, forPlayer)
    return SquadUtils.canPlayerSeeSquad(forPlayer, thing)
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
