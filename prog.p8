pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--mirror image
--version: alpha

--init
function _init()
  -- game variables --
  modes = {"title","game","over"}
  game = modes[1]
  menuitem(1,"switch level", function() toggle_level() end)
  prev_t = time()
  pot_kills = 0 --total potential kills
  kill_limit = 3 --per level
  text_prevt = time() + rnd(10)
  text_dur = 2
  speaker = null
  msg = null
  enemy_is_talking = false
  killtext_t = 0
  killtext_dur = 2
  killmsg = null
  neutral_text = {
          "hmm...",
          ":(",
          "...",
          "?",
          "where...?",
          "she's not here",
          "anyone?"
  }
  evil_text = {
        "stop her!",
        "killer!",
        "stay away!",
        "be careful",
        "kill on sight",
        "she'll kill us"
  }
  good_text = {
        "poor girl...",
        "...",
        "life is hard",
        "it's an order",
        "no choice",
        "who is she",
        "what are we doing?"
  }
  text = {neutral_text,evil_text,good_text}
  killed_text = {
        "oh no!",
        "d:",
        "jeff!!",
        "kyle!!",
        "aaron!!",
        "killer!!",
        "man down!",
        "call back up!"
  }
  --ratio = 0 -- tot_kills/pot_kills
  nlvls = 3
  lvl = -1
  lvl_kill_cap = 3
  x = {10,0,0} --player position by level
  y = {104,96,104}
  exit_x = {127,127,0} --position to proceed to next level
  exit_y = {24,32,0}

  music(1)

  -- player static variables --
  player = {}
  player.lvl_killc = 3
  player.max_hp = 10
  player.morality = 0
  morality_sp = {1,2,3}
  --sprites = {idle,walk1,walk2,crouch_idle,crouch_move,jump,attack}
  neutral_sprites = {1,3,4,2,18,5,6}
  evil_sprites = {32,34,35,33,49,36,37}
  good_sprites = {38,40,41,39,55,42,43}
  sprites = {neutral_sprites,evil_sprites,good_sprites}
  --size by 8x8 chunks
  --size = {idle,walk1,walk2,crouch_idle,crouch_move,jump,attack}
  neutral_w = {1,1,1,1,1,1,1}
  neutral_h = {2,2,2,1,1,2,2}
  evil_w = {1,1,1,1,1,1,1}
  evil_h = {2,2,2,1,1,2,2}
  good_w = {1,1,1,1,1,1,1}
  good_h = {2,2,2,1,1,2,2}
  w = {neutral_w,evil_w,good_w}
  h = {neutral_h,evil_h,good_h}
  --size by pixels
  --size = {idle,walk1,walk2,crouch_idle,crouch_move,jump,attack}
  neutral_pw = {8,8,8,8,8,8,8}
  neutral_ph = {16,16,16,8,8,16,16}
  evil_pw = {8,8,8,8,8,8,8}
  evil_ph = {16,16,16,8,8,16,16}
  good_pw = {8,8,8,8,8,8,8}
  good_ph = {16,16,16,8,8,16,16}
  pw = {neutral_pw,evil_pw,good_pw}
  ph = {neutral_ph,evil_ph,good_ph}
  --speed = {walking, crouching, jumping}
  neutral_speed = {32,16,32}
  evil_speed = {32,16,32}
  good_speed = {32,16,32}
  speed = {neutral_speed,evil_speed,good_speed}
  --attribute sprites
  --health_sp = {full,empty}
  health_sp = {44,60}
  --blast_sp = {full,empty}
  blast_sp = {45,61}
  --stealth = {neutral,evil,good}
  stealth = {0,-10,10}
  --blinking, offset = {standing,crouching}
  blink_dur = 0.5
  eye_color = {7,8,7}
  eye_offset_y = {3,2}
  eye_offset_x = {3,4}
  -- player current variables --
  player.is_dead = false
  player.morality_sp = morality_sp[1]
  player.s = sprites[player.morality_sp][1] --sprite, idle
  player.s_w = w[player.morality_sp][1] --sprite size
  player.s_h = h[player.morality_sp][1]
  player.w = pw[player.morality_sp][1] --size by pixels
  player.h = ph[player.morality_sp][1]
  player.x = 0 --position
  player.y = 0
  player.hp = player.max_hp
  player.flipped = false
  player.move_animt = 0.5
  player.move_prevt = 0
  player.speed = speed[player.morality_sp][1] --neutral walking
  player.stealth = stealth[3]
  player.is_crouching = false
  --player.tot_kills = 0 --total kills
  player.is_stunned = false
  player.is_jumping = false
  player.can_triplej = false
  --shoot, do attacking animation
  player.shoot_start = 0
  player.shoot_animt = 0.5
  --got hit, do flashing animation
  player.is_hit = false
  player.hit_start = 0
  player.hit_prevt = 0 --time flashes
  player.hit_dur = 1 --length of flashing
  player.hit_s = 47 --sprite to flash to
  player.hit_prev_s = player.s --most recent sprite
  --blinking
  player.eye_offset_y = eye_offset_y[1]
  player.eye_offset_x = eye_offset_x[1]
  player.eye_gap = 2
  player.next_blink = time() + flr(rnd(10)+1)
  player.eyes_open = true
  player.eye_color = eye_color[player.morality_sp]
  --particles
  p = {}
  p.limit = 20
  p.prevt = {time(),time()} --{hair,blast}
  p.timecap = {0.5,0.2} --{hair,blast}
  p.lifespan = {0.5,1} --{hair,blast}
  rndx = {8,4} --{hair,blast}
  rndy = {4,8} --{hair,blast}
  neutral_colors = {}
  good_colors = {7,12}
  evil_colors = {8,9,10}
  hair_colors = {neutral_colors,evil_colors,good_colors}
  blast_colors = {1,5,6,7}

  --jumping variables
  player.jump_tprev = 0 --jump time
  player.jump_prog = 0 --jump progress in remaining height
  player.njump = 0 --first, second, or third jump
  player.jump1 = 16 --height of first jump
  player.jumpxtra = 8 --height of extra jumps

  -- player knockback and stun --
  player.stun_start = 0
 player.stun_dur = 1
 player.knock = 10 --knockback when touch enemy

 -- player blasts --
 blast = {}
 blast.s = 16 --sprite
 blast.s_w = 1 --size
 blast.s_h = 1
 blast.w = 8 --size by pixels
 blast.h = 6 --size by pixels
 blast.speed = 2 --speed of blasts
 blast.limit = 5 --max onscreen
 blast.wait = 0.5 --time between blasts
 blast.prevt = 0

 --paths for enemies to travel
 path1 = {120,-120}
 path2 = {48,-48}
 path3 = {16,-16}

 --enemies
 enemy_attr = {} --kind 1 ez, 2 med, 3 hard
 enemy_attr.s = {8,7,9} --idle sprites
 enemy_attr.s_w = {1,1,2} --sprite size
 enemy_attr.s_h = {2,2,2}
 enemy_attr.w = {7,7,12} --size by pixels
 enemy_attr.h = {16,16,16}
 enemy_attr.walk_s = {129,128,9} --walk sprites
 enemy_attr.move_animt = 0.5
 enemy_attr.speed = {16,16,32}
 enemy_attr.range = {40,60,60}
 enemy_attr.attack_s = {12,11,13}
 enemy_attr.shoot_h = {6,6}
 enemy_attr.dead_stand_s = {132,135}
 enemy_attr.dead_flat_s = {149,133}
 enemy_attr.dead_flat_s_h = {1,1}
 enemy_attr.dead_flat_s_w = {2,2}
 enemy_attr.dead_flat_h = {8,8}
 enemy_attr.dead_flat_w = {16,16}
 enemy_attr.death_t = time()
 enemy_attr.surprised = 46
 enemy_attr.reload = 2 --time between shots
 enemy_attr.shoot_speed = 20
 enemy_bullet = {}
 enemy_bullet.s = 15 --sprite
 enemy_bullet.s_h = 1 --size
 enemy_bullet.s_w = 1
 enemy_bullet.h = 2 --size by pixels
 enemy_bullet.w = 2
 enemy_attr.wait = 2 --wait between path steps and after seeing player
 enemy_attr.eye_offset_x = {2,2,5}
 enemy_attr.eye_offset_y = {2,2,1}
 enemy_attr.eye_gap = {3,2,3}
 enemy_attr.eye_color = {6,5,10}
 --[[ enemy attributes
 enemy[k].x
 enemy[k].y
 enemy[k].kind, 1 = easy, 2 = medium, 3 = hard
 enemy[k].s, sprite
 enemy[k].s_w, size
 enemy[k].s_h
 enemy[k].w, size by pixels
 enemy[k].h
 enemy[k].flipped, bool
 enemy[k].is_dead, bool
 enemy[k].speed
 enemy[k].sees_you, bool, sees player
 enemy[k].range, vision range
 enemy[k].prev_shot, for reload time
 enemy[k].path, path to move along
 enemy[k].path_prog, progress of movement in path
 enemy[k].wait_start
 enemy[k].waiting
 enemy[k].attack_s, attack sprite
 enemy[k].next_blink, time blinks
 enemy[k].eyes_open
 enemy[k].eye_offset_x
 enemy[k].eye_offset_y
 enemy[k].eye_gap
 enemy[k].eye_color
 enemy[k].on_ground, bool for death
 enemy_bullet[i].x
 enemy_bullet[i].y
 enemy_bullet[i].direction
 enemy_bullet[i].prevt, for moving bullet
 ]]
