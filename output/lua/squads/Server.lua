local function OnSelectSquad(client, message)
    message.squadNumber = message.squadNumber or kSquadType.Unassigned
    local player = client:GetControllingPlayer()
    if HasMixin(player, "SquadMember") then
        local success = player:SwitchToSquad(message.squadNumber)
        Server.SendNetworkMessage(client, "SquadMemberJoinedSquad", {success = success}, true)
    end
end

Server.HookNetworkMessage("SelectSquad", OnSelectSquad)
