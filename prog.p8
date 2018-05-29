pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init
function _init()
  -- game variables --
  prev_t = time()
  pot_kills = 0 --total potential kills
  level = 0
  kill_limit = 3 --per level
  lvl = 1

  -- player static variables --
  player = {}
  player.max_hp = 10
  morality = {1,2,3}
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
  -- player current variables --
  player.is_dead = false
  player.morality = morality[3]
  player.s = sprites[player.morality][1] --sprite, idle
  player.s_w = w[player.morality][1] --sprite size
  player.s_h = h[player.morality][1]
  player.w = pw[player.morality][1] --size by pixels
  player.h = ph[player.morality][1]
  player.x = 0 --position
  player.y = 0
  player.hp = player.max_hp
  player.flipped = false
  player.move_animt = 0.5
  player.move_prevt = 0
  player.speed = speed[1] --neutral speed
  player.stealth = stealth[3]
  player.is_crouching = false
  player.tot_kills = 0 --total kills
  player.is_stunned = false
  player.is_jumping = false
  player.can_triplej = false
  --shoot, do attacking animation
  player.shoot_start = 0
  --got hit, do flashing animation
  player.is_hit = false
  player.hit_start = 0
  player.hit_prevt = 0 --time flashes
  player.hit_dur = 1 --length of flashing
  player.hit_s = 47 --sprite to flash to
  player.hit_prev_s = player.s --most recent sprite

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

 new_level(120,0,lvl,3)
end

--[[
sets up next level.
new player position (x,y),
lvl: level id for map.
potk: potential kills for this map.
reboots enemies as well.
]]
function new_level(x,y,lvl,potk)
 player.x = x
 player.y = y
 player.s = sprites[player.morality][1] --idle --player.stand_s
 player.lvl_killc = 0
 pot_kills += potk
 -- enemies --
 enemy = {} --kind 1 ez, 2 med, 3 hard
 enemy.s = {8,7,9}
 enemy.s_w = {1,1,2} --sprite size
 enemy.s_h = {2,2,2}
 enemy.w = {7,7,12} --size by pixels
 enemy.h = {16,16,16}
 enemy.speed = {16,16,32}
 enemy.range = {40,60,60}
 enemy.attack_s = {12,11,13}
 player.shoot_animt = 0.5
 enemy.shoot_h = {6,6}
 enemy.surprised = 46
 enemy.reload = 2 --time between shots
 enemy.shoot_speed = 20
 enemy.bullet = {}
 enemy.bullet.s = 15 --sprite
 enemy.bullet.s_h = 1 --size
 enemy.bullet.s_w = 1
 enemy.bullet.h = 2 --size by pixels
 enemy.bullet.w = 2
 enemy.wait = 2 --wait between path steps and after seeing player
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
 enemy.bullet[i].x
 enemy.bullet[i].y
 enemy.bullet[i].direction
 enemy.bullet[i].prevt, for moving bullet
 ]]
 spawn(lvl) --spawn enemies
end

--[[
spawn enemies for each level
]]
function spawn(lvl)
  if lvl==0 then
    --spawn enemies
    make_enemy(1,0,0,false,path1)
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
-->8
--player

