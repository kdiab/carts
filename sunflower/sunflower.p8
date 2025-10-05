pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init
function _init()
		debug = true
		state = "game"
		menu = false
		palt(0,false)
		palt(15,true)
		init_sunflower()
		init_upgrades()
		if debug then
				init_dbg()
		end
end


-- string math for big num
--function stringadd(a, b)
--    return tostr(tonum(a .. "", 2) + tonum(b .. "", 2), 2)
--end

function stringadd(a, b)
  a = a .. ""  -- ensure strings
  b = b .. ""
  
  local result = ""
  local carry = 0
  local i = #a
  local j = #b
  
  while i > 0 or j > 0 or carry > 0 do
    local digit_a = i > 0 and tonum(sub(a, i, i)) or 0
    local digit_b = j > 0 and tonum(sub(b, j, j)) or 0
    
    local sum = digit_a + digit_b + carry
    carry = flr(sum / 10)
    result = (sum % 10) .. result
    
    i -= 1
    j -= 1
  end
  
  return result
end

function stringsub(a, b)
  a = a .. ""
  b = b .. ""
  
  if biglt(a, b) then
    return "0"
  end
  
  local result = ""
  local borrow = 0
  local i = #a
  local j = #b
  
  while i > 0 do
    local digit_a = tonum(sub(a, i, i))
    local digit_b = j > 0 and tonum(sub(b, j, j)) or 0
    
    local diff = digit_a - digit_b - borrow
    
    if diff < 0 then
      diff = diff + 10
      borrow = 1
    else
      borrow = 0
    end
    
    result = diff .. result
    i -= 1
    j -= 1
  end
  
  while #result > 1 and sub(result, 1, 1) == "0" do
    result = sub(result, 2)
  end
  
  return result
end

function biggt(a, b)
  if #a > #b then return true end
  if #a < #b then return false end
  
  for i=1,#a do
    local digit_a = tonum(sub(a,i,i))
    local digit_b = tonum(sub(b,i,i))
    if digit_a > digit_b then return true end
    if digit_a < digit_b then return false end
  end
  
  return false
end
--
--function stringmul(a, b)
--    return tostr(tonum(a .. "", 2) * (tonum(b .. "", 2) << 16), 2)
--end

function stringmul(a, b)
  a = a .. ""
  b = b .. ""
  
  if a == "0" or b == "0" then return "0" end
  
  local result = "0"
  
  for i = #b, 1, -1 do
    local digit = tonum(sub(b, i, i))
    local partial = ""
    local carry = 0
    
    for j = #a, 1, -1 do
      local prod = tonum(sub(a, j, j)) * digit + carry
      carry = flr(prod / 10)
      partial = (prod % 10) .. partial
    end
    
    if carry > 0 then
      partial = carry .. partial
    end
    
    for k = 1, #b - i do
      partial = partial .. "0"
    end
    
    result = stringadd(result, partial)
  end
  
  return result
end

function bigqe(a, b) 
  return a == b 
end

function biglt(a, b) 
  return biggt(b, a)
end
-->8
--update & draw

function _update()
		update_menu()
		update_sunflower()
		if debug then
				update_dbg()
		end
end

function _draw()
		cls(1)
		draw_sunflower()
		draw_menu()
		if debug then
				draw_dbg()
		end
end


-->8
--sunflower
function init_sunflower()
		transition_offset = 0
		seeds = {}
		i=0
		total_seeds = "50"
		timer = 0
		fertilizer=1
		heavy_seeds=1
		growth_hormone=1
		photosynthesis=1
		bonus = "800"
		counter = 1
end

function update_sunflower()		
		timer += fertilizer
		if timer >= 30 then
				for j = 1,heavy_seeds do
						spawn_seed()
						increment_seeds(growth_hormone*photosynthesis)
				end
				timer = 0
		end
		if i >= 1080 then
				i = 0
				counter += 1
				stringadd(total_seeds,bonus)
				bonus = stringmul("800",tostr(counter))
				seeds = {}
		end
		if btnp(❎) and not menu then
		  spawn_seed()
		  increment_seeds(1+fertilizer)
		end
