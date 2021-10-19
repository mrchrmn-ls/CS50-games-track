Map = Class{}

-- assign sprite numbers to tile variables

-- base tiles
TILE_BRICK = 1
TILE_EMPTY = 4

-- cloud tiles
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9


-- set scroll speed
local SCROLL_SPEED = 62

function Map:init()
    -- set spritesheet file
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')

    -- width and height of tiles of the spritesheet in pixels
    self.tileWidth = 16
    self.tileHeight =16

    -- width and height of the map in tile units
    self.mapWidth = 50
    self.mapHeight = 28

    -- this list represents the map in terms of numbers
    self.tiles = {}

    self.groundlevels = {}

    -- slicing the spritesheet into individual sprites using helper function from Util.lua
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    -- get map dimensions in pixels to determine limits of camera movement
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.playerstartcolumn = 1

    -- populate entire map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- generate each column of the map, starting at 1 while varying the ground level
    local x = 1
    local currentgroundlevel = self.mapHeight / 2

    while x <= self.mapWidth do

        -- 5% chance for a cloud
        if math.random(20) == 1 and x < self.mapWidth then
            -- determine cloud position (Y)
            local cloudY = math.random(currentgroundlevel - 6)

            -- set cloud tiles
            self:setTile(x, cloudY, CLOUD_LEFT)
            self:setTile(x + 1, cloudY, CLOUD_RIGHT)
        end

        -- 5% chance for mushroom
        if (x == 10 or x == 11) and self.playerstartcolumn == 1 then

            -- set starting column for player to ten or eleven, ensuring there's no gap at this position
            self.playerstartcolumn = x
            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --advance column
            self.groundlevels[x] = currentgroundlevel
            x = x + 1

        elseif math.random(20) == 1 then
            -- set mushroom
            self:setTile(x, currentgroundlevel - 2, MUSHROOM_TOP)
            self:setTile(x, currentgroundlevel - 1, MUSHROOM_BOTTOM)

            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --advance column
            self.groundlevels[x] = currentgroundlevel - 2
            x = x + 1

        -- 10% chance for bush
        elseif math.random(10) == 1 and x < self.mapWidth then

            -- set left half and ground
            self:setTile(x, currentgroundlevel - 1, BUSH_LEFT)

            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- advance column and draw right half
            self.groundlevels[x] = currentgroundlevel
            x = x + 1
            self:setTile(x, currentgroundlevel - 1, BUSH_RIGHT)

            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            --advance column
            self.groundlevels[x] = currentgroundlevel
            x = x + 1

        -- 6% chance for hit block
        elseif math.random(16) == 1 then
            -- set block
            self:setTile(x, currentgroundlevel - 4, JUMP_BLOCK)
            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --advance column
            self.groundlevels[x] = currentgroundlevel
            x = x + 1

        -- leave gaps
        elseif math.random(20) == 1 then
            self.groundlevels[x] = self.mapHeight + 1
            x = x + 1

        elseif math.random(20) == 1 then
            self.groundlevels[x] = self.mapHeight + 1
            self.groundlevels[x + 1] = self.mapHeight + 1
            x = x + 2

        else
            -- set ground
            for y = currentgroundlevel, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            --advance column
            self.groundlevels[x] = currentgroundlevel
            x = x + 1

            currentgroundlevel = math.max(self.mapHeight / 4, math.min(currentgroundlevel + math.random(2) - math.random(2), 3 * self.mapHeight / 4))

        end
    end

    -- initialize camera position, taking into account that the player will likely be positioned in column 10
    self.camX = 0
    self.camY = math.max(0, (self.groundlevels[10] - (self.mapHeight / 2 )) * self.tileHeight)

end

-- return whether given tile is collidable
function Map:collides(tile)

    -- these tiles are collidables
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT, MUSHROOM_BOTTOM, MUSHROOM_TOP
    }

    -- iterate through collidables list and return true if tile from arguments is in it
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false

end


-- updates the map camera position
function Map:update(dt, player)
    self.camX = math.max(0, 
        math.min(player.x - VIRTUAL_WIDTH / 2, self.mapWidthPixels - VIRTUAL_WIDTH))
end

-- sets a tile in the tile map to a particular value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- asks for the tile at position tile coordinates x, y
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- ask for tile at pixel coordinates x, y
function Map:tileAt(x, y)
    return {
    tileX = math.floor(x / self.tileWidth) + 1,
    tileY = math.floor(y / self.tileHeight) + 1,
    id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- renders the map
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end