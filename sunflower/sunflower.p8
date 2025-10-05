pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init
function _init()
		debug = false
		state = "start"
		menu = false
		palt(0,false)
		palt(14,true)
		init_sunflower()
		init_upgrades()
		init_particles()
		init_john()
		init_story()
		init_ending()
		if debug then
				init_dbg()
		end
end

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
		cls()
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

--misc functions

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
--game menus

--start
function update_start()
		if btnp(❎) then
				state = "intro"
				start_story()
		end
end

function draw_start()
		print("press ❎ to start",24,44,7)
		print("\fccontrols",42,74,7)
		print("❎ pollinate",34,84,7)
		print("z/🅾️ open/close shop",20,92,7)
		print("⬆️/⬇️ navigate shop",22,100,7)
end

--intro

function update_intro()
		update_john()
		update_story()
		if not story_active then
			 if btnp(❎) then
			 		state = "game"
			 end
		end
end

function draw_intro()
		draw_john()
		draw_story()
		if not story_active then
			 print("press ❎ to start",24,24,7)
		end
end

--tutorial

-- i think the game is 
-- self explanatory
-- will consider

--end
function update_end()
				update_ending()
				update_eviljohn()
				update_particles()
end

function draw_end()
				draw_ending()
				draw_particles()
				if show_shadow then
						spr(73,65,90,2,4)
				end
				if show_eviljohn then
				draw_eviljohn()
				spawn_flames(73,120,30) 
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
		  increment_seeds((1+fertilizer)*photosynthesis)
		end
		if biggte(total_seeds, "1000000000") then
				state = "end"
				start_ending()
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
  flames = {}
end

function init_fall_particles()

end

function update_particles()
		update_seed_particles()
  update_fall_particles()
  update_bloom_particles()
  update_flames()
end

function draw_particles()
		draw_seed_particles()
		draw_fall_particles()
		draw_bloom_particles()
		draw_flames()
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

function spawn_flames(x, y, count)
  for i = 1, count or 10 do
    add(flames, {
      x = x + rnd(8) - 4,
      y = y,
      vy = -0.5 - rnd(1),  
      vx = rnd(1) - 0.5, 
      life = 15 + rnd(15),
      c = 9
    })
  end
end

function update_flames()
  for f in all(flames) do
    f.x += f.vx
    f.y += f.vy
    f.vy -= 0.05 
    f.life -= 1
    
    if f.life > 20 then
      f.c = 10  
    elseif f.life > 10 then
      f.c = 9   
    else
      f.c = 8 
    end
    if f.life < 5 then f.c = 5 end
    
    if f.life <= 0 then
      del(flames, f)
    end
  end
end

function draw_flames()
  for f in all(flames) do
    if f.life > 5 then
      circfill(f.x, f.y, 1, f.c)
    else
      pset(f.x, f.y, f.c)
    end
  end
end
-->8
--farmer john
-- evil variant 73 75 77

function init_john()
 tick,frame,step=0,1,4
 john={11,13}
 evil_john = {75,77}
 init_motivational()
end

function update_john()
 tick=(tick+1)%step
 if (tick==0) frame=frame%#john+1
end

function draw_john()
	local x = 112
	local y = 84
	local legs = 45

 spr(john[frame],x,y,2,2)
 spr(legs,x,y+16,2,2)
end

function update_eviljohn()
 tick=(tick+1)%step
 if (tick==0) frame=frame%#evil_john+1
end

function draw_eviljohn()
	local x = 65
	local y = 90
	local legs = 45
 spr(evil_john[frame],x,y,2,4)
-- spr(legs,x,y+16,2,2)
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

function init_story()
  story_text = "\f6farmer john:\n\n\f7the world is dying...\ndarkness spreads \nacross the land.\nonly one thing can save us: \n\f8one billion sunflower seeds!\n\f7their golden light will\nrestore hope to humanity.\ngrow them. save the world."
  story_index = 0
  story_timer = 0
  story_active = false
  story_speed = 2
end

function start_story()
  story_index = 0
  story_timer = 0
  story_active = true
end

function update_story()
  if story_active then
    story_timer += 1
    
    if story_timer >= story_speed then
      story_index += 1
      story_timer = 0
      
      if story_index >= #story_text then
        story_active = false
      end
    end
  end
