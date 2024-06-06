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

GOBBO.UI.Overrides = GOBBO.UI.Overrides or {}

function GOBBO.UI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("gobbo_ui_override_popups", (GOBBO.OverrideDermaMenus > 1) and "1" or "0", true, false, "Should the default derma popups be restyled with GOBBO UI?", 0, 1)
function GOBBO.UI.ShouldOverrideDermaPopups()
    local overrideSetting = GOBBO.OverrideDermaMenus

    if not overrideSetting or overrideSetting == 0 then return false end
    if overrideSetting == 3 then return true end

    return overridePopupsCvar:GetBool()
end