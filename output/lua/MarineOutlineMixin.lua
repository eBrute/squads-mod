-- ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\MarineOutlineMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

MarineOutlineMixin = CreateMixin( MarineOutlineMixin )
MarineOutlineMixin.type = "MarineOutline"

MarineOutlineMixin.expectedMixins =
{
    Model = "For copying bonecoords and drawing model in view model render zone.",
}

function MarineOutlineMixin:__initmixin()

    if Client then
        self.marineOutlineVisible = false
    end

end

if Client then

    function MarineOutlineMixin:OnDestroy()

        if self.marineOutlineVisible then
            local model = self:GetRenderModel()
            if model ~= nil then
                EquipmentOutline_RemoveModel( model )
            end
        end

    end

    function MarineOutlineMixin:OnModelChanged()
        self.marineOutlineVisible = false
    end

    function MarineOutlineMixin:OnUpdate(deltaTime)
        PROFILE("MarineOutlineMixin:OnUpdate")
        local player = Client.GetLocalPlayer()

        local model = self:GetRenderModel()
        if model ~= nil then

            -- NOTE begin squad code
            local isInSquad = HasMixin(self, "SquadMember") and not self:isa("MarineCommander") and self:GetSquadNumber() > kSquadType.Unassigned
            local isInSameSquad = isInSquad and GetAreFriends(self, player) and self:GetSquadNumber() == player:GetSquadNumber()
            local hasSquadOutline = isInSameSquad or (isInSquad and (player:isa("MarineCommander") or Client.GetLocalClientTeamNumber() == kSpectatorIndex))
            local outlineModel = Client.GetOutlinePlayers() and
                                    ( ( Client.GetLocalClientTeamNumber() == kSpectatorIndex ) or
                                      ( player:isa("MarineCommander") and self.catpackboost )  or
                                      hasSquadOutline )

            local outlineColor
            if hasSquadOutline then
                local squadNumber = self:GetSquadNumber()
                outlineColor = EquipmentOutline_GetSquadColor(squadNumber)
            -- NOTE end squad code
            elseif self.catpackboost then
                outlineColor = kEquipmentOutlineColor.Fuchsia
            elseif HasMixin(self, "ParasiteAble") and self:GetIsParasited() then
                outlineColor = kEquipmentOutlineColor.Yellow
            else
                outlineColor = kEquipmentOutlineColor.TSFBlue
            end

            if outlineModel ~= self.marineOutlineVisible or outlineColor ~= self.marineOutlineColor then

                EquipmentOutline_RemoveModel( model )
                if outlineModel then
                    EquipmentOutline_AddModel( model, outlineColor )
                    self.marineOutlineColor = outlineColor
                end

                self.marineOutlineVisible = outlineModel
            end

        end

    end

end
