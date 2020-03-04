

Animation = {}
Animation.__index = Animation

function Animation:create(params)
    local this = {
        texture = params.texture,

        -- quads defining this animation
        framesLeft = params.framesLeft or {},
        framesRight = params.framesRight or {},
        
        -- time in seconds each frame takes (1/20 by default)
        interval = params.interval or 0.05,

        isLooping = params.isLooping or false,

        isShooting = params.isShooting or false,

        player = params.player or nil,

        -- stores amount of time that has elapsed
        timer = 0,

        currentFrame = 1,
        
        currentSprite = nil
    }

    setmetatable(this,self)
    return this
end 

function Animation:getCurrentFrame(direction)
    if direction == 'right' then
        return self.framesRight[self.currentFrame]
    else
        return self.framesLeft[self.currentFrame]
    end
end

function Animation:getFrames()
    return #self.framesRight
end

function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt,direction)
  
    self.timer = self.timer + 1
    
    if direction == 'right' then 
        self.currentSprite = self.framesRight
    else 
        self.currentSprite = self.framesLeft 
    end

    if self.timer > self.interval then
        --self.timer = self.timer - self.interval
        self.timer = 0
        self.currentFrame = self.currentFrame + 1 
        if self.isLooping then
            if self.currentFrame > #self.currentSprite then self.currentFrame = 1 end
        else
            if self.currentFrame > #self.currentSprite then
                self.currentFrame = #self.currentSprite
            end
        end
    end
    -- iteratively subtract interval from timer to proceed in
    -- the animation, in case we skipped more than one frame

end