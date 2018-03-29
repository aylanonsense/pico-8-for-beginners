pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local score
local game_objects

function _init()
	-- start the score counter at zero
	score=0
	-- create the game objects
	game_objects={}
	-- create a player
	make_player(64,24)
	-- create some coins
	local i
	for i=1,3 do
		make_coin(30+15*i,80)
	end
	-- create some blocks
	for i=1,14 do
		make_block(8*i,90)
	end
	make_block(50,50)
	make_block(90,70)
	make_block(30,82)
end

function _update()
	local obj
	-- update all the game objects
	for obj in all(game_objects) do
		obj:update()
	end
end

function _draw()
	-- clear the screen
	cls()
	-- draw the score
	print(score,5,5,7)
	-- draw all the game objects
	local obj
	for obj in all(game_objects) do
		obj:draw()
	end
end


-- game object creation functions
function make_player(x,y)
	return make_game_object("player",x,y,{
		width=8,
		height=8,
		move_speed=1,
		is_standing_on_block=false,
		is_facing_left=false,
		walk_counter=0,
		update=function(self)
			-- update walk counter
			if self.walk_counter==0 then
				self.walk_counter=8
			else
				self.walk_counter-=1
			end
			-- apply friction
			self.velocity_x*=0.2
			-- move the player with the arrow keys
			if btn(1) then
				self.velocity_x=self.move_speed
				self.is_facing_left=false
			end
			if btn(0) then
				self.velocity_x=-self.move_speed
				self.is_facing_left=true
			end
			-- jump when z is pressed
			if btn(4) and self.is_standing_on_block then
				self.velocity_y=-3
				sfx(3)
			end
			-- apply gravity
			self.velocity_y+=0.1
			-- make sure the velocity doesn't get too big
			self.velocity_x=mid(-3,self.velocity_x,3)
			self.velocity_y=mid(-3,self.velocity_y,3)
			-- apply the velocity
			self.x+=self.velocity_x
			self.y+=self.velocity_y
			-- check to see if hitting coins
			for_each_game_object("coin",function(coin)
				if self:check_for_hit(coin) and not coin.is_collected then
					coin.is_collected=true
					score+=1
					sfx(4)
				end
			end)
			-- check to see if colliding with blocks
			local was_standing_on_block=self.is_standing_on_block
			self.is_standing_on_block=false
			for_each_game_object("block",function(block)
				local collision_dir=self:check_for_collision(block,3.1)
				self:handle_collision(block,collision_dir)
				if collision_dir=="down" then
					self.is_standing_on_block=true
					if not was_standing_on_block then
						sfx(5)
					end
				end
			end)
		end,
		draw=function(self)
			-- self:draw_bounding_box(7)
			local sprite_num
			if self.is_standing_on_block then
				if self.velocity_x==mid(-0.1,self.velocity_x,0.1) then
					sprite_num=8
				elseif self.walk_counter<4 then
					sprite_num=9
				else
					sprite_num=10
				end
			else
				if self.velocity_y>0 then
					sprite_num=12
				else
					sprite_num=11
				end
			end
			spr(sprite_num,self.x,self.y,1,1,self.is_facing_left)
		end
	})
end

function make_block(x,y)
	return make_game_object("block",x,y,{
		width=8,
		height=8,
		draw=function(self)
			spr(6,self.x,self.y)
			-- rect(self.x,self.y,self.x+self.width,self.y+self.height,8)
		end
	})
end

function make_coin(x,y)
	return make_game_object("coin",x,y,{
		width=6,
		height=7,
		is_collected=false,
		draw=function(self)
			if not self.is_collected then
				spr(7,self.x,self.y)
				-- rect(self.x,self.y,self.x+self.width,self.y+self.height,12)
			end
		end
	})
end