end

function draw_sunflower()
--		circfill(64,63,54,14)
--		spr(9,63,63,2,2)
		map()
		for s in all(seeds) do
				circfill(s.x,s.y,s.s,s.c)
				if s.s > 0 then
				circfill(s.x,s.y,0,0)
				end
		end
		draw_petals_around_circle()
		draw_info()
end


function spawn_seed()
  local p = 0.618033988749895
  local center_x = 64.5
  local center_y = 63.5
  local scale = 1.3
  local s = 0
  
  if i == 91 then  -- calculate offset once at transition
    transition_offset = 1.2 * sqrt(90) - 1.9 * sqrt(91)
  end
  
  if i > 90 then
    s = 1
    scale = 1.9
  end
  
  local angle = i * p
  local distance = scale * sqrt(i) + (i > 90 and transition_offset or 0)
  local x = center_x + cos(angle) * distance
  local y = center_y + sin(angle) * distance
  local c = flr(rnd(2) + 9)
  add(seeds, {x=x,y=y,s=s,c=c})
  i += 1
end

function increment_seeds(a)
		total_seeds = stringadd(a, total_seeds)
end

function draw_petals_around_circle()
  local center_x = 60
  local center_y = 60
  local radius = 54
  local num_petals = 30
  
  local petal_sprites = 
  {35, 35, 7, 33, 1, 39, 3, 37}            
  
  for i = 0, num_petals-1 do
    local angle = i / num_petals
    local x = center_x + cos(angle) * radius
    local y = center_y + sin(angle) * radius
    
    local rotation_angle = (angle + 0.25) % 1
    local sprite_index = flr(rotation_angle * 8) % 8
    local sprite_num = petal_sprites[sprite_index + 1]  -- +1 because lua arrays start at 1
    
    spr(sprite_num, x-4, y-4, 2, 2)
  end
end
function draw_info()
		local c = 13
--		rectfill(0,122,128,128,0)
	 print("shop:z/🅾️",1,123,c)
	 print("pollinate:❎",80,123,c)
	 print("s:"..total_seeds,1,1,c)
	 print("bonus:\n"..bonus,97,1,c)
end
-->8
--upgrade menu

function init_upgrades()
		local x=6
		local y=10
		active = 1
		upgrades = {
				{
						x=x,
						y=y,
						upgrade="fertilizer",
						cost="15",
						cost_mult="50",
						desc="+1 seed per second",
						m=30,
						lvl=fertilizer
				},
				{
						x=x,
						y=y+24,
						cost="500",
						cost_mult="1000",
						upgrade="heavy seeds",
						desc="+1 seed per pod",
						m=50,
						lvl=heavy_seeds
				},
				{
						x=x,
						y=y+48,
						upgrade="growth hormone",
						cost="10000",
						cost_mult="25000",
						desc="exponential \nproduction boost!",
						m=32000,
						lvl=growth_hormone
				},
				{
						x=x,
						y=y+80,
						upgrade="photosynthesis+",
						cost="1000000",
						cost_mult = 0,
						desc="start over but gain \n+100% boost!",
						m=32000,
						lvl=photosynthesis
				},
				
		}
end

function update_menu()
		if btnp(4) then
				menu = not menu
		end
		if btnp(⬆️) then
				active -= 1
				if active == 0 then
						active = 4
				end
		end
		if btnp(⬇️) then
				active += 1
				if active == 5 then
						active = 1
				end
		end
		if btnp(❎) and menu then
				buy_upgrade(upgrades[active])
		end
end

