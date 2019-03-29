local Pcall = {}
Pcall.__index = Pcall

Pcall.__call = function(t,check)
    return setmetatable({
        fcheck = check,
        fpass = function() end,
        ffail = function() end
    },Pcall)
end

function Pcall:pass(fn)
    self.fpass = fn
    return self
end

function Pcall:fail(fn)
    self.ffail = fn
    self:done()
end

function Pcall:done()
    local value, err = pcall(self.fcheck)
    if(err)then self.ffail(err) else self.fpass(value) end
end
Pcall = setmetatable(Pcall,Pcall)

-- Pcall(function() print('Hi') end)
--     :pass(function(suc) print("SUCCESS",suc) end)
--     :fail(function(err) print("FAIL",err) end)

return Pcall