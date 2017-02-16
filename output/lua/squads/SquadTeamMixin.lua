-- a squadteam is a team that has several squads
-- the squadteam informs the squads about joining/leaving players
-- squadteam assigns the default squad

Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Squad.lua")

SquadTeamMixin = CreateMixin(SquadTeamMixin)
SquadTeamMixin.type = "SquadTeam"

function SquadTeamMixin:__initmixin()
    self.squads = {}
    self.nextSquadUpdateTime = 0
    self.nextSquadUpdateSquad = 1
	for squadNumber = 1, #kSquadType do
		self.squads[squadNumber] = Squad()
		self.squads[squadNumber]:Initialize(self.__mixindata.teamNumber, squadNumber)
	end
end


function SquadTeamMixin:GetSquad(squadNumber)
    if squadNumber ~= kSquadType.Invalid then
        return self.squads[squadNumber]
    end
end


-- NOTE on teamswitch, AddPlayer happens before RemovePlayer
-- NOTE entity is added to team on creation, even before control is transfered to entity
function SquadTeamMixin:AddPlayer(player)
    if player and player:isa("Player") then
        self:AddPlayerToSquad(player, kSquadPlayerDefault)
    end
end


function SquadTeamMixin:RemovePlayer(player)
    if HasMixin(player, "SquadMember") then
        local squadNumber = player:GetSquadNumber()
        self:RemovePlayerFromSquad(player, squadNumber, true)
    end
end


-- if this is called, team is removing a playerId that is no longer a valid player
-- so just try to remove from every squad
function SquadTeamMixin:RemovePlayerById(playerId)
    for squadNumber = 1, #kSquadType do
        self.squads[squadNumber]:RemovePlayerById(playerId)
    end
end


function SquadTeamMixin:AddPlayerToSquad(player, squadNumber)
    if squadNumber ~= kSquadType.Invalid then
        return self.squads[squadNumber]:AddPlayer(player)
    end
    return false
end


function SquadTeamMixin:RemovePlayerFromSquad(player, squadNumber, notifyPlayer)
    if squadNumber ~= kSquadType.Invalid then
        self.squads[squadNumber]:RemovePlayer(player, notifyPlayer)
    end
end


function SquadTeamMixin:ResetSquads()
    for squadNumber = 1, #kSquadType do
		self.squads[squadNumber]:Reset()
	end
end


function SquadTeamMixin:Update(deltaTime)
    local now = Shared.GetTime()
    if now > self.nextSquadUpdateTime then
        self.squads[self.nextSquadUpdateSquad]:OnUpdate(deltaTime) -- only update one squad at a time to spread the load
        self.nextSquadUpdateTime = now + kUpdateIntervalMedium
        if self.nextSquadUpdateSquad < #kSquadType then
            self.nextSquadUpdateSquad = self.nextSquadUpdateSquad + 1
        else
            self.nextSquadUpdateSquad = 1
        end
    end
end


function SquadTeamMixin:DumpSquads()
    for squadNumber = 1, #kSquadType do
		self.squads[squadNumber]:Dump()
	end
end
