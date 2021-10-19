-- import lua library files
Class = require 'class'
push = require 'push'

-- import lua class files
require 'Paddle'
require 'Ball'

-- check for joystick (only one player)
joysticks = love.joystick.getJoysticks()

require 'aicontrols'
require 'keycontrols'

if joysticks then
    require 'joycontrols'
end

-- set constants for the game
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
BALL_SPEED = 1

MAX_POINTS = 2

AI1 = true
AI2 = false


-- LOAD
-- this all happens when the game loads
function love.load()
    -- set title
    love.window.setTitle("This is Pong!")


    -- initialize random
    math.randomseed(os.time())


    -- set up graphics
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    smallFont = love.graphics.newFont('04B_03__.TTF', 8)
    victoryFont = love.graphics.newFont('04B_03__.TTF', 24)
    scoreFont = love.graphics.newFont('04B_03__.TTF', 32)


    -- set up sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
        ['out'] = love.audio.newSource('out.wav', 'static')
    }


    -- initialize game objects
    player1 = Paddle(5, 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)


    -- initialize game variables
    player1score = 0
    player2score = 0
    winningPlayer = 0
    servingPlayer = 0
    gameState = 'start'
end


function love.resize(w, h)
    push:resize(w, h)
end


-- KEY PRESS
-- Check for key presses
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' or gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            player1score = 0
            player2score = 0
            gameState = 'start'
        end
    end
end

function love.joystickpressed(joystick, button)
    if joysticks[1]:isGamepadDown('a') then
        if gameState == 'start' or gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            player1score = 0
            player2score = 0
            gameState = 'start'
        end
    end
end


-- UPDATE
-- this all happens during each update
function love.update(dt)

    if AI1 then
        p1ai(dt)
    else
        p1joy(dt)
        p1key(dt)
    end

    if AI2 then
        p2ai(dt)
    else
        -- p2joy(dt)
        p2key(dt)
    end

    -- ball motion
    if gameState == 'play' then
        ball:update(dt)
    end

    -- paddle collision
    if ball:collides(player1) then
        sounds['paddle_hit']:play()

        ball.dx = -ball.dx * 1.05
        ball.x = player1.x + 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        if love.keyboard.isDown('w') or love.keyboard.isDown('s') or love.keyboard.isDown('up') or love.keyboard.isDown('down') then
            ball.dy = ball.dy * 1.5
        end
    end

    if ball:collides(player2) then
        sounds['paddle_hit']:play()

        ball.dx = -ball.dx * 1.05
        ball.x = player2.x - 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        if love.keyboard.isDown('w') or love.keyboard.isDown('s') or love.keyboard.isDown('up') or love.keyboard.isDown('down') then
            ball.dy = ball.dy * 1.5
        end
    end

    -- wall collision
    if ball.y <= 0 then
        sounds['wall_hit']:play()
        ball.dy = -ball.dy
        ball.y = 0
    end

    if ball.y >= VIRTUAL_HEIGHT - 5 then
        sounds['wall_hit']:play()
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT -5
    end

    -- out!
    if ball.x <= 0 then
        sounds['out']:play()
        player2score = player2score + 1
        servingPlayer = 1
        ball:reset()
        ball.dx = 100
        checkForVictory()
    end

    if ball.x >= VIRTUAL_WIDTH - 5 then
        sounds['out']:play()
        player1score = player1score + 1
        servingPlayer = 2
        ball:reset()
        ball.dx = -100
        checkForVictory()
    end

end



-- DRAW
-- this is continually drawn on screen depending on updated game variables
function love.draw()
    push:apply('start')

    -- clear screen
    love.graphics.clear(0.2, 0.22, 0.25, 1)

    -- draw ball
    ball:render()

    -- draw paddles
    player1:render()
    player2:render()

    -- draw on screen messages depending on gamestate

    if gameState == 'start' then

        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Pong!", 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press enter to play.", 0, 96, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then

        displayScore()

    elseif gameState == 'serve' then

        displayScore()

        love.graphics.setFont(smallFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. ", press enter to serve.", 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'victory' then

        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 32, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to play again.", 0, 80, VIRTUAL_WIDTH, 'center')

    end

    push:apply('end')
end



-- CUSTOM FUNCTIONS

function checkForVictory()
    if player1score >= MAX_POINTS or player2score >= MAX_POINTS then
        gameState = 'victory'
    else
        gameState = 'serve'
    end
    winningPlayer = player1score > player2score and 1 or 2
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 35, VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setColor(0, 0.8, 0, 0.5)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end