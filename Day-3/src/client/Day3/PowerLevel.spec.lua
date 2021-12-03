return function()
    local PowerLevel = require(script.Parent.PowerLevel)
    local input1 = require(script.Parent.input1)

    describe("PowerLevel", function()
        it("should get gamma and epsilon", function()
            local gamma, epsilon = PowerLevel.getGammaAndEpsilon(input1.getInput()):andThen(
                function(results)
                    -- print("results:", results)
                    expect(results.product).to.equal(749376)
                end
            )
            
        end)
    end)
end