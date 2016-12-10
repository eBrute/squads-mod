class 'Squad'

function Squad:Initialize(SquadName, SquadNumber)
    self.SquadName = SquadName
    self.SquadNumber = SquadNumber
    self.playerIds = table.array(kMaxSquadsMembersPerSquad)
end


function Squad:Uninitialize()
end


function Squad:OnCreate()
end


function Squad:OnInitialized()
end


function Squad:AddPlayer(player)
    if player and player:isa("Player") then
        local id = player:GetId()
        return table.insertunique(self.playerIds, id)
    else
        Print("Squad:AddPlayer(): Entity must be player (was %s)", SafeClassName(player))
        return false
    end
end


function Squad:OnEntityChange(oldId, newId)
end


function Squad:GetPlayer(playerIndex)
    if (playerIndex >= 1 and playerIndex <= table.count(self.playerIds)) then
        return Shared.GetEntity( self.playerIds[playerIndex] )
    end

    Print("Squad:GetPlayer(%d): Invalid index specified (1 to %d)", playerIndex, table.count(self.playerIds))
    return nil

end


function Squad:RemovePlayer(player)
    assert(player)
    if not table.removevalue(self.playerIds, player:GetId()) then
        Print("Player %s with Id %d not in playerId list.", player:GetClassName(), player:GetId())
    end

    player:SetSquadNumber(kSquadInvalid)
end



function Squad:GetNumPlayers()
    local numPlayers = 0
    local numRookies = 0
    local numBots = 0

	local function CountPlayers( player )
		local client = Server.GetOwner(player)
		if client then
			numPlayers = numPlayers + 1

			if player:GetIsRookie() then
				numRookies = numRookies + 1
            end

            if client:GetIsVirtual() then
                numBots = numBots + 1
            end
		end
	end

	self:ForEachPlayer( CountPlayers )
    return numPlayers, numRookies, numBots
end


function Squad:GetNumDeadPlayers()
    local numPlayers = 0

	local function CountDeadPlayer( player )
		if not player:GetIsAlive() then
			 numPlayers = numPlayers + 1
		end
	end

	self:ForEachPlayer( CountDeadPlayer )
    return numPlayers
end



function Squad:GetPlayers()
	local playerList = {}

	local function CollectPlayers( player )
		table.insert(playerList, player)
	end

	self:ForEachPlayer( CollectPlayers )
    return playerList
end



function Squad:GetSquadNumber()
    return self.SquadNumber
end


function Squad:Reset()
    self.playerIds = { }
end


function Squad:GetIsPlayerOnSquad(player)
    return table.find(self.playerIds, player:GetId())
end


-- For every player on Squad, call functor(player)
function Squad:ForEachPlayer(functor)
    for i, playerId in ipairs(self.playerIds) do
        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") then
            if functor(player, self.SquadNumber) == false then
                break
            end
        else
            table.remove( self.playerIds, i )
        end
    end
end


function Squad:SendCommand(command)
    local function PlayerSendCommand(player)
        Server.SendCommand(player, command)
    end
    self:ForEachPlayer(PlayerSendCommand)
end


function Squad:GetHasActivePlayers()
    local hasActivePlayers = false
    local currentSquad = self

    local function HasActivePlayers(player)
        if player:GetIsAlive() then
            hasActivePlayers = true
            return false
        end
    end

    self:ForEachPlayer(HasActivePlayers)
    return hasActivePlayers
end



function Squad:Update(timePassed)
end


function Squad:BroadcastMessage(message)
    local function SendMessage(player)
        Server.Broadcast(player, message)
    end

    self:ForEachPlayer(SendMessage)
end
