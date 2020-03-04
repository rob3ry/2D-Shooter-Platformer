require 'Animation'

EnemyView = {}
EnemyView.__index = EnemyView

function EnemyView:create(enemy,texturePath)
    local this = {
        enemy = enemy,

        pHeight = 84,
        pWidth = 64,
        quadWidth = 30,
        quadHeight = 47,
        texture = g.newImage(texturePath),

        x = enemy.x,
        y = enemy.y,

        state = enemy.state,
        direction = enemy.direction,

        animation = nil,

        currentFrame = nil,
    }
    --[[ print('x of enemy: ' , this.x)
    print('y of enemy: ' , this.y) ]]
    this.animations = {
        ['idle'] = Animation:create({
            texture = enemy.texture,
            framesRight = {
                g.newQuad(20,719,this.quadWidth,this.quadHeight,this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(20,591,this.quadWidth,this.quadHeight,this.texture:getDimensions())
            }
        }),
        ['walking'] = Animation:create({
            texture = enemy.texture,
            framesRight = {
                g.newQuad( 82, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(147, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(210, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(273, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(335, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(401, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(466, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(531, 719, this.quadWidth, this.quadHeight, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad( 82, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(148, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(214, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(277, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(339, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(405, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(470, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(534, 591, this.quadWidth, this.quadHeight, this.texture:getDimensions()),
            },
            interval = 5,
            isLooping = true
        }),
        ['attacking'] = Animation:create({
            texture = enemy.texture,
            framesRight = {
                --g.newQuad( 84, 1998, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(276, 1998, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(467, 1998, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(658, 1998, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(851, 1998, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(1043, 1998, 58, this.quadHeight, this.texture:getDimensions())
                
            },
            framesLeft = {
                --g.newQuad( 72, 1614, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(272, 1614, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(467, 1614, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(649, 1614, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(822, 1614, 58, this.quadHeight, this.texture:getDimensions()),
                g.newQuad(1011, 1614, 58, this.quadHeight, this.texture:getDimensions())
                
            },
            interval = 5,
        })
    }

    this.animation = this.animations['walking']
    this.currentFrame = this.animation:getCurrentFrame()

    setmetatable(this,self)
    return this
end

function EnemyView:getFrames(state)
    return self.animations[state]:getFrames()
end

function EnemyView:setState(newState)
    self.player.state = newState
end


function EnemyView:handleInput(state)
    self.animations[state]:restart()
    self.animation = self.animations[state]
end

--[[ function View:handleShooting(dt,direction)
    self.animations['shooting']:restart()
    self.animation = self.animations['shooting']
    for i=1,3 do
        self.animation:update(dt,direction)
        self.currentFrame = self.animation:getCurrentFrame()
    end
end  ]]

function EnemyView:update(state,direction)
    self.animation:update(dt,direction)
    self.currentFrame = self.animation:getCurrentFrame(direction)

    --[[if state == 'idle' then
        self.animation = self.animations['idle']
    else
        self.animations[state]:restart()
        self.animation = self.animations[state]
    end]]
end

function EnemyView:render(x,y)
    g.setColor(255,255,255,255)
    --if self.enemy.isHit() then
    if self.enemy.hit == true then
        g.setColor(255,0,0)
    end
    g.draw(self.texture,self.currentFrame,
    math.floor(x), math.floor(y), 0, 
    math.min(self.pWidth / self.quadWidth,self.pHeight / self.quadHeight),
    math.min(self.pWidth / self.quadWidth,self.pHeight / self.quadHeight))
end