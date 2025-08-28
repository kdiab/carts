pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		debug             = true
		bg                = 1
		game_state        = "menu"
		dial_speed        = 0.1
		dial_acceleration = 1
		dial_direction    = 1
		lock_counter      = 50
		player = {
		start_x           = 0, 
		start_y           = 0, 
		end_x             = 0, 
		end_y             = 0, 
		col               = 8}
		if debug then
				debug_init()
		end
end

function debug_init()
		game_state   = "game"
		lock_counter = 9
		pos          = 0
end

-->8
--update & draw

function _update()
		if game_state == "menu" then
				update_menu()
		elseif game_state == "game" then
				update_game()
		end
end

function _draw()
		cls(bg)
		if game_state == "menu" then
				draw_menu()
		elseif game_state == "game" then
				draw_game()
		end
end
-->8
--menu

function update_menu()
		if btn(4) then 
				game_state = "game" 
		end
end

function draw_menu()
		print("press 🅾️ (z) to start!",22,63,7)
end
-->8
--game

function update_game()
		update_player()
		if debug then
				debug_movement()
		end
end

function draw_game()
		draw_lock()
		draw_player()
end
-->8
--player

function update_player()
    local angle = dial_direction * time() * dial_speed * dial_acceleration
    if debug then
    		angle = dial_direction * pos
   	end
    local inner_radius = 30
    local outer_radius = 45
    local center_x = 64
    local center_y = 64
 
    local start_x = center_x + cos(angle) * inner_radius
    local start_y = center_y + sin(angle) * inner_radius
    local end_x = center_x + cos(angle) * outer_radius
    local end_y = center_y + sin(angle) * outer_radius
				player.start_x = start_x 
				player.start_y = start_y
				player.end_x = end_x
				player.end_y = end_y
end

function draw_player()
				if debug then
						print("⧗: "..time().."\nx: "..player.start_x.."\ny: "..player.start_y.."\nend x: "..player.end_x.."\nend y: "..player.end_y.."\ncol: "..player.col,0,0,7)
    end
    line(player.start_x, player.start_y, player.end_x, player.end_y, player.col)   
end
-->8
--lock
function draw_lock()
		local lock_color = 6
		local counter_color = 0
		local x = 57
		local y = 59
		local cirx = 64
		local ciry = 64
		local cirin = 30
		local cirout = 45
		if lock_counter < 10 then
				x = 61
		end
		circfill(cirx,ciry,cirin,lock_color)
		circ(cirx,ciry,cirin,lock_color)
		circ(cirx,ciry,cirout,lock_color)
		print("\^w\^t\^b"..lock_counter,x,y,counter_color) 
end
-->8
--dbg

function debug_movement()
		if btn(⬆️) then pos += 0.01 end
		if btn(⬇️) then pos -= 0.01 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