--[[
change sprite, update sizes, x, y, speed
]]
function change_sprite(id)
  if(not player.is_hit) player.s = sprites[player.morality][id]
  player.hit_prev_s = sprites[player.morality][id]
  player.y += player.h-ph[player.morality][id]
  player.x += player.w-pw[player.morality][id]
  player.s_h = h[player.morality][id]
  player.s_w = w[player.morality][id]
  player.w = pw[player.morality][id]
  player.h = ph[player.morality][id]
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
 if v_collide(x1,x2,player.y-1,0)
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
  player.tot_kills += 1
  player.lvl_killc += 1
  local ratio = player.tot_kills/pot_kills
  dab = player.morality..morality[2]..ratio
  if ratio > 0.5 then --make evil
    player.morality = morality[2]
    player.stealth = stealth[2]
  elseif ratio > 0.2 then --make neutral
    player.morality = morality[1]
    player.stealth = stealth[1]
  end
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
   --is blast still valid?
   if blast[i].flipped and
      blast[i].x<-4 then
    kill_blast(i) --not valid
   elseif not blast[i].flipped and
      blast[i].x > 130 then
    kill_blast(i)
   end
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
  spr(blast.s,blast[i].x,blast[i].y,blast.s_w,blast.s_h,blast[i].flipped)
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
  for i=1,blast.limit do
    if (not blast[i] or --if blast[i] doesn't exist
       blast[i].y < 0) and
       player.lvl_killc<kill_limit then --blast[i] is done
      spr(blast_sp[1],(blast.limit-i)*8,10)
    else
      spr(blast_sp[2],(blast.limit-i)*8,10)
    end
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
  enemy[k].s = enemy.s[kind] --sprite
  enemy[k].s_w = enemy.s_w[kind] --size
  enemy[k].s_h = enemy.s_h[kind]
  enemy[k].w = enemy.w[kind]
  enemy[k].h = enemy.h[kind]
  enemy[k].prev_t = time()
  enemy[k].flipped = flipped
  enemy[k].is_dead = false
  enemy[k].speed = enemy.speed[kind]
  enemy[k].sees_you = false
  enemy[k].range = enemy.range[kind]
  enemy[k].shoot_h = enemy.shoot_h[kind]
  enemy[k].prev_shot = 0
  enemy[k].path = path
  enemy[k].path_prog = 1
  enemy[k].prev_x = enemy[k].x
  enemy[k].prev_y = enemy[k].y
  enemy[k].waiting = false
  enemy[k].is_jumping = false
  enemy[k].attack_s = enemy.attack_s[kind]
end

--[[
move enemy along a predetermined path.
k = enemy index
]]
function move_enemy()
  for i=1,#enemy do
    local dt = time() - enemy[i].prev_t
    enemy[i].prev_t = time()
    if enemy[i].path and --path exists
       not enemy[i].sees_you and
       not enemy[i].waiting then
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
        time()-enemy[i].wait_start>=enemy.wait then
        enemy[i].waiting = false
    end
  end --end for
end

--[[
enemy has been killed,
delete them
]]
function kill_enemy(k)
 enemy[k].is_dead = true
end

pmid = 0
emid = 0
--[[
enemy notices where player is
]]
function enemy_notice(x1,x2,k)
  enemy[k].sees_you = true
  --if touched, face player
  pmid = (x1+x2)/2
  emid = (2*enemy[k].x+enemy[k].w)/2
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
  if dt < enemy.reload then return 0 end
  enemy[k].prev_shot = time()
  --find valid bullet
  local valid = 0
  for i=1,#enemy.bullet do
    if enemy.bullet[i].y < 0 then
      valid = i
      break
    end
  end
  if valid==0 then
    valid = #enemy.bullet+1
  end
  --start shot
  enemy.bullet[valid] = {}
  enemy.bullet[valid].y = enemy[k].y+enemy[k].shoot_h
  enemy.bullet[valid].prevt = time()
  if enemy[k].flipped then
    enemy.bullet[valid].x = enemy[k].x+enemy[k].w
    enemy.bullet[valid].direction = 1
  else
    enemy.bullet[valid].x = enemy[k].x
    enemy.bullet[valid].direction = -1
  end
end

function enemy_move_bullet()
  for i=1,#enemy.bullet do
    if not (enemy.bullet[i].y < 0) then
      local dt = time() - enemy.bullet[i].prevt
      enemy.bullet[i].prevt = time()
      enemy.bullet[i].x += enemy.bullet[i].direction*enemy.shoot_speed*dt
      if enemy.bullet[i].x > 130 or enemy.bullet[i].x < -4 then
        kill_bullet(i)
      end--end if
    end--end if
    --check collision
    local x1 = enemy.bullet[i].x
    local x2 = enemy.bullet[i].x+enemy.bullet.w-1
    local y1 = enemy.bullet[i].y
    local y2 = enemy.bullet[i].y+enemy.bullet.h-1
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
  enemy.bullet[i].y = -100
end

function display_enemy_bullet()
  for i=1,#enemy.bullet do
    spr(enemy.bullet.s,enemy.bullet[i].x,enemy.bullet[i].y,enemy.bullet.s_h,enemy.bullet.s_w)
  end
end

