-- Challenge 1
-- Guess 1: 4396, too low
-- Guess 2: 52965, fixed marked logic, but still too low
-- Guess 3: 69579 - finally! Types for the win. They found all kind of parsing bugs and mispellings.

local Bingo = {}
local array = require(script.Parent.Parent.luafp.array)
local tail = array.tail
-- local fill = array.fill
local collection = require(script.Parent.Parent.luafp.collection)
local map = collection.map
local reduce = collection.reduce
local filter = collection.filter
-- local some = collection.some
local every = collection.every
local ROWS = 5
local COLS = 5

function Bingo.playBingo(input)
    local data = input:split("\n\n")
    local numberStrings = data[1]:split(",")
    local numbers = map(
        function(numberString)
            return tonumber(numberString)
        end, 
        numberStrings
    )
    local boardStrings = tail(data)
    local boards = getBoardsFromStrings(boardStrings)
    -- print("boards:", boards)
    local gameResult = reduce(
        function(acc, number)
            if acc.winner == false then
                print("drawing number:", number)
                acc.boards = drawNumber(number, acc.boards)
                -- Did anyone win?
                local rowWinningUnmarkedNumbers = getAnyBoardWinnerUnmarkedRowNumbers(acc.boards)
                local colWinningUnmarkedNumbers = getAnyBoardWinnerUnmarkedColNumbers(acc.boards)
                if rowWinningUnmarkedNumbers ~= nil and #rowWinningUnmarkedNumbers > 0 then
                    print("Found some row winner(s)!")
                    local firstRowWinner = rowWinningUnmarkedNumbers[1]
                    acc.winner = true
                    acc.allUnmarkedNumbers = firstRowWinner.unmarked
                    acc.latestNumber = number
                    acc.board = firstRowWinner.board
                    return acc
                elseif colWinningUnmarkedNumbers ~= nil and #colWinningUnmarkedNumbers > 0 then
                    print("Found some col winner(s)!")
                    local firstColWinner = colWinningUnmarkedNumbers[1]
                    acc.winner = true
                    acc.allUnmarkedNumbers = firstColWinner.unmarked
                    acc.latestNumber = number
                    acc.board = firstColWinner.board
                    return acc
                else
                    print("No winner(s) yet.")
                    return acc
                end
            else
                return acc
            end
        end,
        { winner = false, boards = boards },
        numbers
    )
    -- print("gameResult.winner:", gameResult.winner)
    if gameResult.winner == true then
        print("*** Winning Board ***")
        printBoard(gameResult.board)
        local total = reduce(
            function(acc, item)
                return acc + item
            end,
            0,
            gameResult.allUnmarkedNumbers
        )
        print("total:", total, "gameResult.latestNumber:", gameResult.latestNumber, "product:", (total * gameResult.latestNumber))
        return total * gameResult.latestNumber
    else
        printAllBoards(gameResult.boards)
        return 0
    end
end

function getBoardsFromStrings(boardStrings:{string}):{Board}
   return map(getBoard, boardStrings)
end

function printBoard(board:Board):string
    local row
    local col
    local index = 0
    local str = "\n"
    for row=1,ROWS do
        for col=1,COLS do
            index = index + 1
            local boardItem = board[index]
            str = str .. numberToMonostring(boardItem.number) .. ":" .. booleanToCharacter(boardItem.marked) .. " "
        end
        str = str .. "\n"
    end
    print(str)
    return str
end

function numberToMonostring(number:number?):string
    if number == nil then
        return "??"
    elseif number < 10 then
        return " " .. tostring(number)
    elseif number >= 10 then
        return tostring(number)
    else
        return "!!"
    end
end

function booleanToCharacter(bool:boolean):string
    if bool == true then
        return "t"
    else
        return "f"
    end
end

function printAllBoards(boards:{Board}):{string}
    local strings = map(
        function(board:Board):string
            return printBoard(board)
        end,
        boards
    )
    return strings
end

