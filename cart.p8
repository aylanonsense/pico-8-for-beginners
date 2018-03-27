pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local pumpkin
local coin
local score

function _init()
	score=0
	-- create a pumpkin object
	pumpkin={
		x=64,
		y=64,
		width=8,
		height=8,
		move_speed=1,
		is_horizontally_aligned=false,
		is_vertically_aligned=false,
		update=function(self)
			if btn(1) then
				self.x+=self.move_speed
			end
			if btn(0) then
				self.x-=self.move_speed
			end
			if btn(3) then
				self.y+=self.move_speed
			end
			if btn(2) then
				self.y-=self.move_speed
			end
			-- check to see if the pumpkin is aligned with the coin
			local top=self.y
			local bottom=self.y+self.height
			if top<coin.y and coin.y<bottom then
				self.is_horizontally_aligned=true
			else
				self.is_horizontally_aligned=false
			end
			local left=self.x
			local right=self.x+self.width
			if left<coin.x and coin.x<right then
				self.is_vertically_aligned=true
			else
				self.is_vertically_aligned=false
			end
			-- collect the coin
			if self.is_horizontally_aligned and self.is_vertically_aligned and not coin.is_collected then
				coin.is_collected=true
				score+=1
			end
		end,
		draw=function(self)
			spr(4,self.x,self.y)
			-- rect(self.x,self.y,self.x+self.width,self.y+self.height,7)
			-- print(self.is_vertically_aligned,self.x+10,self.y,7)
			-- print(self.is_horizontally_aligned,self.x+10,self.y+7,6)
		end
	}
	coin={
		x=80,
		y=100,
		is_collected=false,
		update=function(self)
		end,
		draw=function(self)
			if not self.is_collected then
				spr(7,self.x-3,self.y-4)
				-- pset(self.x,self.y,12)
			end
		end
	}
end

function _update()
	pumpkin:update()
	coin:update()
end

function _draw()
	-- clear the screen
	cls()
	print(score,5,5,7)
	pumpkin:draw()
	coin:draw()
end

__gfx__
000000000000000000500500000000000000b0000000b0000000b000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cc0550cc00000000000b3000000b3000000b3000009aa0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ccc55ccc00000000099b39400eeb3e200ccb3c1009aaaa000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ccc55ccc0000000099494994ee2e2ee2cc1c1cc109aaaa000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cee55eec0000000094999494e2eee2e2c1ccc1c109aaaa000000000000000000000000000000000000000000000000000000000000000000
0000000000000000eee55eee0000000094999499e2eee2eec1ccc1cc09aaaa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000ee00ee00000000094999499e2eee2eec1ccc1cc009aa0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000094994900e2ee2e00c1cc1c0000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a0000180501a0501c0502405024050240502405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001b0661b0661b0661b0641b0671b0641b0630d0000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180551a0551c0552405024040240302402024010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
