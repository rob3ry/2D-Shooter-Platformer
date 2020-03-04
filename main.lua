require 'conf'
require 'util'
require 'Map'
require 'Player'

g = love.graphics
map = Map:create()
--player = Player:create(map)

--loads everything that should be loaded when the program runs
function love.load()
    wWidth = 768
    wHeight = 640

    bg = g.newImage("assets/bg.png")
    sx = wWidth / bg:getWidth()
    sy = wHeight / bg:getHeight()

    start = g.newImage("assets/start_menu.jpg")
    ssx = wWidth / start:getWidth()
    ssy = wHeight / start:getHeight()

    win = g.newImage("assets/you_win.jpg")
    sx1 = wWidth / win:getWidth()
    sy1 = wHeight / win:getHeight()

    heart = g.newImage("assets/heart1.png")

    shotSound = love.audio.newSource("assets/pistol.wav","static")
    winSound = love.audio.newSource("assets/triumph.wav","static")

    groundColor = {25,200,25}

    gameState = 'title'

end

---->here all the input is processed and all changes are to be made<----
function love.update(dt)
    if gameState == 'title' then
        if love.keyboard.isDown('return') then
            gameState = 'play'
        end
    elseif gameState == 'play' then
        if love.keyboard.isDown('p') then
            gameState = 'pause'
        end
        map:update(dt)
    --player:update(dt)
    elseif gameState == 'pause' then
        if love.keyboard.isDown('return') then
            gameState = 'play'
        end
    end

    love.keyboard.updateKeys()

end


----- it renders everything on the scene-----
function love.draw()
    
    if gameState == 'title' then
        game_title()
    elseif gameState == 'pause' then
        game_pause()
    elseif gameState == 'win' then
        game_win()
    elseif gameState == 'over' then
        game_over()
    elseif gameState == 'play' then
        map:render()
    end
end


--function to handle every key-release event
function love.keyreleased(key)
    love.keyboard.keysPressed[key] = true
    if key == "escape" then
       love.event.quit()
    end

end

function love.resize(w,h)
    push:resize(w,h)
end

function game_title()
    g.setNewFont(40)
    local font = g.getFont()
    local text = 'Main Menu'
    local width = font:getWidth(text)
    g.print(text,wWidth/2 - width/2,50)

    g.setColor(255,255,255,255)
    g.draw(start,0,wHeight/5,0,math.min(ssx,ssy),math.min(ssx,ssy))
    g.setBackgroundColor(0/255,0/255,70/255,255)
    --g.setBackgroundColor(0/255,140/255,100/255,255)

    g.setNewFont(18)
    local font2 = g.getFont()
    local text2 = 'Press Enter to start...'
    local width2 = font2:getWidth(text2)
    g.print(text2,wWidth/2 - width2/2 ,wHeight - 100)
end

function game_pause()
    g.setNewFont(40)
    local font = g.getFont()
    local text = 'Pause'
    local width = font:getWidth(text)
    g.print(text,wWidth/2 - width/2,50)

    g.setColor(255,255,255,255)
    g.draw(start,0,wHeight/5,0,math.min(ssx,ssy),math.min(ssx,ssy))
    g.setBackgroundColor(0/255,0/255,70/255,255)
    --g.setBackgroundColor(0/255,140/255,100/255,255)

    g.setNewFont(18)
    local font2 = g.getFont()
    local text2 = 'Press Enter to resume'
    local width2 = font2:getWidth(text2)
    g.print(text2,wWidth/2 - width2/2 ,wHeight - 100)
end

function game_win()
    --winSound:play(1)

    g.setColor(255,255,255,255)
    g.draw(win,0,0,0,math.min(sx1,sy1),math.max(sx1,sy1))
    g.setColor(0,0,0)
    --g.setBackgroundColor(0/255,140/255,100/255,255) 

    g.setNewFont(20)
    local font2 = g.getFont()
    local text2 = 'Your result: '..map.player.score
    local width2 = font2:getWidth(text2)
    g.print(text2,wWidth/2 - width2/2 ,wHeight - 100)

    g.setNewFont(18)
    local font3 = g.getFont()
    local text3 = 'Press Esc to quit...'
    local width3 = font3:getWidth(text3)
    g.print(text3,wWidth/2 - width3/2 ,wHeight - 50)
end

function game_over()
    g.setBackgroundColor(0,0,0)
    g.setColor(255,255,255)

    g.setNewFont(70)
    local font = g.getFont()
    local text = 'Game Over'
    local width = font:getWidth(text)
    g.print(text,wWidth/2 - width/2,250)

    --[[ g.setColor(255,255,255,255)
    g.draw(start,0,wHeight/5,0,math.min(ssx,ssy),math.min(ssx,ssy)) ]]
    --g.setBackgroundColor(0/255,140/255,100/255,255)

    g.setNewFont(18)
    local font2 = g.getFont()
    local text2 = 'Press Esc to quit...'
    local width2 = font2:getWidth(text2)
    g.print(text2,wWidth/2 - width2/2 ,wHeight - 100)
end


--[[ function checkCollision(ax1,ay1,aw,ah,bx1,by1,bw,bh)
    local ax2,ay2,bx2,by2 = ax1 + aw,ay1 + ah, bx1 + bw, by1 + bh
    return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end ]]

