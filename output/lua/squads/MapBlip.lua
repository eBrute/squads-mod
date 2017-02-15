Script.Load("lua/squads/SquadUtils.lua")

local playerNetworkVars =
{
    squadNumber = "enum kSquadType",
}

local oldPlayerMapBlipOnCreate = PlayerMapBlip.OnCreate
function PlayerMapBlip:OnCreate()
    oldPlayerMapBlipOnCreate(self)
    self.squadNumber = kSquadType.Invalid
end

if Client then
    function PlayerMapBlip:GetMapBlipColor(minimap, item)
        local blipTeam = self:GetMapBlipTeam(minimap)
        local teamVisible = self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating
        local blipColor = item.blipColor

        if teamVisible and self.ownerEntityId then
            local localPlayer = Client.GetLocalPlayer()

            if SquadUtils.canPlayerSeeSquadMapBlip(localPlayer, self.squadNumber, self:GetTeamNumber()) then
                blipColor = kSquadMinimapBlipColors[self.squadNumber]
            end

            if self.isInCombat then
                local percentage = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
                blipColor = LerpColor(kRed, blipColor, percentage)
            end
            return blipColor
        end
        return MapBlip.GetMapBlipColor(self, minimap, item)
    end
end

Shared.LinkClassToMap("PlayerMapBlip", PlayerMapBlip.kMapName, playerNetworkVars)
