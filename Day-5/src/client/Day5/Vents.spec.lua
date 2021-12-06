return function()
    local Vents = require(script.Parent.Vents)
    local input = require(script.Parent.input)

    describe("Vents", function()
        it("should get max crossed lines", function()
            
            local results = Vents.getCrossingLines(input.getInput())
            print("results:", results)
            expect(results).to.equal(5145)
        end)
    end)
end