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

--- @class GOBBO.Frame : EditablePanel
local PANEL = {}

AccessorFunc(PANEL, "Draggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "Sizable", "Sizable", FORCE_BOOL)
AccessorFunc(PANEL, "MinWidth", "MinWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "MinHeight", "MinHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "ScreenLock", "ScreenLock", FORCE_BOOL)
AccessorFunc(PANEL, "RemoveOnClose", "RemoveOnClose", FORCE_BOOL)

AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)

function PANEL:SetImgurID(id)
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	return self:GetImageURL():match("https://i.imgur.com/(.-).png")
end

GOBBO.RegisterFont("UI.FrameTitle", "Open Sans Bold", 22)

function PANEL:Init()
	self.CloseButton = vgui.Create("GOBBO.ImageButton", self)
	self.CloseButton:SetImageURL("https://pixel-cdn.lythium.dev/i/fh640z2o")
	self.CloseButton:SetNormalColor(GOBBO.Colors.PrimaryText)
	self.CloseButton:SetHoverColor(GOBBO.Colors.Negative)
	self.CloseButton:SetClickColor(GOBBO.Colors.Negative)
	self.CloseButton:SetDisabledColor(GOBBO.Colors.DisabledText)

	self.CloseButton.DoClick = function(s)
		self:Close()
	end

	self.ExtraButtons = {}

	self:SetTitle("GOBBO Frame")

	self:SetDraggable(true)
	self:SetScreenLock(true)
	self:SetRemoveOnClose(true)

	local size = GOBBO.Scale(200)
	self:SetMinWidth(size)
	self:SetMinHeight(size)

	local oldMakePopup = self.MakePopup
	function self:MakePopup()
		oldMakePopup(self)
		self:Open()
	end
end

function PANEL:DragThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Dragging then
		local x = mousex - targetPanel.Dragging[1]
		local y = mousey - targetPanel.Dragging[2]

		if targetPanel:GetScreenLock() then
			x = math.Clamp(x, 0, scrw - targetPanel:GetWide())
			y = math.Clamp(y, 0, scrh - targetPanel:GetTall())
		end

		targetPanel:SetPos(x, y)
	end

	local _, screenY = targetPanel:LocalToScreen(0, 0)
	if (hoverPanel or targetPanel).Hovered and targetPanel:GetDraggable() and mousey < (screenY + GOBBO.Scale(30)) then
		targetPanel:SetCursor("sizeall")
		return true
	end
end

function PANEL:SizeThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Sizing then
		local x = mousex - targetPanel.Sizing[1]
		local y = mousey - targetPanel.Sizing[2]
		local px, py = targetPanel:GetPos()

		local screenLock = self:GetScreenLock()
		if x < targetPanel.MinWidth then x = targetPanel.MinWidth elseif x > scrw - px and screenLock then x = scrw - px end
		if y < targetPanel.MinHeight then y = targetPanel.MinHeight elseif y > scrh - py and screenLock then y = scrh - py end

		targetPanel:SetSize(x, y)
		targetPanel:SetCursor("sizenwse")
		return true
	end

	local screenX, screenY = targetPanel:LocalToScreen(0, 0)
	if (hoverPanel or targetPanel).Hovered and targetPanel.Sizable and mousex > (screenX + targetPanel:GetWide() - GOBBO.Scale(20)) and mousey > (screenY + targetPanel:GetTall() - GOBBO.Scale(20)) then
		(hoverPanel or targetPanel):SetCursor("sizenwse")
		return true
	end
end

function PANEL:Think()
	if self:DragThink(self) then return end
	if self:SizeThink(self) then return end

	self:SetCursor("arrow")

	if self.y < 0 then
		self:SetPos(self.x, 0)
	end
end

function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen(0, 0)
	local mouseX, mouseY = gui.MouseX(), gui.MouseY()

	if self.Sizable and mouseX > (screenX + self:GetWide() - GOBBO.Scale(30)) and mouseY > (screenY + self:GetTall() - GOBBO.Scale(30)) then
		self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
		self:MouseCapture(true)
		return
	end

	if self:GetDraggable() and mouseY < (screenY + GOBBO.Scale(30)) then
		self.Dragging = {mouseX - self.x, mouseY - self.y}
		self:MouseCapture(true)
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture(false)
end

function PANEL:CreateSidebar(defaultItem, imageURL, imageScale, imageYOffset, buttonYOffset)
	if IsValid(self.SideBar) then return end
	self.SideBar = vgui.Create("GOBBO.Sidebar", self)

	if defaultItem then
		timer.Simple(0, function()
			if not IsValid(self.SideBar) then return end
			self.SideBar:SelectItem(defaultItem)
		end)
	end

	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		self.SideBar:SetImageURL(imageURL)
	end

	if imageScale then self.SideBar:SetImageScale(imageScale) end
	if imageYOffset then self.SideBar:SetImageOffset(imageYOffset) end
	if buttonYOffset then self.SideBar:SetButtonOffset(buttonYOffset) end

	return self.SideBar
end

function PANEL:AddHeaderButton(elem, size)
	elem.HeaderIconSize = size or .45
	return table.insert(self.ExtraButtons, elem)
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
	local headerH = GOBBO.Scale(30)
	local btnPad = GOBBO.Scale(6)
	local btnSpacing = GOBBO.Scale(6)

	if IsValid(self.CloseButton) then
		local btnSize = headerH * .45
		self.CloseButton:SetSize(btnSize, btnSize)
		self.CloseButton:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)

		btnPad = btnPad + btnSize + btnSpacing
	end

	for _, btn in ipairs(self.ExtraButtons) do
		local btnSize = headerH * btn.HeaderIconSize
		btn:SetSize(btnSize, btnSize)
		btn:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)
		btnPad = btnPad + btnSize + btnSpacing
	end

	if IsValid(self.SideBar) then
		self.SideBar:SetPos(0, headerH)
		self.SideBar:SetSize(GOBBO.Scale(200), h - headerH)
	end

	local padding = GOBBO.Scale(6)
	self:DockPadding(self.SideBar and GOBBO.Scale(200) + padding or padding, headerH + padding, padding, padding)
	
	self:LayoutContent(w, h)
end

function PANEL:Open()
	self:SetAlpha(0)
	self:SetVisible(true)
	self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
	self:AlphaTo(0, .1, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:OnClose()
		if pnl:GetRemoveOnClose() then pnl:Remove() end
	end)
end

function PANEL:OnClose() end

function PANEL:ShowCloseButton(bool)
	self.CloseButton:SetVisible(bool)
end

function PANEL:PaintHeader(x, y, w, h)
	GOBBO.DrawRoundedBoxEx(GOBBO.Scale(6), x, y, w, h, GOBBO.Colors.Header, true, true)

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .6
		GOBBO.DrawImage(GOBBO.Scale(6), x + (h - iconSize) / 2, y + iconSize, iconSize, imageURL, color_white)
		GOBBO.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + GOBBO.Scale(12) + iconSize, y + h / 2, GOBBO.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
		return
	end

	GOBBO.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + GOBBO.Scale(6), y + h / 2, GOBBO.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
end

function PANEL:Paint(w, h)
	GOBBO.DrawRoundedBox(GOBBO.Scale(4), 0, 0, w, h, GOBBO.Colors.Background)
	self:PaintHeader(0, 0, w, GOBBO.Scale(30))
end

vgui.Register("GOBBO.Frame", PANEL, "EditablePanel")
