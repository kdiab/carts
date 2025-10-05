pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init
function _init()
		debug = true
		state = "game"
		menu = false
		palt(0,false)
		palt(14,true)
		init_sunflower()
		init_upgrades()
		init_particles()
		init_john()
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

function biggte(a, b)
  return not biglt(a, b)
end
-->8
--update & draw

function _update()
		if state == "game" then
				update_menu()
				update_sunflower()
				update_particles()
				update_motivational()
		elseif state == "start" then
				update_start()
		elseif state == "intro" then
				update_intro()
		elseif state == "end" then
				update_end()
		end
		if debug then
				update_dbg()
		end
end

function _draw()
		cls(1)
		if state == "game" then
				draw_sunflower()
				draw_particles()
				draw_motivational()
				draw_menu()
		elseif state == "start" then
				draw_start()
		elseif state == "intro" then
				draw_intro()
		elseif state == "end" then
				draw_end()
		end
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
				total_seeds = stringadd(total_seeds,bonus)
				bonus = stringmul("800",tostr(counter))
				seeds = {}
				show_motivational()
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
  
  if i == 91 then
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
  spawn_particles(x,y)
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
		local c = 0
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
						cost_mult="3",
						desc="exponential \nproduction boost!",
						m=32000,
						lvl=growth_hormone
				},
				{
						x=x,
						y=y+80,
						upgrade="photosynthesis+",
						cost="1000000",
						cost_mult = "2",
						desc="start over but gain \n+100% boost!",
						m=32000,
						lvl=photosynthesis
				}
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
		local max_c = 9
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
								if u.m == u.lvl then
										print("lvl: "..u.lvl.." max.",u.x,u.y+8,max_c)
								else
										print("cost: "..u.cost.." lvl: "..u.lvl,u.x,u.y+8,active_c)
								end
								print(u.desc,u.x,u.y+16,active_d)
						else
								print(u.upgrade,u.x,u.y,inactive)
								if u.m == u.lvl then
										print("lvl: "..u.lvl.." max.",u.x,u.y+8,inactive)
								else
										print("cost: "..u.cost.." lvl: "..u.lvl,u.x,u.y+8,inactive)
								end
								print(u.desc,u.x,u.y+16,inactive)
						end
				end
				active_arrow(upgrades[active])
		end
end

function active_arrow(u)
		local x = 94
		local y = u.y - 1
		local arrow = 25
		spr(arrow,x,y,2,1)
end

function buy_upgrade(u)
		if u.m == u.lvl then
				return
		end
  if biggte(total_seeds, u.cost) then
    total_seeds = stringsub(total_seeds, u.cost) 
  		u.lvl += 1
  		if u.upgrade == "fertilizer" then
      fertilizer += 1
      u.cost = stringadd(u.cost, u.cost_mult)
    elseif u.upgrade == "heavy seeds" then
      heavy_seeds += 1
      u.cost = stringadd(u.cost, u.cost_mult)
    elseif u.upgrade == "growth hormone" then
      growth_hormone += 1
      u.cost = stringmul(u.cost, u.cost_mult)
    elseif u.upgrade == "photosynthesis+" then
      u.cost = stringmul(u.cost, u.cost_mult)
      photosynthesis += 1
      newgame_plus()
    end
  end
end

function newgame_plus()
		seeds = {}
		particles = {}
		active = 1
		menu = false
		i=0
		total_seeds = "50"
		timer = 0
		fertilizer=1
		heavy_seeds=1
		growth_hormone=1
		bonus = "800"
		counter = 1
		reset_upgrades()
		start_bloom_animation()
end

function reset_upgrades()
		local x=6
		local y=10
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
						cost_mult="3",
						desc="exponential \nproduction boost!",
						m=32000,
						lvl=growth_hormone
				},
				{
						x=x,
						y=y+80,
						upgrade="photosynthesis+",
						cost=upgrades[4].cost,
						cost_mult = 2,
						desc="start over but gain \n+100% boost!",
						m=32000,
						lvl=photosynthesis
				}
		}
