-- local pkgpath = string.gsub(...,'%.','/')
-- print('init luachalk',...)
-- package.path = package.path .. ';' .. pkgpath ..'/?.lua;'
local colors_codes = require"lummander.colors"
local Colorizer = {}
Colorizer.__index = Colorizer
Colorizer.__call = function(cls,...)
    return cls.new(...)
end

local ustring = function(value)
    return '\u{001b}['..value..'m'
end

function Colorizer.new(options)
    options = options or {}
    local c = {}
    for color,value in pairs(colors_codes) do
        if(color ~= 'reset') then
            c[color] = function (str)
                return ustring(colors_codes[color])..str..ustring(colors_codes.reset)
            end
            c["p"..color] = function (str)
                io.write(ustring(value)..str..ustring(colors_codes.reset))
                return c
            end
        end
    end
    c.ustr = function(style, str)
        local styles = {}
        for s in string.gmatch(style, "[^%.]+") do
            table.insert(styles, s)
        end
        local style = ''
        for _, sty in ipairs(styles) do
            style = ustring(colors_codes[sty])
        end
        return style..str..ustring(colors_codes.reset)
    end
    c.codes = colors_codes
    -- return setmetatable(c,Colorizer)
    return c
end

return Colorizer.new()
-- return Chalk