function draw_menu()
		local y1=7
		local y2=126
		local x1=1
		local x2=126
		local active_u = 7
		local active_c = 12
		local active_d = 6
		local inactive = 13
		if menu then
				rectfill(x1,y1,x2,y2,0)
				rect(x1,y1,x2,y2,6)
				print("⬆️",118,9,6)
				print("⬇️",118,120,6)
				print("close: z / 🅾️    buy:x / ❎",4,120,6)
				for i=1, #upgrades do
						local u = upgrades[i]
						if active == i then
								print(u.upgrade,u.x,u.y,active_u)
								print("cost: "..u.cost.." lvl: "..u.lvl,u.x,u.y+8,active_c)
								print(u.desc,u.x,u.y+16,active_d)
						else
								print(u.upgrade,u.x,u.y,inactive)
								print("cost: "..u.cost.." lvl: "..u.lvl,u.x,u.y+8,inactive)
								print(u.desc,u.x,u.y+16,inactive)
						end
				end
				active_arrow(upgrades[active])
		end
end

function active_arrow(u)
		local x = 94
		local y = u.y - 1
		local arrow = 11
		spr(arrow,x,y,2,1)
end

function buy_upgrade(u)
  if biggt(total_seeds, u.cost) then
    total_seeds = stringsub(total_seeds, u.cost) 
    u.cost = stringadd(u.cost, u.cost_mult)
  		u.lvl += 1
  		if u.upgrade == "fertilizer" then
      fertilizer += 1
    elseif u.upgrade == "heavy seeds" then
      heavy_seeds += 1
    elseif u.upgrade == "growth hormone" then
      growth_hormone += 1
    end
  end
end
-->8

-->8

-->8
--dbg
function init_dbg()
--		for j=1, 600 do
--				spawn_seed()
--		end
--juice it
		fertilizer=30	
		heavy_seeds=1
		growth_hormone=1
		photosynthesis=1
end

function update_dbg()
end

