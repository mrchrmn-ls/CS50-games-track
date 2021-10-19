Ball = Class{}


function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and -math.random(80, 100) or math.random(80, 100)
    self.dy = math.random(-100, 100)
end


-- Axis aligned bounding box collision check
function Ball:collides(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end

    if self.y > box.y + box.height or self.y+ self.height < box.y then
        return false
    end

    return true
end


function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    self.dx = BALL_SPEED * (math.random(2) == 1 and -100 or 100)
    self.dy = BALL_SPEED * math.random(-100, 100)
end



function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end


function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end