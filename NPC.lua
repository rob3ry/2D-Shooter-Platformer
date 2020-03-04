require 'EnemyView'

local wWidth = 768
local wHeight = 640
local WALKING_SPEED = 100
local JUMP_VELOCITY = 700

NPC = {}
NPC.__index = NPC

function NPC:create(map,x,y)
    local this = {
        oldx = x,
        oldy = y,
        x = x,
        y = y,
        
        width = 64,
        
        height = 84,

        -- reference to map for checking tiles
        map = map,
        texture = g.newImage("assets/zombie.png"),
        --texture = g.newImage("dave_walk_and_jump.png"),
        
        texturePath = "assets/zombie.png",
        
        -- view component is HERE
        view = EnemyView:create(self, "assets/zombie.png"),

        -- used to determine behavior and animations
        state = 'walking',

        -- determines sprite flipping
        direction = 'left',

        -- amount of lifes the hero has
        lifes = 3,

        hit = false,
        attacked = false,
    
        -- x and y velocity
        dx = 0,
        dy = 0
    }
    this.dx = -WALKING_SPEED
    this.sTimer = 0
    this.aTimer = 0
    --this.hit = false

    this.behaviors = {
        ['idle'] = function(dt)
            this.dx = 0

            local p = this.map.player
            if checkCollision(this.x,this.y,this.width,this.height,p.x,p.y,p.width,p.height) then
                if this.attacked then
                    if this.sTimer > 30 then
                        this.sTimer = 0
                        --this.attacked = true
                        this.state = 'attacking'
                        this.view:handleInput(this.state)
                    end
                else
                    this.attacked = true
                    this.state = 'attacking'
                    this.view:handleInput(this.state)
                end
            else
                this.state = 'walking'
                this.view:handleInput(this.state)
            end
            --- not sure about it
            --[[ if not this.map:collides(this.map:tileAt(this.x, this.y + this.height)) and
            not this.map:collides(this.map:tileAt(this.x + (this.width - 1), this.y + this.height)) then
                this.state = 'falling'
                this.view:handleInput(this.state)
            end  ]]
            -- --- --- -- --- ----

            this.inBoundaries(this)
        end,
        ['walking'] = function (dt)
            local p = this.map.player
            if checkCollision(this.x,this.y,this.width,this.height,p.x,p.y,p.width,p.height) then
                this.sTimer = 0
                this.state = 'attacking'
                this.view:handleInput(this.state)
                this.attacked = false
            end
            if this.direction == 'right' then
                this.dx = WALKING_SPEED
            else
                this.dx = -WALKING_SPEED
            end

            if this.dx < 0 then
                if not this.map:collides(this.map:tileAt(this.x, this.y + this.height)) then
                    this.dx = WALKING_SPEED
                    this.direction = 'right'
                    --this.view:handleInput(this.state)
                end
            else
                if not this.map:collides(this.map:tileAt(this.x + (this.width - 1), this.y + this.height)) then
                    this.dx = -WALKING_SPEED
                    this.direction = 'left'
                end
            end 

            this:checkRightCollision()
            this:checkLeftCollision()
        
       
            -- falling off of edge of tiles handling --
            if not this.map:collides(this.map:tileAt(this.x, this.y + this.height)) and
            not this.map:collides(this.map:tileAt(this.x + (this.width - 1), this.y + this.height)) then
                if this.dx < 0 then
                    this.direction = 'right'
                    this.dx = -this.dx
                else
                    this.direction = 'left'
                    this.dx = -this.dx
                end
            end

            this.inBoundaries(this)
        end,    
        ['attacking'] = function(dt)
            this.dx = 0
            local attackX
            local p = this.map.player

            if this.direction == 'right' then
                attackX = this.x + 20
            else
                attackX = this.x - 20
            end

            
            --this.sTimer = 0
            if this.sTimer > 30 then
                if checkCollision(attackX,this.y,this.width,this.height,p.x,p.y,p.width,p.height) then
                    this.map.player.lifes = this.map.player.lifes - 1
                    --gameState = 'over'
                end
                this.sTimer = 0
                this.state = 'idle'
                this.view:handleInput(this.state)
            end
            --[[ this.state = 'walking'
            this.view:handleInput(this.state) ]]

            this.inBoundaries(this)
        end
    }


    setmetatable(this,self)
    return this
end

function NPC:iterateTimer()
    self.sTimer = self.sTimer + 1
end

--[[ function NPC:isHit()
    return self.hit
end ]]
--[[ function NPC:setHit(state)
    self.hit = state
end ]]

function NPC:inBoundaries()
    if self.x <= 0 then
        self.x = 0
    elseif self.x + self.width >= self.map.pixelMapWidth then
        self.x = self.map.pixelMapWidth - self.width
    end
end

-- check if there's a tile our left
function NPC:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collides(self.map:tileAt(self.x - 1,self.y)) or
        self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            -- if so, reset velocity and position and change state
            self.dx = 0
            local xmod = (self.x - 1) % self.map.tileWidth
            local offset = self.map.tileWidth - xmod
            self.x = math.floor(self.x - 1 + offset)
            self.dx = WALKING_SPEED
            self.direction = 'right'
            --print("wall is hit , direction should be changed...dx = ", self.dx)
        end
    end
end

-- check if there's a tile our right
function NPC:checkRightCollision()
    if self.dx > 0 then
        if self.map:collides(self.map:tileAt(self.x + self.width,self.y)) or
        self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            self.dx = 0
            self.x = math.floor(self.x - (self.x % self.map.tileWidth))
            self.dx = -WALKING_SPEED
            self.direction = 'left'
            --print("wall is hit , direction should be changed...dx = ", self.dx)
        end
    end
end

--[[ function NPC:defaultWalk()
    if self.x > self.oldx + 100 then
        self.direction = 'left'
        self.dx = -WALKING_SPEED
    elseif self.x < self.oldx - 100 then
        self.direction = 'right'
        self.dx = WALKING_SPEED
    end
end ]]

function NPC:update(dt)

    dt = love.timer.getDelta()
    self.behaviors[self.state](dt)
    self.view:update(self.state,self.direction)


    self:iterateTimer()
    
    self.x = self.x + self.dx * dt
    
end


function NPC:render()
    self.view:render(self.x, self.y)
end
    