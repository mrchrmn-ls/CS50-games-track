Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400
local GRAVITY = 40

function Player:init(map)
    -- width and hight in pixels
    self.width = 16
    self.height = 20

    -- set initial x position in tile grid
    local startX = map.playerstartcolumn

    -- initial position in pixels
    self.x = map.tileWidth * (startX - 1)
    self.y = map.tileHeight * (map.groundlevels[startX] - 1) - self.height

    self.dx = 0
    self.dy = 0

    -- assign texture / sprite data
    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture, 
            frames = {
                self.frames[1]
            }, 
            interval = 1
        }, 
        ['walking'] = Animation {
            texture = self.texture, 
            frames = {
                self.frames[8], 
                self.frames[9], 
                self.frames[10], 
                self.frames[11]
            }, 
            interval = 0.15
        }, 
        ['jumping'] = Animation {
            texture = self.texture, 
            frames = {
                self.frames[3]
            }, 
            interval = 1
        }
    }

    self.animation = self.animations['idle']

    self.behaviours = {
        ['idle'] = function()
            self.animation = self.animations['idle']
            self.dy = 0
            self.dx = 0

            if joysticks then
                -- dpad and keyboard controls
                if joysticks[1]:isGamepadDown('a') or love.keyboard.wasPressed('space') then
                    self.dy = -JUMP_VELOCITY
                    self.state = 'jumping'
                elseif joysticks[1]:isGamepadDown('dpleft') or joysticks[1]:isGamepadDown('dpright') or love.keyboard.isDown('a') or love.keyboard.isDown('d') then
                    self.state = 'walking'
                end
            end

        end, 
        ['walking'] = function()
            self.animation = self.animations['walking']

            if joysticks then
                -- dpad and keyboard controls
                if joysticks[1]:isGamepadDown('a') or love.keyboard.wasPressed('space') then
                    self.dy = -JUMP_VELOCITY
                    self.state = 'jumping'
                elseif joysticks[1]:isGamepadDown('dpleft') or love.keyboard.isDown('a') then
                    self.dx = -MOVE_SPEED
                    self.direction = 'left'
                elseif joysticks[1]:isGamepadDown('dpright') or love.keyboard.isDown('d') then
                    self.dx = MOVE_SPEED
                    self.direction = 'right'
                else
                    self.state = 'idle'
                end
            end

            -- check for collision left and right
            --self:checkRightCollision()
            --self:checkLeftCollision()

            -- check if there is a collidable tile beneath player
            if  not map:collides(map:tileAt(self.x, self.y + self.height)) 
                and not map:collides(map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.state = 'jumping'
            end

        end, 
        ['jumping'] = function()
            love.keyboard.keysPressed = {}
            self.animation = self.animations['jumping']
            self.dy = self.dy + GRAVITY

            if  not map:collides(map:tileAt(self.x, self.y + self.height)) 
                and not map:collides(map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                self.y = (map:tileAt(self.x, self.y +self.height).y - 1) * map.tileHeight - self.height
                self.dy = 0
                self.state = 'idle'
            end

            if joysticks then
                -- dpad and keyboard controls
                if joysticks[1]:isGamepadDown('dpleft') or love.keyboard.isDown('a') then
                    self.dx = -MOVE_SPEED
                    self.direction = 'left'
                elseif joysticks[1]:isGamepadDown('dpright') or love.keyboard.isDown('d') then
                    self.dx = MOVE_SPEED
                    self.direction = 'right'
                end
            end
        end
    }
end


function Player:update(dt, map)
    self.behaviours[self.state]()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self.animation:update(dt)

    -- check for jump
    if self.dy < 0 then
        print("Jump!")

        --check for tiles above
        if map:tileAt(self.x, self.y) ~= TILE_EMPTY or
            map:tileAt(self.x + self.width - 1, self.y) ~= TILE_EMPTY then

            print("TILE")

            -- stop jump
            self.dy = 0

            -- change tiles
            if map:tileAt(self.x, self.y) == JUMP_BLOCK then
                map:setTile(math.floor(self.x / map.tileWidth) + 1, 
                math.floor(self.y / map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
            if map:tileAt(self.x + self.width - 1, self.y) == JUMP_BLOCK then
                map:setTile(math.floor((self.x + self.width - 1) / map.tileWidth) + 1, 
                math.floor(self.y / map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
        end

    end
end


function Player:render()

    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), 
        math.floor(self.x + self.width / 2), math.floor(self.y), 
        0, scaleX, 1, 
        self.width / 2, 0)
end