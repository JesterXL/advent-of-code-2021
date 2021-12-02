local Cow = {}

function Cow:ispositive(x : number) : boolean
    return x > 0
end

return Cow

-- print(ispositive(1))
-- print(ispositive("2"))

-- function isfoo(a)
--     return a == "foo"
-- end

-- print(isfoo("bar"))
-- print(isfoo(1))