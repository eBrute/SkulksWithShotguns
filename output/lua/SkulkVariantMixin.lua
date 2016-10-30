-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\SkulkVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")

SkulkVariantMixin = CreateMixin(SkulkVariantMixin)
SkulkVariantMixin.type = "SkulkVariant"

SkulkVariantMixin.kModelNames = {}
SkulkVariantMixin.kViewModelNames = {}

for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.modelFilePart .. ".model" )
end


for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kViewModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.viewModelFilePart .. "_view.model" )
end

SkulkVariantMixin.kDefaultModelName = SkulkVariantMixin.kModelNames[kDefaultSkulkVariant]
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

SkulkVariantMixin.networkVars =
{
    variant = "enum kSkulkVariant",
}

function SkulkVariantMixin:__initmixin()

    self.variant = kDefaultSkulkVariant

end

function SkulkVariantMixin:GetVariant()
    return self.variant
end

function SkulkVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
end

function Dump(variable, name, maxdepth, depth)
    if name == nil then
        name = '(this)'
    end

    if maxdepth == nil then
        maxdepth = 5
    end

    if depth == nil then
        depth = 0
    end

    if type(variable) == 'nil' then
        Print(name .. ' = (nil)')
    elseif type(variable) == 'number' then
        Print(name .. ' = ' .. variable)
    elseif type(variable) == 'boolean' then
        if variable then
            Print(name .. ' = true')
        else
            Print(name .. ' = false')
        end
    elseif type(variable) == 'string' then
        Print(name .. ' = "' .. variable .. '"')
    elseif type(variable) == 'table' then
        Print(name .. ' = (' .. type(variable) .. ')')

        for i, v in pairs(variable) do
            if type(i) ~= 'userdata' then
                if v == _G then -- because _G._G == _G
                    Print(name .. '.' .. i)
                elseif v ~= variable then
                    if depth >= maxdepth then
                        Print(name .. '.' .. i .. ' (...)')
                    else
                        Dump(v, name .. '.' .. i, maxdepth, depth + 1)
                    end
                else
                    Print(name .. '.' .. i .. ' = ' .. name)
                end
            end
        end
    else -- function, userdata, thread, cdata
        Print(name .. ' = (' .. type(variable) .. ')')

        if getmetatable(variable) and getmetatable(variable).__towatch then
            Dump(getmetatable(variable).__towatch, name .. ' (' .. type(variable) .. ')', maxdepth, depth + 1)
        end
    end
end

function SkulkVariantMixin:GetVariantModel()

    if self.GetTeamNumber and self:GetTeamNumber() == 1 then
        return SkulkVariantMixin.kModelNames[kSkulkVariant.abysss]
    else
        return SkulkVariantMixin.kModelNames[kSkulkVariant.normal]
    end
end

function SkulkVariantMixin:GetVariantViewModel()
    return SkulkVariantMixin.kViewModelNames[ self.variant ]
end

if Server then

    -- Usually because the client connected or changed their options
    function SkulkVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        -- local changed = data.skulkVariant ~= self.variant

        -- if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            -- return
        -- end

        -- if GetHasVariant( kSkulkVariantData, data.skulkVariant, client ) or client:GetIsVirtual() then

            -- cleared, pass info to clients
            self.variant = data.skulkVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kSkulkAnimationGraph)

        -- else
            -- Print("ERROR: Client tried to request skulk variant they do not have yet")
        -- end

        if changed then

            -- Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end

        end

    end

end