function getTabs(howMany)
    local i
    local tabs = ""
    for i=1,howMany do
        tabs = tabs .. "\t"
    end
    return tabs
end

-- 34 90 18 33 83
-- 27  7 25 61 15
-- 43  5 51 32 45
-- 24 17 72 31 22
-- 77 46 78 16  9
type RowIndex = number
type ColIndex = number
type BoardItem = {
    number: number,
    colIndex: ColIndex,
    rowIndex: RowIndex,
    marked: boolean
}
type Board = {BoardItem}

function getBoard(stringInput:string):Board
    assert(type(stringInput) == "string", "stringInput is not a string")
    assert(stringInput ~= "", "stringInput is an empty string")
    local boards = {}
    local row
    local col
    local boardStrings = stringInput:split('\n')
    for row=1,#boardStrings do
        local numberString = boardStrings[row]
        local cols = parseColumnString(numberString)
        for col=1,#cols do
            local num = cols[col]
            local board = createBoard(num, col, row, false)
            table.insert(boards, board)
        end
    end
    return boards
end

function parseColumnString(numberString:string):{string}
    local cols = numberString:split(' ')
    print("cols:", cols)
    local filtered = filter(
        function(item:string):boolean
            if item == "" then
                return false
            else
                return true
            end
        end,
        cols
    )
    assert(#filtered == COLS, "Parsed columns do not match COLS. Filtered length: " .. tostring(#filtered) .. ", COLS: " .. tostring(COLS) .. ", and cols:" .. printTable(cols))
    return filtered
end

function printTable(table)
    local str = ""
    for key in ipairs(table) do
        str = str .. tostring(key) .. ","
    end
    return str
end

function createBoard(num:string?, colIndex:number?, rowIndex:number?, marked:boolean?):Board
    assert(type(num) == "string", "num is a not a string.")
    assert(num ~= "", "Num is a blank string.")

    assert(type(colIndex) == "number", "colIndex is not a number.")
    assert(colIndex >= 1, "colIndex is not 1 or above.")
    assert(colIndex <= COLS, "colIndex is greater than allowable COLS")

    assert(type(rowIndex) == "number", "rowIndex is not a number.")
    assert(rowIndex >= 1, "rowIndex is not 1 or above.")
    assert(rowIndex <= ROWS, "rowIndex is greater than allowable ROWS")

    assert(type(marked) == "boolean", "marked is not a boolean")

    local number = tonumber(num)
    assert(type(number) == "number", "Parsed number is not a number. Parsing failed somehow.")
    assert(number >= 0, "Number is not 0 or greater.")

    return { number = number, colIndex = colIndex, rowIndex = rowIndex, marked = false }
end

function drawNumber(number, boards)
    return map(
        function(board)
            return markNumberOnBoard(number, board)
        end,
        boards
    )
end

function markNumberOnBoard(number, board)
    -- print("markNumberOnBoard:", board)
    return map(
        function(boardNumber)
            -- print("boardNumber:", boardNumber)
            -- print("boardNumber:", boardNumber.number, "number:",number)
            if boardNumber.number == number then
                -- print("found a match, number:", number)
                boardNumber.marked = true
                return boardNumber
            else
                return boardNumber
            end
        end,
        board
    )
end

function boardRowAllMarkedByIndex(board, rowIndex)
    local matchingRows = filterBoardItemsByRowIndex(board, rowIndex)
    return allBoardItemsAreMarked(matchingRows)
end

function filterBoardItemsByRowIndex(board:Board, rowIndex:RowIndex)
    return filter(
        function(boardItem:BoardItem):boolean
            return boardItemMatchesRowIndex(boardItem, rowIndex)
        end,
        board
    )
end

function boardItemMatchesRowIndex(boardItem:BoardItem, rowIndex:RowIndex):boolean
    return boardItem.rowIndex == rowIndex
end

function allBoardItemsAreMarked(boardItems:{BoardItem}):boolean
    return every(
        function(boardItem:BoardItem):boolean
            return boardItem.marked == true
        end,
        boardItems
    )
end

type WinnerFound = {
    winner:Board?
}

function boardRowAllMarked(board:Board):{number} | nil
    local anyWinner = reduce(
        function(acc:WinnerFound, rowIndex:RowIndex)
            return reduceRowWinner(board, acc, rowIndex)
        end,
        {},
        {1, 2, 3, 4, 5}
    )
    if anyWinner.winner ~= nil then
        return getAllUnmarkedNumbersOnBoard(anyWinner.winner)
    else
        return nil
    end
end

function reduceRowWinner(board:Board, acc:WinnerFound, rowIndex:RowIndex):WinnerFound
    if acc.winner == nil then
        if boardRowAllMarkedByIndex(board, rowIndex) == true then
            acc.winner = board
            return acc
        else
            return acc
        end
    else
        return acc
    end
end

type WinningBoard = {
    board:Board,
    unmarked:{number}
}

function getAnyBoardWinnerUnmarkedRowNumbers(boards:{Board}):{WinningBoard}
    return reduce(
        function(acc:WinningBoard, board:Board)
            return reduceRowWinningBoards(acc, board)
        end,
        {},
        boards
    )
end

function reduceRowWinningBoards(acc:{WinningBoard}, board:Board):{WinningBoard}
    local unmarked = boardRowAllMarked(board)
    if unmarked ~= nil then 
        table.insert(acc, { board = board, unmarked = unmarked })
        return acc
    else
        return acc
    end
end

-- function getAllBoardIndices(rows, cols)
--     local row
--     local col
--     local boardIndices = {}
--     for row=1,rows do
--         for col=1,cols do
--             table.insert(boardIndices, { row = row, col = col })
--         end
--     end
--     return boardIndices
-- end

function boardColAllMarkedByIndex(board, colIndex)
    local cols = filter(
        function(boardItem)
            return boardItem.colIndex == colIndex
        end,
        board
    )
    return every(
        function(boardNumber)
            return boardNumber.marked
        end,
        cols
    )
end

function boardColAllMarked(board:Board):{number} | nil
    local anyWinner = reduce(
        function(acc:WinnerFound, colIndex:ColIndex)
            return reduceColWinner(board, acc, colIndex)
        end,
        {},
        {1, 2, 3, 4, 5}
    )
    if anyWinner.winner ~= nil then
        return getAllUnmarkedNumbersOnBoard(anyWinner.winner)
    else
        return nil
    end
end

function reduceColWinner(board:Board, acc:WinnerFound, colIndex:ColIndex):WinnerFound
    if acc.winner == nil then
        if boardColAllMarkedByIndex(board, colIndex) == true then
            acc.winner = board
            return acc
        else
            return acc
        end
    else
        return acc
    end
end

function getAnyBoardWinnerUnmarkedColNumbers(boards:{Board}):{WinningBoard}
    return reduce(
        function(acc:WinningBoard, board:Board)
            return reduceColWinningBoards(acc, board)
        end,
        {},
        boards
    )
end

function reduceColWinningBoards(acc:{WinningBoard}, board:Board):{WinningBoard}
    local unmarked = boardColAllMarked(board)
    if unmarked ~= nil then 
        table.insert(acc, { board = board, unmarked = unmarked })
        return acc
    else
        return acc
    end
end

function getAllUnmarkedNumbersOnBoard(board:Board):{number}
    local filtered = getUnmarkedBoardNumbers(board)
    return mapBoardItemsToNumbers(filtered)
end

function getUnmarkedBoardNumbers(board:Board):{BoardItem}
    return filter(
        function(boardItem:BoardItem):boolean
            return boardItem.marked == false
        end,
        board
    )
end

function mapBoardItemsToNumbers(boardItems:{BoardItem}):{number}
    return map(
        function(boardNumber:BoardItem)
            return boardNumber.number
        end,
        boardItems
    )
end

return Bingo