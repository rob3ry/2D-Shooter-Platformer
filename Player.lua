--require 'Animation'
require 'View'
require 'ShootingHandler'

local WALKING_SPEED = 200
local JUMP_VELOCITY = 600

Player = {}
Player.__index = Player

function Player:create(map)
    local this = {
        x = 0,
        y = 0,
        
        width = 64,
        
        height = 84,

        -- reference to map for checking tiles
        map = map,
        texture = g.newImage("assets/dave.png"),
        
        -- view component is HERE
        view = View:create(self,"assets/dave.png"),

        -- another view component for smoke after shooting
        view2 = ShootingHandler:create(self, "assets/dave.png"),

        -- used to determine behavior and animations
        state = 'walking',
        prevState = 'idle',

        -- determines sprite flipping
        direction = 'right',

        -- amount of lifes the hero has
        lifes = 3,

        -- player score
        score = 0,

        -- ammo things
        maxAmmo = 8,
        ammo = 8,
        ammoFull = true,

        -- table with shots
        shots = {},

        -- x and y velocity
        dx = 0,
        dy = 0
    }

    this.x, this.y = 100, 1000 - this.height
    this.sTimer = 0

    this.behaviors = {
        ['idle'] = function(dt)
            --this.prevState = this.state
            if love.keyboard.wasPressed('space') then
                this.dy = -JUMP_VELOCITY
                this.prevState = this.state
                this.state = 'jumping'
                this.view:handleInput(this.state)
            elseif love.keyboard.isDown('left') then 
                this.direction = 'left'
                this.dx = -WALKING_SPEED
                this.prevState = this.state
                this.state = 'walking'
                this.view:handleInput(this.state)
            elseif love.keyboard.isDown('right')  then
                this.direction = 'right'
                this.dx = WALKING_SPEED
                this.prevState = this.state
                this.state = 'walking'
                this.view:handleInput(this.state)
            elseif love.keyboard.wasPressed('lctrl') then
                if this.ammo > 0 then
                    this.sTimer = 0
                    this:shoot()
                    this.ammoFull = false
                    this.prevState = this.state
                    this.state = 'shooting'
                    this.view:handleInput(this.state)
                    this.view2:handleInput(this.state,this.x,this.y,this.direction)
                end
            else
                this.dx = 0
            end
        
            if not this.ammoFull then
                if this.sTimer > 20 and this.ammo < this.maxAmmo then
                    this.ammoFull = true
                    this.ammo = this.ammo + 1
                    this.prevState = this.state
                    this.state = 'reloading'
                    this.view:handleInput(this.state)
                    this.sTimer = 0
                end
            elseif this.ammo < this.maxAmmo then
                --this.ammoFull = true
                this.ammo = this.ammo + 1
                this.prevState = this.state
                this.state = 'reloading'
                this.view:handleInput(this.state)
            end

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()
        end,

        ['walking'] = function (dt)
            if love.keyboard.wasPressed('space') then
                this.dy = -JUMP_VELOCITY
                this.prevState = this.state
                this.state = 'jumping'
                this.view:handleInput(this.state)
            elseif love.keyboard.isDown('left') then
                this.direction = 'left'
                this.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                this.direction = 'right'
                this.dx = WALKING_SPEED
            else
                this.dx = 0
                this.prevState = this.state
                this.state = 'idle'
                this.view:handleInput(this.state)
            end
       
            -- falling off of edge of tiles handling --
            if not this.map:collides(this.map:tileAt(this.x, this.y + this.height)) and
            not this.map:collides(this.map:tileAt(this.x + (this.width - 1), this.y + this.height)) then
                this.prevState = this.state
                this.state = 'falling'
                this.view:handleInput(this.state)
            end
            for _,enemy in ipairs(this.map.enemies) do
                if checkCollision(this.x,this.y,this.width,this.height,enemy.x,enemy.y,enemy.width,enemy.height) then
                    this.dx = 0
                end
            end

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()
        end,

        ['jumping'] = function(dt)
            if love.keyboard.isDown('left') then
                this.direction = 'left'
                this.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                this.direction = 'right'
                this.dx = WALKING_SPEED
            else
                this.dx = 0
            end

            -- apply map's gravity before y velocity
            this.dy = this.dy + (this.map.gravity * (dt*2))
            
            if this.map:collides(this.map:tileAt(this.x,this.y + this.height)) or
            this.map:collides(this.map:tileAt(this.x + this.width - 1, this.y + this.height)) then
                this.dy = 0
                this.prevState = this.state
                this.state = 'idle'
                this.view:handleInput(this.state)
                this.y = this.y - ((this.y + this.height) % this.map.tileHeight)
                --this.y = math.floor(this.y - (this.y % this.map.tileHeight))
            end

            for _,enemy in ipairs(this.map.enemies) do
                if checkCollision(this.x,this.y,this.width,this.height,enemy.x,enemy.y,enemy.width,enemy.height) then
                    this.dx = 0
                end
            end

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()
        end,

        ['falling'] = function(dt)
            if love.keyboard.isDown('left') then
                this.direction = 'left'
                this.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                this.direction = 'right'
                this.dx = WALKING_SPEED
            else
                this.dx = 0
            end

            -- apply map's gravity before y velocity
            this.dy = this.dy + (this.map.gravity * (dt*2))
            
            if this.map:collides(this.map:tileAt(this.x,this.y + this.height)) or
            this.map:collides(this.map:tileAt(this.x + this.width - 1, this.y + this.height)) then
                this.dy = 0
                this.prevState = this.state
                this.state = 'idle'
                this.view:handleInput(this.state)
                this.y = this.y - ((this.y + this.height) % this.map.tileHeight)
                --this.y = math.floor(this.y - (this.y % this.map.tileHeight))
            end

            for _,enemy in ipairs(this.map.enemies) do
                if checkCollision(this.x,this.y,this.width,this.height,enemy.x,enemy.y,enemy.width,enemy.height) then
                    this.dx = 0
                end
            end

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()
        end,

        ['shooting'] = function(dt)
            --print('x of player: ' , this.x)
            --print('y of player: ' , this.y)

            if this.sTimer > 20 then
                this.sTimer = 0
                this.prevState = this.state
                this.state = 'idle'
                this.view:handleInput(this.state)
            end

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()

        end,

        ['reloading'] = function(dt)
            if this.sTimer > 30 then
                this.sTimer = 0
                this.prevState = this.state
                this.state = 'idle'
                this.view:handleInput(this.state)
            end 
           --[[  if this.ammo == this.maxAmmo then
                this.state = 'idle'
                this.view:handleInput(this.state)
            end ]]

            -- check for collisions moving left or right
            this:inBoundaries()
            this:checkRightCollision()
            this:checkLeftCollision()

        end
    }

    setmetatable(this,self)
    return this
