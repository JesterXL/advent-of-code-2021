return function()
    local Bingo = require(script.Parent.Bingo)
    local input = require(script.Parent.input)

    describe("Bingo", function()
        it("should get a board", function()
            local results = Bingo.playBingo(input.getInput())
            print("results:", results)
            expect(results).to.equal(69579)
        end)
        it("should get the last winning board", function()
            local results = Bingo.getLastWinningBoard(input.getInput())
            print("results:", results)
            expect(results).to.equal(1)
        end)
    end)
end