end

function draw_story()
  if story_active or story_index > 0 then
    local revealed = sub(story_text, 1, story_index)
    if state == "intro" then
    		print(revealed, 10, 40, 7)
    elseif state == "end" then
    		print(revealed, 10, 5, 7)
    end
  end
end

function init_ending()
  ending_lines = {}
  ending_text = ""
  ending_index = 0
  ending_timer = 0
  ending_active = false
  ending_scroll = 0
  ending_speed = 2
  show_eviljohn = false
  eviljohn_trigger_index = 0
  eviljohn_shadow_index = 0
 	show_shadow = false
end

function start_ending()
  ending_text = "\f7you did it!\n\n\faone billion seeds!\f7\n\nthe world is saved!\n\n...\n\n\f8wait.\f7\n\nthe seeds are \f8glowing\f7.\n\n\f8farmer john\f7 appears from \nthe shadows.\n\n\"well done, puppet.\n\nyou grew my \f8army\f7 for me.\n\neach seed... a vessel \nof \f8darkness\f7.\n\none billion seeds to \n\f8consume\f7 the sun!\n\nthe world won't be saved...\n\nit will be \f8mine!!!\f7.\"\n\nthe sky turns \f8black\f7.\n\nyou've \f8doomed\f7 us all.\n\n\f8game over.\f7"
  
  ending_index = 0
  ending_timer = 0
  ending_active = true
  ending_scroll = 0
  show_eviljohn = false
  show_shadow = false
  eviljohn_trigger_index = 160
  eviljohn_shadow_index = 150
end

function update_ending()
  if ending_active then
    ending_timer += 1
    
    if ending_timer >= ending_speed then
      ending_index += 1
      ending_timer = 0
    if ending_index >= eviljohn_shadow_index and not show_shadow then
      show_shadow = true
    end
    if ending_index >= eviljohn_trigger_index and not show_eviljohn then
      show_shadow = false
      show_eviljohn = true
    end
      local revealed = sub(ending_text, 1, ending_index)
      local line_count = 0
      for i = 1, #revealed do
        if sub(revealed, i, i) == "\n" then
          line_count += 1
        end
      end
      
      if line_count > 12 then
        ending_scroll += 0.5
      end
      
      if ending_index >= #ending_text then
        ending_active = false
      end
    end
  end
end

function draw_ending()
  if ending_active or ending_index > 0 then
    cls(0)
    local revealed = sub(ending_text, 1, ending_index)
    print(revealed, 20, 20 - ending_scroll, 7)
  end
end
-->8
--dbg
function init_dbg()
--		for j=1, 600 do
--				spawn_seed()
--		end
--juice it
--		fertilizer=30
--		heavy_seeds=50
--		growth_hormone=1
--		photosynthesis=1
		total_seeds = "999999990"
--state = "end"
end

function update_dbg()
end

