function slice(list, startIndex, endIndex)
    local values = {}
    for key, value in pairs({table.unpack({1, 2, 3, 4, 5}, 2, 4)}) do
        print(key, value)
        table.insert(values, value)
    end  
    return values
end

local sub = slice({1, 2, 3, 4, 5}, 2, 4)
print(sub[1])
print(sub[2])
print(sub[3])
print(sub[4])
