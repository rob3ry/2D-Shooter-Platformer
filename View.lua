require 'Animation'

View = {}
View.__index = View

function View:create(player,texturePath)
    local this = {
        player = player,
        pHeight = 84,
        pWidth = 64,

        texture = g.newImage(texturePath),
        
        x = player.x,
        y = player.y,

        state = player.state,
        direction = player.direction,

        animation = nil,

        currentFrame = nil,
    }

    this.animations = {
        ['idle'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(8,18,64,this.pHeight,this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(222,126,64,this.pHeight,this.texture:getDimensions())
            }
        }),
        ['walking'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(82, 17, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(152, 17, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(229, 17, this.pWidth, this.pHeight, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(158,127,this.pWidth,this.pHeight + 3,this.texture:getDimensions()),
                g.newQuad(86,127,this.pWidth,this.pHeight + 3,this.texture:getDimensions()),
                g.newQuad(4,127,this.pWidth,this.pHeight + 3,this.texture:getDimensions())
            },
            interval = 5,
            isLooping = true
        }),
        ['jumping'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(313, 15, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(385, 15, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(460, 15, this.pWidth, this.pHeight, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(461, 121, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(383, 121, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(303, 125, this.pWidth, this.pHeight, this.texture:getDimensions())
            },
            interval = 25
        }),
        ['falling'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(460, 15, this.pWidth, this.pHeight, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(303, 125, this.pWidth, this.pHeight, this.texture:getDimensions())
            },
        }),
        ['shooting'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(537, 14, 72, this.pHeight, this.texture:getDimensions()),
                g.newQuad(621, 13, 72, this.pHeight, this.texture:getDimensions())
            },
            framesLeft = {
                g.newQuad(922, 111, 73, this.pHeight, this.texture:getDimensions()),
                g.newQuad(839, 112, 75, this.pHeight, this.texture:getDimensions())
            },
            interval = 10,
            isShooting = true,
            player = this.player
        }),
        ['reloading'] = Animation:create({
            texture = player.texture,
            framesRight = {
                g.newQuad(10, 229, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(90, 229, this.pWidth, this.pHeight, this.texture:getDimensions()),
            },
            framesLeft = {
                g.newQuad(10, 229, this.pWidth, this.pHeight, this.texture:getDimensions()),
                g.newQuad(90, 229, this.pWidth, this.pHeight, this.texture:getDimensions()),
            },
            interval = 20,
            isLooping = true
        })
    }

    this.animation = this.animations['idle']
    this.currentFrame = this.animation:getCurrentFrame()

    setmetatable(this,self)
    return this
end

function View:getFrames(state)
    return self.animations[state]:getFrames()
end

function View:setState(newState)
    self.player.state = newState
end

function View:handleInput(state)
    self.animations[state]:restart()
    self.animation = self.animations[state]
end

function View:update(state,direction)
    self.animation:update(dt,direction)
    self.currentFrame = self.animation:getCurrentFrame(direction)
end

function View:render(x,y)
    g.draw(self.texture,self.currentFrame,
    math.floor(x), math.floor(y))
end