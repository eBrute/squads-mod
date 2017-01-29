-- Hook to change the hint text for squad members
-- hint text is used in GUIUnitStatus

Script.Load("lua/Globals.lua")

local oldPlayerUI_GetStatusInfoForUnit = PlayerUI_GetStatusInfoForUnit

function PlayerUI_GetStatusInfoForUnit(player, unit)
    unitState = oldPlayerUI_GetStatusInfoForUnit(player, unit)
    if not unitState then
        return unitState
    end

    if unit and unit:isa("Player") and unit:GetShowUnitStatusFor(player)
    and HasMixin(unit, "SquadMember") and player:GetTeamNumber() == unit:GetTeamNumber() then
        local squadNumber = unit:GetSquadNumber()
        if squadNumber > kSquadType.Unassigned then
            -- NOTE NS2+ uses a table as hint, vanilla has a string
            if type(unitState.Hint) == 'table' then
                if unitState.Hint.Hint and unitState.Hint.Hint == "" then
                    unitState.Hint.Hint = kSquadNames[squadNumber]
                else
                    unitState.Hint.Hint = kSquadNames[squadNumber] .. " (" .. unitState.Hint.Hint .. ")"
                end
            else
                if unitState.Hint == "" then
                    unitState.Hint = kSquadNames[squadNumber]
                else
                    unitState.Hint = kSquadNames[squadNumber] .. " (" .. unitState.Hint .. ")"
                end
            end
            unitState.SquadNumber = squadNumber
        end
    end

    return unitState
end
