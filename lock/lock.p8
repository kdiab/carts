pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		--general
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
		start_x           = -100, 
		start_y           = -100, 
		end_x             = -100, 
		end_y             = -100, 
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
		lock_counter = 9
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
		update_player()
		if intersect(wall) then
				game_state = "dead"
		end
		collect_coin()
		local offset = 64
		local inner  = 30
		local outer  = 45
		create_coin(
		offset, 
		offset,
		inner, 
		outer)
		if debug then
				debug_movement()
		end
end

function draw_game()
		draw_lock()
		draw_coin()
		draw_player()
end

function collect_coin()
		if btnp(4) then
				if not intersect(coin) then
						game_state = "dead"
				else
						coin_is_spawned = false
						lock_counter -= 1
						dial_speed *= dial_direction
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
		--player
		dial_speed        = 0.01
		dial_direction    = -1
		wall_direction    = 1
		pos               = 0
		coin_pos										= 0
		player            = {
		start_x           = -100, 
		start_y           = -100, 
		end_x             = -100, 
		end_y             = -100, 
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

function add_particles(a)
		for i = 1, 10 do
				part = {
				x=a.x+rnd(15), 
				y=a.y-11+rnd(20), 
				r=a.r, 
				col=a.c,
				life=6
				}
				add(particles, part)
		end
end

function update_particles()
		for p in all(particles) do
				p.life -= .3
				p.y -= 1
				p.r -= .1
				if p.life <= 0 then
						del(particles, p)
				end
		end
end

function draw_particles()
		cls(1)
		spr(1,player.x,player.y,2,2)
		for p in all(particles) do
				circfill(p.x,p.y,p.r,p.c)
		end	
end
-->8
--dbg

function debug_movement()
		if btn(⬆️) then dbg_pos += 0.005 end
		if btn(⬇️) then dbg_pos -= 0.005 end
		if btn(❎) then coin_is_spawned = false end
end

function debug_draw()
	local player_midpoint_y = (player.start_y + player.end_y)/2
	local player_midpoint_x = (player.start_x + player.end_x)/2
	circ(player_midpoint_x,player_midpoint_y,0,0)
	print("player_pos: "..dbg_pos..
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
