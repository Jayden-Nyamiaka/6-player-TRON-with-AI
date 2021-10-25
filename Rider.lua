-- rider class declaration using imported Class library
Rider = Class {}

-- constructs rider
function Rider:init(num, numOfPlayers, player, color, length, speed, xPos, yPos, direction)
    self.num = num
    self.player = player
    self.color = color
    self.length = length
    self.speed = speed
    self.startX = xPos
    self.startY = yPos
    self.startDirection = direction
    self.alive = true
    self.trails = {}
    
    if self.player then
        if self.num == 1 then
            self.up = "w"
            self.left = "a"
            self.down = "s"
            self.right = "d"
            self.controls = "W A S D"
            if numOfPlayers == 1 then
                self.secondary = true
                self.upSecondary = "up"
                self.leftSecondary = "left"
                self.downSecondary = "down"
                self.rightSecondary = "right"
                self.controlsSecondary = "Arrow Keys"
            end
        elseif self.num == numOfPlayers then
            self.up = "up"
            self.left = "left"
            self.down = "down"
            self.right = "right"
            self.controls = "Arrow Keys"
        elseif self.num + 1 == numOfPlayers then
            self.up = "i"
            self.left = "j"
            self.down = "k"
            self.right = "l"
            self.controls = "I J K L"
        else
            self.up = "g"
            self.left = "v"
            self.down = "b"
            self.right = "n"
            self.controls = "G V B N"
        end
    else
        self.controls = "AI"
        self.predictDistance = 0
        self.turnTimer = 0
        self.turnCount = 0
        self.sideDistance = VIRTUAL_WIDTH
    end

    self.x = self.startX
    self.y = self.startY
    self.direction = self.startDirection
    self.trailCount = 1
    self.trails[1] = Trail(self.color, self.x, self.y, self.length, self.direction)

    audioCollisions = {
        ['trail'] = love.audio.newSource("Audio/Tron_TrailCollision.wav", "static"),
        ['rider'] = love.audio.newSource("Audio/Tron_RiderCollision.wav", "static"),
        ['wall'] = love.audio.newSource("Audio/Tron_WallCollision.wav", "static"),
        ['self'] = love.audio.newSource("Audio/Tron_SelfCollision.wav", "static")
    }
end


-- resets rider and deletes all trails
function Rider:reset()
    for i = 1, self.trailCount do
        self.trails[i]:delete()
    end
    self.x = self.startX
    self.y = self.startY
    self.direction = self.startDirection
    self.trails = {}
    self.trailCount = 1
    self.trails[1] = Trail(self.color, self.x, self.y, self.length, self.direction)
    self.alive = true
    if not(self.player) then
        self.turnTimer = 0
        self.turnCount = 0
        self.predictDistance = 0
    end
end


-- COLLISION METHODS
-- checks for collisions between riders
function Rider:collideRider(rider)
    if self.x >= rider.x + rider.length or self.x + self.length <= rider.x or self.y >= rider.y + rider.length or self.y + self.length <= rider.y then
        return false
    end
    self.trails[self.trailCount]:extendDistance(self.length)
    rider.trails[rider.trailCount]:extendDistance(rider.length)
    self.alive = false
    rider.alive = false
    audioCollisions["rider"]:play()
    return true
end

-- checks for collisions (trail specific)
function Rider:collide(trail)
    if (not trail.alive) or self.x >= trail.x + trail.width or self.x + self.length <= trail.x or self.y >= trail.y + trail.height or self.y + self.length <= trail.y then
        return false
    end
    self.trails[self.trailCount]:extendDistance(self.length)
    self.alive = false
    audioCollisions["trail"]:play()
    return true
end

-- checks for collisions (all trails + riders)
function Rider:collision(playerCount)
    for rider = 1, #riders do
        for i = 1, riders[rider].trailCount do
            if self:collide(riders[rider].trails[i]) then
                return true
            end
        end
    end
    return false
end


-- AI MOVEMENT METHODS
-- sets new predictDistance
function Rider:newPredictDistance()
    if UNBEATABLE then 
        self.predictDistance = round(self.length *  1.25) -- 1.25
    else
        local distanceGenerator = math.random(5)
        if distanceGenerator == 1 then
            -- chance for long predictDistance 1/5 times (2 - 5 lengths)
            self.predictDistance = round(self.length * math.random(4, 10)/2)
        elseif  distanceGenerator == 2 then
            -- chance for very short predictDistance 1/5 times (0.5 lengths)
            self.predictDistance = round(self.length * 0.5)
        else
            -- chance for short predictDistance 7/10 times (0.5 - 3 lengths)
            self.predictDistance = round(self.length * math.random(2, 12) / 4)
        end
    end