function display_enemies()
  for i=1,#enemy do
    if not enemy[i].is_dead then
      spr(enemy[i].s,enemy[i].x,enemy[i].y,enemy[i].s_w,enemy[i].s_h,enemy[i].flipped)
    end
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
      local box1 = enemy[i].x-enemy[i].range+player.stealth
      local box2 = enemy[i].x+enemy[i].w/2
      if enemy[i].flipped then
        box1 = enemy[i].x+0.5*enemy[i].w
        box2 = box1+enemy[i].range-player.stealth
      end
      --rect(box1,y3,box2,y4,5)
      if is_inside(x1,x2,y1,y2,box1,box2,y3,y4) then
        enemy_notice(x1,x2,i)
      end
      if enemy[i].sees_you and enemy[i].waiting then
        spr(enemy.surprised,enemy[i].x,enemy[i].y-10) --! exclamation mark
        enemy[i].s = enemy[i].attack_s --attack sprite
      else
        enemy[i].sees_you = false
        enemy[i].s = enemy.s[enemy[i].kind] --normal sprite
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
  if v_collide(x1,x2,y,0) then
    player.njump = 0
    if v_collide(x1,x2,y-0.5,0) then
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
    if v_collide(x1,x2,y,0) then
      if v_collide(x1,x2,y-0.5,0) then
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
function h_collide(x,y1,y2,flag)
 -- screen boundary
 if(x>127 or x<0) return true
 --wall collision
 x = x/8
 y1 = y1
 y2 = y2
 for i=y1,y2 do
  if fget(mget(x+16*lvl,i/8),flag) then
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
function v_collide(x1,x2,y,flag)
 x1 = x1
 x2 = x2
 y = y/8
 --screen boundary
 if(y<0) return true
 --wall collision
 for i=x1,x2 do
  if fget(mget((i/8)+16*lvl,y),flag) then
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
 if h_collide(x1,y1,y2,0) or
    h_collide(x2,y1,y2,0) then
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
  if not player.is_dead then
    dt = time() - prev_t
    prev_t = time()
    local x1 = player.x
    local x2 = player.x+player.w
    local y1 = player.y
    local y2 = player.y+player.h
    -- walk
    if btn(0) and not
       h_collide(x1-1,y1,y2-1,0) and
       not player.is_stunned then
     player.x -= player.speed*dt
     player.flipped = true
     if h_collide(x1,y1,y2-1,0) then
       player.x += 1
     end
    end
    if btn(1) and not
       h_collide(x2,y1,y2-1,0) and
       not player.is_stunned then
     player.x += player.speed*dt
     player.flipped = false
     if h_collide(x2-1,y1,y2-1,0) then
       player.x -= 1
     end
    end
    -- jump
    if btnp(2) and can_jump() and
       not player.is_stunned then
      start_jump()
    end
    -- crouch
    if btn(3) and
       not player.is_stunned or
       player.is_crouching and v_collide(x1,x2-1,y1-1,0) then
      player.is_crouching = true
      if btn(0) or btn(1) then --crouch walking
        local mt = time()-player.move_prevt
        if mt >= player.move_animt then
          player.move_prevt = time()
          if player.s==sprites[player.morality][4] then
            change_sprite(5)
          else
            change_sprite(4)
          end
        end
      else
        change_sprite(4) --crouch idle
      end
      player.speed = speed[player.morality][2] --crouching speed
    elseif not v_collide(x1,x2-1,y1,0) then
      player.is_crouching = false
    if not v_collide(x1,x2,y2) then --falling
      --6 = jumping/falling
      change_sprite(6)
    elseif btn(0) or btn(1) then --is walking
      local mt = time()-player.move_prevt
      if mt >= player.move_animt then
        player.move_prevt = time()
        if player.s==sprites[player.morality][2] then
          change_sprite(3)
        else
          change_sprite(2)
        end
      end
    else --idle
      --1 = idle
      change_sprite(1)
     end
     player.speed = speed[player.morality][1] --walking speed
    end
    --shoot
    if btnp(4) and
       player.lvl_killc<kill_limit
       then
     shoot()
    player.shoot_start = time()
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
   fall()
   move_blasts()
   enemy_move_bullet()
   move_enemy()
   touch_enemy()
   if player.hp<=0 then
     player_die()
   end
 else
   if btn(4) then
     _init()
   end
 end
end

function _draw()
  cls()
  if not player.is_dead then
    display_map(lvl)
    display_enemies()
    enemy_check_range()
    display_blasts()
    display_attr()
    display_enemy_bullet()
    spr(player.s,player.x,player.y,player.s_w,player.s_h,player.flipped)
  else
    print("game over",48,60,8)
    print("press z to start again",20,70,8)
  end

