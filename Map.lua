require 'util'
require 'NPC'

Map = {}
Map.__index = Map

--[[ -- a speed to multiply delta time to scroll map; smooth value
local scrollSpeed = 124 ]]

-- constructor for our map object
function Map:create()
    local this = {

        -- texture containing tile sheet
        tileSheet = g.newImage('assets/tileSet.png'),
        tileWidth = 64,
        tileHeight = 64,
        mapWidth = 30,
        mapHeight = 25,
        tiles = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,6,6,6,6,6,6},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,6,6,6,6,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,6,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,5},
            {0,0,0,0,0,0,0,0,0,6,6,0,0,-2,0,0,0,0,0,0,6,0,0,6,6,6,6,6,6,6},
            -- camera start Y
            {0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,0,0,0,0,6,6,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,6,6,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,6,6,6,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,6,0,0,0,-1,0,6,0,0,0,0,0,0,0},
            {0,0,0,0,0,6,6,0,0,6,6,-1,0,0,0,0,6,0,6,6,6,6,6,6,6,6,6,6,0,0},
            {0,0,0,0,6,6,0,0,0,0,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,-2,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6},
            {6,6,6,6,5,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,6},
            {2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            {2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            --camera end Y
            {2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            {2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            {2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
        },
        -- applies positive y influence on anything affected
        --gravity = 15,
        gravity = 700,

        -- camera offsets
        camX = 0,
        camY = 13 * 64,

        cameraWidth = 768,
        cameraHeight = 640,

        zombieTex = g.newImage('assets/zombie.png'),

        -- tables for enemies and bonuses
        enemies = {},
        hearts = {}
        
    }

    this.spawn = false
    this.hSpawn = false
    -- associate player with map
    this.player = Player:create(this)

    -- generate a quad (individual frame/sprite) for each tile
    this.tileSet = generateQuads(this.tileSheet,64,64)

    -- this are the height and width of the tile map in pixels
    this.pixelMapHeight = this.mapHeight * this.tileWidth
    this.pixelMapWidth = this.mapWidth * this.tileWidth

    setmetatable(this,self)

    return this

end
function Map:update(dt)
    self.player:update(dt)

    for i,h in ipairs(self.hearts) do
        if self.player.lifes < 3 then
            if checkCollision(h.x,h.y,h.w,h.h,self.player.x,self.player.y,self.player.width,self.player.height) then
                self.player.lifes = self.player.lifes + 1
                table.remove(self.hearts,i)
            end
        end
    end

    for i,enemy in ipairs(self.enemies) do
        if enemy.lifes == 0 then
            table.remove(self.enemies,i)
            self.player.score = self.player.score + 10
        end
        enemy:update()
        --[[ print('enemy hit: ', enemy.hit)
        print('enemy lifes: ', enemy.lifes) ]]
    end

    --[[ self.camX = math.min(self.pixelMapWidth - (wWidth/2),math.max(0, 
    math.min(self.player.x - (wWidth/2 - self.player.width), math.min(self.pixelMapWidth,self.player.x)))) ]]
    self.camX = math.max(0, math.min(self.player.x - (wWidth/2 - self.player.width), 
    math.min(self.pixelMapWidth,self.player.x)))
    if self.camX > self.pixelMapWidth - (wWidth ) then
        self.camX = self.pixelMapWidth - (wWidth)
    end

    if self.player.y <= self.cameraHeight + (6*64) then 
        self.camY = self.player.y - (self.cameraHeight / 2) 
    --[[ elseif self.player.y >= 17 * 64 then
        self.camY = self.player.y - (7 * 64) ]]
    end
end

function Map:render()
    g.setColor(255,255,255,255)
    g.draw(bg,0,0,0,math.max(sx,sy))
    g.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

    for i = 1, self.mapHeight do
        for j = 1, self.mapWidth do
            --[[ local sx = 64 / quadWidth
            local sy = 64 / quadHeight ]]
            if self.tiles[i][j] > 0 then
                g.draw(self.tileSheet,self.tileSet[self.tiles[i][j]], 
                (j - 1) * self.tileWidth,(i - 1) * self.tileWidth)
            elseif self.spawn == false and self.tiles[i][j] == -1 then
                local npc = NPC:create(self,(j - 1) * self.tileWidth,(i - 1) * self.tileWidth - 20)
                table.insert(self.enemies,npc)
            elseif self.hSpawn == false and self.tiles[i][j] == -2 then
                local h = {}
                h.x = (j-1) * 64
                h.y = (i-1) * 64
                h.w,h.h = 32,32
                table.insert(self.hearts,h)
            end
        end
    end
    self.spawn = true
    self.hSpawn = true
    
    self.player:render()
    
    for _,enemy in ipairs(self.enemies) do
        enemy:render()
        if enemy.hit then enemy.hit = false end
    end
    for i,h in ipairs(self.hearts) do
        g.draw(heart,h.x,h.y,0,math.min(h.w/heart:getWidth(),h.h/heart:getHeight()),
        math.max(h.w/heart:getWidth(),h.h/heart:getHeight()))
    end

    g.setColor(0,0,0)
    g.setNewFont(15)
    g.print('Lifes: '.. self.player.lifes, self.camX + 5, self.camY + 5)
    g.print('Ammo: '.. self.player.ammo, self.camX + 5, self.camY + 25)
    g.print('Score: '.. self.player.score, self.camX + 5, self.camY + 45)
    
    
end

--[[function Map:tileAt(x, y)
    return self.tiles[math.floor(x / self.tileWidth) + 1][math.floor(y / self.tileHeight) + 1]
end]]

function Map:tileAt(x, y)
    return self.tiles[math.floor(y / self.tileHeight) + 1][math.floor(x / self.tileWidth) + 1]
end

function Map:tileY(y)
    return math.floor(y / self.tileHeight) + 1
end
function Map:tileX(x)
    return math.floor(x / self.tileWidth) + 1
end

function Map:getTile(x, y)
    return self.tiles[(y-1) * self.mapWidth + x]
end

function Map:setTile(x, y, tile)
    self.tiles[(y-1) * self.mapWidth + x] = tile
end

function Map:collides(tile)
    local collidables = { 1,2,3,5,6,7,9}

    for _, v in ipairs(collidables) do
        if tile == v then
            return true
        end
    end

    return false
end

function Map:collidesFinal(tile)
    local collidables = { 8 }

    for _, v in ipairs(collidables) do
        if tile == v then
            return true
        end
    end

    return false
end

--[[
function Map:tileAt(x, y)
    return self.getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
end

function Map:render()
    for y = 1,self.mapHeight do
        for x = 1,self.mapWidth do
            g.draw(self.spriteSheet,self.tileSprites[self:getTile(x,y)],
            (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end
]]