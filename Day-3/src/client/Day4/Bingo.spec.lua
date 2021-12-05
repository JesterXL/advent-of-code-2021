return function()
    local Bingo = require(script.Parent.Bingo)
    local input = require(script.Parent.input)

    describe("Bingo", function()
        it("should get a board", function()
            local results = Bingo.playBingo(input.getInput())
            print("results:", results)
            expect(results).to.equal(69579 )
        end)
    end)
end