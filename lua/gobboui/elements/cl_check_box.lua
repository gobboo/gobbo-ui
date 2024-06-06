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

--- @class GOBBO.Checkbox : GOBBO.ImageButton
local PANEL = {}

function PANEL:Init()
    self:SetIsToggle(true)

    local boxSize = GOBBO.Scale(20)
    self:SetSize(boxSize, boxSize)

    self:SetImageURL("https://pixel-cdn.lythium.dev/i/7u6uph3x6g")

    self:SetNormalColor(GOBBO.Colors.Transparent)
    self:SetHoverColor(GOBBO.Colors.PrimaryText)
    self:SetClickColor(GOBBO.Colors.PrimaryText)
    self:SetDisabledColor(GOBBO.Colors.Transparent)

    self:SetImageSize(.8)

    self.BackgroundCol = GOBBO.CopyColor(GOBBO.Colors.Primary)
end

function PANEL:PaintBackground(w, h)
    if not self:IsEnabled() then
        GOBBO.DrawRoundedBox(GOBBO.Scale(4), 0, 0, w, h, GOBBO.Colors.Disabled)
        self:PaintExtra(w, h)
        return
    end

    local bgCol = GOBBO.Colors.Primary

    if self:IsDown() or self:GetToggle() then
        bgCol = GOBBO.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = GOBBO.LerpColor(animTime, self.BackgroundCol, bgCol)

    GOBBO.DrawRoundedBox(GOBBO.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("GOBBO.Checkbox", PANEL, "GOBBO.ImageButton")