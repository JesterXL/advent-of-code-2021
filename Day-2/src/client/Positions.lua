-- Day 1
-- Guess 1: CORRECT - 1635930

local Positions = {}
local collection = require(script.Parent.luafp.collection)
local map = collection.map
local reduce = collection.reduce
local filter = collection.filter
local array = require(script.Parent.luafp.array)
local slice = array.slice

local Up = "up"
local Down = "down"
local Forward = "forward"

-- I don't think this works. Roblox ignores it, but
-- the Up/Down/Forward work because they're basically string constants.
-- luau-analyze is like "wtf is this"
type Direction = Up | Down | Forward

type Position =  { 
    direction: Direction,
    amount: number
}

type Vector = {
    depth: number,
    horizontal: number
}

function Positions.getProductFromHorizontalAndDepth(inputs)
    local positionStrings = splitString(inputs)
    local positions = map(positionStringToPosition, positionStrings)
    local finalVector = reduce(moveUsingPositions, { depth = 0, horizontal = 0}, positions)
    return finalVector.depth * finalVector.horizontal
end

function splitString(input)
    local lines = {}
    for s in input:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

function positionStringToPosition(positionString:string):Position
    local positionEnumString, value = parsePositionString(positionString)
    if positionEnumString == "up" then
        return { direction = Up, amount = value }
    elseif positionEnumString == "down" then
        return { direction = Down, amount = value }
    elseif positionEnumString == "forward" then
        return { direction = Forward, amount = value }
    else
        error("Unknown position: " .. positionEnumString)
    end
end

function parsePositionString(string:string):(string, number)
    local list = {}
    for w in string:gmatch("%S+") do
        table.insert(list, w)
    end
    return list[1], tonumber(list[2])
end

function moveUsingPositions(vector:Vector, position:Position):Vector
    -- print("vector:", vector, "position:", position)
    if position.direction == Up then
        vector.depth = vector.depth - position.amount
    elseif position.direction == Down then
        vector.depth = vector.depth + position.amount
    elseif position.direction == Forward then
        vector.horizontal = vector.horizontal + position.amount
    else
        error("Unknown direction: " .. position.direction)
    end
    return vector
end


return Positions

