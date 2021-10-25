-- imports custom tools library
require "Util"

-- CAPITALIZED indicates it should be treated as a constant (no actual limitations)
WINDOW_WIDTH = round(690 * 1.75)
WINDOW_HEIGHT = round(384 * 1.75)

-- * 0.6
-- * 0.2
VIRTUAL_WIDTH = round(690 * 0.6)
VIRTUAL_HEIGHT = round(384 * 0.6)

VOLUME = 1 -- 0 to 1

UNBEATABLE = true

-- debug settings and checking variables (displayed uner FPS)
DEBUG = false
TEST1 = nil
TEST2 = nil
-- 110 
-- 35
RIDER_SPEED = 110
-- 4
-- 1
RIDER_SIZE = 4

INCREMENT_EFFECT = 150 -- 150
VOLUME_FADE = 0.75 -- 0.75

TURN_TIME_ALLOWANCE = (0.75 * 110) / RIDER_SPEED -- 0.75

-- imports class and push libraries (GitHub)
Class = require "class"
push = require "push"

-- imports Trail and Rider classes (Trail 1st bc Rider uses Trails)
require "Trail"
require "Rider"

-- sets volume to VOLUME
love.audio.setVolume(VOLUME)

-- Runs automatically when game starts only once to intialize the game
function love.load()

    -- sets filter to "nearest" (point filter) to stop blurring
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- sets random seeds
    math.randomseed(os.time())

    -- sets up push but has not acutally started yet
    -- push is an object --> colon means setupScreen is a method on the push object
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        vsync = true,
        resizable = true
    })

    -- creates fonts
    smallFont = love.graphics.newFont("04B_03.TTF", round(VIRTUAL_HEIGHT / 28.8)) -- 8
    midFont = love.graphics.newFont("04B_03.TTF", 16) -- 8
    mediumFont = love.graphics.newFont("04B_03.TTF", round(VIRTUAL_HEIGHT / 9.6)) -- 24
    bigFont = love.graphics.newFont("04B_03.TTF", round(VIRTUAL_HEIGHT / 5.8)) -- 40

    love.window.setTitle("Tron")

    -- initializes vars for radii effect
    radii = {}
    shape = {}
    radii[1] = 1
    radii_switch = 1
    overTimer = 0
    -- prepares round_win, game_win, or tie message
    message = 1
    -- sets up player select, ai select
    start = "player"
    players = 4
    ai = 2
    aiMax = 2
    aiMin = 0
    selectColorCode = {
        ["players"] = math.random(6),
        ["ai"] = math.random(6)
    }
    -- ensures color values of adjacent digits are different
    while selectColorCode["ai"] == selectColorCode["players"] do
        selectColorCode["ai"] = math.random(6)
    end
    -- initializes game score
    scores = {}
    -- sets score limit to 10 by default
    scoreLimit = "10"
    -- generates random color values for each digit in scoreLimit
    scoreColorCode = {
        [1] = math.random(6),
        [2] = math.random(6)
    }
    -- ensures color values of adjacent digits are different
    while scoreColorCode[2] == scoreColorCode[1] do
        scoreColorCode[2] = math.random(6)
    end
    -- rider vars that change later based on input
    riders = {}
    ridersAlive = 0
    winner = "Tie"
    -- initializes riders
    set(players, ai)

    -- generates sound effects
    audioMain = {
        ['startUp'] = love.audio.newSource("Audio/Tron_StartUp.wav", "static"),
        ['restart'] = love.audio.newSource("Audio/Tron_Restart.wav", "static"),
        ['chooseRider'] = love.audio.newSource("Audio/Tron_ChooseRider.wav", "static"),
        ['chooseScore'] = love.audio.newSource("Audio/Tron_ChooseScore.wav", "static"),
        ['scoreInput'] = love.audio.newSource("Audio/Tron_ScoreInput.wav", "static"),
        ['back'] = love.audio.newSource("Audio/Tron_Back.wav", "static"),
        ['scoreInvalid'] = love.audio.newSource("Audio/Tron_ScoreInvalid.wav", "static"),
        ['startRound'] = love.audio.newSource("Audio/Tron_StartRound.wav", "static"),
        ['pause'] = love.audio.newSource("Audio/Tron_Pause.wav", "static"),
        ['resume'] = love.audio.newSource("Audio/Tron_Resume.wav", "static"),
        ['winRound'] = love.audio.newSource("Audio/Tron_WinRound.wav", "static"),
        ['tieRound'] = love.audio.newSource("Audio/Tron_TieRound.wav", "static"),
        ['winGameInitial'] = love.audio.newSource("Audio/Tron_WinGameInitial.wav", "static"),
        ['winGamePulsate1'] = love.audio.newSource("Audio/Tron_WinGamePulsate1.wav", "static"),
        ['winGamePulsate2'] = love.audio.newSource("Audio/Tron_WinGamePulsate2.wav", "static"),
        ['winGamePulsate3'] = love.audio.newSource("Audio/Tron_WinGamePulsate3.wav", "static"),
        ['winGamePulsate4'] = love.audio.newSource("Audio/Tron_WinGamePulsate4.wav", "static"),
        ['winGamePulsate5'] = love.audio.newSource("Audio/Tron_WinGamePulsate5.wav", "static")
    }

    -- sets game state to start
    gameState = "start"

    -- plays startUp audio
    audioMain['startUp']:play()
