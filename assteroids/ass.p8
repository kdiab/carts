pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		debug = true
		
		pi = 3.1415926535

		init_bullet()
		init_player()
		init_asteroid()
end
-->8
--update & draw
function _update()
		update_player()
		update_asteroid()
		update_bullet()
		if debug then
				dbg_spawn_asteroids()
		end
end

function _draw()
		cls(0)
		draw_player()
		draw_asteroid()
		draw_bullet()
		if debug then
				dbg_print()
		end
end
-->8
--player

function init_player()
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
		timer = 0
		fire_rate = 7
end

function update_player()
		timer += 1
		if h > 128 then
				h = 0
		elseif h < 0 then
				h = 128
		end
		if k > 128 then
				k = 0
		elseif k < 0 then
				k = 128
		end
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
		if btn(4) and timer >= fire_rate then
						spawn_bullet(
								p.top.x,
								p.top.y,
								p.d_vec.x,
								p.d_vec.y
						)
					timer = 0
		end
end

function draw_player()
		line(p.top.x, p.top.y, p.left.x, p.left.y)
		line(p.top.x, p.top.y, p.right.x, p.right.y)
		line(p.right.x, p.right.y, p.left.x, p.left.y)
end
-->8
--bullet

function init_bullet()
		bullets = {}
		bullet_size = 1
		bullet_life = 12
		bullet_color = 9
end

function update_bullet()
		for b in all(bullets) do
				b.x += b.dx*fire_rate
				if b.x > 128 then
						b.x = 0
				elseif b.x < 0 then
						b.x = 128
				end
				b.y += b.dy*fire_rate
				if b.y > 128 then
						b.y = 0
				elseif b.y < 0 then
						b.y = 128
				end
		end
		for b in all(bullets) do
				if b.l <= 0 then
						del(bullets,b)
				else
						b.l -= 1
				end
		end
end

function spawn_bullet(x, y, dx, dy)
		local b = {
							x=x,
							y=y,
							dx=dx,
							dy=dy,
							c=bullet_color,
							l=bullet_life
						}
		add(bullets,b)
end

function draw_bullet()
		for b in all(bullets) do
				circ(b.x, b.y, bullet_size,b.c)
		end
end
-->8
--assteroids

function init_asteroid()
		asteroids = {}
end

function update_asteroid()
		for a in all(asteroids) do
				a.x += a.dx
				a.y += a.dy
				if a.x < 0 then
						del(asteroids, a)
				elseif a.x > 128 then
						del(asteroids, a)
				end
				if a.y < 0 then
						del(asteroids, a)
				elseif a.y > 128 then
						del(asteroids, a)
				end
		end
end

function draw_asteroid()
		for a in all(asteroids) do
				circ(a.x, a.y, a.r, 7)
		end
end

function spawn_asteroid(r,odx,ody,ox,oy)
		local angle = rnd(1)
		local dx = cos(angle)
		local dy = sin(angle)
		local x
		local y
		if dx <= 0 and not odx then
				x = 128
		elseif dx > 0 then
				x = 0
		end
		
		if dy <= 0 and not ody then
				y = 128
		elseif dy > 0 then
				y = 0
		end
		
		if odx then
				dx = odx
		end
		if ody then
				dy = ody
		end
		if ox then
				x = ox
		end
		if oy then
				y = oy
		end
		
		local a = {
				x=x,
				y=y,
				dx=dx,
				dy=dy,
				r=r
		}
		add(asteroids, a)
end
-->8
--dbg
function dbg_spawn_asteroids()
		if btn(❎) then
				spawn_asteroid(rnd((8)))
		end
end

function dbg_print()
		line(h, k,p.top.x,p.top.y,8)
		print(
		"tip x: "..p.top.x..
		"\ntip y: "..p.top.y..
		"\nleft x: "..p.left.x..
		"\nleft y: "..p.left.y..
		"\nright x: "..p.right.x..
		"\nright y: "..p.right.y..
		"\nh : "..h..
		"\nk : "..k..
		"\ndy : "..p.d_vec.y..
		"\ndx : "..p.d_vec.x,
		0,0,6
		)
end
__gfx__
00000000007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