end
-->8
--particles
function init_particles()
  particles = {}
  fall_particles = {}
  falling = false
  bloom_particles = {}
  blooming = false
end

function init_fall_particles()

end

function update_particles()
		update_seed_particles()
  update_fall_particles()
  update_bloom_particles()
end

function draw_particles()
		draw_seed_particles()
		draw_fall_particles()
		draw_bloom_particles()
end

function spawn_particles(x, y)
  for i = 1, 1 do
    add(particles, {
      x = x,
      y = y,
      vx = rnd(2) - 1,
      vy = rnd(2) - 1,
      life = 10,
      c = flr(rnd(2) + 9)
    })
  end
end

function start_fall_animation()
  falling = true
  fall_particles = {}
  
  for i = 1, 500 do
    add(fall_particles, {
      x = rnd(128),
      y = rnd(0),
      vy = 1 + rnd(2),
      c = flr(rnd(2) + 9),
      s = flr(rnd(2))
    })
  end
end

function start_bloom_animation()
  blooming = true
  bloom_particles = {}
  
  local center_x = 63
  local center_y = 63
  
  for i = 1, 1000 do
    local angle = rnd(1)  
    local speed = 1 + rnd(7)
    
    add(bloom_particles, {
      x = center_x,
      y = center_y,
      vx = cos(angle) * speed,
      vy = sin(angle) * speed,
      life = 30 + rnd(20),  
      c = flr(rnd(3) + 8),
      s = 1
    })
  end
end

function update_bloom_particles()
  if blooming then
    for p in all(bloom_particles) do
      p.x += p.vx
      p.y += p.vy
      p.vx *= 0.95
      p.vy *= 0.95
      p.life -= 1
      
      if p.life <= 0 then
        del(bloom_particles, p)
      end
    end
    
    if #bloom_particles == 0 then
      blooming = false
    end
  end
end


function update_fall_particles()
  if falling then
    for p in all(fall_particles) do
      p.y += p.vy
      p.vy += 0.01
      p.x += sin(p.y / 2)
      if p.y > 128 then
        del(fall_particles, p)
      end
    end
    
    if #fall_particles == 0 then
      falling = false
    end
  end
end

function update_seed_particles()
  for p in all(particles) do
    p.x += p.vx
    p.y += p.vy
    p.life -= 1
    
    p.vx *= 0.9
    p.vy *= 0.9
    --  p.vy += 0.1
    --  p.vy -= 0.05
    if p.life <= 0 then
      del(particles, p)
    end
  end
end

function draw_seed_particles()
  for p in all(particles) do
    if p.life > 5 then
      circfill(p.x, p.y, 1, p.c)
    else
      pset(p.x, p.y, p.c)
    end
  end
end

function draw_bloom_particles()
  if blooming then
    for p in all(bloom_particles) do
      if p.life > 10 then
        circfill(p.x, p.y, p.s, p.c)
      else
        pset(p.x, p.y, p.c)
      end
    end
  end
end

function draw_fall_particles()
  if falling then
    for p in all(fall_particles) do
      circfill(p.x, p.y, p.s, p.c)
    end
  end
end
-->8
--farmer john

function init_john()
 tick,frame,step=0,1,4
 john={11,13}
 init_motivational()
end

function update_john()
 tick=(tick+1)%step
 if (tick==0) frame=frame%#john+1
end

function draw_john()
	local x = 64
	local y = 64
	local legs = 45
 spr(john[frame],x,y,2,2)
 spr(legs,x,y+16,2,2)
end


function init_motivational()
  motiv_text = ""
  motiv_y = 0
  motiv_life = 0
  motiv_phrases = {
    "\^t\^wyou're on fire!",
    "\^t\^wamazing!",
    "\^t\^wget it!",
    "\^t\^wnice!",
    "\^t\^wgood job!",
    "\^t\^wkeep going!",
    "\^t\^wwow!",
    "\^t\^wperfect!",
    "\^t\^wincredible!"
  }
end

