-- Challenge 1
-- Guess 1: 15 -- incorrect
-- Guess 2: 5145, CORRECT

local collection = require(script.Parent.Parent.luafp.collection)
local map = collection.map
local filter = collection.filter
local reduce = collection.reduce

local Vents = {}

local LineType = {
    HorizontalLineType = "horizontal",
    VerticalLineType = "vertical",
    LineType = "line",
}

type HorizontalLine = {
    x1:number,
    x2:number,
    y1:number,
    y2:number,
    typeString:string
}
type VerticalLine = {
    x1:number,
    x2:number,
    y1:number,
    y2:number,
    typeString:string
}
type Line = {
    x1:number,
    x2:number,
    y1:number,
    y2:number,
    typeString:string
}

type RowIndex = number
type ColIndex = number

type GridItem = {
    row:RowIndex,
    col:ColIndex,
    count:number
}

type Grid = {
    rows:RowIndex,
    cols:ColIndex,
    gridItems:{GridItem}
}

type Point = {
    x:number,
    y:number
}

function pointToString(point)
    return "Point x=" .. tostring(point.x) .. ", y=" .. tostring(point.y) 
end

function Vents.getCrossingLines(input)
    local parsedLines = parseInputIntoLines(input)
    local onlyHorizontalOrVerticalLines = includeHorizontalAndVerticalLines(parsedLines)
    print("Building grid...")
    local grid = buildGridFromLines(onlyHorizontalOrVerticalLines)
    print("Getting maximum intersections...")
    -- local gridString = printGrid(grid)
    local maxIntersections = getMaximumIntersections(grid)
    print("maxIntersections:", maxIntersections)
    local howManyMaxIntersections = getHowManyIntersections(grid, maxIntersections)
    -- print(gridString)
    print("howManyMaxIntersections:", howManyMaxIntersections)
    -- return howManyMaxIntersections
    return howManyMaxIntersections
end

function parseInputIntoLines(input:string):{HorizontalLine | VerticalLine | Line}
    local lineStrings = input:split('\n')
    local lines = map(
        function(lineString:string):HorizontalLine | VerticalLine
            return parseLineString(lineString)
        end,
        lineStrings
    )
    return lines
end

function parseLineString(lineString:string):HorizontalLine | VerticalLine | Line
    local one, two = table.unpack(lineString:split(' -> '))
    local x1String, y1String = table.unpack(one:split(','))
    local x2String, y2String = table.unpack(two:split(','))
    local x1 = tonumber(x1String)
    local y1 = tonumber(y1String)
    local x2 = tonumber(x2String)
    local y2 = tonumber(y2String)

    assert(type(x1) == "number", "x1 isn't a number")
    assert(type(y1) == "number", "y1 isn't a number")
    assert(type(x2) == "number", "x2 isn't a number")
    assert(type(y2) == "number", "y2 isn't a number")

    if x1 == x2 then
        return createHorizontalLine(x1, y1, x2, y2)
    elseif y1 == y2 then
        return createVerticalLine(x1, y1, x2, y2)
    else
        return createLine(x1, y1, x2, y2)
    end
end

function createHorizontalLine(x1:number, y1:number, x2:number, y2:number):HorizontalLine
    return { x1 = x1, y1 = y1, x2 = x2, y2 = y2, typeString = LineType.HorizontalLineType }
end

function createVerticalLine(x1:number, y1:number, x2:number, y2:number):VerticalLine
    return { x1 = x1, y1 = y1, x2 = x2, y2 = y2, typeString = LineType.VerticalLineType }
end

function createLine(x1:number, y1:number, x2:number, y2:number):Line
    return { x1 = x1, y1 = y1, x2 = x2, y2 = y2, typeString = LineType.LineType }
end

function includeHorizontalAndVerticalLines(lines:{HorizontalLine | VerticalLine | Line}):{HorizontalLine | VerticalLine}
    return filter(
        function(line:HorizontalLine | VerticalLine | Line):boolean
            if line.typeString == LineType.LineType then
                return false
            else
                return true
            end
        end,
        lines
    )
end

function getLargestX(lines:{HorizontalLine | VerticalLine | Line}):number
    return reduce(
        function(acc:number, line:HorizontalLine | VerticalLine | Line):number
            local largestX = getLargestLineX(line)
            if largestX > acc then
                return largestX
            else
                return acc
            end
        end,
        1,
        lines
    )
end

function getLargestY(lines:{HorizontalLine | VerticalLine | Line}):number
    return reduce(
        function(acc:number, line:HorizontalLine | VerticalLine | Line):number
            local largestY = getLargestLineY(line)
            if largestY > acc then
                return largestY
            else
                return acc
            end
        end,
        1,
        lines
    )
end

function getLargestLineX(line:HorizontalLine | VerticalLine | Line):number
    if line.x1 > line.x2 then
        return line.x1
    elseif line.x2 > line.x1 then
        return line.x2
    else
        return line.x1
    end
end

function getLargestLineY(line:HorizontalLine | VerticalLine | Line):number
    if line.y1 > line.y2 then
        return line.y1
    elseif line.y2 > line.y1 then
        return line.y2
    else
        return line.y1
    end
end

function resetTimer()
	return tick() + 1/60
end

