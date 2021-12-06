-- Excercise 1
-- Guess 1: 2157354, too high
-- Guess 2: 749376... I was using the wrong input1:get() value, my bad...
--
-- Excercise 2
-- Guess 1: 8188, too low
-- Guess 2: 2372923, algo was foobarred, and Promises are hard


local PowerLevel = {}
local collection = require(script.Parent.Parent.luafp.collection)
local map = collection.map
local reduce = collection.reduce
local filter = collection.filter
local func = require(script.Parent.Parent.luafp.func)
local String = require(script.Parent.Parent.String)
local Promise = require(script.Parent.Parent.Promise)
local BIT_STRING_LENGTH = 12

function PowerLevel.getGammaAndEpsilon(input)
    -- local binaryStrings = String.splitOnNewLines(input)
    return Promise.new(function(resolve, reject, onCancel)
        resolve(input)
    end)
    :andThen(splitInput) -- 1010\n1010\n -> 1010,1010
    :andThen(mapStringToList) -- 1010,1010 -> {1,0,1,0}, {1,0,1,0}
    :andThen(reduceCharactersToIndices) -- {1,0,1,0}, {1,0,1,0} -> {1, 1}, {0, 0}, {1, 1}, {0, 0}
    :andThen(countCharactersOccurence) -- {1, 1}, {0, 0}, {1, 1}, {0, 0} -> [1] =  { ["0"] = 10, ["1"] = 8 }, [2] = { ["0"] = 12, ["1"] = 6 },
    :andThen(combineLargestSmallest)
    :andThen(getLargestAndSmallest)
    :andThen(reformBinary)
end

function async(value)
    return Promise.new(function(resolve)
        resolve(value)
    end)
end

function splitInput(input)
    return String.splitOnNewLines(input)
end

function mapStringToList(binaryStrings)
    return async(map(String.toList, binaryStrings))
end

function reduceCharactersToIndices(binaryStringLists) -- {1,0,1,0}, {1,0,1,0}
    return async(reduce(changeOrder, {}, binaryStringLists))
end

function changeOrder(acc, binaryStringCharacterList)
    local _ = map(
        function(item, index, list)
            if acc[index] == nil then
                acc[index] = {}
            end
            table.insert(acc[index], item)
            return item
        end,
        binaryStringCharacterList
    )
    return acc
end

function countCharactersOccurence(charactersOrdered)
    local mapped = map(
        function(characterList, index, list)
            local counted = reduce(
                function(acc, character)
                    if acc[character] == nil then
                        acc[character] = 1
                    else
                        acc[character] = acc[character] + 1
                    end
                    return acc
                end,
                {},
                characterList
            )
            return counted
        end,
        charactersOrdered
    )
    return async(mapped)
end

function setDefaultsForZeros(countedCharacters)
    local mapped = map(
        function(counted)
            if counted["0"] == nil then
                counted["0"] = 0
            elseif counted["1"] == nil then
                counted["1"] = 0
            end
            return counted
        end,
        countedCharacters
    )
    return async(mapped)
end

function combineLargestSmallest(countedCharacters) -- [1] =  { ["0"] = 10, ["1"] = 8 }, [2] = { ["0"] = 12, ["1"] = 6 },
    local flattened = {}
    for character, count in pairs(countedCharacters) do
        if flattened[character] == nil then
            flattened[character] = count
        else
            flattened[character].count = flattened[character].count + count
        end
    end
    -- print("flattened:", flattened)
    return async(flattened)
end

-- [12] =  ▼  {
--     ["0"] = 9,
--     ["1"] = 9
--  }
function getLargestAndSmallest(countedCombined)
    local mapped = map(
        function(item, index, list)
            local zeroCount = item["0"]
            local oneCount = item["1"]
            if zeroCount > oneCount then
                return { largest = "0", largestCount = zeroCount, smallest = "1", smallestCount = oneCount }
            else
                return { largest = "1", largestCount = oneCount, smallest = "0", smallestCount = zeroCount }
            end
        end,
        countedCombined
    )
    return async(mapped)
end

function reformBinary(largestAndSmallest)
    local largestBinaryString = reduce(
        function(acc, item)
            acc = acc .. item.largest
            return acc
        end,
        "",
        largestAndSmallest
    )
    local smallestBinaryString = reduce(
        function(acc, item)
            acc = acc .. item.smallest
            return acc
        end,
        "",
        largestAndSmallest
    )
    local gamma = tonumber(largestBinaryString, 2)
    local epsilon = tonumber(smallestBinaryString, 2)
    return { 
        largestBinaryString = largestBinaryString, 
        smallestBinaryString = smallestBinaryString, 
        gamma = gamma,
        epsilon = epsilon,
        product = gamma * epsilon
    }
end

function PowerLevel.getOxygenAndCO2(input)
    local bitstringList = splitInput(input)
    return extractOxygenAndCO2(bitstringList)
end

function getCombinedLargestAndSmallest(bitstringList)
    return Promise.new(function(resolve, reject, onCancel)
        resolve(bitstringList)
    end)
    :andThen(mapStringToList) -- 1010,1010 -> {1,0,1,0}, {1,0,1,0}
    :andThen(reduceCharactersToIndices) -- {1,0,1,0}, {1,0,1,0} -> {1, 1}, {0, 0}, {1, 1}, {0, 0}
    :andThen(countCharactersOccurence) -- {1, 1}, {0, 0}, {1, 1}, {0, 0} -> [1] =  { ["0"] = 10, ["1"] = 8 }, [2] = { ["0"] = 12, ["1"] = 6 },
    :andThen(setDefaultsForZeros)
    :andThen(combineLargestSmallest)
    :andThen(getLargestAndSmallestElseEqual)
