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
--]]

--- @class GOBBO.Slider : GOBBO.Button
local PANEL = {}

function PANEL:Init()
    self.Fraction = 0

    self.Grip = vgui.Create("GOBBO.ImageButton", self)
    self.Grip:NoClipping(true)

    self.Grip:SetImageURL("https://pixel-cdn.lythium.dev/i/g6e8z4pz")
    self.Grip:SetNormalColor(GOBBO.CopyColor(GOBBO.Colors.Primary))
    self.Grip:SetHoverColor(GOBBO.OffsetColor(GOBBO.Colors.Primary, -15))
    self.Grip:SetClickColor(GOBBO.OffsetColor(GOBBO.Colors.Primary, 15))

    self.Grip.OnCursorMoved = function(pnl, x, y)
        if not pnl.Depressed then return end

        x, y = pnl:LocalToScreen(x, y)
        x = self:ScreenToLocal(x, y)

        self.Fraction = math.Clamp(x / self:GetWide(), 0, 1)

        self:OnValueChanged(self.Fraction)
        self:InvalidateLayout()
    end

    self.BackgroundCol = GOBBO.OffsetColor(GOBBO.Colors.Background, 20)
    self.FillCol = GOBBO.OffsetColor(GOBBO.Colors.Background, 10)
end

function PANEL:OnMousePressed()
    local w = self:GetWide()

    self.Fraction = math.Clamp(self:CursorPos() / w, 0, 1)
    self:OnValueChanged(self.Fraction)
    self:InvalidateLayout()
end

function PANEL:OnValueChanged(fraction) end

function PANEL:Paint(w, h)
    local rounding = h * .5
    GOBBO.DrawRoundedBox(rounding, 0, 0, w, h, self.BackgroundCol)
    GOBBO.DrawRoundedBox(rounding, 0, 0, self.Fraction * w, h, self.FillCol)
end

function PANEL:PerformLayout(w, h)
    local gripSize = h + GOBBO.Scale(6)
    local offset = GOBBO.Scale(3)
    self.Grip:SetSize(gripSize, gripSize)
    self.Grip:SetPos((self.Fraction * w) - (gripSize * .5), -offset)
end

vgui.Register("GOBBO.Slider", PANEL, "GOBBO.Button")