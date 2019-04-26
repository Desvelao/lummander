local utils = {string = {}, table = {}}

function utils.string.starts_with(str, sw)
    return str:sub(1, #sw) == sw
end

function utils.string.ends_with(str, sw)
    return str:sub(#str-#sw+1, #str) == sw
end

function utils.string.split(text, patron)
    local split = {}
    for i in string.gmatch(text, patron) do
        table.insert(split,i)
    end
    return split
end

function utils.table.find(array, fn)
    local find = nil
    for i, v in ipairs(array) do
        if fn(v, i, array) then
            find = v
            break
        end
    end
    return find
end

function utils.table.filter(array, fn)
    local new = {}
    for i, v in ipairs(array) do
        if fn(v, i, array) then
            table.insert(new,v)
        end
    end
    return new
end

function utils.table.join(array, sep)
    sep = sep or ""
    local join = ""
    for i,v in ipairs(array) do
        join = join .. ((i > 1 and sep) or "") .. v
    end
    return join
end

function utils.table.for_each(array, fn)
    for i,v in pairs(array) do
        fn(v, i, array)
    end
end

function utils.table.map(array, fn)
    local new = {}
    for i,v in pairs(array) do
        table.insert(new, fn(v, i, array))
    end
    return new
end

function utils.table.includes(array, value)
    local include = false
    for _,v in ipairs(array) do
        if(v == value) then include = true; break end
    end
    return include
end

return utils