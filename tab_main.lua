--Minetest
--Copyright (C) 2013 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

-- https://github.com/orgs/minetest/teams/engine/members

local current_game, singleplayer_refresh_gamebar

function singleplayer_refresh_gamebar()

	local old_bar = ui.find_by_name("game_button_bar")
	if old_bar ~= nil then
		old_bar:delete()
	end

	local function game_buttonbar_button_handler(fields)
		if fields.game_open_cdb then
			local maintab = ui.find_by_name("main")
			local dlg = create_store_dlg("game")
			dlg:set_parent(maintab)
			maintab:hide()
			dlg:show()
			return true
		end

		for _, game in ipairs(pkgmgr.games) do
			if fields["game_btnbar_" .. game.id] then
				apply_game(game)
				return true
			end
		end
	end

	local btnbar = buttonbar_create("game_button_bar",
		game_buttonbar_button_handler,
		{x=-0.3,y=8.75}, "horizontal", {x=12.4,y=1.15})

	for _, game in ipairs(pkgmgr.games) do
		local btn_name = "game_btnbar_" .. game.id

		local image = nil
		local text = nil
		local tooltip = core.formspec_escape(game.title)

		if (game.menuicon_path or "") ~= "" then
			image = core.formspec_escape(game.menuicon_path)
		else
			local part1 = game.id:sub(1,5)
			local part2 = game.id:sub(6,10)
			local part3 = game.id:sub(11)

			text = part1 .. "\n" .. part2
			if part3 ~= "" then
				text = text .. "\n" .. part3
			end
		end
		btnbar:add_button(btn_name, text, image, tooltip)
	end

	local plus_image = core.formspec_escape(defaulttexturedir .. "plus.png")
	btnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))
end


return {
	name = "main",
	caption = fgettext("Main"),
	cbf_formspec = function(tabview, name, tabdata)

		local version = core.get_version()

		local fs =
			"style[label_button;border=false]" ..
			"button[0.1,3.4;5.3,0.5;label_button;" ..
			core.formspec_escape(version.project .. " " .. version.string) .. "]" ..
			"button[1.5,4.1;2.5,0.8;solo;solo]"


		-- Render information
		fs = fs .. "style[label_button2;border=false]" ..
			"button[0.1,6;5.3,1;label_button2;" ..
			fgettext("Active renderer:") .. "\n" ..
			core.formspec_escape(core.get_active_renderer()) .. "]"

		if PLATFORM == "Android" then
			fs = fs .. "button[0.5,5.1;4.5,0.8;share_debug;" .. fgettext("Share debug log") .. "]"
		else
			fs = fs .. "tooltip[userdata;" ..
					fgettext("Opens the directory that contains user-provided worlds, games, mods,\n" ..
							"and texture packs in a file manager / explorer.") .. "]"
			fs = fs .. "button[0.5,5.1;4.5,0.8;userdata;" .. fgettext("Open User Data Directory") .. "]"
		end

		return fs, "size[15.5,7.1,false]real_coordinates[true]"
	end,
	cbf_button_handler = function(this, fields, name, tabdata, tabview)
		if fields.solo then
            print("bouton cliqué")
            local local_tab = tabdata["local"]  -- Assurez-vous que "local" est le nom correct de l'onglet
            if local_tab then
                tabview:switch_to_tab(local_tab)  -- tabview doit être passé en tant que paramètre à cbf_button_handler
            end
            
            return true
		end

		if fields.share_debug then
			local path = core.get_user_path() .. DIR_DELIM .. "debug.txt"
			core.share_file(path)
		end

		if fields.userdata then
			core.open_dir(core.get_user_path())
		end
	end,
}