end

--[[
sets up next level.
new player position (x,y),
lvl: level id for map.
potk: potential kills for this map.
reboots enemies as well.
]]
function new_level(toggled)
  lvl = (lvl+1)%(nlvls)
  if lvl == nlvls then
  end_game()
else
  player.x = x[lvl+1]
  player.y = y[lvl+1]
  player.s = sprites[player.morality_sp][1] --idle --player.stand_s
  if not toggled then
    player.morality -= lvl_kill_cap - player.lvl_killc
    player.lvl_killc = 0
    --pot_kills += lvl_kill_cap
  end
  music(16)
  if lvl==1 then --exiting tutorial, reset morality
    --player.tot_kills = 0
    player.morality = 0
    --pot_kills = lvl_kill_cap
    player.hp = player.max_hp
  end
  --ratio = player.tot_kills/pot_kills
  if player.morality >= 3 then --make evil
    player.morality_sp = morality_sp[2]
  elseif player.morality > -3 then --make neutral
    player.morality_sp = morality_sp[1]
  else --ratio < 0.2, make good
    player.morality_sp = morality_sp[3]
  end
  player.stealth = stealth[player.morality_sp]
  player.eye_color = eye_color[player.morality_sp]
  -- enemies --
  enemy = {}
  spawn(lvl) --spawn enemies
end
end

--[[
spawn enemies for each level
]]
function spawn(lvl)
  if lvl==0 then
    --spawn enemies
    make_enemy(1,50,10,false,nopath)
    make_enemy(1,110,10,false,nopath)
  elseif lvl==1 then
    make_enemy(2,120,56,false,nopath)
    make_enemy(2,112,96,false,nopath)
    make_enemy(2,24,80,true,path2)
    make_enemy(2,40,48,false,nopath)
    make_enemy(2,0,32,false,path3)
  end
end

--[[
display map for specific level
]]
function display_map(lvl)
  map(16*lvl,0,0,0)
end


