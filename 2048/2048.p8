pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init

function _init()
		debug = true
		grid = {}
		init_grid()
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
end
-->8
-- game draw & update

function _update()
		update_grid()
end

function _draw()
		cls()
		draw_grid()
end
-->8
-- grid

function update_grid()
		if btn(➡️) then
				move_right()
		end
		if btn(⬅️) then
				move_left()
		end
		if btn(⬆️) then
				move_up()
		end
		if btn(⬇️) then
				move_down()
		end
end

function draw_grid()
local y = 40
local x = 35
local gx = 42
local gy = 37
local gx1 = gx+(12*4)
local gy1 = gy+(10*4)
line(gx,gy,gx1,gy) --top
line(gx,gy,gx,gy1) --left
line(gx,gy1,gx1,gy1) --bottom
line(gx1,gy,gx1,gy1) --right
		for i=1, #grid do
				for j=1, #grid do
						x += 12
						if grid[i][j] == 0 then
								print(" ",x,y)
						else
								print(grid[i][j],x,y)
						end
				end
				x=35
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
-->8
--dbg

function dbg_init()
		grid[1][1] = 2
		grid[1][3] = 1
		grid[1][2] = 2
		grid[4][4] = 1
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