end

function Player:iterateTimer()
    self.sTimer = self.sTimer + 1
end

function Player:inBoundaries()
    if self.x <= 0 then
        self.x = 0
    elseif self.x + self.width >= self.map.pixelMapWidth then
        self.x = self.map.pixelMapWidth - self.width
    end
end

-- check if there's a tile our left
function Player:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collides(self.map:tileAt(self.x - 1,self.y)) or
        self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            -- if so, reset velocity and position and change state
            self.dx = 0
            local xmod = (self.x - 1) % self.map.tileWidth
            local offset = self.map.tileWidth - xmod
            self.x = math.floor(self.x - 1 + offset)
        end
    end
end

-- check if there's a tile our right
function Player:checkRightCollision()
    if self.dx > 0 then
        if self.map:collides(self.map:tileAt(self.x + self.width,self.y)) or
        self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            self.dx = 0
            self.x = math.floor(self.x - (self.x % self.map.tileWidth))
        elseif self.map:collidesFinal(self.map:tileAt(self.x + self.width,self.y)) or
        self.map:collidesFinal(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            gameState = 'win'
            winSound:play()
        end
    end
end


function Player:shoot()
    
    local shot = {}
    shot.w = 6
    shot.h = 2
    shot.y = self.y + 30
    if self.direction == "left" then
        shot.x = self.x
        shot.speed = -1000
    else
        shot.x = self.x + self.width - 10
        shot.speed = 1000
    end
    table.insert(self.shots, shot)
    self.ammo = self.ammo - 1
    shotSound:play()
    
end


function Player:drawShots()
    for _,v in ipairs(self.shots) do
        g.setColor(255,0,0,255)
        g.rectangle("fill",v.x,v.y,v.w,v.h)
        g.setColor(255,255,255,255)
    end
end

function Player:checkBulletCollision(dt)
    local spark = g.newQuad(360,244,37,32,self.texture:getDimensions())

    for i,v in ipairs(self.shots) do
        if self.map:collides(self.map:tileAt(v.x + v.w, v.y)) then
            if v.speed > 0 then
                g.draw(self.texture,spark,v.x - 20,v.y-10)
            else
                g.draw(self.texture,spark,v.x ,v.y-10)
            end
            table.remove(self.shots,i)
        end
        for _,enemy in ipairs(self.map.enemies) do
            if checkCollision(v.x,v.y,v.w,v.h,enemy.x,enemy.y,enemy.width,enemy.height) then
                --enemy:setHit(true)
                enemy.hit = true
                enemy.lifes = enemy.lifes - 1
                table.remove(self.shots,i)
                g.draw(self.texture,spark,v.x - 10,v.y-10)
            end
        end
    end
end

function Player:update(dt)
    
    if self.lifes <= 0 then gameState = 'over' end
    if self.map:tileY(self.y + self.height) > self.map.mapHeight - 1 then
        gameState = 'over'
    end 
    
    dt = love.timer.getDelta()
    self.behaviors[self.state](dt)
    
    self.view:update(self.state,self.direction)
    if self.state == 'shooting' then
        self.view2:update(dt,self.direction)
    end

    self:iterateTimer()

    for i,v in ipairs(self.shots) do
        v.x = v.x + v.speed * dt
    end

    --self:checkBulletCollision(dt)
    --[[ for _,v in ipairs(self.remShots) do
        table.remove(self.shots, v)
    end ]]
    
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.dy < 0 then
        if self.map:collides(self.map:tileAt(self.x,self.y)) or
        self.map:collides(self.map:tileAt(self.x + self.width - 1,self.y)) then
            self.dy = 0
        end
    end

end


function Player:render()
    
    self.view:render(self.x, self.y)
    if self.state == 'shooting' then
        self.view2:render(self.direction)
    end
    self:drawShots()
    self:checkBulletCollision()
   
    --print(self.x, self.y)
    --g.draw(self.texture,self.currentFrame, self.x,
    --self.y,0,scaleX,1,self.xOffset,self.yOffset)
end
    
