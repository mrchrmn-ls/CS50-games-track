-- player 1 AI controls
function p1ai(dt)
    if gameState == 'play' and ball.x < VIRTUAL_WIDTH / 2 and ball.dx < 0 then
        player1:update(dt)
        if player1.y + 5 > ball.y then
            player1.dy = -PADDLE_SPEED
        elseif player1.y + 10 < ball.y then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    end
end

-- player 2 AI controls
function p2ai(dt)
    if gameState == 'play' and ball.x > VIRTUAL_WIDTH / 2 and ball.dx > 0 then
        player2:update(dt)
        if player2.y + 5 > ball.y then
            player2.dy = -PADDLE_SPEED
        elseif player2.y + 10 < ball.y then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    end
end