end
__gfx__
00000000010000000101111001000000010000000110001001000000005555000044444000000444440000000055550000444440000000444440000056000000
0000000010111100101444411011110010111110101111011011111000ffff500044444000000a44a400000000ffff5000444440000000484440000055000000
00700700014444100104747001444410014444010144440001444401005f5f00006446400000044444000000008f8f0000844840000000444440000000000000
0007700010474701000444401047470110474700014747001047470000ffff0000444440000000044000000000ffff0000444440000000004400000000000000
000770000044440000033330004444000044440010444400004444000000f0000000445500000044440000000000f00000004455000000004444400000000000
00700700000400000003630000040000000400000334330000040000004444400055555500000444444440000044444000555556000000044440040000000000
00000000003330000000555000333300033330003333303003333337040444040555555500004444440040000404440466666666888884444440400000000000
00000000033333000065006003333030303333003033300630333000040444040550555688884444400080005555555f64466644888880844444000000000000
070550003033303001011110303330030363306060333000033630005555555f66666666888044444888800000f655f000555446888800844444000000000000
0005705030333030101444410363300600333000004440000033300000f655f06446664488805555588880000004450000555565888800855555000000000000
0560507560444060010474700044400000444000005555000044400000011500001114410000555558880000000111000011111100000005555500000ddd0000
605000060055500000044440005550000055500000500500005550000001111000111161000055000550000000111110001111110000000550055000dccccddd
0607606000505000003333360050500000500500655005000050500000110010001101110005500000550000001000100011011100000055000555000d77dd00
000507000050500000603300655050000050600060000660005005000010000100110111000800000080000001000001001101110000008000000800007d0000
00000000005050000000555060005000050060000000000065000500001000010011011100550000055000000100000100110111000055000000055000700000
00000000066066000006506000006600066000000000000060000660055000550555055505550000550000005500005505550555000555000000555000000000
090000000a0999a00a000000090000000a9000a00a0000000c0000000c0cccc00c0000000c0000000cc000c00c00000000880880006666000008800000000000
a0a9a9009095555a9099aa00909a99a090999a0aa099aa70c0cccc00c0c4444cc0cccc00c0ccccc0c0cccc0cc0ccccc002888780050070600008800000000000
0a5555a00a0585800a5555a00a55550a0a555500095555070c4444c00c0474700c4444c00c44440c0c4444000c44440c02888880050007600008800000000000
90585809000555509058580a905858000958580090585800c047470c00044440c047470cc04747000c474700c047470000288800056000600008800000000000
00555500000499400055550000555500a05555000055550000444400000777700044440000444400c04444000044440000028000056660600000000000000000
000400000009a400000400000005000004a5a4000005000000040000000757000004000000040000077477000004000000000000005555000008800000000000
0049400000005590044a4000044a400044aaa09004499aa700747000000055500077700007777000777770600777776700000000000000000008800000000000
04aaa40000a900a090a9a90040999400909a900a90aaa00007777700007500700777770070777700607770057077700000000000000000000000000000000000
409a90400a09a9a009aa90aa09a990a0a04940000a9aa000707770700c0cccc00677706007577060507770000765700005505500000550000000000000000000
90494090909555590099900000494000004440000049900060777060c0c4444c6077705000777005007770000077700005050500005005000000000000000000
a04440a00a05858000444000004440000055550000449000507770500c0474705077700000777000005555000077700005000500005005000000000000000000
00555000000555500055500000555000005009000055500000555000000444400055500000555000005005000055500000505000000550000000000000000000
005050000099449a0050500000500900aa900a000050500000505000007777750050500000500600765006000050500000050000000000000000000000000000
0090900000a0aa00aa9090000090a000a0000aa00090090000505000005077007650500000507000700007700050050000000000000000000000000000000000
00a0a00000005590a000a0000a00a00000000000aa000a0000606000000055607000600006007000000000007600060000000000000000000000000000000000
0aa0aa00000a90a00000aa000aa0000000000000a0000aa007707700000750700000770007700000000000007000077000000000000000000000000000000000
511151515555555533b3333333b33333000400400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15151115555555553333333b3333333b000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555515555555554334434453355355040400040000000000111111111111001111111111111111000000000000000000000000000000000000000000000000
5515555555a55a55444444445555555500400000000000000015ddddddddd100dddddddddddddddd000000000000000000000000000000000000000000000000
5555155504444440344444443555555540044040000000000015d5555555d100555555555555d555000000000000000000000000000000000000000000000000
5555555504444440444444345555553500440004000000000015d1111115d100111111111115d111000000000000000000000000000000000000000000000000
5555555500400400444544445553555504040440000000000015d1000015d100000000000015d100000000000000000000000000000000000000000000000000
5555555500000000444444445555555500404000000000000015d1000015d100000000000015d100000000000000000000000000000000000000000000000000
55555555555555554444444433b3333300050500000000000015d1000015d1000015d1000015d100000000000000000000000000000000000000000000000000
5555555555555555444444443333333b00050500000000000015d1000015d1000015d1000015d100000000000000000000000000000000000000000000000000
5555555555555555444444445335434500050500000000000015d1111115d1111115d1001115d111000000000000000000000000000000000000000000000000
5555555555555555444444445555544400050500000000000015ddddddddddddddddd100dddddddd000000000000000000000000000000000000000000000000
555555550000000044444444355445440000050000000000001555555555d5555555510055555555000000000000000000000000000000000000000000000000
555555550000000044444444555544340005500000000000001111111115d1111111110011111111000000000000000000000000000000000000000000000000
555555550000000044444444555345450005050000000000000000000015d1000000000000000000000000000000000000000000000000000000000000000000
555555550000000044444444555554440005050000000000000000000015d1000000000000000000000000000000000000000000000000000000000000000000
5555555533b33333000000000000000000050500000000000015d1000015d1000015d10000000000000000000000000000000000000000000000000000000000
555555553333333b000000000000000000050500000000000015d1000155d5100015d10000000000000000000000000000000000000000000000000000000000
5555555543345355000000000000000000050500000000000155d5100155dd101115d10000000000000000000000000000000000000000000000000000000000
5555550554455555000000000000000000050500000000000155dd1000000000ddddd10000000000000000000000000000000000000000000000000000000000
55055555345455550000000000000000005005000000000000bbbb00000000005555d10000000000000000000000000000000000000000000000000000000000
55555555444445350000000000000000055550000000000000b0bb00000000001115d10000000000000000000000000000000000000000000000000000000000
50555505544355550000000000000000550505050000000000b0b000000000000015d10000000000000000000000000000000000000000000000000000000000
0505055544545555000000000000000055000505000000000000b000000000000015d10000000000000000000000000000000000000000000000000000000000
511151510000000000000000000000000000000000000000000bb0000015d1000015d10000000000000000000000000000000000000000000000000000000000
151511150000000000000000000000000000000000000000000bbb000015d1000015d10000000000000000000000000000000000000000000000000000000000
555555150000000000000000000000000000000000000000000b0b000015d1000015d11100000000000000000000000000000000000000000000000000000000
551555050000000000000000000000000000000000000000000b00000015d1000015dddd00000000000000000000000000000000000000000000000000000000
550515550000000000000000000000000000000000000000000b00000015d1000015d55500000000000000000000000000000000000000000000000000000000
555555550000000000000000000000000000000000000000000000000015d1000015d11100000000000000000000000000000000000000000000000000000000
505555050000000000000000000000000000000000000000000000000015d1000015d10000000000000000000000000000000000000000000000000000000000
050505550000000000000000000000000000000000000000000000000015d1000015d10000000000000000000000000000000000000000000000000000000000
__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000010301010000000000000000000000000101000000000000000000000000000001000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000046484948594859574859484948575949580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000077006600000000670000006746680066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000067007600000000000000000066770076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000005342615342420000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000524200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000005261435342000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040400000000000000000000000000070404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000070000000415151515151410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004040400050000000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000060000000000000000000000000435342000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040400000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044000043434343434343000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404064000060600000006060000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050505050505040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606060606060606060606060606060606060606060606060606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010e00000c1731c600001000c1731c67500100000000c1730c1730c1000c1730c1001c67500100000000c1730c1731c600001000c1731c67500100000000c1730c1730c1730c1730c1001c67500100000000c173
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
01140000212501e450180001800021250180001d2502145014252000000f2520e2520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000022550215501f5501d5501c550000000000000000000003800038000380003800037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000d050110501e050210500c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002b45039050306533455126651266513065334654000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 03010244
01 4105074e
00 4106084e
00 41050749
00 41060849
00 09050749
00 09060849
00 09050749
00 0b060849
01 0905070a
00 0906080a
00 0905070a
02 4508060b
00 0a05070e
01 0a0f114e
02 0a10124e
01 17134344
00 17144344
01 17131544
02 17141644
01 17131518
02 17141619
01 1713151a
02 1714161b
03 1c424344
03 1c1d1d1e