function make_game_object(name,x,y,props)
	local obj={
		name=name,
		x=x,
		y=y,
		velocity_x=0,
		velocity_y=0,
		update=function(self)
			-- do nothing
		end,
		draw=function(self)
			-- don't draw anything
		end,
		draw_bounding_box=function(self,color)
			rect(self.x,self.y,self.x+self.width,self.y+self.height,color)
		end,
		center=function(self)
			return self.x+self.width/2,self.y+self.height/2
		end,
		check_for_hit=function(self,other)
			return bounding_boxes_overlapping(self,other)
		end,
		check_for_collision=function(self,other,indent)
			local x,y,w,h=self.x,self.y,self.width,self.height
			local top_hitbox={x=x+indent,y=y,width=w-2*indent,height=h/2}
			local bottom_hitbox={x=x+indent,y=y+h/2,width=w-2*indent,height=h/2}
			local left_hitbox={x=x,y=y+indent,width=w/2,height=h-2*indent}
			local right_hitbox={x=x+w/2,y=y+indent,width=w/2,height=h-2*indent}
			if bounding_boxes_overlapping(bottom_hitbox,other) then
				return "down"
			elseif bounding_boxes_overlapping(left_hitbox,other) then
				return "left"
			elseif bounding_boxes_overlapping(right_hitbox,other) then
				return "right"
			elseif bounding_boxes_overlapping(top_hitbox,other) then
				return "up"
			end
		end,
		handle_collision=function(self,other,dir)
			if dir=="down" then
				self.y=other.y-self.height
				if self.velocity_y>0 then
					self.velocity_y=0
				end
			elseif dir=="left" then
				self.x=other.x+other.width
				if self.velocity_x<0 then
					self.velocity_x=0
				end
			elseif dir=="right" then
				self.x=other.x-self.width
				if self.velocity_x>0 then
					self.velocity_x=0
				end
			elseif dir=="up" then
				self.y=other.y+other.height
				if self.velocity_y<0 then
					self.velocity_y=0
				end
			end
		end
	}
	-- add additional properties
	local key,value
	for key,value in pairs(props) do
		obj[key]=value
	end
	-- add it to the list of game objects
	add(game_objects,obj)
	-- return the game object
	return obj
end


-- hit detection helper functions
function rects_overlapping(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
	return right1>left2 and right2>left1 and bottom1>top2 and bottom2>top1
end

function bounding_boxes_overlapping(obj1,obj2)
	return rects_overlapping(obj1.x,obj1.y,obj1.x+obj1.width,obj1.y+obj1.height,obj2.x,obj2.y,obj2.x+obj2.width,obj2.y+obj2.height)
end


function for_each_game_object(name,callback)
	local obj
	for obj in all(game_objects) do
		if obj.name==name then
			callback(obj)
		end
	end
end

__gfx__
000000000000000000000000000000000000b0000000000077777777000000000003000000030000000300000003000000030000000000000000000000000000
00000000000000000000000000000000000b3000000000007666666d009aa0000033330000333300003333000033330000333300000000000000000000000000
00000000000000000000000000000000099b3940000000007677776d09aaaa000099990000999900009999000094940000999900000000000000000000000000
00000000000000000000000000000000994949940000000076766d6d09aaaa000094940000949400009494000099994400999900000000000000000000000000
00000000000000000000000000000000949994940000000076766d6d09aaaa000099994400999944009999440099990000949400000000000000000000000000
00000000000000000000000000000000949994990000000076dddd6d09aaaa000099990000999900009999000099990000999944000000000000000000000000
0000000000000000000000000000000094999499000000007666666d009aa0000044440000444400004444000444444004444440000000000000000000000000
000000000000000000000000000000000949949000000000dddddddd000000000040040004000040000440000000000000000000000000000000000000000000
__sfx__
010a0000180501a0501c0502405024050240502405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001b0661b0661b0661b0641b0671b0641b0630d0000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180551a0551c0552405024040240302402024010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000011440114411344114431174311b4211f42125411004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01070000180551c0551f0552405024031240110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001144000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
