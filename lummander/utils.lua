local utils = {string = {}, table = {}}

function utils.string.starts_with(str, sw)
    return str:sub(1, #sw) == sw
end

function utils.string.ends_with(str, sw)
    return str:sub(#str-#sw+1, #str) == sw
end

function utils.string.split(text, patron)
    local result = {}
    for i in string.gmatch(text, patron) do
        table.insert(result,i)
    end
    return result
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

function utils.table.join(array, sep)
    sep = sep or ''
    local join = ""
    for _,v in ipairs(array) do
        print(v)
        join = join .. v .. sep
    end
    return join
end

function utils.table.aprint(array)
    table.for_each(array,function(v,i) print(v,i) end)
end

function utils.table.for_each(array, fn)
    for i,v in ipairs(array) do
        fn(v, i, array)
    end
end

function utils.table.includes(array, value)
    local include = false
    for _,v in ipairs(array) do
        if(v == value) then include = true; break end
    end
    return include
end

function utils.pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

return utils