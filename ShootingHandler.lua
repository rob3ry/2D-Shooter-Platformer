require 'Animation'

ShootingHandler = {}
ShootingHandler.__index = ShootingHandler

function ShootingHandler:create(player,texturePath)
    local this = {
        player = player,

        pHeight = 84,
        pWidth = 64,
        texture = g.newImage(texturePath),

        smokeWidth = 22,
        smokeHeight = 19,

        x = 0,
        y = 0,
        

        state = player.state,
        direction = player.direction,

        animation = nil,

        currentFrame = nil,

        --print("player HEIGHT: " , playerHeight)  
    }
    print('x of smoke: ' , this.x)
    print('y of smoke: ' , this.y)
    --[[
    this.y = this.y - 15
    if this.direction == 'right' then
        this.x = this.x + this.pWidth
    else
        this.x = this.x - this.smokeWidth
    end
    ]]

    -- smoke animation --
    this.animations = {
        ['shooting'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(186, 247, 22, 19, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(186, 286, 22, 19, this.texture:getDimensions())
            }
        })
    }

    this.animation = this.animations['shooting']
    this.currentFrame = this.animation:getCurrentFrame()

    setmetatable(this,self)
    return this
end

function ShootingHandler:handleInput(state,x,y,direction)
    self.animations[state]:restart()
    self.animation = self.animations[state]

    if direction == 'right' then
        self.x = x + self.pWidth + 10
    else
        self.x = x - self.smokeWidth
    end
    self.y = y + 25
end

function ShootingHandler:update(dt,direction)
    self.animation:update(dt,direction)
    self.currentFrame = self.animation:getCurrentFrame(direction)
    self.y = self.y - 80 * dt
    --[[ if direction == 'right' then
        self.x = x + self.pWidth + 10
    else 
        self.x = x - self.smokeWidth
    end ]]
    --self.y = y + 16
end

function ShootingHandler:render()
    --[[ y = y - 15
    if direction == 'right' then
        x = x + self.pWidth
    else
        x = x - self.smokeWidth
    end ]]
    --[[ print('x of smoke: ' , self.x)
    print('y of smoke: ' , self.y) ]]
    g.draw(self.texture,self.currentFrame,
    math.floor(self.x), math.floor(self.y))
end