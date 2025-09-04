pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		debug = true
		
		pi = 3.1415926535

		bullet_init()
		player_init()
end
-->8
--update & draw
function _update()
		player_update()
		update_bullet()
end

function _draw()
		player_draw()
		draw_bullet()
		if debug then
				dbg_print()
		end
end
-->8
--player

function player_init()
		r 									= 10
		h 									= 60
		k 									= 60
		tip 							= 0
		b_l 							= 0.40
		b_r 							= 0.60
		s 									= 0.01
		base_speed = 3
		turning_speed = 0.04
		p = {
		top={x=0,y=0},
		left={x=0,y=0},
		right={x=0,y=0},
		d_vec={x=0,y=0}
		}
end

function player_update()
		p = {
		top={x=h+cos(tip+s)*r,y=k+sin(tip+s)*r},
		left={x=h+cos(b_l+s)*r,y=k+sin(b_l+s)*r},
		right={x=h+cos(b_r+s)*r,y=k+sin(b_r+s)*r},
		d_vec={x=cos(tip+s), y=sin(tip+s)}
		}
		if btn(⬅️) then
				s += turning_speed
		end
		if btn(➡️) then
				s -= turning_speed
		end
		if btn(⬆️) then
				h += p.d_vec.x*base_speed
				k += p.d_vec.y*base_speed
		end
		if btn(4) then
				spawn_bullet(
						p.top.x,
						p.top.y,
						p.d_vec.x,
						p.d_vec.y
				)
		end
		
end

function player_draw()
		cls()
		line(p.top.x, p.top.y, p.left.x, p.left.y)
		line(p.top.x, p.top.y, p.right.x, p.right.y)
		line(p.right.x, p.right.y, p.left.x, p.left.y)
		line(h, k,p.top.x,p.top.y,8)
end
-->8
--dbg

function dbg_print()
		print(
		"tip x: "..p.top.x..
		"\ntip y: "..p.top.y..
		"\nleft x: "..p.left.x..
		"\nleft y: "..p.left.y..
		"\nright x: "..p.right.x..
		"\nright y: "..p.right.y..
		"\nh : "..h..
		"\nk : "..k,

		0,0,6
		)
end
-->8
--bullet

function bullet_init()
		bullets = {}
		fire_rate = 2
end

function update_bullet()
		for i=1, #bullets do
				bullets[i].x += bullets[i].dx*fire_rate
				bullets[i].y += bullets[i].dy*fire_rate
		end
		for b in all(bullets) do
				if b.x > 128 
				or b.x < 0
				or b.y > 128
				or b.y < 0 then
						del(bullets,b)
				end
		end
end

function spawn_bullet(x, y, dx, dy)
		local b = {
							x=x,
							y=y,
							dx=dx,
							dy=dy
						}
		add(bullets,b)
end

function draw_bullet()
		for b in all(bullets) do
				circ(b.x, b.y, 1,9)
		end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
