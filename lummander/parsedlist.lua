--- ParsedList class is like array but implements some methods
-- @classmod ParsedList
local ParsedList = {}
ParsedList.__index = ParsedList
function create_parsed_list(list)
    list = list or {}
    return setmetatable(list,ParsedList)
end

--- For each
-- @tparam function fn
-- @usage
-- array:for_each(function(value, index, array)
--      -- do something with eah element
-- end)
function ParsedList:for_each(fn)
    utils.table.for_each(t, fn)
end

return create_parsed_list