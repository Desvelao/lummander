local Lummander = require"lummander.lummander"

return setmetatable({
    Lummander = Lummander,
    Command = Command
},{
    __index = Lummander,
    __call = Lummander
})