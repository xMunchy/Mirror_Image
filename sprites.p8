pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init

function _init()
 -- game variables --
 prev_t = time()
 
 -- player dynamic variables --
 player = {}
 player.s = 1 --sprite
 player.s_w = 1 --sprite size
 player.s_h = 2
 player.x = 0 --position
 player.y = 0
 player.flipped = false
 player.speed = 32
 player.is_crouching = false
 
 -- player jumping --
 player.is_jumping = false
 player.jump_tstart = 0
 player.jump_tprev = 0
 player.jump_h = 0 --height
  --[[
  which jump are you on?
  0 = not jumping
  1 = first jump
  2 = double jump
  3 = triple jump (can no longer jump)
  ]]
 player.njump = 0
 player.jump1 = 16 --height of first jump
 player.jumpxtra = 8 --height of extra jumps

  
 -- player static variables --
 player.stand_s = 1 --sprite
 player.stand_w = 1 --sprite size
 player.stand_h = 2
 player.stand_speed = 32
 player.crouch_s = 18 --sprite
 player.crouch_w = 1 --sprite size
 player.crouch_h = 1
 player.crouch_speed = 16
 player.can_triplej = false

 -- enemies --
 enemy = {} --kind 1 ez, 2 med, 3 hard
 enemy.s = {6,7,8}
 enemy.s_w = 1 --sprite size
 enemy.s_h = 2
 
 -- player blasts --
 blast = {}
 blast.s = 5
 blast.s_w = 1
 blast.s_h = 1
 blast.w = 3 --size by pixels
 blast.h = 3 --size by pixels
 blast.speed = 2 --speed of blasts
 blast.limit = 2 --max onscreen
 blast.wait = 1 --time between blasts
 blast.last = 0
end
-->8
--player

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
 player.jump_tstart = time()
 player.jump_tprev = time()
 player.is_jumping = true
 if player.njump==0 then
  player.jump_h = player.jump1
 else
  player.jump_h = player.jumpxtra
 end
 player.y -= 1
 player.njump += 1
end

--find new position in jump
function jump()
 local dt = time() - player.jump_tprev
 --check for ceiling
 local x1 = player.x
 local x2 = player.x+player.s_w*8-1
 if v_collide(x1,x2,player.y-1,0)
 then
  player.jump_h = 0 --end jump
 end
 if dt > 0.005 and
    player.jump_h > 0
 then --do some jumping
  player.y -= 2
  player.jump_h -= 1
  player.jump_tprev = time()
 end
 if(player.jump_h==0) player.is_jumping = false
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
 local dt = time() - blast.last
 if dt < 1 then
  return 0
 end
 for i=1,#blast do
  if blast[i].mx>0 and
     blast[i].x>128 then
   return i
  elseif blast[i].mx<0 and
         blast[i].x<-4 then
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
  blast.last = time() --time at latest shot
  blast[k] = {}
  blast[k].y = player.y+player.s_h/2*8
  if player.flipped then --left
   blast[k].x = player.x-blast.w
   blast[k].mx = -blast.speed
   blast[k].flipped = true
  else --right
   blast[k].x = player.x+player.s_w*8
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
  blast[i].x += blast[i].mx
 end
end

function display_blasts()
 for i=1,#blast do
  spr(blast.s,blast[i].x,blast[i].y,blast.s_w,blast.s_h,blast[i].flipped)
 end
end
-->8
--enemies

--[[
spawn enemies
kind: enemy type
x and y: position
]]
function make_enemy(kind,x,y,flipped)
 local k = #enemy+1
 enemy[k] = {}
 enemy[k].x = x
 enemy[k].y = y
 enemy[k].kind = kind --1 ez, 2 med, 3 hard
 enemy[k].s = enemy.s[kind] --sprite
 enemy[k].s_w = enemy.s_w --size
 enemy[k].s_h = enemy.s_h
 enemy[k].flipped = flipped
end

function display_enemies()
 for i=1,#enemy do
  spr(enemy[i].s,enemy[i].x,enemy[i].y,enemy[i].s_w,enemy[i].s_h,enemy.flipped)
 end
end
-->8
--collision and physics

--[[
make player fall
simulates gravity
]]
function fall()
 local y = player.y+player.s_h*8
 local x1 = player.x
 local x2 = player.x+player.s_w*8-1
 if v_collide(x1,x2,y,0)
 then
  player.njump = 0
 else
  if(not player.is_jumping) player.y += 1
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
  if fget(mget(x,i/8),flag) then
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
  if fget(mget(i/8,y),flag) then
   return true
  end  
 end
 return false
