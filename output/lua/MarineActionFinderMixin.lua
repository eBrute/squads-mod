-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MarineActionFinderMixin.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/squads/Globals.lua")

local kIconUpdateRate = 0.25

MarineActionFinderMixin = CreateMixin( MarineActionFinderMixin )
MarineActionFinderMixin.type = "MarineActionFinder"

MarineActionFinderMixin.expectedCallbacks =
{
    GetOrigin = "Returns the position of the Entity in world space"
}

function MarineActionFinderMixin:__initmixin()

    if Client and Client.GetLocalPlayer() == self then

        self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
        self.actionIconGUI:SetColor(kMarineFontColor)
        self.lastMarineActionFindTime = 0

    end

end

function MarineActionFinderMixin:OnDestroy()

    if Client and self.actionIconGUI then

        GetGUIManager():DestroyGUIScript(self.actionIconGUI)
        self.actionIconGUI = nil

    end

end

local function SortByGreatestCost(item1, item2)

	local cost1 = HasMixin(item1, "Tech") and LookupTechData(item1:GetTechId(), kTechDataCostKey, 0) or 0
	local cost2 = HasMixin(item2, "Tech") and LookupTechData(item2:GetTechId(), kTechDataCostKey, 0) or 0

	return cost1 < cost2

end

function MarineActionFinderMixin:FindNearbyAutoPickupWeapon()

	local autoPickup = self.ShouldAutopickupWeapons and self:ShouldAutopickupWeapons()
	local autoPickupBetter = self.ShouldAutopickupBetterWeapons and self:ShouldAutopickupBetterWeapons()

	local toPosition = self:GetOrigin()
	local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, Marine.kFindWeaponRange)

	local closestWeapon, closestDistance = nil, Math.infinity
	local currentWeapon = self:GetWeaponInHUDSlot(1)
	local currentWeaponPriority = currentWeapon and Marine.kPickupPriority[currentWeapon:GetTechId()] or 0
	local bestPriority = currentWeapon and currentWeaponPriority or -1

	for i, nearbyWeapon in ipairs(nearbyWeapons) do

		if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then

			local willReplace = self:GetWeaponInHUDSlot( nearbyWeapon:GetHUDSlot() )
			local isEmptySlot = not willReplace or willReplace:isa("Axe")

			if autoPickup and isEmptySlot then

				local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
				if nearbyWeaponDistance < closestDistance then

					closestWeapon = nearbyWeapon
					closestDistance = nearbyWeaponDistance

				end

			elseif autoPickupBetter and currentWeaponPriority < 1 and nearbyWeapon:GetHUDSlot() == 1  then

				local techId = nearbyWeapon:GetTechId()
				local curPriority = Marine.kPickupPriority[techId] or 0

				if curPriority > bestPriority then
					bestPriority = curPriority
					closestWeapon = nearbyWeapon
				end
			end

		end

	end

	return closestWeapon
end

function MarineActionFinderMixin:GetNearbyPickupableWeapon()

	local toPosition = self:GetOrigin()
    local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, Marine.kFindWeaponRange)
    table.sort(nearbyWeapons, SortByGreatestCost)

    local closestWeapon = nil
    local closestDistance = Math.infinity
    local cost = 0

    for i, nearbyWeapon in ipairs(nearbyWeapons) do

        if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then

            local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
            local currentCost = HasMixin(nearbyWeapon, "Tech") and LookupTechData(nearbyWeapon:GetTechId(), kTechDataCostKey, 0) or 0

            if currentCost < cost then
                break

            else

                closestWeapon = nearbyWeapon
                closestDistance = nearbyWeaponDistance
                cost = currentCost

            end

        end

    end

    return closestWeapon
end

if Client then


	local function FindNearbyWeapon(self, toPosition)

		local autoPickupEnabled = self.ShouldAutopickupWeapons and self:ShouldAutopickupWeapons()

		local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, Marine.kFindWeaponRange)
		table.sort(nearbyWeapons, SortByGreatestCost )

		for i, nearbyWeapon in ipairs(nearbyWeapons) do

			if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then

				local foundWeapon = true

				local techId = HasMixin(nearbyWeapon, "Tech") and nearbyWeapon:GetTechId() or 0
				if autoPickupEnabled then

					if kTechId.LayMines or techId == kTechId.Pistol then
						local pickupSlot = nearbyWeapon:GetHUDSlot()
						local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
						if isEmptySlot then
							foundWeapon = false
						end
					elseif techId == kTechId.Welder then
						foundWeapon = false
					end

				end

				if foundWeapon then
					return nearbyWeapon
				end

			end

		end

	end

    function MarineActionFinderMixin:OnProcessMove(input)

        PROFILE("MarineActionFinderMixin:OnProcessMove")

        local gameStarted = self:GetGameStarted()
        local prediction = Shared.GetIsRunningPrediction()
        local now = Shared.GetTime()
        local enoughTimePassed = (now - self.lastMarineActionFindTime) >= kIconUpdateRate
        if not prediction and enoughTimePassed then

            self.lastMarineActionFindTime = now

            local success = false

            if self:GetIsAlive() and not GetIsVortexed(self) then

                local foundNearbyWeapon = FindNearbyWeapon(self, self:GetOrigin())
                if gameStarted and foundNearbyWeapon then

                    self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Drop"), foundNearbyWeapon:GetClassName(), nil)
                    success = true

                else

                    local ent = self:PerformUseTrace()
                    if ent and (gameStarted or (ent.GetUseAllowedBeforeGameStart and ent:GetUseAllowedBeforeGameStart())) then

                        if GetPlayerCanUseEntity(self, ent) and not self:GetIsUsing() then

                            local hintText = nil
                            if ent:isa("CommandStation") and ent:GetIsBuilt() then
                                hintText = gameStarted and "START_COMMANDING" or "START_GAME"
                            -- NOTE begin squads code
                            elseif HasMixin(ent, "SquadMember") then
                                local squadNumber = ent:GetSquadNumber()
                                hintText = string.format("Join %s", kSquadNames[squadNumber])
                            -- NOTE end squads code
                            end

                            self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, hintText, nil)
                            success = true

                        end

                    end

                end

            end

            if not success then
                self.actionIconGUI:Hide()
            end

        end

    end

end
