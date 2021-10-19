--set variables
WINDOWS_WIDTH = 1280
WINDOWS_HEIGHT= 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- require libraries
Class = require 'class'
push = require 'push'

-- require custom classes
require 'Util'
require 'Map'
require 'Player'
require 'Animation'

-- check for joystick (only one player)
joysticks = love.joystick.getJoysticks()

love.keyboard.keysPressed = {}

-- KEY PRESSED
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end


function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end


-- LOAD
function love.load()

    math.randomseed(os.time())

    map = Map()

    player = Player(map)

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOWS_WIDTH, WINDOWS_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end


-- UPDATE
function love.update(dt)
    map:update(dt, player)
    player:update(dt, map)
end


-- DRAW
function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))

    love.graphics.clear(108/255, 140/255, 255/255, 1)

    map:render()

    player:render()

    push:apply ('end')
end