end

-->8
--update and draw

function _update60()
--spawn one enemy
 if #enemy == 0 then
  make_enemy(1,64,104,true)
 end
 dt = time() - prev_t
 prev_t = time()
 local x1 = player.x
 local x2 = player.x+player.s_w*8
 local y1 = player.y
 local y2 = player.y+player.s_h*8
 -- walk
 if btn(0) and not 
    h_collide(x1-1,y1,y2-1,0)
    then
  player.x -= player.speed*dt
  player.flipped = true
 end
 if btn(1) and not
    h_collide(x2,y1,y2-1,0)
    then
  player.x += player.speed*dt
  player.flipped = false
 end
 -- jump
 if btnp(2) and can_jump() then
  start_jump()
 end
 -- crouch
 if btn(3) then
  player.is_crouching = true
  player.y += (player.s_h-player.crouch_h)*8
  player.x += (player.s_w-player.crouch_w)*8
  player.s = player.crouch_s
  player.s_h = player.crouch_h
  player.s_w = player.crouch_w
  player.speed = player.crouch_speed
 elseif not v_collide(x1,x2,y1-1,0) then
  player.is_crouching = false
  player.y += (player.s_h-player.stand_h)*8
  player.x += (player.s_w-player.stand_w)*8
  player.s = player.stand_s
  player.s_h = player.stand_h
  player.s_w = player.stand_w
  player.speed = player.stand_speed
 end
 if btnp(4) then
  shoot()
 end
 if(player.is_jumping) jump()
 fall()
 move_blasts()
end

function _draw()
 cls()
 map(0,0,0,0)
 display_enemies()
 display_blasts()
 spr(player.s,player.x,player.y,player.s_w,player.s_h,player.flipped)
end
__gfx__
00000000010000000101111051115151010000000009800000555500004444400000444440000000000000000000000000000000000000000000000000000000
0000000010111100101444411515111510111100009a988000ffff50004444400000a44a40000000000000000000000000000000000000000000000000000000
00700700014444100104747055555515014444100a90a098005f5f00005445400000444440000000000000000000000000000000000000000000000000000000
0007700010474701000444405515555510474701a0a9090800ffff00004444400000000400000000000000000000000000000000000000000000000000000000
00077000004444000003333055551555004444000a9980800000f000000544550000004440000000000000000000000000000000000000000000000000000000
0070070000040000000363005555555500040000000a980000444440005555550000044444400000000000000000000000000000000000000000000000000000
00000000003330000000555055555555033330000000000004044404055055550000444444040000000000000000000000000000000000000000000000000000
00000000033333000065006055555555303333000000000004044404055055568888444440080000000000000000000000000000000000000000000000000000
0000000030333030010111100000000003363036000000005555555f666666668880444448880000000000000000000000000000000000000000000000000000
00000000303330301014444100000000003330000000000000f655f0644666448880555558880000000000000000000000000000000000000000000000000000
00000000604440600104747000000000004440000000000000011500001114410000555558800000000000000000000000000000000000000000000000000000
00000000005550000004444000000000005550000000000000111110001111610000550055000000000000000000000000000000000000000000000000000000
00000000005050000033333600000000005050000000000000100010001101110005500005500000000000000000000000000000000000000000000000000000
00000000005050000060330000000000655050000000000001000001001101110005000000550000000000000000000000000000000000000000000000000000
00000000005050000000555000000000600050000000000001000001001101110555000005500000000000000000000000000000000000000000000000000000
00000000006066000006506000000000000066000000000055000055055505550555000055000000000000000000000000000000000000000000000000000000
090000000a0999a00a00000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a9a9009095555a9099aa0000000000101111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a5555a00a0585800a5555a000000000014444100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90585809000555509058580a00000000014747010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500000499400055550000000000104444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000009a4000004000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00494000000055900049400000000000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04aaa40000a900a00999990000000000303333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
409a90400a09a9a0909990aa00000000303330360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90494090909555590aa9900000000000303330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a04440a00a0585800044400000000000604440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555000000555500055500000000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005050000099449a0050500000000000005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090900000a0aa00aa90900000000000065050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0a00000005590a000a00000000000060050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0aa00000a90a00000aa0000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
