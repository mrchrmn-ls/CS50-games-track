--player 1 joystick controls
function p1joy(dt)
    player1.dy = joysticks[1]:getGamepadAxis('lefty') * PADDLE_SPEED
    player1:update(dt)
end

--[[ player 2 joystick controls
function p2joy(dt)
    player2.dy = joysticks[2]:getGamepadAxis('leftx') * PADDLE_SPEED
    player2:update(dt)
end]]