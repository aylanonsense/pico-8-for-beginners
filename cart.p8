pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local pumpkin
local score
local coins

function _init()
	score=0
	-- create a pumpkin object
	pumpkin={
		x=64,
		y=64,
		width=8,
		height=8,
		radius=4,
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
		end,
		draw=function(self)
			spr(4,self.x-4,self.y-4)
			-- circ(self.x,self.y,self.radius,7)
			-- rect(self.x,self.y,self.x+self.width,self.y+self.height,7)
			-- print(self.is_vertically_aligned,self.x+10,self.y,7)
			-- print(self.is_horizontally_aligned,self.x+10,self.y+7,6)
		end,
		check_for_collision=function(self,coin)
			-- check to see if the pumpkin is aligned with the coin
			local pumpkin_top=self.y
			local pumpkin_bottom=self.y+self.height
			local pumpkin_left=self.x
			local pumpkin_right=self.x+self.width
			local coin_top=coin.y
			local coin_bottom=coin.y+coin.height
			local coin_left=coin.x
			local coin_right=coin.x+coin.width
			-- collect the coin
			if not coin.is_collected and circles_overlapping(self.x,self.y,self.radius,coin.x,coin.y,coin.radius) then -- rects_overlapping(pumpkin_left,pumpkin_top,pumpkin_right,pumpkin_bottom,coin_left,coin_top,coin_right,coin_bottom) then
				coin.is_collected=true
				score+=1
			end
		end
	}
	coins={
		make_coin(10,10),
		make_coin(40,20),
		make_coin(30,40),
		make_coin(70,80),
		make_coin(90,50),
		make_coin(20,50)
	}
	-- coin={
	-- 	x=80,
	-- 	y=100,
	-- 	is_collected=false,
	-- 	update=function(self)
	-- 	end,
	-- 	draw=function(self)
	-- 		if not self.is_collected then
	-- 			spr(7,self.x-3,self.y-4)
	-- 			-- pset(self.x,self.y,12)
	-- 		end
	-- 	end
	-- }
end

function _update()
	pumpkin:update()
	local coin
	for coin in all(coins) do
		coin:update()
		pumpkin:check_for_collision(coin)
	end
end

function _draw()
	-- clear the screen
	cls()
	print(score,5,5,7)
	pumpkin:draw()
	local coin
	for coin in all(coins) do
		coin:draw()
	end
end

function make_coin(x,y)
	local coin={
		x=x,
		y=y,
		width=6,
		height=7,
		radius=3,
		is_collected=false,
		update=function(self)
		end,
		draw=function(self)
			if not self.is_collected then
				spr(7,self.x-3,self.y-3)
				-- circ(self.x,self.y,self.radius,12)
				-- rect(self.x,self.y,self.x+self.width,self.y+self.height,12)
				-- pset(self.x,self.y,12)
			end
		end
	}
	return coin
end

function is_point_in_rect(x,y,left,top,right,bottom)
	return top<y and y<bottom and left<x and x<right
end

function lines_overlapping(min1,max1,min2,max2)
	return max1>min2 and max2>min1
end

function rects_overlapping(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
	return lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2)
end

function circles_overlapping(x1,y1,r1,x2,y2,r2)
	local dx=mid(-100,x2-x1,100)
	local dy=mid(-100,y2-y1,100)
	return dx*dx+dy*dy<(r1+r2)*(r1+r2)
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
