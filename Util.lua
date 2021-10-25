-- rounds to nearest integer
function round(n)
    return math.floor(n + 0.5)
end

-- sets color by character
function setColor(color)
    if color == "r" then 
        love.graphics.setColor(1, 0, 0, 1)
    elseif color == "g" then 
        love.graphics.setColor(0, 1, 0, 1)
    elseif color == "t" then 
        love.graphics.setColor(0, 1, 1, 1)
    elseif color == "y" then
        love.graphics.setColor(1, 1, 0, 1)
    elseif color == "p" then
        love.graphics.setColor(1, 0, 1, 1)
    elseif color == "b" then
        love.graphics.setColor(0, 0, 1, 1)
    elseif color == "w" then
        love.graphics.setColor(1, 1, 1, 1)
    elseif color == "B" then
        love.graphics.setColor(0, 0, 0, 1)
    end
end

-- maps number to color
function setColorNum(num)
    if num == 1 then 
        setColor("r")
    elseif num == 2 then 
        setColor("g")
    elseif num == 3 then 
        setColor("t")
    elseif num == 4 then
        setColor("y")
    elseif num == 5 then
        setColor("p")
    elseif num == 6 then
        setColor("b")
    end
end