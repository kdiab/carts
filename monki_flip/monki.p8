pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init
function _init()
		debug = true
		palt(0,false)
		palt(14,true)
		init_pillars()
		init_monki()
		if debug then
				init_debug()
		end
end

-->8
--update & draw

function _update()
		update_monki()
 	if debug then
 			update_debug()
 	end
end

function _draw()
	 cls(12)
	 draw_pillars()
	 draw_monki()
	 if debug then
				draw_debug()
		end
end
-->8
--animations

function init_states()
		idle_state()
		falling_state()
		jumping_state()
end

function idle_state()
	local p={}
 p.t,p.f,p.s=0,1,4
 p.sp={1,33}
 monki.idle = p
end

function falling_state()
	local p={}
 p.t,p.f,p.s=0,0,0
 p.sp={35}
 monki.falling = p
end

function jumping_state()
	local p={}
 p.t,p.f,p.s=0,1,4
 p.sp={7,39,41,9}
 monki.jumping = p
end

function update_animation()
	local m = monki.state 
 monki[m].t = (monki[m].t+1)%monki[m].s
 if (monki[m].t==0) then
 		monki[m].f=monki[m].f%#monki[m].sp+1
 end
end

function draw_animation()
		local m = monki.state 
		spr(monki[m].sp[monki[m].f],
		monki.x,monki.y,2,2)
end


-->8
--monki
function init_monki()
		monki={}
		monki.sp = 1
		monki.state = "falling"
		monki.x = 63
		monki.y = 0
		monki.w = 15
		monki.h = 16
		monki.p = false
		init_states()
end

function update_monki()
		if btnp(4) then
--				jump()
		end
		state_machine()
		update_animation()
end

function draw_monki()
		draw_animation()
end

function state_machine()
		--failling -> idle
		falling_state_m()
		--idle -> failling 
		idle_state_m()				
end

function idle_state_m()
		if monki.state == "idle" then
				for p in all(platforms) do
						if not on_pillar(monki,p) then
								monki.state = "falling"
						end
				end
		end
end

function falling_state_m()
		if monki.state == "falling" then
						monki.y += 2
				for p in all(platforms) do
						if on_pillar(monki,p) then
								monki.state = "idle"
						end
				end
		end
end
-->8
--pillars
function init_pillars()
		platforms = {}
		pillars = {}
		add_pillar(11,63,83)
end

function update_pillars()
end

function draw_pillars()
		for p in all(platforms) do
				spr(p.sp,p.x,p.y,2,2)
		end
		for p in all(pillars) do
				spr(p.sp,p.x,p.y,2,2)
		end
end

function add_pillar(sp,x,y)
		p = {}
		p.x = x
		p.y = y
		p.sp = sp
		p.w = 16
		p.h = 2
		for i=p.y+16, 128, 16 do
				p2 = {}
				p2.sp = 43
				p2.x = x
				p2.y = i 
				add(pillars,p2)
		end
		add(platforms,p)
end
-->8
--collision

function on_pillar(a, b)
		offset_right = 6
		offset_left = 2
		return not (
		a.x + offset_right> b.x + b.w
	 or a.x + a.w < b.x + offset_left
		or a.y > b.y + b.h
		or a.y + a.h < b.y
		)
end
-->8
--dbg
function init_debug()
monki.state = "jumping"
	p={}
 p.a=0
 p.s=5
end

function update_debug()
if btn(⬅️) then monki.x -= 1 end
if btn(➡️) then monki.x += 1 end
if btn(⬆️) then monki.y -= 1 end
if btn(⬇️) then monki.y += 1 end
end

function draw_debug()
		local m = monki.state
		for p in all(platforms) do
			print(tostr(on_pillar(monki, p))
			.."\nstate: "..m
			.."\nt: "..monki[m].t
			.."\nf: "..monki[m].f
			.."\ns: "..monki[m].s
			.."\nsp: "..monki[m].sp[monki[m].f]
			,0,0)		
		end
