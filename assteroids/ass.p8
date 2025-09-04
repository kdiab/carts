pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--init
function _init()
		debug = true
		
		pi = 3.1415926535
		player_init()
end
-->8
--update & draw
function _update()
		player_update()
end

function _draw()
		player_draw()
		if debug then
				dbg_print()
		end
end
-->8
--player

function player_init()
		local r = 20
		local h = 30
		local k = 30
		local tip = 0
		local b_l = 0.33
		local b_r = 0.67
		s = 0.01
		p = {
		top={x=h+cos(tip+s)*r,y=k+sin(tip+s)*r},
		left={x=h+cos(b_l+s)*r,y=k+sin(b_l+s)*r},
		right={x=h+cos(b_r+s)*r,y=k+sin(b_r+s)*r}
		}
end

function player_update()
		local r = 10
		local h = 30
		local k = 30
		local tip = 0
		local b_l = 0.40
		local b_r = 0.60
		s += 0.01
		p = {
		top={x=h+cos(tip+s)*r,y=k+sin(tip+s)*r},
		left={x=h+cos(b_l+s)*r,y=k+sin(b_l+s)*r},
		right={x=h+cos(b_r+s)*r,y=k+sin(b_r+s)*r}
		}
end

function player_draw()
		cls()
		line(p.top.x, p.top.y, p.left.x, p.left.y)
		line(p.top.x, p.top.y, p.right.x, p.right.y)
		line(p.right.x, p.right.y, p.left.x, p.left.y)
end
-->8
--dbg

function dbg_print()
		print(
		"top x: "..p.top.x..
		"\ntop y: "..p.top.y..
		"\nleft x: "..p.left.x..
		"\nleft y: "..p.left.y..
		"\nright x: "..p.right.x..
		"\nright y: "..p.right.y,
		33,43,6
		)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