--[[
make a particle
x: right border of particle spawn box
y: bottom border of particle spawn box
dx: x movement of particle
dy: y movement of particle
source: source of particle (ie hair, blast)
color: list of potential colors
]]
function make_particle(x,y,dx,dy,source,color)
  local dt = time() - p.prevt[source]
  if dt >= p.timecap[source] then
    p.prevt[source] = time()
    --find valid particle
    local i = 0
    for j=1,#p do
      if time() >= p[j].lifespan then
        i = j
      end
    end
    if i==0 and #p<p.limit then
      i = #p+1
    end
    --make particle
    if color[flr(rnd(#color)+1)] then
      p[i] = {}
      p[i].x = x + rnd(rndx[source])
      p[i].y = y - rnd(rndy[source])
      p[i].dx = dx
      p[i].dy = dy
      p[i].lifespan = time() + p.lifespan[source]
      p[i].color = color[flr(rnd(#color)+1)]
    end
  end
end

function display_particle()
  for i=1,#p do
    if time() < p[i].lifespan then
      pset(p[i].x,p[i].y,p[i].color)
      p[i].x += p[i].dx
      p[i].y += p[i].dy
    end
  end
end

function toggle_level()
  new_level(true)
end
-->8
--player

--[[
change sprite, update sizes, x, y, speed
]]
function change_sprite(id)
  if(not player.is_hit) player.s = sprites[player.morality_sp][id]
  player.hit_prev_s = sprites[player.morality_sp][id]
  player.y += player.h-ph[player.morality_sp][id]
  player.x += player.w-pw[player.morality_sp][id]
  player.s_h = h[player.morality_sp][id]
  player.s_w = w[player.morality_sp][id]
  player.w = pw[player.morality_sp][id]
  player.h = ph[player.morality_sp][id]
end

--can the player jump?
function can_jump()
 if player.is_crouching then
  return false
 end
 if player.njump == 3 then
  return false
 end
 if player.njump == 2 and
    not player.can_triplej then
  return false
 end
 return true
end

--[[
start the jump.
is this a normal jump, or
a double/triple?
]]
function start_jump()
 --change sprite
 -- 6 = jump
 --start jump
 sfx(32)
 player.jump_tprev = time()
 player.is_jumping = true
 --choose jump height
 if player.njump==0 then
  player.jump_prog = player.jump1
 else
  player.jump_prog = player.jumpxtra
 end
 player.y -= 1
 player.njump += 1
end

--find new position in jump
function jump()
 local dt = time() - player.jump_tprev
 --check for ceiling
 local x1 = player.x
 local x2 = player.x+player.w-1
 if v_collide(x1,x2,player.y-1)
 then
  player.jump_prog = 0 --end jump
 end
 if dt > 0.005 and
    player.jump_prog > 0
 then --do some jumping
  player.y -= 2
  player.jump_prog -= 1
  player.jump_tprev = time()
 end
 if(player.jump_prog==0) player.is_jumping = false
end

--[[
what to do when player
kills someone
]]
function kill(b,e)
  sfx(33)
  kill_blast(b)
  kill_enemy(e)
  killtext_t = time() + killtext_dur
  killspeaker = null
  for i=1,#enemy do
    if not enemy[i].is_dead then
      killspeaker = flr(rnd(#enemy))+1
      while enemy[killspeaker].is_dead do
        killspeaker = flr(rnd(#enemy))+1
      end
      break
    end
  end
  killmsg = killed_text[flr(rnd(#killed_text))+1]
  enemy_dialogue()
  --player.tot_kills += 1
  player.morality += 1
  player.lvl_killc += 1
  --ratio = player.tot_kills/pot_kills
end

--[[
player touched enemy!
knockback and stun.
]]
function player_hit()
  sfx(31)
  if(not player.is_hit) player.hit_start = time()
  player.is_hit = true
  player.hit_prev_s = player.s
  player.hp -= 1
  --player.is_stunned = true
  --player.stun_start = time()
end

--[[
got hit, flash animation
]]
function player_flash()
  local dt = time() - player.hit_prevt
  if dt>=0.2 then
    player.hit_prevt = time()
    if player.s==player.hit_s then
      player.s = player.hit_prev_s
    else
      player.s = player.hit_s
    end
  end
  if time()-player.hit_start >= player.hit_dur then
    player.is_hit = false
  end
end

--[[
player died, do this:
]]
function player_die()
  player.is_dead = true
  game = modes[4]
end

--[[
check to see if stun is
finished
]]
function stop_stun()
 local dt = time() - player.stun_start
 if dt >= player.stun_dur then
  player.is_stunned = false
 end
 if btn(5) then
   _init()
 end
end

--[[
checks if shooting is possible.
returns valid index for new
blast.
criteria:
   -number of blasts
   -time between blasts
]]
function get_valid_blast()
 local dt = time() - blast.prevt
 if dt < blast.wait then
  return 0
 end
 for i=1,#blast do
  if blast[i].y < 0 then
   return i
  end
 end
 if #blast < blast.limit then
  return #blast+1
 end
 return 0
end

--[[
shoot an energy blast in the
direction the player is facing
]]
function shoot()
  local k = get_valid_blast()
  if k != 0 then
    blast.prevt = time() --time at latest shot
    blast[k] = {}
    --find y of blast
    if player.is_crouching then
      blast[k].y = player.y
    else
      blast[k].y = player.y+4
    end
    if player.flipped then --left
      blast[k].x = player.x-blast.w+1
      blast[k].mx = -blast.speed
      blast[k].flipped = true
    else --right
      blast[k].x = player.x+player.w-1
      blast[k].mx = blast.speed
      blast[k].flipped = false
    end
  else
    sfx(34)
  end
end

--[[
after shooting, where are
the blasts?
]]
function move_blasts()
 for i=1,#blast do
  --move only valid blasts
  if blast[i].y>0 then
   blast[i].x += blast[i].mx
   --check wall collision
   blast_hit_wall(i)
   --check enemy collision
   blast_hit(i)
  end--end if
 end--end for
end

--[[
make blasts invalid by
moving to y=-100
]]
function kill_blast(i)
 blast[i].y = -100
end

function display_blasts()
 for i=1,#blast do
   if blast[i].y > 0 then
     spr(blast.s,blast[i].x,blast[i].y,blast.s_w,blast.s_h,blast[i].flipped)
     local x = blast[i].x
     local dx = -0.1
     if blast[i].flipped then
       x = x+blast.w
       dx = 0.1
     end
     make_particle(x,blast[i].y+blast.h,dx,-0.1,2,blast_colors)
  end
 end
end

function display_attr()
  for i=1,player.max_hp do
    if i<= player.hp then
      spr(health_sp[1],(i-1)*8,2)
    else
      spr(health_sp[2],(i-1)*8,2)
    end
  end
  --kill limit
  for i=1,kill_limit do
    if i <= kill_limit-player.lvl_killc then
      spr(blast_sp[1],(i-1)*8,8)
    else
      spr(blast_sp[2],(i-1)*8,8)
    end
  end
  --morality bar
  spr(sprites[3][1],80,0,1,1) --show good head
  spr(sprites[2][1],120,0,1,1,true) --show bad head
  pset(83,3,7) --good left eye
  pset(85,3,7) --good right eye
  pset(122,3,8) --bad left eye
  pset(124,3,8) --bad right eye
  -- rectfill(88,3,98,5,12) --good bar
  -- rectfill(98,3,104,5,3) --neutral bar
  -- rectfill(104,3,120,5,8) --bad bar
  -- rect(88,2,120,6,2) --bar border
  -- line((119-89)*ratio+89,3,(119-89)*ratio+89,5,9) --indicator
  rectfill(89,3,98,5,12) --good bar
  rectfill(99,3,109,5,3) --neutral bar
  rectfill(110,3,119,5,8) --bad bar
  rect(88,2,120,6,2) --bar border
  line(104+player.morality*5/3,3,104+player.morality*5/3,5,9) --indicator
end

function check_exit()
  local x1 = player.x
  local x2 = player.x+player.w-1
  local y1 = player.y
  local y2 = player.y+player.h-1
  if is_inside(exit_x[lvl+1],exit_x[lvl+1],exit_y[lvl+1],exit_y[lvl+1],x1,x2,y1,y2) then
    new_level(false)
  end
end

-->8
--enemies

--[[
spawn enemies
kind: enemy type
x and y: position
]]
function make_enemy(kind,x,y,flipped,path)
  local k = #enemy+1
  enemy[k] = {}
  enemy[k].x = x
  enemy[k].y = y
  enemy[k].kind = kind --1 ez, 2 med, 3 hard
  enemy[k].s = enemy_attr.s[kind] --sprite
  enemy[k].s_w = enemy_attr.s_w[kind] --size
  enemy[k].s_h = enemy_attr.s_h[kind]
  enemy[k].w = enemy_attr.w[kind]
  enemy[k].h = enemy_attr.h[kind]
  enemy[k].prev_t = time()
  enemy[k].flipped = flipped
  enemy[k].is_dead = false
  enemy[k].speed = enemy_attr.speed[kind]
  enemy[k].sees_you = false
  enemy[k].range = enemy_attr.range[kind]
  enemy[k].shoot_h = enemy_attr.shoot_h[kind]
  enemy[k].prev_shot = 0
  enemy[k].path = path
  enemy[k].path_prog = 1
  enemy[k].prev_x = enemy[k].x
  enemy[k].prev_y = enemy[k].y
  enemy[k].waiting = false
  enemy[k].is_jumping = false
  enemy[k].attack_s = enemy_attr.attack_s[kind]
  enemy[k].move_prevt = time()
  enemy[k].next_blink = time()+flr(rnd(10)+1)
  enemy[k].eyes_open = true
  enemy[k].eye_offset_x = enemy_attr.eye_offset_x[kind]
  enemy[k].eye_offset_y = enemy_attr.eye_offset_y[kind]
  enemy[k].eye_gap = enemy_attr.eye_gap[kind]
  enemy[k].eye_color = enemy_attr.eye_color[kind]
  enemy[k].on_ground = false
end

--[[
move enemy along a predetermined path.
k = enemy index
]]
function move_enemy()
  for i=1,#enemy do
    if not enemy[i].is_dead then
      local dt = time() - enemy[i].prev_t
      enemy[i].prev_t = time()
      if enemy[i].path and --path exists
      not enemy[i].sees_you and
      not enemy[i].waiting then
        local mt = time()-enemy[i].move_prevt
        if mt >= enemy_attr.move_animt then
          enemy[i].move_prevt = time()
          if enemy[i].s==enemy_attr.s[enemy[i].kind] then
            enemy[i].s = enemy_attr.walk_s[enemy[i].kind]
          else
            enemy[i].s = enemy_attr.s[enemy[i].kind]
          end
        end
        local p = enemy[i].path_prog
        local xdirection = 0
        if enemy[i].path[p] < 0 then --facing left
          enemy[i].flipped = false
          xdirection = -1
        else --facing right
          enemy[i].flipped = true
          xdirection = 1
        end
        local front = enemy[i].x-1
        local y1 = enemy[i].y
        local y2 = y1+enemy[i].h-1
        if(enemy[i].flipped) front=enemy[i].x+enemy[i].w
        if(not h_collide(front,y1,y2)) enemy[i].x += xdirection*enemy[i].speed*dt
        if abs(enemy[i].x-enemy[i].prev_x)>=abs(enemy[i].path[p]) or
        h_collide(front,y1,y2) then
          enemy[i].wait_start = time()
          enemy[i].waiting = true
          enemy[i].path_prog = p % #enemy[i].path+1
          enemy[i].prev_x = enemy[i].x
        end
      elseif enemy[i].waiting and
        time()-enemy[i].wait_start>=enemy_attr.wait then
          enemy[i].waiting = false
          enemy[i].s = enemy_attr.s[enemy[i].kind]
      end
    else --is dead
      if time() > enemy[i].death_t and
         not enemy[i].on_ground then
        sfx(35)
        enemy[i].on_ground = true
        enemy[i].y += (enemy[i].s_h-enemy_attr.dead_flat_s_h[enemy[i].kind])*8
        enemy[i].s = enemy_attr.dead_flat_s[enemy[i].kind]
        enemy[i].s_h = enemy_attr.dead_flat_s_h[enemy[i].kind]
        enemy[i].s_w = enemy_attr.dead_flat_s_w[enemy[i].kind]
        enemy[i].h = enemy_attr.dead_flat_h[enemy[i].kind]
      end
    end --end if
  end --for
end

--[[
enemy has been killed,
delete them
]]
function kill_enemy(k)
 enemy[k].is_dead = true
 enemy[k].s = enemy_attr.dead_stand_s[enemy[k].kind]
 enemy[k].death_t = time()+1
 if player.x < enemy[k].x then
   enemy[k].flipped = false
 else
   enemy[k].flipped = true
 end
end

--[[
enemy notices where player is
]]
function enemy_notice(x1,x2,k)
  enemy[k].sees_you = true
  --if touched, face player
  local pmid = (x1+x2)/2
  local emid = (2*enemy[k].x+enemy[k].w)/2
  if pmid <= emid then
    enemy[k].flipped = false
  else
    enemy[k].flipped = true
  end
  --shoot at player
  if enemy[k].kind != 3 then
    enemy[k].wait_start = time()
    enemy[k].waiting = true
    enemy_shoot(k)
  end
end

function enemy_shoot(k)
  local dt = time() - enemy[k].prev_shot
  if dt < enemy_attr.reload then return 0 end
  enemy[k].prev_shot = time()
  --find valid bullet
  local valid = 0
  for i=1,#enemy_bullet do
    if enemy_bullet[i].y < 0 then
      valid = i
      break
    end
  end
  if valid==0 then
    valid = #enemy_bullet+1
  end
  --start shot
  enemy_bullet[valid] = {}
  enemy_bullet[valid].y = enemy[k].y+enemy[k].shoot_h
  enemy_bullet[valid].prevt = time()
  if enemy[k].flipped then
    enemy_bullet[valid].x = enemy[k].x+enemy[k].w
    enemy_bullet[valid].direction = 1
  else
    enemy_bullet[valid].x = enemy[k].x
    enemy_bullet[valid].direction = -1
  end
end

function enemy_move_bullet()
  for i=1,#enemy_bullet do
    if not (enemy_bullet[i].y < 0) then
      local dt = time() - enemy_bullet[i].prevt
      enemy_bullet[i].prevt = time()
      enemy_bullet[i].x += enemy_bullet[i].direction*enemy_attr.shoot_speed*dt
      if enemy_bullet[i].x > 130 or enemy_bullet[i].x < -4 then
        kill_bullet(i)
      end--end if
    end--end if
    --check collision
    local x1 = enemy_bullet[i].x
    local x2 = enemy_bullet[i].x+enemy_bullet.w-1
    local y1 = enemy_bullet[i].y
    local y2 = enemy_bullet[i].y+enemy_bullet.h-1
    local x3 = player.x
    local x4 = player.x+player.w-1
    local y3 = player.y
    local y4 = player.y+player.h-1
    if is_inside(x1,x2,y1,y2,x3,x4,y3,y4) then
      kill_bullet(i)
      player_hit()
    elseif h_collide(x1,y1,y2) or h_collide(x2,y1,y2) then
      kill_bullet(i)
    end
  end--end for
end

function kill_bullet(i)
  enemy_bullet[i].y = -100
end

function enemy_dialogue()
  if time() >= text_prevt then
    if not enemy_is_talking then --speak
      enemy_is_talking = true
      text_prevt = time() + text_dur
      speaker = flr(rnd(#enemy))+1
      msg = text[player.morality_sp][flr(rnd(#text[player.morality_sp]))+1]
    else --stop talking
      enemy_is_talking = false
      text_prevt = time() + rnd(10)+5
      msg = null
      speaker = null
    end
  end
  if enemy_is_talking and
      speaker and --speaker exists
      not enemy[speaker].is_dead and
      not enemy[speaker].sees_you then
    print(msg,enemy[speaker].x+4-2*#msg,enemy[speaker].y-6,6)
  end
  if time() < killtext_t and
      killspeaker and
      killspeaker != speaker then
    print(killmsg,enemy[killspeaker].x+4-2*#killmsg,enemy[killspeaker].y-6,6)
    enemy[killspeaker].wait_start = time()
    enemy[killspeaker].waiting = true
  end
end

function display_enemy_bullet()
  for i=1,#enemy_bullet do
    spr(enemy_bullet.s,enemy_bullet[i].x,enemy_bullet[i].y,enemy_bullet.s_h,enemy_bullet.s_w)
  end
end

function display_enemies()
  for i=1,#enemy do
    spr(enemy[i].s,enemy[i].x,enemy[i].y,enemy[i].s_w,enemy[i].s_h,enemy[i].flipped)
    if(not enemy[i].is_dead) display_eyes(enemy[i])
  end
end

--[[
display eyes, make blinking
]]
function display_eyes(entity)
  local x = entity.x
  local y = entity.y
  local eye_y = y+entity.eye_offset_y
  if entity.flipped then
    eye_x = x+entity.s_w*8-1-entity.eye_offset_x
    eye_x2 = eye_x-entity.eye_gap
  else
    eye_x = x+entity.eye_offset_x
    eye_x2 = eye_x+entity.eye_gap
  end
  --blink
  if time() >= entity.next_blink then
    if entity.eyes_open then --blink
      entity.eyes_open = false
      entity.next_blink = time() + blink_dur
    else --open eyes
      entity.eyes_open = true
      entity.next_blink = time() + flr(rnd(10)+1)
    end
  end
  if entity.eyes_open then
    pset(eye_x,eye_y,entity.eye_color)
    pset(eye_x2,eye_y,entity.eye_color)
  end
end

function enemy_check_range()
  local x1 = player.x
  local x2 = player.x+player.w-1
  local y1 = player.y
  local y2 = player.y+player.h-1
  for i=1,#enemy do
    if not enemy[i].is_dead then
      local y3 = enemy[i].y
      local y4 = y3+enemy[i].h-1
      --determine x values of vision box
      local x3 = enemy[i].x-enemy[i].range+player.stealth
      local x4 = enemy[i].x+enemy[i].w/2
      if enemy[i].flipped then
        x3 = enemy[i].x+0.5*enemy[i].w
        x4 = x3+enemy[i].range-player.stealth
      end
      --rect(box1,y3,box2,y4,5)
      if is_inside(x1,x2,y1,y2,x3,x4,y3,y4) then
        enemy_notice(x1,x2,i)
      end
      if enemy[i].sees_you and enemy[i].waiting then
        spr(enemy_attr.surprised,enemy[i].x,enemy[i].y-10) --! exclamation mark
        enemy[i].s = enemy[i].attack_s --attack sprite
      else
        enemy[i].sees_you = false
      end
    end
  end
end
-->8
--collision and physics

--[[
make player fall
simulates gravity
]]
function fall()
  --make player fall
  local y = player.y+player.h
  local x1 = player.x
  local x2 = player.x+player.w-1
  if v_collide(x1,x2,y) then
    player.njump = 0
    if v_collide(x1,x2,y-0.5) then
      player.y = flr(player.y-0.5)
    end
  else
    if(not player.is_jumping) player.y += 1.5
  end
  --make enemies fall
  for i=1,#enemy do
    local y = enemy[i].y+enemy[i].h
    local x1 = enemy[i].x
    local x2 = enemy[i].x+enemy[i].w-1
    if v_collide(x1,x2,y) then
      if v_collide(x1,x2,y-0.5) then
        enemy[i].y = flr(enemy[i].y-0.5)
      end
    else
      if(not enemy[i].is_jumping) enemy[i].y += 1.5
    end
  end
end

--[[
detect horizontal map collision
x: left or right side of player
y1: top side of player
y2: bottom side of player
flag: flag of relevant map tile
]]
function h_collide(x,y1,y2)
 -- screen boundary
 if(x>127 or x<0) return true
 --wall collision
 x = x/8
 y1 = y1
 y2 = y2
 for i=y1,y2 do
  if fget(mget(x+16*lvl,i/8),0) or
     fget(mget(x+16*lvl,i/8),1) then
   return true
  end
 end
 return false
end

--[[
detect vertical map collision
ex. ceiling, floor
x1: left side of player
x2: right side
y: top or bottom of player
flag: flag of relevant map tile
]]
function v_collide(x1,x2,y)
  local down = false --checking under player?
  if(y>player.y) down = true
  local a = flr(y/8)
  --screen boundary
  if(a<0) return true
  --wall collision
  for i=x1,x2 do
    if fget(mget((i/8)+16*lvl,a),0) then
      return true
    elseif fget(mget((i/8)+16*lvl,a),1) and down then --upper half blocks
      return true
    elseif fget(mget((i/8)+16*lvl,a),1) and
           not down and
           (y<=a*8+4 or player.is_crouching) then
      return true
    elseif fget(mget((i/8)+16*lvl,a),2) and not down then --lower half blocks
      return true
    elseif fget(mget((i/8)+16*lvl,a),2) and
           down and y>=a*8+4 then
      return true
    end
  end
  return false
end

--blast map collision
function blast_hit_wall(i)
 local y1 = blast[i].y
 local y2 = blast[i].y+blast.h-1
 local x1 = blast[i].x+8-blast.w
 local x2 = x1+blast.w-1
 --collision
 if h_collide(x1,y1,y2) or
    h_collide(x2,y1,y2) then
  kill_blast(i)
 end
end

--blast enemy collision
function blast_hit(i)
 local x1 = blast[i].x
 local x2 = x1+blast.w-1
 local y1 = blast[i].y
 local y2 = y1+blast.h-1

 for j=1,#enemy do
  local x3 = enemy[j].x
  local x4 = x3+enemy[j].w-1
  local y3 = enemy[j].y
  local y4 = y3+enemy[j].h-1
  --determine enemy collision box
  if enemy[j].flipped then
   x3 += enemy[j].s_w*8-enemy[j].w
   x4 = enemy[j].x+enemy[j].s_w*8-2
  end
  --detect collision
  if not enemy[j].is_dead and
     is_inside(x1,x2,y1,y2,x3,x4,y3,y4)
     then
   kill(i,j)
  end
 end
end

--[[
if object 1 with x1,x2,y1,y2 is inside object 2 with x3,x4,y3,y4
]]
function is_inside(x1,x2,y1,y2,x3,x4,y3,y4)
  if
       (
       x1>=x3 and
       x1<=x4
       or
       x2>=x3 and
       x2<=x4
       ) and
       (
       y1>=y3 and
       y1<=y4
       or
       y2>=y3 and
       y2<=y4
       ) then
    return true
  else
    return false
  end
end

--[[
does the player touch
an enemy?
]]
function touch_enemy()
  local x1 = player.x
  local x2 = player.x+player.w-1
  local y1 = player.y
  local y2 = player.y+player.h-1
 --detect collision
 for j=1,#enemy do
  local x3 = enemy[j].x
  local x4 = enemy[j].x+enemy[j].w-1
  local y3 = enemy[j].y
  local y4 = enemy[j].y+enemy[j].h-1
  --determine enemy collision box
  if enemy[j].flipped then
   x3 += enemy[j].s_w*8-enemy[j].w
   x4 = enemy[j].x+enemy[j].s_w*8-2
  end
  --collision detection
  if not enemy[j].is_dead and
     is_inside(x1,x2,y1,y2,x3,x4,y3,y4) then
   enemy_notice(x1,x2,j)
  end
 end
end
-->8
--update and draw

function _update60()
  if game=="title" then --splash
    if btnp(4) then
     game = modes[2]
     new_level(false)
    end
  -- elseif game=="instr" then --instructions
  --   if btnp(4) then
  --     game=modes[3]
  --     prev_t = time()
  --     new_level(x[lvl+1],y[lvl+1],false)
  --   end
elseif game=="game" then
    dt = time() - prev_t
    distance = flr(player.speed*dt)
    if(distance>0) prev_t = time()
    local x1 = player.x
    local x2 = player.x+player.w
    local y1 = player.y
    local y2 = player.y+player.h
    -- walk
    if btn(0) and not
       h_collide(x1-1,y1,y2-1) and
       not player.is_stunned then
     player.x -= distance
     player.flipped = true
     if h_collide(x1,y1,y2-1) then
       player.x += 1
     end
     check_exit()
    end
    if btn(1) and not
       h_collide(x2,y1,y2-1) and
       not player.is_stunned then
     player.x += distance
     player.flipped = false
     if h_collide(x2-1,y1,y2-1) then
       player.x -= 1
     end
     check_exit()
    end
    -- jump
    if btnp(2) and can_jump() and
       not player.is_stunned then
      start_jump()
    end
    -- crouch
    if btn(3) or
       player.is_crouching and v_collide(x1,x2-1,y1-1) or
       v_collide(x1,x2-1,y1) then
      player.is_crouching = true
      --blinking
      player.eye_offset_y = eye_offset_y[2]
      player.eye_offset_x = eye_offset_x[2]
      if btn(0) or btn(1) then --crouch walking animation
        local mt = time()-player.move_prevt
        if mt >= player.move_animt or
        player.s==sprites[player.morality_sp][1] or
        player.s==sprites[player.morality_sp][2] or
        player.s==sprites[player.morality_sp][3]
        then
          player.move_prevt = time()
          if player.s==sprites[player.morality_sp][4] then
            change_sprite(5)
          else
            change_sprite(4)
          end
        end
      else
        change_sprite(4) --crouch idle
      end
      player.speed = speed[player.morality_sp][2] --crouching speed
    elseif not v_collide(x1,x2-1,y1) then
      player.is_crouching = false
      --blinking
      player.eye_offset_y = eye_offset_y[1]
      player.eye_offset_x = eye_offset_x[1]
       --falling
      if not v_collide(x1,x2,y2) then
        --6 = jumping/falling
        change_sprite(6)
      elseif btn(0) or btn(1) then --is walking
        local mt = time()-player.move_prevt
        if mt >= player.move_animt or
        player.s==sprites[player.morality_sp][4] or
        player.s==sprites[player.morality_sp][5]
        then
          player.move_prevt = time()
          if player.s==sprites[player.morality_sp][2] then
            change_sprite(3)
          else
            change_sprite(2)
          end
        end
      else --idle
        --1 = idle
        change_sprite(1)
      end
      player.speed = speed[player.morality_sp][1] --walking speed
    end
    --shoot
    if btnp(4) then
      if player.lvl_killc<kill_limit then
        shoot()
        player.shoot_start = time()
      else
        sfx(34)
      end
  end

  if time()-player.shoot_start<player.shoot_animt then
    if player.is_crouching then
      change_sprite(5)
    else
      change_sprite(7)
    end
  end

   if(player.is_jumping) jump()
   if(player.is_stunned) stop_stun()
   if(player.is_hit) player_flash()
   make_particle(player.x,player.y,0,-0.1,1,hair_colors[player.morality_sp])
   fall()
   move_blasts()
   enemy_move_bullet()
   move_enemy()
   touch_enemy()
   if player.hp<=0 then
     player_die()
   end
 elseif game=="over" then --dead
   if btnp(4) then
     _init()
   end
 end
end

function _draw()
  cls()
  if game=="title" then --splash
    spr(192,44,44,5,3)
    print("a game about morality",20,70,6)
    print("press z to start",32,96,5)
  -- elseif game=="instr" then
  --   player.x = 10
  --   player.y = 10
  --       spr(player.s,player.x,player.y,player.s_w,player.s_h,player.flipped)
  --   display_eyes(player)
  --   print(" this is you.",20,14,7)
  --   print("  ⬆️   to jump.",15,30,7)
  --   print("⬅️  ➡️ to move.",15,40,7)
  --   print("  ⬇️   to crouch.",15,50,7)
  --   print("   z   to shoot.",15,60,7)
  --   print("you can only kill 3 people.",10,80,7)
  --   print("press z to continue.",24,115,5)
elseif game=="game" then --game
    display_map(lvl)
    if lvl==0 then --tutorial level
      print(" move",20,82,5)
      print("⬅️  ➡️",20,90,5)
      print("jump",65,82,5)
      print("⬆️",70,90,5)
      print("double",95,65,5)
      print(" jump ",95,72,5)
      print("⬆️⬆️",100,80,5)
      print("crouch",60,45,5)
      print("  ⬇️  ",60,52,5)
      print("shoot",28,10,5)
      print("  z  ",28,18,5)
    end
    display_enemies()
    enemy_check_range()
    display_blasts()
    display_attr()
    display_enemy_bullet()
    spr(player.s,player.x,player.y,player.s_w,player.s_h,player.flipped)
    display_eyes(player)
    display_particle()
    if(#enemy>0) enemy_dialogue()
  elseif game=="over" then --game over
    print("game over",48,60,8)
    print("press z to start again",20,70,8)
  end
end
__gfx__
00000000010000000101111001000000001000000110001001000000005555000044444000000444440000000055550000444440000000444440000056000000
0000000010111100101444411011110001111100101111011011111000ffff5000444440000004444400000000ffff5000444440000000444440000055000000
0070070001444410010444400144441010444410014444000144440100ffff0000444440000004444400000000ffff0000444440000000444440000000000000
0007700010444401000444401044440101444401014444001044440000ffff0000444440000000044000000000ffff0000444440000000004400000000000000
000770000044440000033330004444001044440010444400004444000000f0000000445500000044440000000000f00000004455000000004444400000000000
00700700000400000003630000040000000400000334330000040000004444400055555500000444444440000044444000555556000000044440040000000000
00000000003330000000555000333300033330003333303003333337040444040555555500004444440040000404440466666666888884444440400000000000
00000000033333000065006003333030303333003033300630333000040444040550555688884444400080005555555f64466644888880844444000000000000
000077703033303001011110303330030363306060333000033630005555555f66666666888044444888800000f655f000555446888800844444000000000000
0007560730333030101444410363300600333000004440000033300000f655f06446664488805555588880000004450000555565888800855555000000000000
0076006760444060010444400044400000444000005555000044400000011500001114410000555558880000000111000011111100000005555500000ddd0000
677100070055500000044440005550000055500000500500005550000001111000111161000055000550000000111110001111110000000550055000dccccddd
0056510700505000003333360050500000500500655005000050500000110010001101110005500000550000001000100011011100000055000555000d77dd00
000017600050500000603300655050000050600060000660005005000010000100110111000800000080000001000001001101110000008000000800007d0000
00000000005050000000555060005000050060000000000065000500001000010011011100550000055000000100000100110111000055000000055000700000
00000000066066000006506000006600066000000000000060000660055000550555055505550000550000005500005505550555000555000000555000000000
090000000a0999a00a000000009000000a9000a00a0000000c0000000c0cccc00c00000000c000000cc000c00c00000000880880000550000008800000000000
a0a9a9009095555a9099aa00099a990090999a0aa099aa70c0cccc00c0c4444cc0cccc000ccccc00c0cccc0cc0ccccc002888780005110600008800000000000
0a5555a00a0555500a5555a0905555a00a555500095555070c4444c00c0444400c4444c0c04444c00c4444000c44440c0288888006006c500008800000000000
90555509000555509055550a0a55550a0955550090555500c044440c00044440c044440c0c44440c0c444400c044440000288800060600500008800000000000
00555500000499400055550090555500a055550000555500004444000007777000444400c0444400c0444400004444000002800005c010100000000000000000
000400000009a400000400000005000004a5a4000005000000040000000757000004000000040000077477000004000000000000000665000008800000000000
0049400000005590044a4000044a400044aaa09004499aa700777000000055500077700007777000777770600777776700000000000000000008800000000000
04aaa40000a900a090a9a90040999400909a900a90aaa00007777700007500700777770070777700607770057077700000000000000000000000000000000000
409a90400a09a9a009aa90aa09a990a0a04940000a9aa000707770700c0cccc00677706007577060507770000765700005505500000000000000000000000000
90494090909555590099900000494000004440000049900060777060c0c4444c6077705000777005007770000077700005050500000550000000000000000000
a04440a00a05555000444000004440000055550000449000507770500c0444405077700000777000005555000077700005000500005005000000000000000000
00555000000555500055500000555000005009000055500000555000000444400055500000555000005005000055500000505000005005000000000000000000
005050000099449a0050500000500900aa900a000050500000505000007777750050500000500600765006000050500000050000000550000000000000000000
0090900000a0aa00aa9090000090a000a0000aa00090090000505000005077007650500000507000700007700050050000000000000000000000000000000000
00a0a00000005590a000a0000a00a00000000000aa000a0000606000000055607000600006007000000000007600060000000000000000000000000000000000
0aa0aa00000a90a00000aa000aa0000000000000a0000aa007707700000750700000770007700000000000007000077000000000000000000000000000000000
511151515555555533b3333333b33333000400405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15151115555555553333333b3333333b000004005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555515555555554334434453355355040400045000000000111111111111001111111111111111000000000000000000000000000000000000000000000000
5515555555555555444444445555555500400000500000000015ddddddddd100dddddddddddddddd000000000000000000000000000000000000000000000000
5555155500444400344444443555555540044040500000000015d5555555d100555555555555d555000000000000000000000000000000000000000000000000
5555555500000000444444345555553500440004500000000015d1111115d100111111111115d111000000000000000000000000000000000000000000000000
5555555500000000444544445553555504040440500000000015d1000015d100000000000015d100000000000000000000000000000000000000000000000000
5555555500000000444444445555555500404000500000000015d1000015d100000000000015d100000000000000000000000000000000000000000000000000
55555555555555554444444433b3333300050500000000050015d1000015d1000015d1000015d100000000000000000000000000000000000000000000000000
5555555555555555444444443333333b00050500000000050015d1000015d1000015d1000015d100000000000000000000000000000000000000000000000000
5555555555555555444444445335434500050500000000050015d1111115d1111115d1001115d111000000000000000000000000000000000000000000000000
5555555555555555444444445555544400050500000000050015ddddddddddddddddd100dddddddd000000000000000000000000000000000000000000000000
555555550000000044444444355445440000050000000005001555555555d5555555510055555555000000000000000000000000000000000000000000000000
555555550000000044444444555544340005500000000005001111111115d1111111110011111111000000000000000000000000000000000000000000000000
555555550000000044444444555345450005050000000005000000000015d1000000000000000000000000000000000000000000000000000000000000000000
555555550000000044444444555554440005050000000005000000000015d1000000000000000000000000000000000000000000000000000000000000000000
5555555533b33333000000000000000000050500000000000015d1000015d1000015d10000000000000000000000000000000000000000000000000000000000
555555553333333b000000000000000000050500000000000015d1000155d5100015d10000000000000000000000000000000000000000000000000000000000
5555555543345355000000000000000000050500000000000155d5100155dd101115d10000000000000000000000000000000000000000000000000000000000
5555550554455555000000000000000000050500000000000155dd1000000000ddddd10000000000000000000000000000000000000000000000000000000000
55055555345455550000000000000000005005000000000000bbbb00000000005555d10000000000000000000000000000000000000000000000000000000000
55555555444445350000000000000000055550000000000000b0bb00000000001115d1000155dd10000000000000000000000000000000000000000000000000
50555505544355550000000000000000550505050000000000b0b000000000000015d1000155d510000000000000000000000000000000000000000000000000
0505055544545555000000000000000055000505000000000000b000000000000015d1000015d100000000000000000000000000000000000000000000000000
511151510000000000000000000000000000000000000000000bb0000015d1000015d10000000000000000000000000000000000000000000000000000000000
151511150000000000000000000000000000000000000000000bbb000015d1000015d10000000000000000000000000000000000000000000000000000000000
555555150000000000000000000000000000000000000000000b0b000015d1000015d11100000000000000000000000000000000000000000000000000000000
551555050000000055555555000000000000000000000000000b00000015d1000015dddd00000000000000000000000000000000000000000000000000000000
550515556666666655555555000000000000000000000000000b00000015d1000015d55500000000000000000000000000000000000000000000000000000000
555555556666666655555555000000000000000000000000000000000015d1000015d11100000000000000000000000000000000000000000000000000000000
505555056666666655555555000000000000000000000000000000000015d1000015d10000000000000000000000000000000000000000000000000000000000
050505556666666600444400000000000000000000000000000000000015d1000015d10000000000000000000000000000000000000000000000000000000000
00555500004444400000044444000000000000000000000000000000000000000605060507000000050505050505050525252525252525252525252525252525
00ffff50004444400000044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ffff00004444400000044444000000000000000000000000000000000000000507050604000034050505050505050525252525252525252500000000000000
00ffff00004444400000000440000000000444440000000000000000000055550000000000000000000000000000000000000000000000000000000000000000
0000f0000000445500000044440000000004444400000000000000000005ffff0405060705000000050505000000005525252525250000000000000000000000
0044444000555555000004444444400000064464000000000044005000005f5f0000000000000000000000000000000000000000000000000000000000000000
0404440405555555000044444400400000044444000001114444fff50000ffff0500000006000000050500000000005525252500000000000000000000000000
04044404055055568888444440008000000004450551551144444ff5000000f00000000000000000000000000000000000000000000000000000000000000000
5555555f666666668880444448888000040055550000000000000000000004440700440005340000050000000000150500000000000000000000000000000000
00f655f0644666448880555558888000005555660000000000000000000044440000000000000000000000000000000000000000000000000000000000000000
00011500001114410000555558880000666666660000000000000000555555540500450000000000151515150000000510000000000000000000002424242424
0001110000111161000055000550000066666445000000000000000000f655f10000000000000000000000000000000000000000000000000000000000000000
00100100001110110005500000550000001144110000000000000000000015110500460000000000000000000000000511000000000000343524163524163524
00100100001100110008000000800000011116100500005555044440501111100000000000000000000000000000000000000000000000000000000000000000
05500010055500110055000005500000011151000511115555664440511001000707070707070707070707070707070724242424242424242424242424242424
00000550000005550555000055000000551050000511116666666440000055000000000000000000000000000000000000000000000000000000000000000000
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
07770000000760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677000007600077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077700077600077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00076770777600000000077000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00076077707600776007760700000077007760700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00076007007600076000760007700700700760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00076000007600076000760776070700700760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00076000007600076000760076000706700760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007600777607777076000077007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700077770000000000076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006700006706700077000770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006700077777770700707007007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006700006707070077707007070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006700006707070700707007077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006666777706707077077070777007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777777770000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
00000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000144441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001044440100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000044440000777070707770077000007770077000007070077070700000000000000000000000000000000000000000000000000000000000000000
00000000000004000000070070700700700000000700700000007070707070700000000000000000000000000000000000000000000000000000000000000000
00000000000033300000070077700700777000000700777000007770707070700000000000000000000000000000000000000000000000000000000000000000
00000000000333330000070070700700007000000700007000000070707070700000000000000000000000000000000000000000000000000000000000000000
00000000003033303000070070707770770000007770770000007770770007700700000000000000000000000000000000000000000000000000000000000000
00000000003033303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006044406000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777770000007770077000007770707077707770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007770777000000700707000000700707077707070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007700077000000700707000000700707070707770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007700077000000700707000000700707070707000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777770000000700770000007700077070707000070000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777700077777000000777007700000777007707070777000000000000000000000000000000000000000000000000000000000000000000
00000000000000077700770770077700000070070700000777070707070700000000000000000000000000000000000000000000000000000000000000000000
00000000000000077000770770007700000070070700000707070707070770000000000000000000000000000000000000000000000000000000000000000000
00000000000000077700770770077700000070070700000707070707770700000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777700077777000000070077000000707077000700777007000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777770000007770077000000770777007707070077070700000000000000000000000000000000000000000000000000000000000000
00000000000000000007700077000000700707000007000707070707070700070700000000000000000000000000000000000000000000000000000000000000
00000000000000000007700077000000700707000007000770070707070700077700000000000000000000000000000000000000000000000000000000000000
00000000000000000007770777000000700707000007000707070707070700070700000000000000000000000000000000000000000000000000000000000000
00000000000000000000777770000000700770000000770707077000770077070700700000000000000000000000000000000000000000000000000000000000
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
00000000007070077070700000077077707700000007707700700070700000707077707000700000007770000077707770077077707000777000000000000000
00000000007070707070700000700070707070000070707070700070700000707007007000700000000070000070707000707070707000700000000000000000
00000000007770707070700000700077707070000070707070700077700000770007007000700000000770000077707700707077707000770000000000000000
00000000000070707070700000700070707070000070707070700000700000707007007000700000000070000070007000707070007000700000000000000000
00000000007770770007700000077070707070000077007070777077700000707077707770777000007770000070007770770070007770777007000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007070777070007000777077000770000077707700707000007770077077707770000077707070777077000000777070707770777000000000000000
00000000007070070070007000070070707000000070707070707000007770707070707000000007007070707070700000070070707070070000000000000000
00000000007700070070007000070070707000000077707070777000007070707077007700000007007770777070700000070077707770070000000000000000
00000000007070070070007000070070707070000070707070007000007070707070707000000007007070707070700000070070707070070000000000000000
00000000007070777077707770777070707770000070707070777000007070770070707770000007007070707070700000070070707070070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007770077000007770707007707770000077707000777077707700000070707770077077000770000000000000000000000000000000000000000000
00000000000700700000000700707070000700000070707000707007007070000070707070707070707000000000000000000000000000000000000000000000
00000000000700777000000700707077700700000077707000777007007070000070707700707070707000000000000000000000000000000000000000000000
00000000000700007000000700707000700700000070007000707007007070000077707070707070707070000000000000000000000000000000000000000000
00000000007770770000007700077077000700000070007770707077707070000077707070770070707770070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007770707077700770000077700770000077700000707007707770707000007770770000007770777007700770777077700770077000000000000000
00000000000700707007007000000007007000000070700000707070707070707000000700707000007070707070707000707070007000700000000000000000
00000000000700777007007770000007007770000077700000707070707700770000000700707000007770770070707000770077007770777000000000000000
00000000000700707007000070000007000070000070700000777070707070707000000700707000007000707070707070707070000070007000000000000000
00000000000700707077707700000077707700000070700000777077007070707000007770707000007000707077007770707077707700770007000000000000
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
00000000000000000000000000000000555055505550055005500000555000005550055000000550055055005550555055005050555000000000000000000000
00000000000000000000000000000000505050505000500050000000005000000500505000005000505050500500050050505050500000000000000000000000
00000000000000000000000000000000555055005500555055500000050000000500505000005000505050500500050050505050550000000000000000000000
00000000000000000000000000000000500050505000005000500000500000000500505000005000505050500500050050505050500000000000000000000000
00000000000000000000000000000000500050505550550055000000555000000500550000000550550050500500555050500550555005000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020101000000000000000000000000010201010000000000000000000000000101000000000000000000000000000001000200000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000010201010000000000000000000000000101000000000000000000000000000001000000000000000000000000000000
__map__
5252525252525252525252525252525246484948594859574859484948575949450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000000077006600000000670000006746680066450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
520000000000000000000000000000006600760000000000000000006677007645000b000000000000000000000000001f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000001f7600000000534261534242000066001f43431b000000004141415151515151504141000041410000000071000041515141410000000b00007272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
520000424242424242424242424242420000000000000000000052420000000043434343000000000000000000000050000b000000000071004141000000000000000071001b71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
520000525252520000000000000000420000000000000000000000526143534245000000000000000000000000000050001b717100004141000000000000000000000041515141000000007100007100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
420000525252520000000000000000527040407000000000000000000000005545000b0000415151515141000000000b4343434300000000000000000000000000000000000000000000004151514100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
420000000000000000000000000000525000000000000000000000000000005545001b0000000000000000000000001b00000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242000000005260000000415151515151410000000055434343000000000000000000000071710000000000000b0000000000000000000000000b0000000000001b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5252525252525252525252000000005250000000000000000000000000000042404040400000004141000000004040400000000000001b0000000000000000000000001b717143434343434371711b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005260000000000000000000000000435342785957680000000000000000000000550000000000414100000000000000000000004343434343434343434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000004200000000000000000000000000000052580066770072720000727200000000552000000000000000000000434343434343434343434343434343434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000004244000043434343434343000000000052000076660000000000000000000000553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
520000000000000000004242424242426400006060000000606000000000005201000000000000000000000000000b557040700000000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
520000000000000000005252525252524040404040404040404040404040404011000071717143434343717171001b555050504040404040001b71710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424260606060606060606060606060606060614343434040404040404040404040406060606060606060707070707070707070707000000000000000707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000515151515151515151515151515151515151515151515151515151515151515160504000000000000043704050507050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040605043430000000000505070405060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4507000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000070504000000000000000504050505040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
451700000000004100004100000000000000000000000000000000000000001f000000000000000000000000000000000000000000000000000017000000000060606000000000004343606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4543000041000000000000000000534242424200000000000000000000004343000000000000000000000041515151515141605342424242424242424242001f50000000000000000000000000440050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5342000000000000000000000000075200000000000000000000000000000055000007000000000041000000000000000000000000000000000000000042424250000000000043430000000000540050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4552000000007171710000000000175200000000000000415141000000000055000017000000000000000000000000000000000000000700000000000000000050000000000043434343000000640050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45414100004151515141000000004100000000000000000000000000000000557171717100000000000000000b0000000000000000001771710000000000000050404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45000000000000000000000000000000000000000000000000000000000000555151514100004100000000001b6143434343000041515151515141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500000000000000000000006100000000000000000000000000000000000055000000000000000000415151410000000000000000000000000000000000690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4507000000000000000000004343534200000700000000000000000000000055000000000000000000000000000000000000000000000000000000000069784900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4517000000004151410000000000005261711771435342614343434300000055000000000000000000000000000000000000000000000000000069000077785900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5342424200000000000007000000005242426143434151515151514100000043000000000000000000000000000700000000000000000000006956494857680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4501000000000000000017000000005200000000000000000000000000000050002600000000000000000000001700434343000000000000007700770077660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4511000000000071717171000000000000000000000000000000000000000050003600000000000000000000004343434343430000000000005648594868760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070607070404070607070607070407070706070704040706070706070704070434343434300000043434343434343434343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001305013050130501305013050130501305013050130501305013050130501305013050130501305013050130501005010050100501005010050100501005010050100501305013050130501305013050
01100000060700607506070060750b0700b0700b07506070060750607006075090750907009075060700607506070060750b0700b0700b0750607006075060700607509075090700907500200000000000000000
011000000017334100001733470013653001730017300700001730070000173136530017300173001733470000173347001365300173001730070000173007000017313653001730017300700007000070000700
010e00000315300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000c2550c2550c2550c2550c2550c2550f2550f25505255052550525505255052550525507255072550825508255082550825508255082550a2550a2550325503255032550325503255032550325503255
010e0000084750847508475084750847508475084750847508475084750847508475084750847508475084750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a4750a475
010e00000047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475
010e00000545505455054550545505455054550545505455054550545505455054550545505455054550545505455054550545505455054550545505455054550f4550f4550f4550f4550f4550f4550f4550f455
010e00000f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f4550f455114551145511455114550f4550f4550f4550f4551145511455114551145513455134551345513455
010e00000c1731c600001000c1731c67500100000000c1730c1730c1000c1730c1001c67500100000000c1730c1731c600001000c1731c67500100000000c1730c1730c1730c1730c1001c67500100000000c173
010e00000c1733c6153c6153c615186733c6153c6153c6150c1733c6153c6153c615186733c6153c6153c6150c1733c6153c6153c615186733c6153c6153c6150c1733c6153c6153c615186733c6153c6153c615
010e00000c17318600186731860018673186000c173186730c1000c173186730c1000c1730c10018673000000c17318600186731860018673186000c173186730c1730c173186730c1730c173186731867318673
010e00001817300173186751860018675000001860018675000001810018173001730000018600186751860018173001731867518600186750000018600186750000018173001731817300173186751867518675
010e00000c1731c600001000c1001c6750c1730c1000c1000c1730c1000c1730c1001c67500100000000c1730c1730c1001c6000c1731c6751c6001c6750c1730c1730c1730c1000c1001c6750c1730c1730c173
010e000000000000002415024150271512715529150291552c1512c1552c1502c1552b1512b1552b1502b15500000000002415024150271502715524150241552e1512e1502e1502e15529151291502915029155
010e0000084700847008470084750847508470084700847508470084700847008475084750847008470084750a4710a4700a4750a4750a4750a4700a4700a4750a4700a4700a4750a4750a4750a4700a4700a475
010e00000047000475004700047500475004700047000475004700047500470004750047500470004700047500470004750047000475004750047000470004750047000475004700047500475004700047000475
010e00000545005450054500545505455054500545005455054500545505450054550545505450054500545505450054500545005455054550545005450054550f4500f4550f4550f4550f4550f4500f4500f455
010e00000f4500f4500f4500f4550f4550f4500f4500f4550f4500f4500f4500f4550f4550f4500f4500f455114551145511455114550f4550f4550f4550f4551145511455114551145513455134551345513455
011200000725007240072350725007240072350725007250072500725002250022350225002235022500223503250032400323503250032400323503250032500325003250052500523505250052350525005235
0112000007250072400723507250072400723507250072500725007250022500223502250022350225002235032500324003235032500324003235032500325003250032500a2500a2350a2500a2350925009235
01120000163521635216342163421633216332163221632216312163151a3001a3001a3501a3501a3501a35015352153521534215342153321533215322153221531215315113001130013350133501335013350
011200001635216352163421634216332163321632216322163121631200000113000f3500f3500f3500f350153521535215342153421533215332163511635216342163421d3311d3301d3401d3401d3501d350
011200000a1730a1733a6153a6152e6433a6152e6433a6150a1733a6150a1733a6152e6432e6433a6153a6150a1730a1733a6153a6152e6433a6152e6433a6150a1733a6150a1730a1732e6433a6153a6152e643
011200001a3551a355003001a3551a355003001a3551a355183001835518355000001f3321f3421f3521f3621d3551d355000001d3551d355000001d3551d3550000021355213550000022342223522236222372
011200001f3551f355003001f3551f355003001f3551f355183002135521355000001d3321d3421d3521d36226375273650000024365263550000022355243450000021345223352134513350163601a3701b370
011200001d3551d355003001d3551d355003001d3551d355183001b3551b35500000163321634216352163622135521355000002135521355000002135521355000001f3551f355000001a3421a3521a3621a372
0112000018355183551e0001835518355003001835518355183001a3551a35500000133321334213352133621f3751d3651e3251b3651a3551c32522355213452332518345163351534511350153601637018370
011400001121207212122221422213202112320b24211242072520f252142620a202142720920215272122721127207202122621420213252112520b242112421223205232042420e24204252052021027213272
0114000005573296430557305573356253562529643356250557335625055732e60029643296433a6000557329643055732964300000356253562505573356252964329643055733562535625055000557329643
01140000152711247518000180001527218000112711547120232000001b2421a2421e4002a2002a272292711c2511b2511b2521a2001a2501a200172521a2521f2001f2700000020270212711c2002627229271
0105000022550215501f5501d5501c550000000000000000000003800038000380003800037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000d050110501e050210500c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000013476154770b473054730e671266730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001165434635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002967029670056740467004675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000001270012750d2700127501200012000127001275062700827006270062730427004270042700427501270012750d27001275012000120001270012750627008273062700627004270042700427004273
010e000001270012750d270002000d273082000127001275082720627206200062720427204200042720027201270012750d270002000d2730820001270012750427206272000000227208272000000127209272
010e00000d1733d615256003d615256433d6150d1733d6150d1730d1000d17325600256433d6130d1733d6150d1730d1733d6153d615256433d6000d1733d6000d1733d6150d1733d615256430d173256430d173
010e00000927009275152701527509200002000927009275092000920009270092750020000200092700927506270062751227012275002000020006270062751227006275122701027004275102700327003275
__music__
03 03010244
01 4105074e
00 4106084e
00 41050749
00 41060849
00 09050749
00 0d060849
00 09050749
00 0b060849
01 0905070a
00 0d06080a
00 0905070a
02 4508060b
00 0a05070e
01 0a0f114e
02 0a10124e
01 17134344
00 17144344
00 17131544
00 17141644
01 17131544
00 17141644
00 17131518
02 17141619
03 1c424344
03 1c1d1d1e
03 26246744

