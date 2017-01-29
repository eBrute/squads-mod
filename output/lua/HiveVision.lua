-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\HiveVision.lua
--
--    Created by:   Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local _renderMask       = 0x2
local _invRenderMask    = bit.bnot(_renderMask)
local _maxDistance      = 30
local _maxDistance_Commander = 60
local _enabled          = true

-- NOTE added squad colors, see alien_outline_lookup.dds
kHiveVisionOutlineColor = enum { [0]='Yellow', 'Green', 'KharaaOrange', 'Squad1', 'Squad2', 'Squad3', 'Squad4', 'Squad5', 'Squad6' }
kHiveVisionOutlineColorCount = #kHiveVisionOutlineColor+1

function HiveVision_Initialize()

    HiveVision_camera = Client.CreateRenderCamera()
    HiveVision_camera:SetTargetTexture("*hive_vision", false)
    HiveVision_camera:SetRenderMask( _renderMask )
    HiveVision_camera:SetIsVisible( false )
    HiveVision_camera:SetCullingMode( RenderCamera.CullingMode_Frustum )
    HiveVision_camera:SetRenderSetup( "shaders/HiveVisionMask.render_setup" )

    HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
    HiveVision_screenEffect:SetActive(false)

end

function HiveVision_Shutdown()

    Client.DestroyRenderCamera(HiveVision_camera)
    HiveVision_camera = nil

    Client.DestroyScreenEffect(HiveVision_screenEffect)
    HiveVision_screenEffect = nil

end

-- NOTE begin squad code
function HiveVision_GetSquadColor(squadNumber)
    return 1 + squadNumber -- squad1 is squadNumber 2
end
-- NOTE end squad code


-- Enables or disabls the hive vision effect. When the effect is not needed it should
-- be disabled to boost performance.
function HiveVision_SetEnabled(enabled)

    HiveVision_camera:SetIsVisible(enabled and _enabled)
    HiveVision_screenEffect:SetActive(enabled and _enabled)

end

-- Must be called prior to rendering
function HiveVision_SyncCamera(camera, forCommander)

    HiveVision_camera:SetCoords( camera:GetCoords() )
    HiveVision_camera:SetFov( camera:GetFov() )
    HiveVision_camera:SetFarPlane( ConditionalValue(forCommander, _maxDistance_Commander, _maxDistance) + 1 )

    HiveVision_screenEffect:SetParameter("time", Shared.GetTime())

end

-- Adds a model to the hive vision
function HiveVision_AddModel(model, color)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.bor(renderMask, _renderMask) )

    local outlineid = Clamp( color or kHiveVisionOutlineColor.KharaaOrange, 0, kHiveVisionOutlineColorCount )
    model:SetMaterialParameter("outline", (outlineid + 0.5)/kHiveVisionOutlineColorCount )
end

-- Removes a model from the hive vision
function HiveVision_RemoveModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.band(renderMask, _invRenderMask) )

end

-- for debugging
local function OnCommandHiveVision(enabled)
    _enabled = enabled ~= "false"
end

Event.Hook("Console_hivevision", OnCommandHiveVision)
