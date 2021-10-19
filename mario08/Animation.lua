-- animation player to return the correct frame for drawing at any given time

Animation = Class{}

function Animation:init(params)
    self.texture = params.texture
    self.frames = params.frames

    -- time between animation frames in seconds
    self.interval = params.interval or 0.05

    -- timer in seconds to determine if interval has passed
    self.timer = 0

    -- current frame of the animation
    self.currentFrame = 1
end

-- retrieve frame from list of sprites for drawing purposes
function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

-- reset animation
function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    -- check number of frames in the animation
    if #self.frames == 1 then
        return self.currentFrame
    else
        while self.timer > self.interval do
            self.timer = self.timer - self.interval
            self.currentFrame = (self.currentFrame + 1) % (#self.frames + 1) -- +1 to display all frames in the sequence

            if self.currentFrame == 0 then 
                self.currentFrame = 1
            end
        end
    end
end