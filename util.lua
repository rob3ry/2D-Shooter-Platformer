love.keyboard.keysPressed = { }
love.keyboard.keysReleased = { }

-- returns if specified key was pressed since the last update
function love.keyboard.wasPressed(key)
	if (love.keyboard.keysPressed[key]) then
		return true
	else
		return false
	end
end
-- returns if specified key was released since last update
function love.keyboard.wasReleased(key)
	if (love.keyboard.keysReleased[key]) then
		return true
	else
		return false
	end
end
-- concatenate this to existing love.keypressed callback, if any
function love.keypressed(key, unicode)
	love.keyboard.keysPressed[key] = true
end
-- concatenate this to existing love.keyreleased callback, if any
function love.keyreleased(key)
	love.keyboard.keysReleased[key] = true
end
-- call in end of each love.update to reset lists of pressed\released keys
function love.keyboard.updateKeys()
	love.keyboard.keysPressed = { }
	love.keyboard.keysReleased = { }
end

function generateQuads(atlas,tileWidth,tileHeight)
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    local quads = {}
    local sheetCounter = 1

    for y = 0, sheetHeight-1 do
        for x = 0, sheetWidth-1 do
            quads[sheetCounter] = g.newQuad(x * tileWidth,y * tileHeight,
             tileWidth, tileHeight, atlas:getWidth(), atlas:getHeight())
            sheetCounter = sheetCounter + 1
        end
    end

    return quads
end

function checkCollision(ax1,ay1,aw,ah,bx1,by1,bw,bh)
    local ax2,ay2,bx2,by2 = ax1 + aw,ay1 + ah, bx1 + bw, by1 + bh
    return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end