function draw_dbg()
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
00000000eeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeecccccccccccccccccccccccc00000000eee0000eeee000ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeeee00eee00eeeeeeeee00eee00eeeeeeeeeeeeeeeeeeee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeee0880e0880eeeeeee0880e0880eeeeeeee00eee00eeee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeeee080e080eeeeeeeee080e080eeeeeeee0880e0880eee00000000
000000000000000000000000000000000000000000000000000000000000000000000000e00ee0800080ee00e00ee0800080ee00eeeee080e080eeee00000000
000000000000000000000000000000000000000000000000000000000000000000000000010ee0111110ee010f0ee0fffff0ee0fe00ee0800080ee0000000000
000000000000000000000000000000000000000000000000000000000000000000000000010ee0111110ee010f0ee0fffff0ee0f0f0ee0fffff0ee0f00000000
000000000000000000000000000000000000000000000000000000000000000000000000010ee0181810ee010f0ee0f8f8f0ee0f0f0ee0fffff0ee0f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000110e0111110ee010ff0e06f6f60ee0f0f0ee0f8f8f0ee0f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000110e0100010e0110ff0e0600060e0ff0ff0e06f6f60ee0f00000000
00000000000000000000000000000000000000000000000000000000000000000000000001110010001001110fff006000600fff0ff0e0666660e0ff00000000
00000000000000000000000000000000000000000000000000000000000000000000000001101001110010110ff01006660010ff0fff000666000fff00000000
00000000000000000000000000000000000000000000000000000000000000000000000001011011111011010f0810800080180f0ff01020002010ff00000000
000000000000000000000000000000000000000000000000000000000000000000000000e01111011101111000881108880118800f0810822280180f00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee0111100011110eee0211100011120ee08811088801188000000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeee0211100011120e00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeeee01111111110ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeeee01111111110ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeeee01111111110ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeeee01111111110ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee01111111110eeeee01111111110eeeee01111111110ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee0011111111100eee0011111111100eee0011111111100e00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee00d1111111d00eee00d1111111d00eee00d1111111d00e00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee011d11111d110eee011d11111d110eee011d11111d110e00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee0111ddddd1110eee0111ddddd1110eee0111ddddd1110e00000000
000000000000000000000000000000000000000000000000000000000000000000000000ee0ddd11111ddd0eee0ddd11111ddd0eee0ddd11111ddd0e00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee001111111100eeee001111111100eeee001111111100e00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeee0dd000dd0eeeeeee0dd000dd0eeeeeee0dd000dd0eee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeee0d0eee0d0eeeeeee0d0eee0d0eeeeeee0d0eee0d0eee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eeee010eee010eeeeeee050eee050eeeeeee050eee050eee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee0010eee0100eeeee0050eee0500eeeee0050eee0500ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee0110eee0110eeeee0550eee0550eeeee0550eee0550ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000eee0000eee0000eeeee0000eee0000eeeee0000eee0000ee00000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc00ccccc000c000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000cc00c00cc0c0cc00cccccccccccc
c0cccc0cc0ccccc0ccccccccccc77777cc77c777ccccccccccccccc0000cccccccc0000cccccccccccccccccccccccccc0c0c0c0c0c0c0c0c0cccc0ccccccccc
c000ccccc000cc00ccccccccc777777777777777cccccccccccccc0a9990cccccc0aaaa000ccccccccccccccccccccccc00cc0c0c0c0c0c0c000cccccccccccc
ccc0cc0cccc0ccc0ccccccccc777777777777777cccc0000ccccc0aaaaa90ccc00aaaaaaaa0ccc0000ccccccccccccccc0c0c0c0c0c0c0c0ccc0cc0ccccccccc
c00cccccc000c000cccccccc7777777777777777ccc0a9990cccc0aaaaaa90c09aaaaaaaaaa0c0aaaa000cccccccccccc000c00cc0c0cc00c00ccccccccccccc
ccccccccccccccccccccccccccccccccc77777cccc0aaaaa90cc0aaaaaaaaa009aaaaaaaaaa00aaaaaaaa0cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc0aaaaaa90c0aaaaaaaaa09aaaaaaaaaaa0aaaaaaaaaa0cccccccccc000c000c000cccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccc0aaaaaaaaa00aaaaaaaaa90aaaaaa00aaaa0aaaaaaaaa0cccccccccc0c0c0c0c0c0cccccccccccccccccccc
cccccccccccccccccccccccccccccccccc0000ccc0aaaaaaaaa0aaaaaaaaaaaa0aaaa0aaaaaa0aaaaaaaaa0c0000ccccc000c0c0c0c0cccc77ccccc7cccc7ccc
ccccccccccccccccccccccccccccccccc0a9990cc0aaaaaaaaa90aaaaaaaaaa90aaa00aaaaaa0aaaa00aaaa0aaaa000cc0c0c0c0c0c07777777ccc77ccc777cc
ccccccccccc777cccccccccccccccccc0aaaaa900aaaaaaaaaaaa0aa0aaaaaa90a0000aaaaaa0aaa0aaaaaa0aaaaaaa0c000c000c0007777777777777777777c
cccccccccc777777cccccccccccccccc0aaaaaa90aaaaaaaaaaa90aaa0aaaaaa9000aaaaaaaa0aa00aaaaaa0aaaaaaaa0cccccccc77777777777777777777777
ccccccccc7777777ccccccccccccccc0aaaaaaaaa0aaa0aaaaaa909aaa0aaaaa909aaaaaaaa900000aaaaaa0aaaaaaaa0ccccccc777777777777777777777777
cccccccc77777777ccccccccccccccc0aaaaaaaaa09aaa0aaaaaa909aa00aa9990aaaa999990000aaaaaaaa0aaaaaaaa0ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc0000ccc0aaaaaaaaa909aaa0aaaaa9099900999909992990000009aaaaaaaa90aaa00aaaa00000cccccccccccccccccccccccccc
ccccccccccccccccccccccc0a9990c0aaaaaaaaaaaa09aa00aa99902990099202222000402009aaaa999990aaa0aaaaaa0aaaa000ccccccccccccccccccccccc
cccccccccccccccccccccc0aaaaa900aaaaaaaaaaa90999009999040220022004040404040029992990000aaa00aaaaaa0aaaaaaa0cccccccccccccccccccccc
cccccccccccccccccccccc0aaaaaa909aaa0aaaaaa9029900992040404040404040404040002222000022aa0000aaaaaa0aaaaaaaa0ccccccccccccccccccccc
ccccccccccccccccccccc0aaaaaaaaa09aaa0aaaaaa9022002204040404040404040404040404040404299000aaaaaaaa0aaaaaaaa0ccccccccccccccccccccc
ccccccccccccccccccccc0aaaaaaaaa099aaa0aaaaa904040404040404040404040404040404040404029009aaaaaaaa90aaaaaaaa0ccccccccccccccccccccc
ccccccccccccccccccccc0aaaaaaaaa9099aa00aa9990040404040404040404040404040404040404042009aaaa999990aaaa00aaaa0cccccccccccccccccccc
cccccccccccccccccccc0aaaaaaaaaaaa099900999900404040404040404040404040404040404040400029992990000aaaa0aaaaaa0cccccccccccccccccccc
cccccccccccccccccccc0aaaaaaaaaaa9029900992004040404040404040404040404040404040404040022220004029aaa00aaaaaa0cccccccccccccccccccc
cccccccccccccccccc000000a0aaaaaa900220022004040404040404040404040404040404040404040404040404022aa0000aaaaaa0cccccccccccccccccccc
ccccccccccccccc000aaaaa90a0aaaaaa900404040404040404040404040404040404040404040404040404040404299000aaaaaaaa0cccccccccccccccccccc
cccccccccccccc0aaaaaaaaa90a0aaaaa90404040404040404040404040404040404040404040404040404040404029009aaaaaaaa90000ccccccccccccccccc
ccccccccccccc0aaaaaaaaaa90a00aa999004040404040404040404040404040404040404040404040404040404042009aaaa999990aaaa00ccccccccccccccc
ccccccccccccc0aaaaaaaaaa9090099990040404040404040404040404040404040404040404040404040404040400029992990000aaaaaaa0cccccccccccccc
ccccccccccccc0aaaa0aaaaa9090099200404040404040404040404040404040404040404040404040404040404040022220009aaaaaaaaaaa0ccccccccccccc
cccccccccccc0aaaaa0aaaaa990002200404040404040404040404040404040404040404040404040404040404040404040299aaa0aaaaaaa90ccccccccccccc
cccccccccccc0aaaaaa000aaa90040404040404040404040404040404040404040404040404040404040404040404040404299aa0aaaaaaaa90ccccccccccccc
cccccccccccc0aaaaaaa00aaa2040404040404040404040404040404040404040404040404040404040404040404040404000000aaaaaaaaa90ccccccccccccc
cccccccccccc0aaaaaaaa00aa920404040404040404040404040404040404040404040404040404040404040404040404040000aaaaaaaaa90cccccccccccccc
cccccccccccc000000aaa009a92404040404040404040404040404040404040404040404040404040404040404040404040299aaaaaaaaa90ccccccccccccccc
ccccccccc000aaaaa90aaa00992040404040404040404040404040404040404040404040404040404040404040404040404299aaaaaaaaa000cccccccccccccc
cccccccc0aaaaaaaaa909a900224040404040404040404040404040404040404040404040404040404040404040404040400299aaaaa9009aa000ccccccccccc
ccccccc0aaaaaaaaaa9022990000404040404040404040404040404040404040404040404040404040404040404040404040099aa99a099aaaaaa00ccccccccc
ccccccc0aaaaaaaaaa90022220040404040404040404040404040404040404040404040404040404040404040404040404040099900099aaaaaaaaa0cccccccc
ccccccc0aaaa0aaaaa9040404040404040404040404040404040404040404040404040404040404040404040404040404040400000299aaaaaaaaaaa0ccccccc
cccccc0aaaaa0aaaaa990404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aaa0aaaaaaa90ccccccc
77cccc0aaaaaa000aaa90040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aa0aaaaaaaa90ccccccc
777ccc0aaaaaaa00aaa2040404040404040404040404040404040404040404040404040404040404040404040404040404040404000000aaaaaaaaa90ccccccc
7777770aaaaaaaa00aa920404040404040404040404040404040404040404040404040404040404040404040404040404040404040000aaaaaaaaa90cccccccc
77777770a000000009a92404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aaaaaaaaa90ccccccccc
777777000aaaaa9000992040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aaaaaaaaa0cccccccccc
ccccc0aaaaaaaaa9000224040404040404040404040404040404040404040404040404040404040404040404040404040404040400299aaaaa900000cccccccc
cccc0aaaaaaaaaa9090000404040404040404040404040404040404040404040404040404040404040404040404040404040404040099aa99a0aaaaa00cccccc
cccc0aaaaaaaaaa902200404040404040404040404040404040404040404040404040404040404040404040404040404040404040400999000aaaaaaaa0ccccc
cccc0aaaa0aaaaa9004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400009aaaaaaaaaaa0cccc
ccc0aaaaa0aaaaa990040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aaa0aaaaaaa90cccc
ccc0aaaaaa000aaa90404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aa0aaaaaaaa90cccc
ccc0aaaaaaa00aaa2004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000aaaaaaaaa90cccc
ccc0aaaaaaaa00aa924040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000aaaaaaaaa90ccccc
cccc0aaaaaaa009a92040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aaaaaaaaa90cccccc
ccccc0aaaaaaa00992404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aaaaaaaaa0ccccccc
ccccc099aaa90000220404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aaaaa900cccccccc
cccccc0090009990004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404099aa99a000cccc7ccc
cccccccc0a99aa9900040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040999000aa000c777cc
cccccc009aaaaa992040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400099aaaaaa00777c
ccccc0aaaaaaaaa9920404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400999aaaaaaaaa0777
cccc09aaaaaaaaa992404040404040404040404040404040404040404040404090404040404040404040404040404040404040404040400299aaaaaaaaaaa077
ccc09aaaaaaaaa000004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aaa0aaaaaaa90cc
cc09aaaaaaaaa000004040404040404040404040404040404040404040404040a040404040404040404040404040404040404040404040299aa0aaaaaaaa90cc
cc09aaaaaaaa0aa9920404040404040404040404040404040404040404040409040404040404040404040404040404040404040404040400000aaaaaaaaa90cc
cc09aaaaaaa0aaa992404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000aaaaaaaaa90ccc
cc0aaaaaaaaaaa992004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404299aaaaaaaaa90cccc
ccc0aaaaaaaaa0000040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040299aaaaaaaaa0ccccc
cccc00aaaa0009990404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400022220000900cccccc
cccccc0000a99aa9904040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404000992299900ccccccc
ccccccc009aaaaa992040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404022009a9aaa990cccccc
cccccc0aaaaaaaaa99204040404040404040404040404040404040404040404040404040404040404040404040404040404040404040429900aaaaaaa0cccccc
ccccc09aaaaaaaaa99240404040404040404040404040404040404040404040404040404040404040404040404040404040404040404029a900aaaaaaa0ccccc
cccc09aaaaaaaaa000004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040429aa00aaaaaaaa0cccc
ccc09aaaaaaaaa0000040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404002aaa00aaaaaaa0cccc
ccc09aaaaaaaa0aa99204040404040404040404040404040404040404040404040404040404040404040404040404040404040404040409aaa000aaaaaa0cccc
ccc09aaaaaaa0aaa992404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040099aaaaa0aaaaa0cccc
ccc0aaaaaaaaaaa9000040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404009aaaaa0aaaa0ccccc
cccc0aaaaaaaa000999004040404040404040404040404040404040404040404040404040404040404040404040404040404040404002209aaaaaaaaaa0ccccc
ccccc00aaaaa0a99aa9900404040404040404040404040404040404040404040404040404040404040404040404040404040404040000909aaaaaaaaaa0ccccc
ccccccc000009aaaaa9920040404040404040404040404040404040404040404040404040404040404040404040404040404040404220009aaaaaaaaa0cccccc
ccccccccc0aaaaaaaaa9924040404040404040404040404040404040404040404040404040404040404040404040404040404040402990009aaaaa000ccccccc
cc77c77709aaaaaaaaa99204040404040404040404040404040404040404040404040404040404040404040404040404040404040429a900000000a0cccccccc
777777709aaaaaaaaa000040404040404040404040404040404040404040404040404040404040404040404040404040404040404029aa00aaaaaaaa0ccccccc
77777709aaaaaaaaa0000004040404040404040404040404040404040404040404040404040404040404040404040404040404040402aaa00aaaaaaa0ccccccc
77777709aaaaaaaa0aa99240404040404040404040404040404040404040404040404040404040404040404040404040404040404009aaa000aaaaaa0ccccccc
c7777709aaaaaaa0aaa992040404040404040404040404040404040404040404040404040404040404040404040404040404040404099aaaaa0aaaaa0ccccccc
cccccc0aaaaaaaaaaa9920000040404040404040404040404040404040404040404040404040404040404040404040404040404040409aaaaa0aaaa0cccccccc
ccccccc0aaaaaaaaa99000999004040404040404040404040404040404040404040404040404040404040404040404040404002222009aaaaaaaaaa0cccccccc
cccccccc00aaaaaa990a99aa9900404040404040404040404040404040404040404040404040404040404040404040404040000992209aaaaaaaaaa0cccccccc
cccccccccc000aa9009aaaaa992004040404040404040404040404040404040404040404040404040404040404040404040422009a909aaaaaaaaa0ccccccccc
ccccccccccccc000aaaaaaaaa99240404040404040404040404040404040404040404040404040404040404040404040404029900aaa09aaaaa000cccccccccc
cccccccccccccc09aaaaaaaaa99204040404040404040404040404040404040404040404040404040404040404040404040429a900aaa000000ccccccccccccc
ccccccccccccc09aaaaaaaaa000040404040404040404040404040404040404040404040404040404040404040404040404029aa00aaaaaaaa0ccccccccccccc
cccccccccccc09aaaaaaaaa0000004040404040404040404040404040404040404040404040404040404040404040404040402aaa00aaaaaaa0ccccccccccccc
cccccccccccc09aaaaaaaa0aa99240404040404040404040404040404040404040404040404040404040404040404040404009aaa000aaaaaa0ccccccccccccc
cccccccccccc09aaaaaaa0aaa992040404040404040404040404040404040404040404040404040404040404040404040404099aaaaa0aaaaa0ccccccccccccc
cccccccccccc0aaaaaaaaaaa9000222200404040404040404040404040404040404040404040404040404040404040022220009aaaaa0aaaa0cccccccccccccc
ccccccccccccc0aaaaaaa0000992999200040404040404040404040404040404040404040404040404040404040400009922909aaaaaaaaaa077c777cccccccc
cccccccccccccc00aaaa099999aaaa90024040404040404040404040404040404040404040404040404040404040422009a9a09aaaaaaaaaa0777777cccccccc
cccccccccccccccc00009aaaaaaaa900920404040404040404040404040404040404040404040404040404040404029900aaa09aaaaaaaaa07777777cccccccc
ccccccccccccccccccc0aaaaaaaa0009924040404040404040404040404040404040404040404040404040404040429a900aaa09aaaaa00077777777cccccccc
ccccccccccccccccccc0aaaaaa0000aa220404040404040404040404040404040404040404040404040404040404029aa00aaaa000000cccc77777cccccccccc
ccccccccccccccccccc0aaaaaa00aaa9204000222200404040404040404040404040404040404040404002222000002aaa00aaaaaaa0cccccccccccccccccccc
ccccccccccccccccccc0aaaaaa0aaaa0000992999200040404040404040404040404040404040404040000992299909aaa000aaaaaa0cccccccccccccccccccc
ccccccccccccccccccc0aaaa00aaaa099999aaaa900240404040404040404040404040404040404040422009a9aaa099aaaaa0aaaaa0cccccccccccccccccccc
cccccccccccccccccccc0aaaaaaaa09aaaaaaaa9009204040404040404040404040404040404040404029900aaaaaa09aaaaa0aaaa0ccccccccccccccccccccc
cccccccccccccccccccc0aaaaaaaa0aaaaaaaa00099240404040404040404040404040404040404040429a900aaaaa09aaaaaaaaaa0ccccccccccccccccccccc
cccccccccccccccccccc0aaaaaaaa0aaaaaa0000aa2200002222000404040404040404040002222000029aa00aaaaa09aaaaaaaaaa0ccccccccccccccccccccc
ccccccccccccccccccccc0aaaaaaa0aaaaaa00aaa00009929992004040404040404040404000992299902aaa00aaaa09aaaaaaaaa0cccccccccccccccccccccc
cccccccccccccccccccccc000aaaa0aaaaaa0aaa099999aaaa9002040002220022220000022009a9aaa09aaa000aaaa09aaaaa000ccccccccccccccccccccccc
ccccccccccccccccccccccccc00000aaaa00aaa09aaaaaaaa90000009929990009922999029900aaaaa099aaaaa0aaaa000000cccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc0aaaaaaaa0aaaaaaaa000099999aaaa922009a9aaa929a900aaaaa09aaaaa0aaaa0ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc0aaaaaaaa0aaaaaa000009aaaaaaaa9029900aaaaaa29aa00aaaaa09aaaaaaaaaa0ccccccccccccccccccccccccccccccc
ccccccccccc77777cc77c777cccccc0aaaaaaaa0aaaaaa00aa0aaaaaaaa00029a900aaaaa02aaa00aaaa09aaaaaaaaaa0ccccccccccccccccccccccccccccccc
ccccccccc777777777777777ccccccc0aaaaaaa0aaaaaa0aaa0aaaaaa0000a29aa00aaaaa09aaa000aaa09aaaaaaaaa0cccccccccccccccccccccccccccccccc
ccccccccc777777777777777cccccccc000aaaa0aaaa00aaaa0aaaaaa00aaa02aaa00aaaa099aaaaa0aaa09aaaaa0007cccccccccccccccccccccccccccccccc
cccccccc7777777777777777ccccccccccc0000c0aaaaaaaaa0aaaaaa0aaaa09aaa000aaaa09aaaaa0aaaa0000007777cccccccccccccccccccccccccccccccc
ccccccccccccccccc77777cccccccccccccccccc0aaaaaaaaa0aaaa00aaaaa099aaaaa0aaa09aaaaaaaaaa0ccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc0aaaaaaaaaa0aaaaaaaaaaa09aaaaa0aaa09aaaaaaaaaa0ccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccc0aaaaaaaa00aaaaaaaaaa909aaaaaaaaa09aaaaaaaaa0cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc000aaaa0c0aaaaaaaaaa909aaaaaaaaaa09aaaaa000ccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc0000ccc0aaaaaaaa0009aaaaaaaaa0c000000cccccccccccccccccccccccccccccccccccccccc77c777
cc00c0c0cc00c000ccccc000ccc0cc00000cccccccccccccccccc000aaaa0ccc09aaaaa000cccccc000cc00c0ccc0ccc000c00cc000c000c000777cc70000077
c0ccc0c0c0c0c0c0cc0cccc0cc0cc00ccc00cccccccccccccccccccc0000ccccc000000ccccccccc0c0c0c0c0ccc0cccc0cc0c0c0c0cc0cc0c77707700707007
c000c000c0c0c000cccccc0ccc0cc00c0c00cccccccccccccccccccccccccccccccccccccccccccc000c0c0c0ccc0cccc0cc0c0c000cc0cc0077777700070007
ccc0c0c0c0c0c0cccc0cc0cccc0cc00ccc00cccccccccccccccccccccccccccccccccccccccccccc0ccc0c0c0ccc0cccc0cc0c0c0c0cc0cc077770770070700c
c00cc0c0c00cc0ccccccc000c0cccc00000ccccccccccccccccccccccccccccccccccccccccccccc0ccc00cc000c000c000c0c0c0c0cc0cc000cccccc00000cc

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