end

-- changes to a random direction and updates trails to reflect that switch
function Rider:randomDirection()
    switchDir = math.random(2)
    if self.direction == "u"  or self.direction == "d" then
        if switchDir == 1 then
            return "l"
        end
        return "r"
    else
        if switchDir == 1 then 
            return "u"
        end
        return "d"
    end
end

-- used by AI to check if a boxed outline is overlapping with an object (rider or trail)
function Rider:overlapBox(isRider, object, boxX, boxY, boxWidth, boxHeight)
    if isRider then
        if (boxX >= object.x + object.length) or (boxX + boxWidth <= object.x) or 
        (boxY >= object.y + object.length) or (boxY + boxHeight <= object.y) then
            return false
        end
    else
        if (not object.alive) or (boxX >= object.x + object.width) or (boxX + boxWidth <= object.x) or 
        (boxY >= object.y + object.height) or (boxY + boxHeight <= object.y) then
            return false
        end
    end
    return true
end

-- used by AI to check overlapping X pos
function Rider:overlapX(isRider, object)
    if isRider then
        if self.x >= object.x + object.length or self.x + self.length <= object.x then
            return false
        end
    else
        if (not object.alive) or self.x >= object.x + object.width or self.x + self.length <= object.x then
            return false
        end
    end
    return true
end

-- used by AI to check overlapping Y pos
function Rider:overlapY(isRider, object)
    if isRider then
        if self.y >= object.y + object.length or self.y + self.length <= object.y then
            return false
        end
    else
        if (not object.alive) or self.y >= object.y + object.height or self.y + self.length <= object.y then
            return false
        end
    end
    return true
end

-- checks if trail is in the path between rider and predictPosition
function Rider:predictCollide(isRider, object, predictPosition)
    if self.direction == "u" then -- up
        -- addresses object correctly based on if it's a rider or trail
        if isRider then
            bottomObj = object.y + object.length
        else
            bottomObj = object.y + object.height
        end
        -- check if bottom of object is in path [predictPosition to top of rider] + if x pos align
        if (bottomObj > predictPosition) and (bottomObj < self.y) and self:overlapX(isRider, object) then
            return true
        end
    elseif self.direction == "d" then -- down
        -- check if top of object is in path [predictPosition to bottom of rider] + if x pos align
        if (object.y > self.y + self.length) and (object.y < predictPosition) and self:overlapX(isRider, object) then
            return true
        end
    elseif self.direction == "l" then -- left
        -- addresses object correctly based on if it's a rider or trail
        if isRider then
            rightObj = object.x + object.length
        else
            rightObj = object.x + object.width
        end
        -- check if right of object is in path [predictPosition to left of rider] + if y pos align
        if (rightObj > predictPosition) and (rightObj < self.x) and self:overlapY(isRider, object) then
            return true
        end
    else -- right
        -- check if left of object is in path [predictPosition to right of rider] + if y pos align
        if (object.x > self.x + self.length) and (object.x < predictPosition) and self:overlapY(isRider, object) then
            return true
        end
    end
    return false
end

-- checks if a rider is blocked in given direction and if blocked, returns distance from the block
function Rider:blocked(direction, checkDistance)
    -- outlines a box to the side of the rider based on given direction
    local checkX = 0
    local checkY = 0
    local checkWidth = 0
    local checkHeight = 0
    if direction == "u" then
        checkX = self.x
        checkY = self.y - checkDistance
        checkWidth = self.length
        checkHeight = checkDistance
    elseif direction == "d" then
        checkX = self.x
        checkY = self.y + self.length
        checkWidth = self.length
        checkHeight = checkDistance
    elseif direction == "l" then
        checkX = self.x - checkDistance
        checkY = self.y
        checkWidth = checkDistance
        checkHeight = self.length
    else
        checkX = self.x + self.length
        checkY = self.y
        checkWidth = checkDistance
        checkHeight = self.length
    end

    -- checks against every rider and every single trail (trails first bc walls are farthest)
    for rider = 1, #riders do
        if self:overlapBox(true, riders[rider], checkX, checkY, checkWidth, checkHeight) then
            if direction == "u" then
                return self.y - (riders[rider].y + riders[rider].length)
            elseif direction == "d" then
                return riders[rider].y - (self.y + self.length)
            elseif direction == "l" then
                return self.x - (riders[rider].x + riders[rider].length)
            else
                return riders[rider].x - (self.x + self.length)
            end
        end
        for i = 1, riders[rider].trailCount do
            if self:overlapBox(false, riders[rider].trails[i], checkX, checkY, checkWidth, checkHeight) then
                if direction == "u" then
                    return self.y - (riders[rider].trails[i].y + riders[rider].trails[i].height)
                elseif direction == "d" then
                    return riders[rider].trails[i].y - (self.y + self.length)
                elseif direction == "l" then
                    return self.x - (riders[rider].trails[i].x + riders[rider].trails[i].width)
                else
                    return riders[rider].trails[i].x - (self.x + self.length)
                end
            end
        end
    end
    -- if all else proves false, returns distance between self and wall in that direction
    if direction == "u" then
        return self.y - 2
    elseif direction == "d" then
        return math.floor(VIRTUAL_HEIGHT - 2) - (self.y + self.length)
    elseif direction == "l" then
        return self.x - 2
    else
        return math.floor(VIRTUAL_WIDTH - 2) - (self.x + self.length)
    end
