--[[
	GOBBO UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

GOBBO.UI.RegisteredFonts = GOBBO.UI.RegisteredFonts or {}
local registeredFonts = GOBBO.UI.RegisteredFonts

do
    GOBBO.UI.SharedFonts = GOBBO.UI.SharedFonts or {}
    local sharedFonts = GOBBO.UI.SharedFonts

    function GOBBO.RegisterFontUnscaled(name, font, size, weight)
        weight = weight or 500

        local identifier = font .. size .. ":" .. weight

        local fontName = "GOBBO:" .. identifier
        registeredFonts[name] = fontName

        if sharedFonts[identifier] then return end
        sharedFonts[identifier] = true

        surface.CreateFont(fontName, {
            font = font,
            size = size,
            weight = weight,
            extended = true,
            antialias = true
        })
    end
end

do
    GOBBO.UI.ScaledFonts = GOBBO.UI.ScaledFonts or {}
    local scaledFonts = GOBBO.UI.ScaledFonts

    function GOBBO.RegisterFont(name, font, size, weight)
        scaledFonts[name] = {
            font = font,
            size = size,
            weight = weight
        }

        GOBBO.RegisterFontUnscaled(name, font, GOBBO.Scale(size), weight)
    end

    hook.Add("OnScreenSizeChanged", "GOBBO.UI.ReRegisterFonts", function()
        for k,v in pairs(scaledFonts) do
            GOBBO.RegisterFont(k, v.font, v.size, v.weight)
        end
    end)
end

do
    local setFont = surface.SetFont
    local function setPixelFont(font)
        local pixelFont = registeredFonts[font]
        if pixelFont then
            setFont(pixelFont)
            return
        end

        setFont(font)
    end

    GOBBO.SetFont = setPixelFont

    local getTextSize = surface.GetTextSize
    function GOBBO.GetTextSize(text, font)
        if font then setPixelFont(font) end
        return getTextSize(text)
    end

    function GOBBO.GetRealFont(font)
        return registeredFonts[font]
    end
end