end


-- resizes window appropriately
function love.resize(w, h)
    push:resize(w, h)
end


-- sets up correct number of riders and resets game
function set(numPlayers, numAI)
    -- clears riders, scores, and radii tables
    riders = {}
    scores = {}
    radii = {}
    shape = {}
    radii[1] = 1
    radii_switch = 1
    overTimer = 0
    -- finds riders position and direction based on total number of riders
    totalRiders = numPlayers + numAI
    x = {}
    y = {}
    dir = {}
    color = {}
    if totalRiders == 2 then
        color[1] = "r"
        color[2] = "t"

        x[1] = round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2)
        y[1] = round(VIRTUAL_HEIGHT / 2 - RIDER_SIZE / 2)
        dir[1] = "r"
        
        x[2] = round(VIRTUAL_WIDTH * (3/4) - RIDER_SIZE / 2)
        y[2] = round(VIRTUAL_HEIGHT / 2 - RIDER_SIZE / 2)
        dir[2] = "l"
    elseif totalRiders == 3 then
        color[1] = "r"
        color[2] = "g"
        color[3] = "t"

        x[1] = round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2)
        y[1] = round(VIRTUAL_HEIGHT * (1/3) - RIDER_SIZE / 2)
        dir[1] = "r"
        
        x[2] = round(VIRTUAL_WIDTH * (3/4) - RIDER_SIZE / 2) - 2
        y[2] = round(VIRTUAL_HEIGHT * (1/3) - RIDER_SIZE / 2)
        dir[2] = "l"
        
        x[3] = round(VIRTUAL_WIDTH / 2 - RIDER_SIZE / 2)
        y[3] = round(VIRTUAL_HEIGHT * (7/9) - RIDER_SIZE / 2)
        dir[3] = "u"
    elseif totalRiders == 4 then
        color[1] = "r"
        color[2] = "g"
        color[3] = "y"
        color[4] = "t"

        x[1] = round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2)
        y[1] = round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2)
        dir[1] = "r"

        x[2] = round(VIRTUAL_WIDTH * (3/4) - RIDER_SIZE / 2)
        y[2] = round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2)
        dir[2] = "l"

        x[3] = round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2)
        y[3] = round(VIRTUAL_HEIGHT * (3/4) - RIDER_SIZE / 2)
        dir[3] = "r"

        x[4] = round(VIRTUAL_WIDTH * (3/4) - RIDER_SIZE / 2)
        y[4] = round(VIRTUAL_HEIGHT * (3/4) - RIDER_SIZE / 2)
        dir[4] = "l"
    elseif totalRiders == 5 then
        color[1] = "r"
        color[2] = "g"
        color[3] = "y"
        color[4] = "p"
        color[5] = "t"

        x[1] = round(VIRTUAL_WIDTH / 2 - VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2) -- 1/3height left from mid x
        y[1] = round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2) -- 1/4height y
        dir[1] = "r"

        x[2] = round(VIRTUAL_WIDTH / 2 + VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2) -- 1/3height right from mid x
        y[2] = round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2) --1/4height y
        dir[2] = "l"

        x[3] = round(VIRTUAL_WIDTH / 2 - VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2) -- 1/3height left from mid x
        y[3] = round(VIRTUAL_HEIGHT * (55/100) - RIDER_SIZE / 2) --3/4height y
        dir[3] = "r"

        x[4] = round(VIRTUAL_WIDTH / 2 + VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2) -- 1/3height right from mid x
        y[4] = round(VIRTUAL_HEIGHT * (55/100) - RIDER_SIZE / 2) -- 3/4height y
        dir[4] = "l"

        x[5] = round(VIRTUAL_WIDTH / 2 - RIDER_SIZE / 2) -- mid x
        y[5] = round(VIRTUAL_HEIGHT * (55/100) + VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2) -- 1/3height down from mid y
        dir[5] = "u"
    elseif totalRiders == 6 then
        color[1] = "r"
        color[2] = "g"
        color[3] = "y"
        color[4] = "b"
        color[5] = "p"
        color[6] = "t"

        x[1] = round(VIRTUAL_WIDTH / 2 - VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height left from mid x
        y[1] = round(VIRTUAL_HEIGHT * 2/6 - RIDER_SIZE / 2) -- 1/4height y
        dir[1] = "r"

        x[2] = round(VIRTUAL_WIDTH / 2 + VIRTUAL_HEIGHT / 3 + RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height right from mid x
        y[2] = round(VIRTUAL_HEIGHT * 2/6 - RIDER_SIZE / 2) --1/4height y
        dir[2] = "l"

        x[3] = round(VIRTUAL_WIDTH / 2 - VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height left from mid x
        y[3] = round(VIRTUAL_HEIGHT * 4/6 - RIDER_SIZE / 2) --3/4height y
        dir[3] = "r"

        x[4] = round(VIRTUAL_WIDTH / 2 + VIRTUAL_HEIGHT / 3 + RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height right from mid x
        y[4] = round(VIRTUAL_HEIGHT * 4/6 - RIDER_SIZE / 2) -- 3/4height y
        dir[4] = "l"

        x[5] = round(VIRTUAL_WIDTH / 2 - RIDER_SIZE / 2) -- mid x
        y[5] = round(VIRTUAL_HEIGHT / 2 - VIRTUAL_HEIGHT / 3  + RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height up from mid y
        dir[5] = "d"

        x[6] = round(VIRTUAL_WIDTH / 2 - RIDER_SIZE / 2) -- mid x
        y[6] = round(VIRTUAL_HEIGHT / 2 + VIRTUAL_HEIGHT / 3 - RIDER_SIZE / 2 - RIDER_SIZE / 2) -- 1/3height down from mid y
        dir[6] = "u"
    end

    -- initializes according number of riders and score
    isPlayer = true
    for i = 1, totalRiders do
        if i > numPlayers then
            isPlayer = false
        end
        riders[i] = Rider(i, numPlayers, isPlayer, color[i], RIDER_SIZE, RIDER_SPEED, x[i], y[i], dir[i])
        scores[i] = 0
    end

    -- makes ridersAlive reflect number of riders
    ridersAlive = totalRiders
    -- sets winner to tie by default
    winner ="Tie"
end


-- dictates what occurs when certain keys are pressed
function love.keypressed(key)
    -- quits if esc key is pressed
    if key == "escape" then
        love.event.quit()
    -- toggles DEBUG when \ is pressed
    elseif key == "\\" then
        if DEBUG then
            DEBUG = false
        else
            DEBUG = true
        end
    -- allows user to pause and resume game
    elseif key == "p" then
        -- pauses game if not in pause (saves current state first)
        if gameState ~= "pause" then
            -- plays pause audio
            audioMain['pause']:play()
            previousState = gameState
            gameState = "pause"
        -- resumes from pause
        else
            -- plays resume audio
            audioMain['resume']:play()
            gameState = previousState
        end
    -- restarts game if r is pressed in pause
    elseif key == "r" and gameState == "pause" then
        -- plays restart audio
        audioMain['restart']:play()
        -- resets riders
        set(players, ai)
        -- generates random color values for each digit in scoreLimti
        scoreColorCode = {
            [1] = math.random(6),
            [2] = math.random(6)
        }
        -- ensures color values of adjacent digits are different
        while scoreColorCode[2] == scoreColorCode[1] do
            scoreColorCode[2] = math.random(6)
        end
        -- resets up player select, ai select
        start = "player"
        selectColorCode = {
            ["players"] = math.random(6),
            ["ai"] = math.random(6)
        }
        -- ensures color values of adjacent digits are different
        while selectColorCode["ai"] == selectColorCode["players"] do
            selectColorCode["ai"] = math.random(6)
        end
        -- sets gameState back to start
        gameState = "start"
    -- resets game from game_over state after 3 seconds if any key is pressed
    elseif gameState == "game_over" and overTimer > 3 then
        -- replays startUp audio
        audioMain['startUp']:play()
        -- resets riders
        set(players, ai)
        -- sets gameState back to start
        gameState = "start"
    -- controls scoreLimit based on user input when inside choose state
    elseif gameState == "choose" then
        -- allows user to add more numbers while scoreLimit has less than 3 digits
        if (key == "0" or key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or
        key == "6" or key == "7" or key == "8" or key == "9") then
            if string.len(scoreLimit) < 3 then
                -- plays scoreInput audio
                audioMain['scoreInput']:play()
                scoreLimit = scoreLimit .. key
                scoreColorCode[string.len(scoreLimit)] = math.random(6)
                -- ensures color values of adjacent digits are different
                while scoreColorCode[string.len(scoreLimit)] == scoreColorCode[string.len(scoreLimit) - 1] do
                    scoreColorCode[string.len(scoreLimit)] = math.random(6)
                end
            else
                -- plays scoreInvalid audio
                audioMain['scoreInvalid']:play()
            end
        -- allows user to delete digits in scorLimit using backspace
        elseif key == "backspace" then
            if string.len(scoreLimit) > 0 then
                -- plays back audio
                audioMain['back']:play()
                scoreLimit = ""
            else
                -- plays back audio
                audioMain['back']:play()
                -- sets score limit to 10 by default
                scoreLimit = "10"
                -- generates random color values for each digit in scoreLimti
                scoreColorCode = {
                    [1] = math.random(6),
                    [2] = math.random(6)
                }
                -- ensures color values of adjacent digits are different
                while scoreColorCode[2] == scoreColorCode[1] do
                    scoreColorCode[2] = math.random(6)
                end
                gameState = "start"
            end
        -- enters play state when enter or space is clicked / converts scoreLimit to number value
        elseif key == "enter" or key == "return" or key == "space" then
            -- plays startRound audio
            audioMain['startRound']:play()
            if scoreLimit == "" then scoreLimit = "10" end
            scoreLimit = tonumber(scoreLimit)
            gameState = "play"
        end 
    -- switches state when enter key is pressed
    elseif key == "enter" or key == "return" or key == "space" then
        -- start changes
        if gameState == "start" then
            -- plays chooseRider audio
            audioMain['chooseRider']:play()
            -- start player to start ai
            if start == "player" then
                start = "ai"
            -- start ai to choose state
            else
                gameState = "choose"
            end
        -- choose to play / converts scoreLimit to number value
        elseif gameState == "choose" then
            -- plays startRound audio
            audioMain['startRound']:play()
            if scoreLimit == "" then scoreLimit = "10" end
            scoreLimit = tonumber(scoreLimit)
            if scoreLimit < 1 then
                scoreLimit = 0
            end
            gameState = "play"
        -- resumes from pause
        elseif gameState == "pause" then
            -- plays resume audio
            audioMain['resume']:play()
            gameState = previousState
        -- next round (play) from end
        elseif gameState == "round_end" then
            -- plays startRound audio
            audioMain['startRound']:play()
            gameState = "play"
        end
    -- allows user to choose number of riders
    elseif gameState == "start" then
        if start == "player" then
            if (key == "0" or key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or
            key == "6" or key == "7" or key == "8" or key == "9" or key == "backspace") and 
            (players ~= tonumber(key)) and not (key == "backspace" and players == 0) then
                -- plays chooseScore audio
                audioMain['chooseScore']:play()
                players = tonumber(key)
                if key == "5" or key == "6" or key == "7" or key == "8" or key == "9" then
                    players = 4
                end
                if key == "backspace" then
                    players = 0
                end
                aiMax = 6 - players
                if aiMax < ai then
                    ai = aiMax
                end
                aiMin = 2 - players
                if aiMin > ai then
                    ai = aiMin
                end
                selectColorCode["players"] = math.random(6) 
                -- ensures color values of adjacent digits are different
                while selectColorCode["players"] == selectColorCode["ai"] do
                    selectColorCode["players"] = math.random(6)
                end
                set(players, ai)
            elseif key == "enter" or key == "return" or key == "space" then
                -- plays chooseRider audio
                audioMain['chooseRider']:play()
                start = "ai"
            else
                -- plays scoreInvalid audio
                audioMain['scoreInvalid']:play()
            end
        else
            -- sets ai count to 0 / goes back if ai count is already 0
            if key == "backspace" then
                if ai == 0 then
                    -- plays back audio
                    audioMain['back']:play()
                    start = "player"
                else
                    -- plays chooseRider audio
                    audioMain['chooseRider']:play()
                    ai = 0
                    selectColorCode["ai"] = math.random(6) 
                    -- ensures color values of adjacent digits are different
                    while selectColorCode["ai"] == selectColorCode["players"] do
                        selectColorCode["ai"] = math.random(6)
                    end
                end
            elseif (key == "0" or key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or
            key == "6" or key == "7" or key == "8" or key == "9") and ai ~= tonumber(key) then
                aiMax = 6 - players
                aiMin = 2 - players
                if aiMax < tonumber(key) then
                    -- plays scoreInvalid audio
                    audioMain['scoreInvalid']:play()
                    ai = aiMax
                elseif aiMin > tonumber(key) then
                    -- plays scoreInvalid audio
                    audioMain['scoreInvalid']:play()
                    ai = aiMin
                else
                    -- plays chooseRider audio
                    audioMain['chooseRider']:play()
                    ai = tonumber(key)
                    selectColorCode["ai"] = math.random(6) 
                    -- ensures color values of adjacent digits are different
                    while selectColorCode["ai"] == selectColorCode["players"] do
                        selectColorCode["ai"] = math.random(6)
                    end
                end
                set(players, ai)
            elseif key == "enter" or key == "return" or key == "space" then
                -- plays chooseRider audio
                audioMain['chooseRider']:play()
                set(players, ai)
                gameState = "choose"
            end
        end
    end
end


-- updates game (dt varies based on comp frame rate and processing power)
function love.update(dt)
    -- updates only made in play state
    if gameState == "play" then
        -- rider movement updates
        for i = 1, #riders do
            riders[i]:update(dt)
        end
        -- updates ridersAlive
        ridersAlive = 0
        for i = 1, #riders do
            if riders[i].alive then
                ridersAlive = ridersAlive + 1
            end
        end
        -- winning logic
        if ridersAlive == 1 or ridersAlive == 0 then
            -- changes state to round_end by default
            gameState = "round_end"
            message = math.random(5)
            -- increments score if there is a singular winner
            if ridersAlive == 1 then
                for i = 1, #riders do
                    if riders[i].alive then
                        scores[i] = scores[i] + 1
                        winner = i
                        break
                    end
                end
                -- changes state to game_over if the current winning player has reached scoreLimit
                if scores[winner] >= scoreLimit then
                    -- plays winGameInitial audio
                    audioMain['winGameInitial']:play()
                    gameState = "game_over"
                else
                    -- plays winRound audio
                    audioMain['winRound']:play()
                end

                -- sets winner to the string of the color
                winnerNum = winner
                if riders[winner].color == "r" then
                    winner = "Red"
                elseif riders[winner].color == "g" then
                    winner = "Green"
                elseif riders[winner].color == "y" then
                    winner = "Yellow"
                elseif riders[winner].color == "t" then
                    winner = "Teal"
                elseif riders[winner].color == "p" then
                    winner = "Purple"
                elseif riders[winner].color == "b" then
                    winner = "Blue"
                end
            -- clarifies no winner if tie
            else
                -- plays tieRound audio
                audioMain['tieRound']:play()
                winner = "Tie"
            end
            -- resets rider positions
            for i = 1, #riders do
                riders[i]:reset()
            end
            -- resets alive count
            ridersAlive = #riders
        end
    elseif gameState == "game_over" then
        overTimer = overTimer + dt
        -- controls radii effect
        inc = INCREMENT_EFFECT * dt
        for i = 1, #radii do
            radii[i] = radii[i] + inc
        end
        if radii[radii_switch] > 125 then
            if (radii_switch + 1) == 5 then
                radii_switch = 1
            else
                radii_switch = radii_switch + 1
            end
            radii[radii_switch] = 1
            shape[radii_switch] = math.random(8) + 2
            if shape[radii_switch] == 10 then shape[radii_switch] = 40 end
            -- controls fade out effect
            if overTimer <= 2 then
                volume = 1
            else
                volume = volume * VOLUME_FADE
            end
            if volume > 0.001 then
                -- plays one of five random winGamePulsating_ sounds
                randomWinSound = "winGamePulsate" .. tostring(math.random(5))
                audioMain[randomWinSound]:setVolume(volume)
                audioMain[randomWinSound]:play()
            end
        end
    end
end


-- runs after update automatically to draw anything to the screen
function love.draw()
    -- starts push state
    push:apply("start")

    -- sets background color
    love.graphics.clear(0, 0, 0, 0)
    
    -- for start and choose states
    if gameState == "start" or gameState == "choose" then
        -- displays TRON intro message
        displayTRON()
        -- renders choose score, press to play, and pause messages
        displayIntroScreens(gameState)
        -- renders riders
        for i = 1, #riders do
            riders[i]:render(gameState)
        end
    -- for play state
    elseif gameState == "play" then
        -- renders riders (alive riders last)
        alive = {} -- clears alive table
        -- renders dead riders first while keeping track of alive riders in alive table
        for i = 1, #riders do
            if not(riders[i].alive) then
                riders[i]:render(gameState)
            else
                alive[i] = true
            end
        end
        -- renders alive riders through alive table
        for r, k in pairs(alive) do
            riders[r]:render(gameState)
        end
    -- for pause state
    elseif gameState == "pause" then
        -- renders PAUSED message
        love.graphics.setFont(bigFont)
        setColor("t") -- red
        love.graphics.print("P", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2, round(VIRTUAL_HEIGHT / 3))
        setColor("r") -- green
        love.graphics.print("A", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2 + bigFont:getWidth("P"), round(VIRTUAL_HEIGHT / 3))
        setColor("y") -- yellow
        love.graphics.print("U", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2 + bigFont:getWidth("PA"), round(VIRTUAL_HEIGHT / 3))
        setColor("g") -- teal
        love.graphics.print("S", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2 + bigFont:getWidth("PAU"), round(VIRTUAL_HEIGHT / 3))
        setColor("b") -- blue
        love.graphics.print("E", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2 + bigFont:getWidth("PAUS"), round(VIRTUAL_HEIGHT / 3))
        setColor("p") -- purple
        love.graphics.print("D", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("PAUSED") / 2 + bigFont:getWidth("PAUSE"), round(VIRTUAL_HEIGHT / 3))
        
        -- renders resume and restart Messages
        setColor("w")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Space, Enter, or P to Resume", -1, round(VIRTUAL_HEIGHT / 3 + bigFont:getHeight("PAUSED")), VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press R to Restart", 0, round(VIRTUAL_HEIGHT / 3 + bigFont:getHeight("PAUSED")) + 10, VIRTUAL_WIDTH, "center")

        -- renders colorful border
        spanHorizontal = round(VIRTUAL_WIDTH * (3/4) - VIRTUAL_WIDTH / 4 + RIDER_SIZE)
        spanVertical = round(VIRTUAL_HEIGHT * (2/3) - VIRTUAL_HEIGHT / 4 - RIDER_SIZE)
        -- purple left line
        setColor("p")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2), round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2) + RIDER_SIZE, RIDER_SIZE, spanVertical)
        -- teal right line
        setColor("t")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE * 3/2 + spanHorizontal) - 1, round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2) + RIDER_SIZE, RIDER_SIZE, spanVertical)
        -- blue top left line
        setColor("b")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2), round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2), spanHorizontal / 2, RIDER_SIZE)
        -- yellow top right line
        setColor("y")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2 + spanHorizontal / 2), round(VIRTUAL_HEIGHT / 4 - RIDER_SIZE / 2), spanHorizontal / 2, RIDER_SIZE)
        -- green bottom left line
        setColor("g")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2), round(VIRTUAL_HEIGHT * (2/3) - RIDER_SIZE / 2), spanHorizontal / 2, RIDER_SIZE)
        -- red bottom right line
        setColor("r")
        love.graphics.rectangle("fill", round(VIRTUAL_WIDTH / 4 - RIDER_SIZE / 2 + spanHorizontal / 2), round(VIRTUAL_HEIGHT * (2/3) - RIDER_SIZE / 2), spanHorizontal / 2, RIDER_SIZE)
    elseif gameState == "round_end" then
        -- prints winner or tie
        setColor("w")
        love.graphics.setFont(mediumFont)
        if winner == "Tie" then
            -- varies tie messages
            if message == 1 then
                message = "No Winner"
            elseif message == 2 then
                message = "Too Bad - It's a Tie"
            elseif message == 3 then
                message = "Tie - No One Wins"
            elseif message == 4 then
                message = "Everyone Loses :("
            elseif message == 5 then
                message = "Surprise - We have a Tie!"
            end
        else
            setColor(riders[winnerNum].color)
            -- varies winning messages
            if message == 1 then
                message = winner .. " Takes the Round!"
            elseif message == 2 then
                message =  winner .. " Comes Out on Top!"
            elseif message == 3 then
                message = winner .. " is the Lone Survivor"
            elseif message == 4 then
                message = winner .. " Refuses to Relent!"
            elseif message == 5 then
                message = winner .. " Proves Skillful in Battle"
            end
        end
        love.graphics.printf(message, 0, round(VIRTUAL_HEIGHT / 7.5), VIRTUAL_WIDTH, "center") -- 30
        -- prompts input into next round
        setColor("w")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter or Space to Start the Next Round", 0, round(VIRTUAL_HEIGHT * 24/100), VIRTUAL_WIDTH, "center")
        -- displays score
        displayScore(VIRTUAL_HEIGHT / 40, false)
    elseif gameState == "game_over" then
        -- gets winner and sets color to winner's color
        setColor("w")
        love.graphics.setFont(bigFont)
        setColor(riders[winnerNum].color)
        -- increasing shape effect
        for i = 1, #radii do
            love.graphics.circle("line", VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, radii[i], shape[i])
        end
    
        -- varies victory message
        if message == 1 then
            message = string.upper(winner) .. " CLAIMS\nULTIMATE VICTORY"
        elseif message == 2 then
            message = "AND ".. string.upper(winner) .. "\nSEIZES THE GAME"
        elseif message == 3 then
            message = "THE CHAMPION\nIS " .. string.upper(winner)
        elseif message == 4 then
            message = "AND " .. string.upper(winner) .. "\nWINS IT ALL"
        elseif message == 5 then
            message = string.upper(winner) .. " BEATS\nTHE COMPETION"
        end
        love.graphics.printf(message, 0, round(VIRTUAL_HEIGHT / 12), VIRTUAL_WIDTH, "center") -- 30
        
        -- prompts input into next round
        setColor("w")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Any Key to Play Again!", 0, round(VIRTUAL_HEIGHT * (41/100)), VIRTUAL_WIDTH, "center")
        -- displays score
        displayScore(0, true)
    end

    -- renders border
    renderBorder()

    -- displays FPS
    displayFPS()

    -- ends push state
    push:apply("end")