end

-- decides if AI rider should turn
function Rider:turn(playerCount, checkDistance) 
    -- turn set to false by default
    local turn = false
    -- initializes predictX and predictY vars
    local predictX = 0
    local predictY = 0

    -- checks by differing cases of direction
    if self.direction == "u" then -- up
         -- sets predictY to where the upper end of the rider will be
        predictY = self.y - checkDistance
        -- checks if the upper end of the rider will be past the top of the screen
        if predictY < 2 then 
            -- if true, turn is set to true and proceeds to decide if it should turn right or left
            turn = true
        -- if false, checks against every rider and every single trail
        else
            for rider = 1, #riders do
                if self:predictCollide(true, riders[rider], predictY) then
                    turn = true
                    break
                end
                for i = 1, riders[rider].trailCount do
                    if self:predictCollide(false, riders[rider].trails[i], predictY) then
                        turn = true
                        break
                    end
                end
                if turn then
                    break
                end
            end
        end

    elseif self.direction == "d" then -- down
        -- sets predictY to where the bottom end of the rider will be 
        predictY = self.y + self.length + checkDistance
        -- checks if the bottom end of the rider will be past the bottom of the screen
        if predictY > (VIRTUAL_HEIGHT - 2) then 
            -- if true, turn is set to true and proceeds to decide if it should turn right or left
            turn = true
        -- if false, checks against every rider and every single trail
        else
            for rider = 1, #riders do
                if self:predictCollide(true, riders[rider], predictY) then
                    turn = true
                    break
                end
                for i = 1, riders[rider].trailCount do
                    if self:predictCollide(false, riders[rider].trails[i], predictY) then
                        turn = true
                        break
                    end
                end
                if turn then
                    break
                end
            end
        end

    elseif self.direction == "l" then -- left
        -- sets predictX to where the left end of the rider will be
        predictX = self.x - checkDistance
        -- checks if the left end of the rider will be past the left of the screen
        if predictX < 2 then 
            -- if true, turn is set to true and proceeds to decide if it should turn up or down
            turn = true
        -- if false, checks against every rider and every single trail
        else
            for rider = 1, #riders do
                if self:predictCollide(true, riders[rider], predictX) then
                    turn = true
                    break
                end
                for i = 1, riders[rider].trailCount do
                    if self:predictCollide(false, riders[rider].trails[i], predictX) then
                        turn = true
                        break
                    end
                end
                if turn then
                    break
                end
            end
        end

    else -- right
        -- sets predictX to where the right end of the rider will be 
        predictX = self.x + self.length + checkDistance
        -- checks if the right end of the rider will be past the right of the screen
        if predictX > (VIRTUAL_WIDTH - 2) then 
            -- if true, turn is set to true and proceeds to decide if it should turn up or down
            turn = true
        -- if false, checks against every rider and every single trail
        else
            for rider = 1, #riders do
                if self:predictCollide(true, riders[rider], predictX) then
                    turn = true
                    break
                end
                for i = 1, riders[rider].trailCount do
                    if self:predictCollide(false, riders[rider].trails[i], predictX) then
                        turn = true
                        break
                    end
                end
                if turn then
                    break
                end
            end
        end
    end

    -- if turn needs to happen
    if turn then
        -- sets blocked variables in the case of vertical movement
        if self.direction == "u" or self.direction == "d" then
            leftUpBlock = self:blocked("l", self.sideDistance)
            rightDownBlock = self:blocked("r", self.sideDistance)
        -- sets blocked variables in the case of horizontal movement
        else
            leftUpBlock = self:blocked("u", self.sideDistance)
            rightDownBlock = self:blocked("d", self.sideDistance)
        end
       
        -- if blocked certainly in both directions, stays on course except makes a random turn ~ every 50 frames
        if leftUpBlock < self.length and rightDownBlock < self.length then
            if math.random(25) == 1 then
                return self:randomDirection()
            end
            return self.direction
         -- if not blocked at all or blocked but not certainly wth same degree of block on both sides,
         -- chooses random direction
        elseif math.floor(leftUpBlock) == math.floor(rightDownBlock) then
            return self:randomDirection()
        -- if blocked in more in left or up direction (distance to block is less), turn right or down
        elseif leftUpBlock < rightDownBlock then
            -- if moving vertically and blocked left, chooses right
            if self.direction == "u" or self.direction == "d" then
                return "r"
            -- if moving horizontally and blocked up, chooses down
            else
                return "d"
            end
        -- if blocked in more in other right or down direction (distance to block is less), turn left or up
        else
            -- if moving vertically and blocked right, chooses left
            if self.direction == "u" or self.direction == "d" then
                return "l"
            -- if moving horizontally and blocked down, chooses up
            else
                return "u"
            end
        end
    end
    -- returns same direction if turn does not need to occur
    return self.direction
