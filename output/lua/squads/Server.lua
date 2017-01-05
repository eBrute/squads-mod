local function OnSelectSquad(client, message)
    message.squadNumber = message.squadNumber and tonumber(message.squadNumber) or 1 -- TODO assert range
    local player = client:GetControllingPlayer()
    if HasMixin(player, "SquadMember") then
        player:SwitchToSquad(message.squadNumber)
    end
end

Server.HookNetworkMessage("SelectSquad", OnSelectSquad)