-- -- Call where appropriate, such as at the top of loops.
-- function MaybeYield()
-- 	if tick() >= expireTime then
-- 		wait() -- insert preferred yielding method
-- 		ResetTimer()
-- 	end
-- end

function isTimeUp(expireTime)
    return tick() >= expireTime
end

function buildGridFromLines(lines:{HorizontalLine | VerticalLine | Line}):Grid
    -- print("buildGridFromLines, #lines:", #lines)
    local largestX = getLargestX(lines)
    local largestY = getLargestY(lines)
    -- print("largestX:", largestX, "largestY:", largestY)
    local col, row
    local gridItems = {}
    local expireTime = resetTimer()
    local percent25Done = false
    local percent50Done = false
    local percent75Done = false
    for row=0,largestX do
        for col=0,largestY do
            local gridItem = createGridItem(row, col, 0)
            local updatedGridItem = checkIntersections(lines, gridItem)
            table.insert(gridItems, updatedGridItem)
            if isTimeUp(expireTime) == true then
                task.wait(0)
                expireTime = resetTimer()
                local percentDone = math.floor((row / largestX) * 100)
                if percent25Done == false and percentDone >= 25 then
                    percent25Done = true
                    print("25% done with Grid...")
                elseif percent50Done == false and percentDone >= 50 then
                    percent50Done = true
                    print("50% done with Grid...")
                elseif percent75Done == false and percentDone >= 75 then
                    percent75Done = true
                    print("75% done with Grid...")
                end
            end
        end
        -- print("Row " .. tostring(row) .. " of " .. tostring(largestX))
    end
    local grid = { rows = largestX, cols = largestY, gridItems = gridItems }
    return grid
end

function createGridItem(row:number, col:number, count:number):GridItem
    assert(type(row) == 'number', "row is not a number.")
    assert(row > -1, "row is not greater than -1")
    
    assert(type(col) == 'number', "col is not a number.")
    assert(col > -1, "col is not greater than -1")

    assert(type(count) == 'number', "count is not a number.")

    return { row = row, col = col, count = count }
end

function checkIntersections(lines:{HorizontalLine | VerticalLine | Line}, gridItem:GridItem):GridItem
    return reduce(
        function(acc:GridItem, line:HorizontalLine | VerticalLine | Line)
            local intersects = pointIntersects({ x = gridItem.col, y = gridItem.row }, line)
            -- print("intersects:", intersects)
            if intersects == true then
                acc.count = acc.count + 1
                return acc
            else
                return acc
            end
        end,
        gridItem,
        lines
    )
end

function pointIntersects(point:Point, line:HorizontalLine | VerticalLine | Line):boolean
    if line.typeString == LineType.HorizontalLineType then
        return pointIntersectsHorizontalLine(point, line)
    elseif line.typeString == LineType.VerticalLineType then
        return pointIntersectsVerticalLine(point, line)
    else
        error("Not implemented.")
    end
end

function pointIntersectsVerticalLine(point:Point, line:VerticalLine):boolean
    if point.y == line.y1 then
        if line.x2 > line.x1 then
            if point.x >= line.x1 and point.x <= line.x2 then
                return true
            else
                return false
            end
        elseif line.x1 > line.x2 then
            if point.x >= line.x2 and point.x <= line.x1 then
                return true
            else
                return false
            end
        else
            -- FIXME
            return false
        end
    else
        return false
    end
end

function pointIntersectsHorizontalLine(point:Point, line:HorizontalLine):boolean
    if point.x == line.x1 then
        if line.y2 > line.y1 then
            if point.y >= line.y1 and point.y <= line.y2 then
                return true
            else
                return false
            end
        elseif line.y1 > line.y2 then
            if point.y >= line.y2 and point.y <= line.y1 then
                return true
            else
                return false
            end
        else
            -- FIXME
            return false
        end
    else
        return false
    end
end

function printGrid(grid:Grid):string
    local str = "\n*** Grid ***\nRows: " .. tostring(grid.rows) .. ", Columns: " .. tostring(grid.cols)
    str = str .. "\n"
    local row, col
    for row=0,grid.rows do
        str = str .. "\n"
        for col=0,grid.cols do
            local gridItem = getGridItemByRowCol(grid.gridItems, row, col)
            local countString = getCountString(gridItem)
            str = str .. countString
        end
    end
    str = str .. "\n"
    return str
end

function getGridItemByRowCol(gridItems:{GridItem}, row:RowIndex, col:ColIndex):GridItem
    local filtered = filter(
        function(item:GridItem):boolean
            return item.row == row and item.col == col
        end,
        gridItems
    )
    return filtered[1]
end

function getCountString(gridItem:GridItem):string
    if gridItem.count == 0 then
        return "  .  "
    elseif gridItem.count < 9 then
        return "  " .. tostring(gridItem.count) .. "  "
    else
        return " " .. tostring(gridItem.count) .. "  "
    end
end

function getMaximumIntersections(grid:Grid):number
    return reduce(
        function(acc:number, item:GridItem):number
            if item.count >= 2 then
                return acc + 1
            else
                return acc
            end
        end,
        0,
        grid.gridItems
    )
end

function getHowManyIntersections(grid:Grid, max:number):number
    return reduce(
        function(acc:number, item:GridItem):number
            if item.count == max then
                return acc + 1
            else
                return acc
            end
        end,
        0,
        grid.gridItems
    )
end

return Vents