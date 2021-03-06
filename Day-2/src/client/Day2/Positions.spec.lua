return function()
    local Positions = require(script.Parent.Positions)
    local input1 = require(script.Parent.input1)

    describe("Positions", function()
        it("should get a product of all positions", function()
            local product = Positions.getProductFromHorizontalAndDepth(input1:getPuzzleInput())
            expect(product).to.equal(1635930)
        end)
        it("should get a product of all positions including aim", function()
            local product = Positions.getProductUsingAim(input1:getPuzzleInput())
            expect(product).to.equal(1781819478)
        end)
    end)

    
end