function draw_dbg()
--	print(stringmul("800","2",1,8,6))
end
__gfx__
00000000fffff0000fffffffffffffffff000ffffff02200220fffffffffffffffffffff04040404040404040007000000000000000000000000000000000000
00000000ffff0a9990fffffffffffff0009990ffff0299009920fffffffff0000fffffff40404040404040400077000000000000000000000000000000000000
00700700fff0aaaaa90fffffffffff0a99aa990ff099990099990fffffff099aa000ffff04040404040404040777777777777777000000000000000000000000
00077000fff0aaaaaa90ffffffff009aaaaa99200999aa00aa990fffff0099aaaaaa00ff40404040404040407777777777777777000000000000000000000000
00077000ff0aaaaaaaaa0ffffff0aaaaaaaaa99209aaaaa0aaa990fff0999aaaaaaaaa0f04040404040404047777777777777777000000000000000000000000
00700700ff0aaaaaaaaa0fffff09aaaaaaaaa99209aaaaaa0aaa990f0299aaaaaaaaaaa040404040404040400777777777777777000000000000000000000000
00000000ff0aaaaaaaaa90fff09aaaaaaaaa0000f09aaaaaa0aaa90f299aaa0aaaaaaa9004040404040404040077000000000000000000000000000000000000
00000000f0aaaaaaaaaaaa0f09aaaaaaaaa00000f09aaaaaaaaaaa0f299aa0aaaaaaaa9040404040404040400007000000000000000000000000000000000000
00000000f0aaaaaaaaaaa90f09aaaaaaaa0aa992f0aaaaaaaaaaaa0f00000aaaaaaaaa9004040404040404040000000000000000000000000000000000000000
00000000f09aaa0aaaaaa90f09aaaaaaa0aaa992ff09aaaaaaaaa0ff0000aaaaaaaaa90f40404040404040400000000000000000000000000000000000000000
00000000f099aaa0aaaaaa900aaaaaaaaaaa9920fff0aaaaaaaaa0ff299aaaaaaaaa90ff04040404040404040000000000000000000000000000000000000000
00000000ff099aaa0aaaaa90f0aaaaaaaaa9990ffff0aaaaaaaaa0ff299aaaaaaaaa0fff40404040404040400000000000000000000000000000000000000000
00000000fff099aa00aa9990ff00aaaaaa9900ffffff09aaaaaa0fff0299aaaaa900ffff04040404040404040000000000000000000000000000000000000000
00000000fff099990099990fffff000aa990fffffffff09aaaaa0ffff099aa99a0ffffff40404040404040400000000000000000000000000000000000000000
00000000ffff0299009920fffffffff0000fffffffffff0999a0ffffff0999000fffffff04040404040404040000000000000000000000000000000000000000
00000000fffff02200220ffffffffffffffffffffffffff0000ffffffff000ffffffffff40404040404040400000000000000000000000000000000000000000
00000000ffffff0000ffffffffffffffffffffffffffffffffffffffffffff000000ffff00000000000000000000000000000000000000000000000000000000
00000000fffff0aaaa000ffff0022220000fffffffffff000222200ffff000aaaaa90fff00000000000000000000000000000000000000000000000000000000
00000000fff00aaaaaaaa0fff000992299900fffff0000992999200fff0aaaaaaaaa90ff00000000000000000000000000000000000000000000000000000000
00000000ff09aaaaaaaaaa0ff22009a9aaa990fff099999aaaa9002ff0aaaaaaaaaa90ff00000000000000000000000000000000000000000000000000000000
00000000ff09aaaaaaaaaa0ff29900aaaaaaa0ff09aaaaaaaa90092ff0aaaaaaaaaa90ff00000000000000000000000000000000000000000000000000000000
00000000f09aaaaaaaaaaa0ff29a900aaaaaaa0f0aaaaaaaa000992ff0aaaa0aaaaa90ff00000000000000000000000000000000000000000000000000000000
00000000f09aaaaaa00aaaa0f29aa00aaaaaaaa00aaaaaa0000aa22f0aaaaa0aaaaa990f00000000000000000000000000000000000000000000000000000000
00000000f09aaaaa0aaaaaa0f02aaa00aaaaaaa00aaaaaa00aaa920f0aaaaaa000aaa90f00000000000000000000000000000000000000000000000000000000
00000000f029aaa00aaaaaa0f09aaa000aaaaaa00aaaaaa0aaaaa90f0aaaaaaa00aaa20f00000000000000000000000000000000000000000000000000000000
00000000f22aa0000aaaaaa0f099aaaaa0aaaaa00aaaa00aaaaaa90f0aaaaaaaa00aa92f00000000000000000000000000000000000000000000000000000000
00000000f299000aaaaaaaa0ff09aaaaa0aaaa0ff0aaaaaaaaaaa90ff0aaaaaaa009a92f00000000000000000000000000000000000000000000000000000000
00000000f29009aaaaaaaa90ff09aaaaaaaaaa0ff0aaaaaaaaaa90ffff0aaaaaaa00992f00000000000000000000000000000000000000000000000000000000
00000000f2009aaaa999990fff09aaaaaaaaaa0ff0aaaaaaaaaa90ffff099aaa9a90022f00000000000000000000000000000000000000000000000000000000
00000000f0029992990000ffff09aaaaaaaaa0ffff0aaaaaaaa00ffffff009992299000f00000000000000000000000000000000000000000000000000000000
00000000f002222000fffffffff09aaaaa000ffffff000aaaa0ffffffffff0000222200f00000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffffffff000000ffffffffffff0000ffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000191a191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090a090a090a090a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000009090a191a191a191a1900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000091a191a090a090a090a090a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000090a090a191a191a191a191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009090a090a090a090a090a090a090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009191a191a191a191a191a191a190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009090a090a090a090a090a090a090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009191a191a191a191a191a191a190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000090a090a090a090a090a090a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000191a191a191a191a191a191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000a090a090a090a090a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000191a191a191a191a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a090a090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
