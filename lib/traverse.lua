Traverse = {}

function Traverse.rect(length, width,is_to_left, todo)    
    for x = 1, width do
        for y = 1, length do
            if y ~= 1 or x == 1 then        
                turtle.forward()
            end
            todo()
        end
        if is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        turtle.forward()
        if is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end  
        is_to_left = not is_to_left
    end
    
    if width %2 == 0 then
        if not is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        for i = 1, width do
            turtle.forward()
        end
        if is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        turtle.back()
    else
        for i = 1, length do
            turtle.forward()
        end
        if not is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        for i = 1, width do
            turtle.forward()
        end
        if not is_to_left then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
    
    end
end

function Traverse.border(length, width, to_left, todo)
    for i =1,length do
        todo()
        turtle.forward()
end
    if to_left then
    turtle.turnLeft()
    else turtle.turnRight() end

    for i = 1, width do
        todo()
        turtle.forward()
    end
    if to_left then
        turtle.turnLeft()
    else turtle.turnRight() end
    for i = 1, length do
        todo()
        turtle.forward()
    end
    if to_left then
        turtle.turnLeft()
    else turtle.turnRight() end
    for i = 1,width do
        todo()
        turtle.forward()
    end
    if to_left then
        turtle.turnLeft()
    else turtle.turnRight() end
end
return Traverse