end


-- renders white border around the edge of the screen
function renderBorder()
    setColor("w")
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH - 1, 1)
    love.graphics.rectangle("fill", 0, 1, 1, VIRTUAL_HEIGHT - 1)
    love.graphics.rectangle("fill", VIRTUAL_WIDTH - 1, 0, 1, VIRTUAL_HEIGHT - 1)
    love.graphics.rectangle("fill", 1, VIRTUAL_HEIGHT - 1, VIRTUAL_WIDTH - 1, 1)
end


-- displays TRON intro message
function displayTRON()
    love.graphics.setFont(bigFont)
    love.graphics.setColor(1, 0, 0, 1) -- red
    love.graphics.print("T", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("TRON") / 2, round(VIRTUAL_HEIGHT / 45))
    love.graphics.setColor(0, 1, 0, 1) -- green
    love.graphics.print("R", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("TRON") / 2 + bigFont:getWidth("T"), round(VIRTUAL_HEIGHT / 45))
    love.graphics.setColor(1, 1, 0, 1) -- yellow
    love.graphics.print("O", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("TRON") / 2 + bigFont:getWidth("TR"), round(VIRTUAL_HEIGHT / 45))
    love.graphics.setColor(0, 1, 1, 1) -- blue
    love.graphics.print("N", round(VIRTUAL_WIDTH / 2) - bigFont:getWidth("TRON") / 2 + bigFont:getWidth("TRO"), round(VIRTUAL_HEIGHT / 45))
