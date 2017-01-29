local function OnSelectSquad(client, message)
    message.squadNumber = message.squadNumber and tonumber(message.squadNumber) or kSquadType.Unassigned -- TODO assert range
    local player = client:GetControllingPlayer()
    if HasMixin(player, "SquadMember") then
        local success = player:SwitchToSquad(message.squadNumber)
        if success then
            Server.SendNetworkMessage(client, "SquadMemberJoinedSquad", {}, true)
        end
    end
end

Server.HookNetworkMessage("SelectSquad", OnSelectSquad)
