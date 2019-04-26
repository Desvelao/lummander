

local Colorizer = require("lummander.colorizer")
local utils = require("lummander.utils")

function Parsed(list)
    list = list or {}
    local mt = {}
    mt.setarg = function(self, key, value) self[key] = value end
    mt.print = function(self) Colorizer.pgreen(stringify(self).."\n") end
    local parsed =
        setmetatable({},{
            __index = mt,
            __newindex = function(self, key, value)
                if(mt[key] == nil)then
                    rawset(self, key, value) 
                else
                    error("Error on Parsed: You can't overwrite the key:" .. tostring(key).."; val:" .. value)
                end
            end,
            __tostring = stringify
        }
    )
    return parsed
end

function stringify(t)
    local str = "<Parsed:"
    local ordered = {}
    for k, v in pairs(t) do
        table.insert(ordered, k)
    end
    table.sort(ordered, function(a,b) return a < b end)
    for _, key in pairs(ordered) do
        local value = t[key]
        if(not (type(value) == "table"))then
            str = str .. " " .. key .. "=" .. tostring(value) ..";"
        else
            str = str .. " " .. key .. "={" .. utils.table.join(value,", ") .. "};"
        end
    end
    return str .. ">"
end

return Parsed