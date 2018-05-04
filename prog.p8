pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 -- player dynamic variables --
 player = {}
 player.s = 1 --sprite
 player.s_w = 1 --sprite size
 player.s_h = 2
 player.x = 0 --position
 player.y = 0
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
 player.crouch_s = 18 --sprite
 player.crouch_w = 1 --sprite size
 player.crouch_h = 1
 player.can_triplej = false

end
-->8
function can_jump()
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
 local y = (player.y+15+1)/8
 local x1 = (player.x)/8
 local x2 = (player.x+7)/8
 if fget(mget(x1,y),0) or
    fget(mget(x2,y),0)
 then
  player.njump = 0
 else
  if(not player.is_jumping) player.y += 1
 end
end
-->8
function _update60()
 if(btn(0)) player.x -= 1
 if(btn(1)) player.x += 1
 if btnp(2) and can_jump() then
  start_jump()
 end
 if(player.is_jumping) jump()
 fall()
end

function _draw()
 cls()
 map(0,0,0,0)
 spr(player.s,player.x,player.y,player.s_w,player.s_h)
end
__gfx__
00000000000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006666000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066666600000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000666666660000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000666666660000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666666660000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060666000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060006000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000600066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