end


-- updates rider
function Rider:update(dt)
    if self.alive then
        -- updates turnTimer and turnCount for AI
        if not(self.player) then
            self.turnTimer = self.turnTimer + dt
            if self.turnTimer > TURN_TIME_ALLOWANCE then
                self.turnCount = 0
            end
        end

        -- wall collisions
        if self.x < 2 or self.x + self.length > (VIRTUAL_WIDTH - 2) or self.y < 2 or self.y + self.length > (VIRTUAL_HEIGHT - 2) then
            self.trails[self.trailCount]:extendDistance(self.length)
            self.alive = false
            audioCollisions["wall"]:play()
            return
        end

        -- rider collisions between riders
        for i = 1, #riders do
            if i ~= self.num then
                if self:collideRider(riders[i]) then
                    return
                end
            end
        end

        -- rider collisions with trails
        if self:collision(#riders) then
            return
        end

        if self.direction == "u" then
            self.y = self.y - self.speed * dt
        elseif self.direction == "d" then 
            self.y = self.y + self.speed * dt
        end

        if self.direction == "l" then
            self.x = self.x - self.speed * dt
        elseif self.direction == "r" then 
            self.x = self.x + self.speed * dt
        end

        -- rider movement for players
        if self.player then
            if (love.keyboard.isDown(self.up) or (self.secondary and love.keyboard.isDown(self.upSecondary))) and (love.keyboard.isDown(self.down)  or (self.secondary and love.keyboard.isDown(self.downSecondary))) then
                audioCollisions['self']:play()
                self.trails[self.trailCount]:extendDistance(self.length)
                self.alive = false
            elseif (love.keyboard.isDown(self.left) or (self.secondary and love.keyboard.isDown(self.leftSecondary))) and (love.keyboard.isDown(self.right) or (self.secondary and love.keyboard.isDown(self.rightSecondary))) then
                audioCollisions['self']:play()
                self.trails[self.trailCount]:extendDistance(self.length)
                self.alive = false
            elseif (love.keyboard.isDown(self.up) or (self.secondary and love.keyboard.isDown(self.upSecondary))) then
                if self.direction == "d" then
                    audioCollisions['self']:play()
                    self.trails[self.trailCount]:extendDistance(self.length)
                    self.alive = false
                elseif self.direction == "u" then
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                else
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                    self.direction = "u"
                    self.trailCount = self.trailCount + 1
                    self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                end
            elseif (love.keyboard.isDown(self.left) or (self.secondary and love.keyboard.isDown(self.leftSecondary))) then
                if self.direction == "r" then
                    audioCollisions['self']:play()
                    self.trails[self.trailCount]:extendDistance(self.length)
                    self.alive = false
                elseif self.direction == "l" then
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                else
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                    self.direction = "l"
                    self.trailCount = self.trailCount + 1
                    self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                end
            elseif (love.keyboard.isDown(self.down) or (self.secondary and love.keyboard.isDown(self.downSecondary))) then
                if self.direction == "u" then
                    audioCollisions['self']:play()
                    self.trails[self.trailCount]:extendDistance(self.length)
                    self.alive = false
                elseif self.direction == "d" then
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                else
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                    self.direction = "d"
                    self.trailCount = self.trailCount + 1
                    self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                end
            elseif (love.keyboard.isDown(self.right) or (self.secondary and love.keyboard.isDown(self.rightSecondary))) then
                if self.direction == "l" then
                    audioCollisions['self']:play()
                    self.trails[self.trailCount]:extendDistance(self.length)
                    self.alive = false
                elseif self.direction == "r" then
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                else
                    self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
                    self.direction = "r"
                    self.trailCount = self.trailCount + 1
                    self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                end
            else
                self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
            end

        -- rider movement for AI
        else
            -- only occurs once to get first predictDistance
            if self.predictDistance == 0 then
                self:newPredictDistance()
            end
            -- starts by extending current trail
            self.trails[self.trailCount]:extendPoint(self.x, self.y, self.length)
            -- only allows turn functionality if less than 2 turns made within acceptance of turnTimer
            if self.turnCount < 2 then
                -- gets predicted direction from AI turn functiion
                newDir = self:turn(#riders, self.predictDistance)
                -- turns if current direction is different from predicted direction
                if newDir ~= self.direction then
                    -- sets current direction to predicted direction
                    self.direction = newDir
                    -- sets up new trail at turn
                    self.trailCount = self.trailCount + 1
                    self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                    -- sets up new predictDistance at each turn
                    self:newPredictDistance()
                    -- increments turnCount
                    self.turnCount = self.turnCount + 1
                -- if function says no turn, random turn ~ once every couple frames (scaled by speed and dt)
                else
                    -- less random turns when UNBEATABLE
                    if UNBEATABLE then
                        randomTurnControl = math.random(6000000 * 1/self.speed * dt)
                    else
                        randomTurnControl = math.random(200000 * 1/self.speed * dt)
                    end
                    if randomTurnControl == 1 then
                        maybeDir = self:randomDirection()
                        -- turns if it will not die from turning in the random direction
                        if self:blocked(maybeDir, self.sideDistance) > self.length * 3 then
                            self.direction = maybeDir
                            -- sets up new trail at turn
                            self.trailCount = self.trailCount + 1
                            self.trails[self.trailCount] = Trail(self.color, self.x, self.y, self.length, self.direction)
                            -- sets up new predictDistance at each turn
                            self:newPredictDistance()
                            -- increments turnCount
                            self.turnCount = self.turnCount + 1
                        end
                    end 
                end
            end
        end
    end
    -- FOR DEBUG
    if self.color == "t" then
        TEST1 = 100000 * 1/self.speed * dt
    end
end


-- renders rider
function Rider:render(state)
    if state == "play" then
        if self.alive then
            setColor(self.color)
            love.graphics.rectangle("fill", self.x, self.y, self.length, self.length)
        end
        for i = 1, self.trailCount do
            self.trails[i]:render()
        end
        if DEBUG and not(self.player) then
            setColor("w")
            -- if rider is going up or down
            if self.direction == "d" or self.direction == "u" then
                -- draws left side prediction outline
                love.graphics.rectangle("line", self.x - self.sideDistance, self.y, self.sideDistance, self.length)
                -- draws up side prediction outline
                love.graphics.rectangle("line", self.x + self.length, self.y, self.sideDistance, self.length)
                -- draws forwards prediction outline for the upwards direction
                if self.direction == "u" then
                    love.graphics.rectangle("line", self.x, self.y - (self.length - 1) - self.predictDistance, self.length, self.length + self.predictDistance)
                -- draws forwards prediction outline for the downwards direction
                else
                    love.graphics.rectangle("line", self.x, self.y + (self.length - 1), self.length, self.length + self.predictDistance)
                end
            -- if rider is going left or right
            else
                -- draws up side prediction outline
                love.graphics.rectangle("line", self.x, self.y - self.sideDistance, self.length, self.sideDistance)
                -- draws down side prediction outline
                love.graphics.rectangle("line", self.x, self.y + self.length, self.length, self.sideDistance)
                -- draws forwards prediction outline for the leftnwards direction
                if self.direction == "l" then
                    love.graphics.rectangle("line", self.x - (self.length - 1) - self.predictDistance, self.y, self.length + self.predictDistance, self.length)
                -- draws forwards prediction outline for the rightwards direction
                else
                    love.graphics.rectangle("line", self.x + (self.length - 1), self.y, self.length + self.predictDistance, self.length)
                end
            end
        end
    else
        -- displays rider
        setColor(self.color)
        love.graphics.rectangle("fill", self.startX, self.startY, RIDER_SIZE, RIDER_SIZE)

        -- displays controls
        setColor("w")
        love.graphics.setFont(smallFont)
        love.graphics.print(self.controls, self.startX - smallFont:getWidth(self.controls) / 2 + 2, self.startY + round(VIRTUAL_HEIGHT / 28.8))
        if self.secondary then
            love.graphics.print(self.controlsSecondary, self.startX - smallFont:getWidth(self.controlsSecondary) / 2 + 2, self.startY + smallFont:getHeight(self.controlsSecondary) + round(VIRTUAL_HEIGHT / 28.8))
        end
    end
end