function show_motivational()
  motiv_text = motiv_phrases[flr(rnd(#motiv_phrases)) + 1]
  motiv_y = 64  
  motiv_life = 30
end

function update_motivational()
  if motiv_life > 0 then
    motiv_life -= 1
    motiv_y -= 0.8
  end
end

function draw_motivational()
  if motiv_life > 0 then
    local c = 0
    local actual_text = sub(motiv_text, 4)
    local text_width = #actual_text * 4 * 2  
    
    print(motiv_text, 69 - text_width/2, motiv_y, c)
  end
end
-->8
--dbg
function init_dbg()
--		for j=1, 600 do
--				spawn_seed()
--		end
--juice it
		fertilizer=30
		heavy_seeds=50
		growth_hormone=1
		photosynthesis=1
		total_seeds = "1000000"
end

function update_dbg()
end

function draw_dbg()
--	print(stringmul("800","2",1,8,6))
end
__gfx__
00000000eeeee0000eeeeeeeeeeeeeeeee000eeeeee02200220eeeeeeeeeeeeeeeeeeeee0404040404040404eeeeee0000eeeeeeeeeeee0000eeeeee00000000
00000000eeee0a9990eeeeeeeeeeeee0009990eeee0299009920eeeeeeeee0000eeeeeee4040404040404040eeeee077990eeeeeeeeee077990eeeee00000000
00700700eee0aaaaa90eeeeeeeeeee0a99aa990ee099990099990eeeeeee099aa000eeee0404040404040404eeeee079990eeeeeeeeee079990eeeee00000000
00077000eee0aaaaaa90eeeeeeee009aaaaa99200999aa00aa990eeeee0099aaaaaa00ee4040404040404040ee000499994000eeee000499994000ee00000000
00077000ee0aaaaaaaaa0eeeeee0aaaaaaaaa99209aaaaa0aaa990eee0999aaaaaaaaa0e0404040404040404e04749999994440ee04749999994440e00000000
00700700ee0aaaaaaaaa0eeeee09aaaaaaaaa99209aaaaaa0aaa990e0299aaaaaaaaaaa04040404040404040ee009999994400eeee009999994400ee00000000
00000000ee0aaaaaaaaa90eee09aaaaaaaaa0000e09aaaaaa0aaa90e299aaa0aaaaaaa900404040404040404eeee00000000eeeeeeee00000000eeee00000000
00000000e0aaaaaaaaaaaa0e09aaaaaaaaa00000e09aaaaaaaaaaa0e299aa0aaaaaaaa904040404040404040eeeee0f0f0f0eeeeeeeee0f0f0f0eeee00000000
00000000e0aaaaaaaaaaa90e09aaaaaaaa0aa992e0aaaaaaaaaaaa0e00000aaaaaaaaa900007000000000000eeeee06f6f60eeeeeeeee06f6f60eeee00000000
00000000e09aaa0aaaaaa90e09aaaaaaa0aaa992ee09aaaaaaaaa0ee0000aaaaaaaaa90e0077000000000000eeeee0600060eeeeeeeee0666660eeee00000000
00000000e099aaa0aaaaaa900aaaaaaaaaaa9920eee0aaaaaaaaa0ee299aaaaaaaaa90ee0777777777777777eeee006000600eeeeeee000666000eee00000000
00000000ee099aaa0aaaaa90e0aaaaaaaaa9990eeee0aaaaaaaaa0ee299aaaaaaaaa0eee7777777777777777eee01006660010eeeee01020002010ee00000000
00000000eee099aa00aa9990ee00aaaaaa9900eeeeee09aaaaaa0eee0299aaaaa900eeee7777777777777777ee0810800080180eee0810822280180e00000000
00000000eee099990099990eeeee000aa990eeeeeeeee09aaaaa0eeee099aa99a0eeeeee0777777777777777e088110888011880e08811088801188000000000
00000000eeee0299009920eeeeeeeee0000eeeeeeeeeee0999a0eeeeee0999000eeeeeee0077000000000000e082111000111280e08211100011128000000000
00000000eeeee02200220eeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeee000eeeeeeeeee00070000000000000880111111111080088011111111108000000000
00000000eeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeecccccccccccccccccccccccc000000000ff01111111110ff00000000
00000000eeeee0aaaa000eeee0022220000eeeeeeeeeee000222200eeee000aaaaa90eeecccccccccccccccccccccccc000000000ff01111111110ff00000000
00000000eee00aaaaaaaa0eee000992299900eeeee0000992999200eee0aaaaaaaaa90eecccccccccccccccccc77c777000000000ff01111111110ff00000000
00000000ee09aaaaaaaaaa0ee22009a9aaa990eee099999aaaa9002ee0aaaaaaaaaa90eeccccccccccc777cc77777777000000000ff01111111110ff00000000
00000000ee09aaaaaaaaaa0ee29900aaaaaaa0ee09aaaaaaaa90092ee0aaaaaaaaaa90eecccccccccc77777777777777000000000f0011111111100f00000000
00000000e09aaaaaaaaaaa0ee29a900aaaaaaa0e0aaaaaaaa000992ee0aaaa0aaaaa90eeccccccccc777777777777777000000000f00d1111111d00f00000000
00000000e09aaaaaa00aaaa0e29aa00aaaaaaaa00aaaaaa0000aa22e0aaaaa0aaaaa990ecccccccc77777777c77777cc00000000e0011d11111d110000000000
00000000e09aaaaa0aaaaaa0e02aaa00aaaaaaa00aaaaaa00aaa920e0aaaaaa000aaa90ecccccccccccccccccccccccc00000000ee0111ddddd1110e00000000
00000000e029aaa00aaaaaa0e09aaa000aaaaaa00aaaaaa0aaaaa90e0aaaaaaa00aaa20ecccccccccccccccccccccccc00000000ee0ddd11111ddd0e00000000
00000000e22aa0000aaaaaa0e099aaaaa0aaaaa00aaaa00aaaaaa90e0aaaaaaaa00aa92e77ccccc7cccccccccccc7ccc00000000eee001111111100e00000000
00000000e299000aaaaaaaa0ee09aaaaa0aaaa0ee0aaaaaaaaaaa90ee0aaaaaaa009a92e777ccc77ccc77777ccc777cc00000000eeee0dd000dd0eee00000000
00000000e29009aaaaaaaa90ee09aaaaaaaaaa0ee0aaaaaaaaaa90eeee0aaaaaaa00992e77777777c77777777777777c00000000eeee0d0eee0d0eee00000000
00000000e2009aaaa999990eee09aaaaaaaaaa0ee0aaaaaaaaaa90eeee099aaa9a90022e77777777c77777777777777700000000eeee050eee050eee00000000
00000000e0029992990000eeee09aaaaaaaaa0eeee0aaaaaaaa00eeeeee009992299000e77777777777777777777777700000000eee0050eee0500ee00000000
00000000e002222000eeeeeeeee09aaaaa000eeeeee000aaaa0eeeeeeeeee0000222200ecccccccccccccccccccccccc00000000eee0550eee0550ee00000000
00000000eeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeecccccccccccccccccccccccc00000000eee0000eee0000ee00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088011111111108000000000
__map__
2929293a2b292929292929292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a292929290a0a0a0a2929293a393b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929090a090a090a090a0929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292909090a0a0a0a0a0a0a0a29292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929090a0a0a090a090a090a090a292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3939090a090a0a0a0a0a0a0a0a0a292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2909090a090a090a090a090a090a092900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290a0a0a0a0a0a0a0a0a0a0a0a0a0a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2909090a090a090a090a090a0a0a092900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29090a0a0a0a0a0a0a0a0a0a0a0a0a2900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b3b090a090a090a090a090a0a0a292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29290a0a0a0a0a0a0a0a0a0a0a0a292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929290a090a090a090a090a093a2b2900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929290a0a0a0a0a0a0a0a2929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
293a2b29290a090a090a3a392929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
