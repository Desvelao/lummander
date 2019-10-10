--- ThemeColor class. Generated internally by Lummander
-- @classmod ThemeColor
local ThemeColor = {}
ThemeColor.__index = ThemeColor

--- Print with color
-- @tparam string|number text
function ThemeColor:__call(text)
    print(self.color(text))
end

function create_theme_color(color, style)
    --- ThemeColor table
    -- @field color color
    
    --- ThemeColor table
    -- @field style strle
    return setmetatable({color = color, style = style}, ThemeColor)
    
end

return create_theme_color