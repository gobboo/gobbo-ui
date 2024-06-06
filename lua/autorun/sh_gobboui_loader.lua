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

GOBBO = GOBBO or {}
GOBBO.UI = GOBBO.UI or {}
GOBBO.UI.Version = "1.3.1"

function GOBBO.LoadDirectory(path)
	local files, folders = file.Find(path .. "/*", "LUA")

	for _, fileName in ipairs(files) do
		local filePath = path .. "/" .. fileName


		if fileName:StartWith("cl_") then
			if SERVER then
				AddCSLuaFile(filePath)
			else
				include(filePath)
			end
		elseif fileName:StartWith("sh_") then
			AddCSLuaFile(filePath)
			include(filePath)
		else
			if SERVER then include(filePath) end
		end
	end

	return files, folders
end

function GOBBO.LoadDirectoryRecursive(basePath)
	local _, folders = GOBBO.LoadDirectory(basePath)
	for _, folderName in ipairs(folders) do
		GOBBO.LoadDirectoryRecursive(basePath .. "/" .. folderName)
	end

	print("Gobbo's Stuff | Loaded directory: " .. basePath)
end

GOBBO.LoadDirectoryRecursive("gobboui")

hook.Run("GOBBO.UI.FullyLoaded")

if CLIENT then return end

resource.AddWorkshop("2468112758")

hook.Add("Think", "GOBBO.UI.VersionChecker", function()
	hook.Remove("Think", "GOBBO.UI.VersionChecker")

	http.Fetch("https://raw.githubusercontent.com/gobboo/gobbo-ui/master/VERSION", function(body)
		if GOBBO.UI.Version ~= string.Trim(body) then
			local red = Color(192, 27, 27)

			MsgC(red,
				"[GOBBO UI] There is an update available, please download it at: https://github.com/gobboo/gobbo-ui/releases\n")
			MsgC(red, "\nYour version: " .. GOBBO.UI.Version .. "\n")
			MsgC(red, "New  version: " .. body .. "\n")
			return
		end
	end)
end)
