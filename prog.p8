pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
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
end
-->8
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

function make_enemy(kind,x,y)
 local k = #enemy+1
 enemy[k] = {}
 enemy[k].x = x
 enemy[k].y = y
 enemy[k].kind = kind --1 ez, 2 med, 3 hard
 enemy[k].s = enemy.s[kind]
 enemy[k].s_w = enemy.s_w
 enemy[k].s_h = enemy.s_h
end

-->8
function _update60()
--[[spawn one enemy
 if #enemy == 0 then
  make_enemy(1,64,104)
 end]]
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
 if(player.is_jumping) jump()
 fall()
end

function _draw()
 cls()
 map(0,0,0,0)
 for i=1,#enemy do
  spr(enemy[i].s,enemy[i].x,enemy[i].y,enemy[i].s_w,enemy[i].s_h)
 end
 spr(player.s,player.x,player.y,player.s_w,player.s_h,player.flipped)
end
__gfx__
0000000001000000000000001111111101000000666000000088880000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000
000000001011110000000000111111111011110066600000088888800cccccc00bbbbbb000000000000000000000000000000000000000000000000000000000
00700700014444100000000011111111014444106660000088888888ccccccccbbbbbbbb00000000000000000000000000000000000000000000000000000000
00077000104747010000000011111111104747010000000088888888ccccccccbbbbbbbb00000000000000000000000000000000000000000000000000000000
00077000004444000000000011111111004444000000000088888888ccccccccbbbbbbbb00000000000000000000000000000000000000000000000000000000
00700700000400000000000011111111000400000000000088888888ccccccccbbbbbbbb00000000000000000000000000000000000000000000000000000000
000000000033300000000000111111110033300000000000088888800cccccc00bbbbbb000000000000000000000000000000000000000000000000000000000
0000000003333300000000001111111103333300000000000088880000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000
000000003033303001011110000000003033303000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000003033303010144441000000003033303000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000006044406001047470000000006044406000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000000055500000044440000000000055500000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000000050500000033333000000000050500000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000000050500000603306000000006550500000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000000050500000055550000000006000500000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
000000000060660006550060000000000000660000000000000080000000c0000000b00000000000000000000000000000000000000000000000000000000000
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
