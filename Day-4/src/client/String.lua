local String = {}

function String.split(str, match)
    local list = {}
    for i in string.gmatch(str, match) do
        table.insert(list, i)
    end
    return list
end

function String.splitOnNewLines(str)
    return String.split(str, "[^\r\n]+")
end

function String.splitOnContains(str)
    return String.split(str, '[^ contain ]*')
end

function String.toList(str)
    local list = {}
    for i = 1, #str do
        local c = str:sub(i,i)
        table.insert(list, c)
    end    
    return list
end

return String