end
__gfx__
00000000eeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555555555555555555555555555500000000
00000000eeeeee044440eeeeeeeeeee0000eeeeeeeeeee044440eeeeeeeeeeeeeeeeeeeeeee00000eeeeeeeee55555dddd55555ee555555dd555555e00000000
00700700eeee004044040eeeeeeeee044440eeeeeeee004044040eeeeeeeeee0000eeeeeee0444440eeeeeeeee555555555555eee55555555555555e00000000
00077000eee0f0404404f0eeeeee004044040eeeeee0f0404404f0eeeeeeee044440eeeee0440004000eeeeee5e5d5dddd5d5e5eee5ee5dddd5ee5ee00000000
00077000eee0f044444400eeeee0f0404404f0eeeee0f044444400eeeeee004044040eeee04000000ff0eeeeeee5d5dddd5d5eeeee5ee55dd55ee5ee00000000
00700700e00e004400040eeeeee0f044444400eeee0e004400040eeeeee0f0404404f0eeee0444000000eeeeee5d55dddd55d5eeee5ee5d55d5ee5ee00000000
000000000440e000fff00eeeee00004400040eeee040e000fff00eeeeee0f044444400eee004404044440eeeee5dd5dddd5dd5eee555e55dd55e555e00000000
00000000040e0444000440eee0440e00fff00eee0440004400044000ee00004400040eee040f0440440040eeeee5d5dddd5d5eeee595e5d55d5e595e00000000
00000000040e04444444440ee040e044000440ee040f44444444444fe0440000fff00eee0000040f044440eeeeee55dddd55eeeee565e5dddd5e565e00000000
00000000040e04044444040ee040e0444444440e0400004444444000e0400044000440ee0444040f044440eeeeeee5dddd5eeeeee565e5dddd5e565e00000000
0000000004400f0444440f0ee040e0404444040e04000044444440eee04004044444040e0f00040f040040eeeeeee5dddd5eeeeee555e5dddd5e555e00000000
00000000e04400044444400ee04400f044440f0e04444044444440eee04004400000440e000f044044440eeeeeeee5dddd5eeeeeeeeee5dddd5eeeee00000000
00000000ee00e004444440eeee0440040440e0eee0000044444440eee044044f040f440e0f04404000f0eeeeeeeee5dddd5eeeeeeeeee5dddd5eeeee00000000
00000000eeeeee04000040eeee04400400400eeeeeeee040000040eeee044000040000eee004440ee00eeeeeeeeee5dddd5eeeeeeeeee5dddd5eeeee00000000
00000000eeeeee0f0ee0f0eeeee00e04f04f0eeeeeeee0f0eee0f0eeeee00e0404f0f0eeeee000eeeeeeeeeeeeeee5dddd5eeeeeeeeee5dddd5eeeee00000000
00000000eeeeee000ee000eeeeeeeee000000eeeeeeee000eee000eeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeee5dddd5eeeeeeeeee5dddd5eeeee00000000
00000000eeeeeeeeeeeeeeeeeeeeeee0000eeeee888e888e888e888eeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeeee0000eeeeeeeeeee044440eeee8eee8e8e8eee8eeeeeeeeeeeee000eeeee0f0f4040e00eeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeee044440eeeee0ee0040440400ee888e888e88ee88eeeeeee00ee044400eee000040000440eeeeeee5dddd5eeeeedddddddddddddddd00000000
00000000eeee004044040eee0400f04044040f0eee8e8e8e8eee8eeeeeee0f00040440f0e044f040f440440eeeeee5dddd5eeeeed66666666666666600000000
00000000eee0f0404404f0ee040040444444040e888e8e8e8eee888eeee044440440f000e04400000440040eeeeee5dddd5eeeeed66666666666666600000000
00000000e000f044444400ee040040440004040eeeeeeeeeeeeeeeeeee040040f04000f0e04044444040040eeeeee5dddd5eeeeed66666666666666600000000
000000000444004400040eee04004000fff0040eeeeeeeeeeeeeeeeeee044440f0404440ee0440004400040eeeeee5dddd5eeeeed66666666666666600000000
000000000400e000fff000ee040044440004440eeeeeeeeeeeeeeeeeee044440f0400000eee00fff0000440eeeeee5dddd5eeeeed66666666666666600000000
00000000040e04440004440e040e0044444440eeeeeeeeeeeeeeeeeeee0400440440f040eee04000440000eeeeeee5dddd5eeeeed66666666666666600000000
00000000040e04044444040e040ee044444440eeeeeeeeeeeeeeeeeeeee044440404400eee004444440f0eeeeeeee5dddd5eeeeedddddddddddddddd00000000
0000000004400f0444440f0e04400044444440eeeeeeeeeeeeeeeeeeeeee0000004440eeee0f4044040f0eeeeeeee5dddd5eeeeed55555555555555500000000
00000000e04400044444400ee0444044444440eeeeeeeeeeeeeeeeeeeeee0ff00000040eeee040440400eeeeeeeee5dddd5eeeeedddddddddddddddd00000000
00000000ee00e004444440eeee000044444440eeeeeeeeeeeeeeeeeeeeeee0004000440eeeee044440eeeeeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeee04000040eeeeeee040000040eeeeeeeeeeeeeeeeeeeeeeeee0444440eeeeeee0000eeeeeeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeee0f0ee0f0eeeeeee0f0eee0f0eeeeeeeeeeeeeeeeeeeeeeeeee00000eeeeeeeeeeeeeeeeeeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeee000ee000eeeeeee000eee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5dddd5eeeeeeeeeeeeeeeeeeeee00000000
