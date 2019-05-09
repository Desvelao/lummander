--- Pcall
-- @classmod Pcall
-- @usage
-- Pcall(function()
--      -- code to try
-- end):pass(function()
--      print("Passed!")
-- end):fail(function()
--      print("Failed!")
-- end)


local Pcall = {}
Pcall.__index = Pcall

--- Create a Pcall
-- @tparam table t Check function
-- @tparam function check Check function
-- @treturn Pcall
Pcall.__call = function(t,check)
    return setmetatable({
        fcheck = check,
        fpass = function() end,
        ffail = function() end
    },Pcall)
end

--- Add pass function
-- @tparam function fn function to execute if pass the check function
-- @treturn Pcall
function Pcall:pass(fn)
    self.fpass = fn
    return self
end

--- Add fail function
-- @tparam function fn function to execute if fail the check function
function Pcall:fail(fn)
    self.ffail = fn
    self:done()
end

--- Execute check function
function Pcall:done()
    local status, err = pcall(self.fcheck)
    if(not status)then self.ffail(err, status) else self.fpass(err) end
end

return setmetatable(Pcall,Pcall)
