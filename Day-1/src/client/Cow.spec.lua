return function()
    local Cow = require(script.Parent.Cow)

    describe("ispositive", function()
        it("should say 1 is positive", function()
            local isPositive = Cow:ispositive(1)
            expect(isPositive).to.equal(true)
        end)

        it("should say -4 is not positive", function()
            local isPositive = Cow:ispositive(-4)
            expect(isPositive).to.equal(false)
        end)
    end)
end