--- Parsed. It's a table with a field by each argument and option defined in found command.
-- @classmod Parsed
local chalk = require("chalk")
local ftable = require("f.table")
local Parsed = {}
Parsed.__index = Parsed

-- function Parsed:__newindex(key, value)
--     if(mt[key] == nil)then
--         rawset(self, key, value) 
--     else
--         error("Error on Parsed: You can't overwrite the key:" .. tostring(key).."; val:" .. value)
--     end
-- end

function Parsed:setarg(key, value) self[key] = value end
--- Print Parsed readable table
function Parsed:print() print(chalk.white(stringify(self).."\n")) end
-- Returns Parsed readable table
function Parsed:__tostring() stringify(self) end

function create_parsed(list)
    list = list or {}
    return setmetatable(list,Parsed)
end

function stringify(t)
    local str = "<Parsed:"
    local ordered = {}
    for k, v in pairs(t) do
        table.insert(ordered, k)
    end
    table.sort(ordered, function(a,b) return tostring(a) < tostring(b) end)
    for _, key in pairs(ordered) do
        local value = t[key]
        if(not (type(value) == "table"))then
            str = str .. " " .. key .. "=" .. tostring(value) ..";"
        else
            str = str .. " " .. key .. "={" .. ftable.join(value,", ") .. "};"
        end
    end
    return str .. ">"
end

return create_parsed