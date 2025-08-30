pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		--general
		coin_sfx 									= 0
		debug             =	false
		bg                = 1
		game_state        = "menu"
		--player
		dial_speed        = 0.01
		dial_direction    = -1
		wall_direction    = 1
		pos               = 0
		coin_pos										= 0
		player            = {
		start_x           = -10, 
		start_y           = -10, 
		end_x             = -10, 
		end_y             = -10, 
		col               = 8}
		--lock
		lock_counter      = 50
		--coin
		coin_is_spawned 		= false
		coin_radius       = 4
		coin_color        = 10
		coin              = {
		x																	= -100, 
		y																	= -100, 
		r                 = coin_radius, 
		col               = coin_color}
		--wall
		wall              = {
		x																	= -100,
		y                 = -100,
		r                 = 2,
		col               = 11}
		--particles
		particles 								= {}
		if debug then
				debug_init()
		end
end

function debug_init()
		game_state   = "game"
		lock_counter = 30
		dbg_pos      = 0
end

-->8
--update & draw

function _update()
		if game_state == "menu" then
				update_menu()
		elseif game_state == "game" then
				update_game()
		elseif game_state == "dead" then
				update_death()
		elseif game_state == "win" then
				update_win()
		end
end

function _draw()
		if game_state == "menu" then
				cls(bg)
				draw_menu()
		elseif game_state == "game" then
				cls(bg)
				draw_game()
		elseif game_state == "dead" then
				draw_death()
		elseif game_state == "win" then
				cls(bg)
				draw_win()
		end
		
		if debug then
				debug_draw()
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
		if intersect(wall) then
				game_state = "dead"
		end
		collect_coin()
		update_player()
		local offset = 64
		local inner  = 30
		local outer  = 45
		create_coin(
		offset, 
		offset,
		inner, 
		outer)
		update_particles(0.3, 0.3, 0.4, 6, 7)
		if debug then
				debug_movement()
		end
end

function draw_game()
		draw_lock()
		draw_coin()
		draw_player()
		draw_particles()
end

function collect_coin()
		if btnp(4) then
				if not intersect(coin) then
						game_state = "dead"
				elseif lock_counter < 1 then
						game_state = "win"
				else
						if lock_counter == 50 then
						coin_sfx = 1
						end
						if lock_counter == 30 then
								coin_sfx = 2
								dial_speed *= 1.5
						end
						if lock_counter == 15 then
								coin_sfx = 3
								dial_speed *= 1.2
						end
						sfx(coin_sfx)
						add_particles(coin, coin.col, 7)
						coin_is_spawned = false
						lock_counter -= 1
						dial_speed = dial_speed * dial_direction
				end		
		end
end
-->8
--player

function update_player()
    pos += dial_speed
    local angle = pos 
    if debug then
    		pos = dbg_pos
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
--coin

function create_coin(
		x_offset, 
		y_offset,
		inner_radius,
		outer_radius)
		if not coin_is_spawned then
				local default = 0.25
				coin_pos += rnd(0.2) + default
				local angle = coin_pos
				local m = (inner_radius + outer_radius) / 2
				local x = x_offset + cos(angle) * m
				local y = y_offset + sin(angle) * m
				coin.x = x
				coin.y = y
				coin_is_spawned = true
				create_wall(
				x_offset,
				y_offset,
				inner_radius,
				outer_radius)
				wall_direction *= -1
		end
end

function draw_coin()
		circfill(coin.x, coin.y, coin.r, coin.col)
end
-->8
--wall

function create_wall(
		x_offset, 
		y_offset,
		inner_radius,
		outer_radius)
				local angle = coin_pos + (0.05 * wall_direction)
				local m = (inner_radius + outer_radius) / 2
				local x = x_offset + cos(angle) * m
				local y = y_offset + sin(angle) * m
				wall.x = x
				wall.y = y
end

function draw_wall()
		circfill(wall.x, wall.y, wall.r, wall.col)
