return function()
    local PowerLevel = require(script.Parent.PowerLevel)
    local input1 = require(script.Parent.input1)

    describe("PowerLevel", function()
        it("should get gamma and epsilon", function()
            local _ = PowerLevel.getGammaAndEpsilon(input1.getInput()):andThen(
                function(results)
                    print("results:", results)
                    expect(results.product).to.equal(749376)
                end
            )
        end)
        it("should get oxygen and co2", function()
            local _ = PowerLevel.getOxygenAndCO2(input1.getInput()):andThen(
                function(results)
                    print("oxygen and CO2 results:", results)
                    expect(results.product).to.equal(2372923)
                end
            )
        end)
    end)
end