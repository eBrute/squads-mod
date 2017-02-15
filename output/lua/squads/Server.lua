-- Hook into server to handle squad selection in the gui

local function OnSelectSquad(client, message)
    message.squadNumber = message.squadNumber or kSquadType.Unassigned
    local player = client:GetControllingPlayer()
    if HasMixin(player, "SquadMember") then
        local success = player:SwitchToSquad(message.squadNumber)
        Server.SendNetworkMessage(client, "SquadMemberJoinedSquad", {squadNumber = message.squadNumber, success = success}, true)
    end
end

Server.HookNetworkMessage("SelectSquad", OnSelectSquad)
