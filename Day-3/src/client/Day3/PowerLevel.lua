-- Excercise 1
-- Guess 1: 2157354, too high
-- Guess 2: 749376... I was using the wrong input1:get() value, my bad...
--
-- Excercise 2
-- Guess 1:


local PowerLevel = {}
local collection = require(script.Parent.Parent.luafp.collection)
local map = collection.map
local reduce = collection.reduce
local String = require(script.Parent.Parent.String)
local Promise = require(script.Parent.Parent.Promise)

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
    return async(String.splitOnNewLines(input))
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

function combineLargestSmallest(countedCharacters) -- [1] =  { ["0"] = 10, ["1"] = 8 }, [2] = { ["0"] = 12, ["1"] = 6 },
    local flattened = {}
    for character, count in pairs(countedCharacters) do
        if flattened[character] == nil then
            flattened[character] = count
        else
            flattened[character].count = flattened[character].count + count
        end
    end
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

function PowerLevel.getGammaAndEpsilon0(input)
    print("PowerLevel:getGammaAndEpsilon:", input)
    local binaryStrings = String.splitOnNewLines(input) -- 1010\n1010\n -> 1010,1010
    local binaryStringLists = map(String.toList, binaryStrings) -- 1010,1010 -> {1,0,1,0}, {1,0,1,0}
    local addedCharactersAtIndices = reduce(addCharactersToPositionalList, {}, binaryStringLists)
    -- {1,0,1,0}, {1,0,1,0} -> 
    -- [5] =  ▼  {
    --     ["0"] =  ▼  {
    --        ["char"] = "0",
    --        ["count"] = 11
    --     },
    --     ["1"] =  ▼  {
    --        ["char"] = "1",
    --        ["count"] = 7
    --     }
    --  },
    local commonChars = reduce(flattenMostCommonCharacters, {}, addedCharactersAtIndices)
    --     ["0"] =  ▼  {
    --        ["char"] = "0",
    --        ["count"] = 401
    --     },
    --     ["1"] =  ▼  {
    --        ["char"] = "1",
    --        ["count"] = 276
    --     }
    local largestCommonCharacter = getLargestCommonCharacter(commonChars)
    print("largestCommonCharacter:", largestCommonCharacter)
    return largestCommonCharacter.char
end

function addCharactersToPositionalList(acc, binaryList)
    local _ = map(
        function(character, index)
            if acc[index] == nil then
                acc[index] = {}
            end
            if acc[index][character] == nil then
                acc[index][character] = { char = character, count = 1 }
            else
                acc[index][character].count = acc[index][character].count + 1
            end
            return character
        end,
        binaryList
    )
    return acc
end

-- [5] =  ▼  {
--     ["0"] =  ▼  {
--        ["char"] = "0",
--        ["count"] = 11
--     },
--     ["1"] =  ▼  {
--        ["char"] = "1",
--        ["count"] = 7
--     }
--  },

function flattenMostCommonCharacters(acc, bitIndiceList)
    -- print("bitIndiceList:", bitIndiceList)
    -- print("acc:", acc, "bitIndiceList:", bitIndiceList)
    for character, characterCount in pairs(bitIndiceList) do
        if acc[character] == nil then
            acc[character] = { char = characterCount.char, count = characterCount.count }
        else
            acc[character].count = acc[character].count + characterCount.count
        end
    end
    return acc
end

function getLargestCommonCharacter(flattenedChars)
    local acc = {}
    for character, charAndCount in pairs(flattenedChars) do
        if acc.char == nil then
            acc.char = character
            acc.count = charAndCount.count
        else
            if charAndCount.count > acc.count then
                acc.char = character
                acc.count = charAndCount.count
            end
        end
    end
    return acc
end

return PowerLevel