end
-->8
--collision
function intersect(a)
    local x = a.x - 64  -- a relative to center
    local y = a.y - 64
    local player_mx = (player.start_x + player.end_x)/2 - 64  -- player midpoint relative to center
    local player_my = (player.start_y + player.end_y)/2 - 64
    
    local dx = x - player_mx
    local dy = y - player_my
    local distance_squared = dx*dx + dy*dy
    
    local collision_radius = a.r + 1.5 -- 1 for padding
    return distance_squared < collision_radius * collision_radius
end
-->8
--death

function update_death()
		if btn(❎) then 
				init()
				game_state = "game" 
		end
end

function draw_death()
		print("oops you died!",22,3,7)
		print("press ❎ to restart")
end

function init()
		coin_sfx 									= 0
		--player
		dial_speed        = 0.01
		dial_direction    = -1
		wall_direction    = 1
		pos               = 0
		coin_pos										= 0
		player            = {
		start_x           = -10, 
		start_y           = -10, 
		end_x             = -10, 
		end_y             = -10, 
		col               = 8}
		--lock
		lock_counter      = 50
		--coin
		coin_is_spawned 		= false
		coin_radius       = 4
		coin_color        = 10
		coin              = {
		x																	= -100, 
		y																	= -100, 
		r                 = coin_radius, 
		col               = coin_color}
		--wall
		wall              = {
		x																	= -100,
		y                 = -100,
		r                 = 2,
		col               = 11}
end
-->8
--particles

function add_particles(a, col, life, offset)
		for i = 1, 10 do
				local part = {
				x= a.x+rnd(15), 
				y= a.y-11+rnd(20), 
				r= a.r-rnd(offset), 
				c= col,
				l= life
				}
				add(particles, part)
		end
end

function update_particles(lrate, yrate, rrate, half_life, cc)
		for p in all(particles) do
				p.l -= lrate
				p.y -= yrate
				p.r -= rrate
				if p.l <= half_life
						then p.c = cc
				end
				if p.l <= 0 then
						del(particles, p)
				end
		end
end

function draw_particles()
		for p in all(particles) do
				circfill(p.x,p.y,p.r,p.c)
		end	
end
-->8
--win

function update_win()
		if btn(❎) then 
				init()
				game_state = "game"	  
		end
end

function draw_win()
		draw_game()
		circfill(64,64,30,6)
		print("you win!",22,3,7)
		print("press ❎ to restart")
		print("\^w\^t\^byou",53,53,counter_color)
		print("\^w\^t\^bwin")
end
-->8
--dbg

function debug_movement()
		if btn(⬆️) then dbg_pos += 0.01 end
		if btn(⬇️) then dbg_pos -= 0.01 end
		if btn(❎) then 
		add_particles(coin, coin.col, 7) 
		end
end

function debug_draw()
	local player_midpoint_y = (player.start_y + player.end_y)/2
	local player_midpoint_x = (player.start_x + player.end_x)/2
	circ(player_midpoint_x,player_midpoint_y,0,0)
	print(
	"player_pos: "..dbg_pos..
	"\n⧗: "..time()..
	"\nx: "..player.start_x..
	"\ny: "..player.start_y..
	"\nend x: "..player.end_x..
	"\nend y: "..player.end_y..
	"\nplayer mp_y: "..player_midpoint_y..
	"\nplayer mp_x: "..player_midpoint_x..
	"\ncol: "..player.col..
	"\ncoin x: "..coin.x..
	"\ncoin y: "..coin.y..
	"\ncoin radius: "..coin.r..
	"\ncoin pos: "..coin_pos..
	"\nwall direction: "..wall_direction..
	"\ncollision status: "..tostr(intersect(coin))..
	"\ndead status: "..tostr(intersect(wall))
	,0,0,7
	)
	draw_wall()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500003a7603a7603a7603a7603c7503c7503c7503c7503070037700377003770037700377003a7003a700160001600018000190001b0001d0002000022000180001b0001d0002300028000300000000000000
010400003a7303a7303a7303c7303c7303c7303c7303c7303a7003a7003c7003c7003c7003c7003c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300003a7303a7303a7303c7303c7303c7303c7303c730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003a7303a7303a7303c7303c7303c7303c7303c730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
