-- a squad member has a squad number assigned to him
-- the squad number and the team number together identify the squad
-- if the team is not a squadteam, the squad number shall be kSquadType.Invalid

Script.Load("lua/Globals.lua")

SquadMemberMixin = CreateMixin(SquadMemberMixin)
SquadMemberMixin.type = "SquadMember"

SquadMemberMixin.networkVars = {
  squadNumber = "enum kSquadType"
}

function SquadMemberMixin:__initmixin()
    self.squadNumber = kSquadType.Invalid
end


-- NOTE does not notify squad, use SwitchToSquad()
function SquadMemberMixin:SetSquadNumber(squadNumber)
    self.squadNumber = squadNumber
end


function SquadMemberMixin:GetSquadNumber()
    return self.squadNumber
end


function SquadMemberMixin:GetSquad()
	local team = self:GetTeam()
    if HasMixin(team, "SquadTeam") then
        return team:GetSquad(self.squadNumber)
    end
end


function SquadMemberMixin:SwitchToSquad(squadNumber)
    local team = self:GetTeam()
    if HasMixin(team, "SquadTeam") then
        team:RemovePlayerFromSquad(self, self.squadNumber)
        team:AddPlayerToSquad(self, squadNumber)
    end
end

if Server then
function SquadMemberMixin:CopyPlayerDataFrom(oldPlayer)
  Log("----")
  if not oldPlayer then
    Log("> oldplayer is nil!!!!!!!!!!!!!!!!!!!!!")
    return
  end
  Log("> CopyPlayerDataFrom, old team: %s, new team: %s", oldPlayer:GetTeamNumber(), self:GetTeamNumber() )
  local oldSquad = oldPlayer:GetSquad() -- this is the squad we were in
  if oldSquad then
    Log("> remove old entity from old squad")
    oldSquad:RemovePlayer(oldPlayer) -- oldPlayer is about to be destroyed, so remove him
  else
    Log("> no old squad!")
  end

  if oldPlayer:GetTeamNumber() == self:GetTeamNumber() then
    Log("> old and new Entity are on the same team")
    -- change occured in the same team (i.e. marine -> exo), so carry over the squad to the new entity
    local newSquad = self:GetSquad() -- new player already has the default squad because NS2Gamerules:OnEntityCreate joined the team
    if newSquad then
      Log("> remove new entity from new squad")
      newSquad:RemovePlayer(self)  -- remove the new player from the default squad
    else
      Log("> Entity Change within team but no newsquad!!!")
    end
    if oldSquad then
      Log("> add new entity to old squad")
      oldSquad:AddPlayer(self)
    else
      Log("> Entity Change within team but no oldsquad!!!!!!!!!!") -- TODO why?
    end
  end
end
end
