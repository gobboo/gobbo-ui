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

--- @class GOBBO.SidebarItem : GOBBO.Button
local PANEL = {}

AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "DrawOutline", "DrawOutline", FORCE_BOOL)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

GOBBO.RegisterFont("SidebarItem", "Open Sans Bold", 19)

function PANEL:Init()
	self:SetName("N/A")
	self:SetDrawOutline(true)

	self.TextCol = GOBBO.CopyColor(GOBBO.Colors.SecondaryText)
	self.BackgroundCol = GOBBO.CopyColor(GOBBO.Colors.Transparent)
	self.BackgroundHoverCol = ColorAlpha(GOBBO.Colors.Scroller, 80)
end

function PANEL:Paint(w, h)
	local textCol = GOBBO.Colors.SecondaryText
	local backgroundCol = GOBBO.Colors.Transparent

	if self:IsHovered() then
		textCol = GOBBO.Colors.PrimaryText
		backgroundCol = self.BackgroundHoverCol
	end

	if self:IsDown() or self:GetToggle() then
		textCol = GOBBO.Colors.PrimaryText
		backgroundCol = self.BackgroundHoverCol
	end

	local animTime = FrameTime() * 12
	self.TextCol = GOBBO.LerpColor(animTime, self.TextCol, textCol)
	self.BackgroundCol = GOBBO.LerpColor(animTime, self.BackgroundCol, backgroundCol)

	if self:GetDrawOutline() then GOBBO.DrawRoundedBox(GOBBO.Scale(4), 0, 0, w, h, self.BackgroundCol, GOBBO.Scale(1)) end

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .65
		GOBBO.DrawImage(GOBBO.Scale(10), (h - iconSize) / 2, iconSize, iconSize, imageURL, self.TextCol)
		GOBBO.DrawSimpleText(self:GetName(), "SidebarItem", GOBBO.Scale(20) + iconSize, h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	GOBBO.DrawSimpleText(self:GetName(), "SidebarItem", GOBBO.Scale(10), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("GOBBO.SidebarItem", PANEL, "GOBBO.Button")

--- @class GOBBO.Sidebar : Panel
PANEL = {}

AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "ImageScale", "ImageScale", FORCE_NUMBER)
AccessorFunc(PANEL, "ImageOffset", "ImageOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "ButtonOffset", "ButtonOffset", FORCE_NUMBER)

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImgurScale", "ImgurScale", FORCE_NUMBER) -- Deprecated
AccessorFunc(PANEL, "ImgurOffset", "ImgurOffset", FORCE_NUMBER) -- Deprecated

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

function PANEL:SetImgurScale(scale)
	self:SetImageScale(scale)
	self.ImgurScale = scale
end

function PANEL:GetImgurScale()
	return self:GetImageScale()
end

function PANEL:SetImgurOffset(offset)
	self:SetImageOffset(offset)
	self.ImgurOffset = offset
end

function PANEL:GetImgurOffset()
	return self:GetImageOffset()
end

function PANEL:Init()
	self.Items = {}

	self.Scroller = vgui.Create("GOBBO.ScrollPanel", self)
	self.Scroller:SetBarDockShouldOffset(true)
	self.Scroller.LayoutContent = function(s, w, h)
		local spacing = GOBBO.Scale(8)
		local height = GOBBO.Scale(35)
		for k,v in pairs(self.Items) do
			v:SetTall(height)
			v:Dock(TOP)
			v:DockMargin(0, 0, 0, spacing)
		end
	end

	self:SetImageScale(.6)
	self:SetImageOffset(0)
	self:SetButtonOffset(0)

	self.BackgroundCol = GOBBO.CopyColor(GOBBO.Colors.Header)
end

function PANEL:AddItem(id, name, imageURL, doClick, order)
	local btn = vgui.Create("GOBBO.SidebarItem", self.Scroller)

	btn:SetZPos(order or table.Count(self.Items) + 1)
	btn:SetName(name)
	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		btn:SetImageURL(imageURL)
	end
	btn.Function = doClick

	btn.DoClick = function(s)
		self:SelectItem(id)
	end

	self.Items[id] = btn

	return btn
end

function PANEL:RemoveItem(id)
	local item = self.Items[id]
	if not item then return end

	item:Remove()
	self.Items[id] = nil

	if self.SelectedItem ~= id then return end
	self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
	local item = self.Items[id]
	if not item then return end

	if self.SelectedItem and self.SelectedItem == id then return end
	self.SelectedItem = id

	for k,v in pairs(self.Items) do
		v:SetToggle(false)
	end

	item:SetToggle(true)
	item.Function(item)
end

function PANEL:PerformLayout(w, h)
	local sideSpacing = GOBBO.Scale(7)
	local topSpacing = GOBBO.Scale(7)
	self:DockPadding(sideSpacing, self:GetImageURL() and w * self:GetImageScale() + self:GetImageOffset() + self:GetButtonOffset() + topSpacing * 2 or topSpacing, sideSpacing, topSpacing)

	self.Scroller:Dock(FILL)
	self.Scroller:GetCanvas():DockPadding(0, 0, self.Scroller.VBar.Enabled and sideSpacing or 0, 0)
end

function PANEL:Paint(w, h)
	GOBBO.DrawRoundedBoxEx(GOBBO.Scale(6), 0, 0, w, h, self.BackgroundCol, false, false, true)

	local imageURL = self:GetImageURL()
	if imageURL then
		local imageSize = w * self:GetImageScale()
		GOBBO.DrawImage((w - imageSize) / 2, self:GetImageOffset() + GOBBO.Scale(15), imageSize, imageSize, imageURL, color_white)
	end
end

vgui.Register("GOBBO.Sidebar", PANEL, "Panel")