end

function getLargestAndSmallestElseEqual(countedCombined)
    local mapped = map(
        function(item, index, list)
            -- print("item:", item, "index:", index)
            local zeroCount = item["0"]
            local oneCount = item["1"]
            -- print("zeroCount:", zeroCount, "oneCount:", oneCount)
            assert(type(zeroCount) == "number", "zeroCount is not a number: " .. tostring(#item))
            assert(type(oneCount) == "number", "oneCount is not a number: " .. tostring(#item))
            if zeroCount > oneCount then
                return { equal = false, largest = "0", largestCount = zeroCount, smallest = "1", smallestCount = oneCount }
            elseif zeroCount < oneCount then
                return { equal = false, largest = "1", largestCount = oneCount, smallest = "0", smallestCount = zeroCount }
            else
                return { equal = true, zeroCount = zeroCount, oneCount = oneCount }
            end
        end,
        countedCombined
    )
    return async(mapped)
end

-- [1] =  ▼  {
--     ["largest"] = "1",
--     ["largestCount"] = 511,
--     ["smallest"] = "0",
--     ["smallestCount"] = 489,
--     ["equal"] = false
--  },
--  [2] =  ▼  {
--     ["equal"] = true,
--     ["zeroCount"] = 511,
--     ["oneCount"] = 511
--  },



-- Start with all 12 numbers and consider only the first bit of each number.
-- There are more 1 bits (7) than 0 bits (5), so keep only the 7 numbers with a 1 in the first position: 11110, 10110, 10111, 10101, 11100, 10000, and 11001.

-- Then, consider the second bit of the 7 remaining numbers: there are more 0 bits (4) than 1 bits (3), 
-- so keep only the 4 numbers with a 0 in the second position: 10110, 10111, 10101, and 10000.

-- In the third position, three of the four numbers have a 1, so keep those three: 10110, 10111, and 10101.
-- In the fourth position, two of the three numbers have a 1, so keep those two: 10110 and 10111.
-- In the fifth position, there are an equal number of 0 bits and 1 bits (one each). 
-- So, to find the oxygen generator rating, keep the number with a 1 in that position: 10111.

-- As there is only one number left, stop; the oxygen generator rating is 10111, or 23 in decimal.

function extractOxygen(bitstringList, bitIndex)
    return getCombinedLargestAndSmallest(bitstringList)
    :andThen(
        function(combined)
            return getOxygen(combined, bitstringList, bitIndex)
        end
    )
    :andThen(
        function(oxygen)
            if #oxygen > 1 then
                return extractOxygen(oxygen, bitIndex + 1)
            else
                return oxygen[1]
            end
        end
    )
end

function extractCO2(bitstringList, bitIndex)
    return getCombinedLargestAndSmallest(bitstringList)
    :andThen(
        function(combined)
            return getCO2(combined, bitstringList, bitIndex)
        end
    ):andThen(
        function(co2)
            -- print("co2, co2:", co2)
            if #co2 > 1 then
                return extractCO2(co2, bitIndex + 1)
            else
                return co2[1]
            end
        end
    )
end

function extractOxygenAndCO2(bitstringList)
    return Promise.all({
        extractOxygen(bitstringList, 1),
        extractCO2(bitstringList, 1)
    }):andThen(
        function(oxygenAndCO2)
            local oxygen = oxygenAndCO2[1]
            local co2 = oxygenAndCO2[2]
            local oxygenRating = tonumber(oxygen, 2)
            local co2Rating = tonumber(co2, 2)
            return { 
                oxygenBinary = oxygen, 
                co2Binary = co2,
                oxygenRating = oxygenRating,
                co2Rating = co2Rating,
                product = oxygenRating * co2Rating
            }
        end
    )
end

function getOxygen(combined, bitstringList, bitIndex)
    -- print("getOxygen, #bitstringList:", #bitstringList)
    if #bitstringList <= 1 then return bitstringList end
    local countedItem = combined[bitIndex]
    -- print("countedItem:", countedItem)
    if countedItem.equal == false then
        return filterBits(countedItem.largest, bitIndex, bitstringList)
    else
        return filterBits("1", bitIndex, bitstringList)
    end
end

function filterBits(oneOrZero, index, bitstringList)
    return filter(
        function(bitstring)
            return string.sub(bitstring, index, index) == oneOrZero
        end,
        bitstringList
    )
end

function getCO2(combined, bitstringList, bitIndex)
    if #combined <= 1 then return combined end
    local countedItem = combined[bitIndex]
    if countedItem.equal == false then
        return filterBits(countedItem.smallest, bitIndex, bitstringList)
    else
        return filterBits("0", bitIndex, bitstringList)
    end
end

-- function filterBits(oneOrZero, index, bitstringList)
--     if #bitstringList <= 1 then return bitstringList end
--     return filter(
--         function(bitstring)
--             return string.sub(bitstring, index, index) == oneOrZero
--         end,
--         bitstringList
--     )
--     if index + 1 <= BIT_STRING_LENGTH then
--         return filterBits(oneOrZero, index + 1, filtered)
--     else
--         return filtered
--     end
-- end





return PowerLevel