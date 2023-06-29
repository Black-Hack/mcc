local args = { ... }

local length = tonumber(args[1])
local width = tonumber(args[2])
local height = tonumber(args[3])

if #args > 3 or not length or not width or not height then
    local program_name = arg[0] or fs.getName(shell.getRunningProgram())
    print('Usage: ' .. program_name .. ' <length> <width> <height>')
    return
end

print('Excavating', length, '*', width, '*', height)

function turnX(x)
    if x ~= 0 then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

turtle.digDown()
turtle.down()
turtle.digDown()
turtle.down()

for i = 1, height do
    for j = 1, width do
        for k = 1, length do
            turtle.digUp()
            turtle.digDown()
            if k + 1 <= length then
                turtle.dig()
                turtle.forward()
            end
        end

        local trn = width % 2 == 1 and 1 - j % 2 or (i + j) % 2

        turnX(trn)
        if j + 1 <= width then
            turtle.dig()
            turtle.forward()
        end
        turnX(trn)
    end

    if i + 1 <= height then
        turtle.down()
        turtle.digDown()
        turtle.down()
        turtle.digDown()
        turtle.down()
    end
end

for i = 1, 3 * height - 1 do
    turtle.up()
end

if height % 2 == 1 then
    if width % 2 == 1 then
        for i = 1, length - 1 do
            turtle.forward()
        end
        turtle.turnRight()
    else
        turtle.turnLeft()
    end

    for i = 1, width - 1 do
        turtle.forward()
    end
    turtle.turnRight()
end
