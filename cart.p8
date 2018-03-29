pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local pumpkin
local score
local coins
local blocks

function _init()
	-- start the score counter at zero
	score=0
	-- create a pumpkin object
	pumpkin={
		x=64,
		y=24,
		velocity_x=0,
		velocity_y=0,
		width=8,
		height=8,
		move_speed=1.5,
		is_standing_on_block=false,
		update=function(self)
			-- apply friction
			self.velocity_x*=0.2
			-- move the player with the arrow keys
			if btn(1) then
				self.velocity_x=self.move_speed
			end
			if btn(0) then
				self.velocity_x=-self.move_speed
			end
			-- jump when z is pressed
			if btn(4) and self.is_standing_on_block then
				self.velocity_y=-3
			end
			-- apply gravity
			self.velocity_y+=0.1
			-- make sure the velocity doesn't get too big
			self.velocity_x=mid(-3,self.velocity_x,3)
			self.velocity_y=mid(-3,self.velocity_y,3)
			-- apply the velocity
			self.x+=self.velocity_x
			self.y+=self.velocity_y
			-- the pumpkin is standing on a block if its
			--  bottom hitbox collide with one
			self.is_standing_on_block=false
		end,
		draw=function(self)
			-- local x,y,w,h=self.x,self.y,self.width,self.height
			spr(4,self.x,self.y)
			-- rect(self.x,self.y,self.x+self.width,self.y+self.height,7)
			-- the top hitbox (blue)
			-- rectfill(x+2,y,x+w-2,y+h/2,12)
			-- -- the bottom hitbox (red)
			-- rectfill(x+2,y+h/2,x+w-2,y+h,8)
			-- -- the left hitbox (green)
			-- rectfill(x,y+2,x+w/2,y+h-2,11)
			-- -- the right hitbox (yellow)
			-- rectfill(x+w/2,y+2,x+w,y+h-2,10)
		end,
		check_for_coin_collision=function(self,coin)
			-- check to see if the pumpkin is aligned with the coin
			if not coin.is_collected and bounding_boxes_overlapping(self,coin) then
				coin.is_collected=true
				score+=1
			end
		end,
		check_for_block_collision=function(self,block)
			-- calculate the four hitboxes
			local x,y,w,h=self.x,self.y,self.width,self.height
			local top_hitbox={x=x+3.1,y=y,width=w-6.2,height=h/2}
			local bottom_hitbox={x=x+3.1,y=y+h/2,width=w-6.2,height=h/2}
			local left_hitbox={x=x,y=y+3.1,width=w/2,height=h-6.2}
			local right_hitbox={x=x+w/2,y=y+3.1,width=w/2,height=h-6.2}
			if bounding_boxes_overlapping(bottom_hitbox,block) then
				self.y=block.y-self.height
				if self.velocity_y>0 then
					self.velocity_y=0
				end
				self.is_standing_on_block=true
			elseif bounding_boxes_overlapping(left_hitbox,block) then
				self.x=block.x+block.width
				if self.velocity_x<0 then
					self.velocity_x=0
				end
			elseif bounding_boxes_overlapping(right_hitbox,block) then
				self.x=block.x-self.width
				if self.velocity_x>0 then
					self.velocity_x=0
				end
			elseif bounding_boxes_overlapping(top_hitbox,block) then
				self.y=block.y+block.height
				if self.velocity_y<0 then
					self.velocity_y=0
				end
			end
		end
	}
	-- create some coins
	coins={}
	blocks={}
	local i
	for i=1,3 do
		add(coins,make_coin(30+15*i,80))
	end
	for i=1,14 do
		add(blocks,make_block(8*i,90))
	end
	add(blocks,make_block(50,50))
	add(blocks,make_block(90,70))
	add(blocks,make_block(30,82))
end

function _update()
	pumpkin:update()
	local coin
	for coin in all(coins) do
		coin:update()
		pumpkin:check_for_coin_collision(coin)
	end
	local block
	for block in all(blocks) do
		block:update()
		pumpkin:check_for_block_collision(block)
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
	local block
	for block in all(blocks) do
		block:draw()
	end
end

function make_block(x,y)
	return {
		x=x,
		y=y,
		width=8,
		height=8,
		update=function(self)
		end,
		draw=function(self)
			spr(6,self.x,self.y)
			-- rect(self.x,self.y,self.x+self.width,self.y+self.height,8)
		end
	}
end

function make_coin(x,y)
	local coin={
		x=x,
		y=y,
		width=6,
		height=7,
		is_collected=false,
		update=function(self)
		end,
		draw=function(self)
			if not self.is_collected then
				spr(7,self.x,self.y)
				-- rect(self.x,self.y,self.x+self.width,self.y+self.height,12)
			end
		end
	}
	return coin
end

function lines_overlapping(min1,max1,min2,max2)
	return max1>min2 and max2>min1
end

function rects_overlapping(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
	return lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2)
end

function bounding_boxes_overlapping(obj1,obj2)
	return rects_overlapping(obj1.x,obj1.y,obj1.x+obj1.width,obj1.y+obj1.height,obj2.x,obj2.y,obj2.x+obj2.width,obj2.y+obj2.height)
end

__gfx__
000000000000000000000000000000000000b0000000000077777777000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000b3000000000007666666d009aa0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099b3940000000007677776d09aaaa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000994949940000000076766d6d09aaaa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000949994940000000076766d6d09aaaa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000949994990000000076dddd6d09aaaa000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000094999499000000007666666d009aa0000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000949949000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a0000180501a0501c0502405024050240502405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001b0661b0661b0661b0641b0671b0641b0630d0000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180551a0551c0552405024040240302402024010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
