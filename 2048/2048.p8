pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init

function _init()
		debug = true
		grid = {}
		init_grid()
		game_state = "game"
		if debug then
				dbg_init()
		end
end

function init_grid()
		for i = 1, 4 do
		    grid[i] = {}
		    for j = 1, 4 do
		        grid[i][j] = 0
		    end
		end
		spawn_number()
end
-->8
-- game draw & update

function _update()
		if game_state == "game" then
				update_grid()
		elseif game_state == "dead" then
				update_dead()
		end
end

function _draw()
		cls()
		draw_grid()
		if game_state == "dead" then
				draw_dead()
		end
end
-->8
-- grid

function update_grid()
		is_game_over()
		if is_game_over() then 
				game_state = "dead"
		end
		if btnp(➡️) then
				move_right()
				spawn_number()
		end
		if btnp(⬅️) then
				move_left()
				spawn_number()
		end
		if btnp(⬆️) then
				move_up()
				spawn_number()
		end
		if btnp(⬇️) then
				move_down()
				spawn_number()
		end
end

function draw_grid()
local y = 40
local x = 20
local gx = 30
local gy = 30
local gx1 = gx+(12*6)+12
local gy1 = gy+(10*4)+12
line(gx,gy,gx1,gy) --top
line(gx,gy,gx,gy1) --left
line(gx,gy1,gx1,gy1) --bottom
line(gx1,gy,gx1,gy1) --right
		for i=1, #grid do
				for j=1, #grid do
						x += 18
						if grid[i][j] == 0 then
								print(" ",x,y)
						else
								print(grid[i][j],x,y)
						end
				end
				x=20
				y += 10
		end
end

function move_right()
		for i=1, #grid do
				for pass=1, #grid -1 do
						for j=#grid, 2, -1 do
							swap_h(i,j-1,j)	
						end	
				end
		end
end

function move_left()
		for i=1, #grid do
				for pass=1, #grid -1 do
						for j=1, #grid-1, 1 do
							swap_h(i,j+1,j)	
						end	
				end
		end
end

function move_down()
		for i=1, #grid do
				for pass=1, #grid -1 do
						for j=1, #grid-1, 1 do
							swap_v(j,j+1,i)	
						end	
				end
		end
end

function move_up()
		for i=1, #grid do
				for pass=1, #grid -1 do
						for j=#grid, 2, -1 do
							swap_v(j,j-1,i)	
						end	
				end
		end
end

function swap_h(row,c1,c2)
		if grid[row][c2] == grid[row][c1] then
				grid[row][c1] += grid[row][c2]
				grid[row][c2] = 0
		end
		if grid[row][c2] == 0 then
				local tmp = grid[row][c1]
				grid[row][c1] = grid[row][c2]
				grid[row][c2] = tmp
		end
end

function swap_v(r1,r2,col)
		if grid[r1][col] == grid[r2][col] then
				grid[r1][col] += grid[r2][col]
				grid[r2][col] = 0
		end
		if grid[r2][col] == 0 then
				local tmp = grid[r1][col]
				grid[r1][col] = grid[r2][col]
				grid[r2][col] = tmp
		end
end

function get_empty()
		local grid_pos = {}
		local x
		local y
		for i=1, #grid do
				for j=1, #grid do
						if grid[i][j] == 0 then
								add(grid_pos,{x=i, y=j})
						end
				end
		end
		if #grid_pos == 0 then
				return {}
		end
		return grid_pos
end

function spawn_number()
		empty_cells = get_empty()
		if #empty_cells == 0 then
				return
		end
		pos = empty_cells[flr(rnd(#empty_cells)) + 1]
		grid[pos.x][pos.y] = 2
end

function can_merge()
		-- check horizontal pairs
		for i=1,4 do
				for j=1,3 do  
		    if grid[i][j] == grid[i][j+1] then
        return true
		  		end
		 	end
		end
		-- check vertical pairs  
		for i=1,3 do  
		  for j=1,4 do
		    if grid[i][j] == grid[i+1][j] then
		      return true
		    end
		  end
		end
		return false
end

function is_game_over()
		local empty_cells = get_empty()
		if #empty_cells == 0 then
				if not can_merge() then
						return true
				end
		end
		return false
end
-->8
--dbg

function dbg_init()
--		game_state = "game"
--		for i = 1, 4 do
--		    grid[i] = {}
--		    for j = 1, 4 do
--		        grid[i][j] = i+j
--		    end
--		end
		grid[1][1] = 2048
		grid[1][2] = 2048
		grid[1][3] = 2048
		grid[1][4] = 2048

end

-->8
--game_over

function update_dead()
		if btnp(4) then
				reset_game()
		end
end

function draw_dead()
		print("no more moves",45,15)
		print("press z to restart",36,95)
end

function reset_game()
		grid = {}
		init_grid()
		game_state = "game"
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