end


-- displays start and choose screen
function displayIntroScreens(state)
    -- for start state
    if state == "start" then
        -- renders bottom 3-line message blurb
        if players + ai == 5 then
            add = round(VIRTUAL_HEIGHT * 5/100)
            love.graphics.setFont(smallFont)
            setColor("b")
            love.graphics.printf("Enter the Number of Players & AI", 0, round(VIRTUAL_HEIGHT * 68/100), VIRTUAL_WIDTH, "center")
            setColor("p")
            love.graphics.printf("Press Enter or Space to Continue!", 0, round(VIRTUAL_HEIGHT * 72/100), VIRTUAL_WIDTH, "center")
            setColor("w")
            love.graphics.printf("(P = Pause / Backspace = Back)", 0, round(VIRTUAL_HEIGHT * 76/100), VIRTUAL_WIDTH, "center")
        else
            add = 0
            love.graphics.setFont(smallFont)
            setColor("b")
            love.graphics.printf("Enter the Number of Players & AI", 0, round(VIRTUAL_HEIGHT * 52/100), VIRTUAL_WIDTH, "center")
            setColor("p")
            love.graphics.printf("Press Enter or Space to Continue!", 0, round(VIRTUAL_HEIGHT * 56/100), VIRTUAL_WIDTH, "center")
            setColor("w")
            love.graphics.printf("(P = Pause / Backspace = Back)", 0, round(VIRTUAL_HEIGHT * 60/100), VIRTUAL_WIDTH, "center")
        end

        -- renders "Players:" and "AI:" selects without actual values or max message underneath
        setColor("w")
        love.graphics.setFont(midFont)
        love.graphics.print("Players: ", round(VIRTUAL_WIDTH / 2) - midFont:getWidth("Players: 0") / 2 + 1, round(VIRTUAL_HEIGHT * 29/100) + add)
        love.graphics.setFont(midFont)
        love.graphics.print("AI: ", round(VIRTUAL_WIDTH / 2) - midFont:getWidth("AI: 0") / 2 + 1, round(VIRTUAL_HEIGHT * 40/100) + add)
        
        -- displays user-entered balues for players and ai & max messages underneath in random colors
        -- number of players
        setColorNum(selectColorCode["players"])
        love.graphics.setFont(midFont)
        love.graphics.print(players, round(VIRTUAL_WIDTH / 2) - midFont:getWidth("Players: 0") / 2 + midFont:getWidth("Players: ") + 1, round(VIRTUAL_HEIGHT * 29/100) + add)
        love.graphics.setFont(smallFont)
        love.graphics.printf("(0 to 4)", -10 + 1, round(VIRTUAL_HEIGHT * 36.25/100) + add, VIRTUAL_WIDTH, "center")
        -- number of ai
        setColorNum(selectColorCode["ai"])
        love.graphics.setFont(midFont)
        love.graphics.print(ai, round(VIRTUAL_WIDTH / 2) - midFont:getWidth("AI: 0") / 2 + midFont:getWidth("AI: ") + 1,  round(VIRTUAL_HEIGHT * 40/100) + add)
        love.graphics.setFont(smallFont)
        love.graphics.print("(" .. aiMax .. " MAX)", round(VIRTUAL_WIDTH / 2) - midFont:getWidth("0 MAX") / 2 - 1 + 1, round(VIRTUAL_HEIGHT * 46/100) + add)

    -- for choose state
    elseif state == "choose" then
        if players + ai == 5 then
            add = - round(VIRTUAL_HEIGHT * 9/100)
        else
            add = 0
        end
        love.graphics.setFont(smallFont)
        setColor("b")
        love.graphics.printf("Enter the Desired Score Limit ", 0, round(VIRTUAL_HEIGHT * 44/100) + add, VIRTUAL_WIDTH, "center")
        setColor("p")
        love.graphics.printf("Press Enter or Space to Play! ", 0, round(VIRTUAL_HEIGHT * 48/100) + add, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(midFont)
        setColor("w")
        love.graphics.print("Score Limit: ", round(VIRTUAL_WIDTH / 2) - midFont:getWidth("Score Limit: 00") / 2,  round(VIRTUAL_HEIGHT * 53/100) + add)
        -- displays user-entered score in random colors
        for i = 1, string.len(scoreLimit) do
            setColorNum(scoreColorCode[i])
            love.graphics.print(string.sub(scoreLimit, i, i), round(VIRTUAL_WIDTH / 2) + midFont:getWidth("Score Limit: ") / 2 - midFont:getWidth("00") / 2 + midFont:getWidth(string.sub(scoreLimit, 1, i-1)),  round(VIRTUAL_HEIGHT * 53/100) + add)
        end
    end
end


-- displays score displaced vertically by add (positive = downward)
function displayScore(add, over)
    love.graphics.setFont(mediumFont)
    underLength = mediumFont:getWidth("Score Limit: " .. tostring(scoreLimit))
    if #riders == 6 then 
        if over then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT / 2) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT / 2) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + add), VIRTUAL_WIDTH * 2/3, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 2/3, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + 2 * (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 2/3, "center") -- 150end
            setColor("b")
            love.graphics.printf("Blue: " .. tostring(scores[4]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 64.5/100 + add), VIRTUAL_WIDTH * 1/3, "center") -- 90
            setColor("p")
            love.graphics.printf("Purple: " .. tostring(scores[5]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 64.5/100 + (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 1/3, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[6]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 64.5/100 + 2 * (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 1/3, "center") -- 150end   
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 32/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 32/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 49/100 + add), VIRTUAL_WIDTH * 2/3, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 49/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 2/3, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 49/100 + 2 * (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 2/3, "center") -- 150end
            setColor("b")
            love.graphics.printf("Blue: " .. tostring(scores[4]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 49/100 + add), VIRTUAL_WIDTH * 1/3, "center") -- 90
            setColor("p")
            love.graphics.printf("Purple: " .. tostring(scores[5]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 49/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 1/3, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[6]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 49/100 + 2 * (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 1/3, "center") -- 150end
        end 
    elseif #riders == 5 then 
        if over then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT / 2) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT / 2) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + add), VIRTUAL_WIDTH * 2/3, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 2/3, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 64.5/100 + add), VIRTUAL_WIDTH * 1/3, "center") -- 90
            setColor("p")
            love.graphics.printf("Purple: " .. tostring(scores[4]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 64.5/100 + (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH * 1/3, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[5]), 0, round(VIRTUAL_HEIGHT * 64.5/100 + 2 * (VIRTUAL_HEIGHT / 9.25) + add), VIRTUAL_WIDTH, "center") -- 150end
             
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 32/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 32/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 49/100 + add), VIRTUAL_WIDTH * 2/3, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 49/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 2/3, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 49/100 + add), VIRTUAL_WIDTH * 1/3, "center") -- 90
            setColor("p")
            love.graphics.printf("Purple: " .. tostring(scores[4]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 49/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH * 1/3, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[5]), 0, round(VIRTUAL_HEIGHT * 49/100 + 2 * (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH, "center") -- 150end
        end
    elseif #riders == 4 then 
        if over then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT / 2) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT / 2) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 66/100 + add), VIRTUAL_WIDTH / 2, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 66/100 + add), VIRTUAL_WIDTH / 2, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 66/100 + VIRTUAL_HEIGHT / 8 + add), VIRTUAL_WIDTH / 2, "center") -- 130
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[4]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 66/100 + VIRTUAL_HEIGHT / 8 + add), VIRTUAL_WIDTH / 2, "center") -- 150
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 32/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 32/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 47/100 + add), VIRTUAL_WIDTH, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 47/100 + (VIRTUAL_HEIGHT / 9) + add), VIRTUAL_WIDTH, "center") -- 110
            setColor("y")
            love.graphics.printf("Yellow: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 47/100 + 2 * (VIRTUAL_HEIGHT / 9) + add), VIRTUAL_WIDTH, "center") -- 130
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[4]), 0, round(VIRTUAL_HEIGHT * 47/100 + 3 * (VIRTUAL_HEIGHT / 9) + add), VIRTUAL_WIDTH, "center") -- 150end
        end
    elseif #riders == 3 then
        if over then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT / 2) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT / 2) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 66/100 + add), VIRTUAL_WIDTH / 2, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 66/100 + add), VIRTUAL_WIDTH / 2, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 66/100 + VIRTUAL_HEIGHT / 8 + add), VIRTUAL_WIDTH, "center") -- 130
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 32/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 32/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 49/100 + add), VIRTUAL_WIDTH, "center") -- 90
            setColor("g")
            love.graphics.printf("Green: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 49/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH, "center") -- 110
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[3]), 0, round(VIRTUAL_HEIGHT * 49/100 + 2 * (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH, "center") -- 150end
        end
    elseif #riders == 2 then
        if over then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 55/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 55/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 73/100 + add), VIRTUAL_WIDTH / 2, "center") -- 90
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[2]), VIRTUAL_WIDTH / 2, round(VIRTUAL_HEIGHT * 73/100 + add), VIRTUAL_WIDTH / 2, "center") -- 110
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Score Limit: " .. tostring(scoreLimit), 0, round(VIRTUAL_HEIGHT * 40/100) + add, VIRTUAL_WIDTH, "center")
            love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - underLength / 2, round(VIRTUAL_HEIGHT * 40/100) + mediumFont:getHeight("S") + add, underLength, RIDER_SIZE)
            setColor("r")
            love.graphics.printf("Red: " .. tostring(scores[1]), 0, round(VIRTUAL_HEIGHT * 58/100 + add), VIRTUAL_WIDTH, "center") -- 90
            setColor("t")
            love.graphics.printf("Teal: " .. tostring(scores[2]), 0, round(VIRTUAL_HEIGHT * 58/100 + (VIRTUAL_HEIGHT / 7) + add), VIRTUAL_WIDTH, "center") -- 110
        end
    end
end


-- displays FPS
function displayFPS()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print(tostring(love.timer.getFPS()) .. "FPS", 3, 3)
    -- TESTING OUTPUT
    if DEBUG then
        love.graphics.print("Test1: " .. tostring(TEST1), 3, 11)
        love.graphics.print("Test2: " .. tostring(TEST2), 3, 19)
    end
end