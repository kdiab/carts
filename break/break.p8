pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pico
function _init()
		player = {
				x = 80, 
				y = 120,
				speed = 2,
				h = 4,
				w = 16,
				c = 3
		}
		
		ball = {
				r = 2,
				x = 80,
				y = 120,
				c = 3
		}
		ball.x = player.x + player.w/2
		ball.y = player.y - 7
		
		bricks = {}
		bricks_init()
end

function _update()
		player_update()
		ball_update()
end

function _draw()
		cls(1)
		player_draw()
		ball_draw()
		bricks_draw()
		circ(ball.x, ball.y, 0,7)
end

function movement(a)
		if btn(⬅️) then a.x-=1 end
		if btn(➡️) then a.x+=1 end
		if btn(⬆️) then a.y-=1 end
		if btn(⬇️) then a.y+=1 end
end

function detect_collision(a,b)
		if a.r then
				return not(
				a.x > b.x + b.w or
				a.y > b.y + b.h or
				a.x + a.r < b.x  or
				a.y + a.r < b.y)
		end
		return not(
				a.x > b.x + b.w or
				a.y > b.y + b.h or
				a.x + a.w < b.x or
				a.y + a.h < b.y)
end
-->8
-- player
function player_update()
		left_bound = player.x
		right_bound = player.x + player.w
		if btn(⬅️) and left_bound > 1 then player.x -= player.speed end
		if btn(➡️) and right_bound < 127 then player.x += player.speed end
end

function player_draw()
		rectfill(player.x, player.y, player.x+player.w, player.y-player.h, player.c)
end
-->8
-- ball
function ball_update()
		movement(ball)
end

function ball_draw()
		circfill(ball.x, ball.y, ball.r, ball.c)
		for b in all(bricks) do
				if detect_collision(ball,b) then
						print(true)
						print("x: "..b.x.." y: "..b.y)
				else
						print(false, 63,63)
				end
		end
		if detect_collision(ball,player) then
				print("player_collision true")
		end
end


-->8
-- bricks

function bricks_init()
		height = 0
		h = 8
		w = 8
	 v_gap = 3
	 h_gap = 2
		for j = 0,height do
				for i = 0,15,2 do
						x1 = i * w
						y1 = j * h
						x2 = x1 + w * 2 - h_gap
						y2 = y1 + h - v_gap
						brick = {x=x1, y=y1, x2=x2, y2=y2, w=w*2-h_gap, h=h-v_gap,c=rnd(15)}
						add(bricks, brick)
			 end
		end
end

function bricks_update()
end

function bricks_draw()
		for b in all(bricks) do
				-- print("x: "..b.x.." y: "..b.y)
				rectfill(b.x, b.y, b.x2, b.y2, b.c)
		end
end
-->8
--game
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
