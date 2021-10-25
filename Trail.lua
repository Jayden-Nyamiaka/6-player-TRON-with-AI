-- trail class declaration using imported Class library
Trail = Class {}

-- constructs trail
function Trail:init(color, x, y, length, direction)
    self.alive = true
    self.color = color
    self.x = x
    self.y = y
    self.direction = direction

    if self.direction == "u" then
        self.height = 0
        self.width = length
        self.y = self.y + length
    elseif self.direction == "l" then
        self.height = length
        self.width = 0
        self.x = self.x + length
    elseif self.direction == "d" then
        self.height = 0
        self.width = length
    else
        self.height = length
        self.width = 0
    end
end

-- extends trail by given distance traveled
function Trail:extendDistance(dist)
    if self.alive then
        if self.direction == "u" then
            self.y = self.y - dist
            self.height = self.height + dist
        elseif self.direction == "d" then
            self.height = self.height + dist
        elseif self.direction == "l" then
            self.x = self.x - dist
            self.width = self.width + dist
        else
            self.width = self.width + dist
        end
    end
end

-- extends trail by x and y position of rider
function Trail:extendPoint(newX, newY, length)
    if self.alive then
        if self.direction == "u" then
            self.height = self.height + self.y - newY - length
            self.y = newY + length
        elseif self.direction == "d" then
            self.height = newY - self.y
        elseif self.direction == "l" then
            self.width = self.width + self.x - newX - length
            self.x = newX + length
        else
            self.width = newX - self.x
        end
    end
end

-- renders trail
function Trail:render()
    if self.alive and self.width > 0 and self.height > 0 then
        setColor(self.color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

-- deletes trail
function Trail:delete()
    self.alive = false
    self.color = "n"
    self.x = -200
    self.y = -200
    self.width = 0
    self.height = 0
    self.direction = "n"
end