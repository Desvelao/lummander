local Command = {}
local utils = require "lummander.utils"
local Colorizer = require "lummander.colorizer"
Command.__index = Command

-- Print Help message
-- @param schema <string> Command schema to parse for extract arguments and their requirements. Default = ""
-- @param options <table> Options. Default = {}
-- @param options.name <table> Options. Default = {}
-- @param options.fn <function> Command Action function. Default = function(...) end. Do nothing.
-- @return Parsed table
function Command.new(schema, config)
    config = config or {}
    config.args = config.args or {}
    -- Create Command table
    local cmd = {
        name = nil,
        description = config.description or "",
        hide = config.hide or true,
        args = {},
        opts = {},
        fn = config.action or function(...) end
    }
    -- Parse schema to extract arguments requirements
    local schema_cmd = Schema_parser(schema)
    utils.table.for_each(schema_cmd,function(v,i,a)
        if(v.type == "cmd" and i == 1)then -- Command argument. Literal. Not support 2 or more literal arguments
            cmd.name = v.name
        elseif(v.type == "req")then -- Argument Required
            table.insert(cmd.args,v) 
        elseif(v.type == "opt")then -- Optional Arguemnt
            table.insert(cmd.args,v)
        end
    end)
    assert(cmd.name,"Command name is required")
    local command = setmetatable(cmd, Command)
    if(config.options)then
        utils.table.for_each(config.options,function(opt,i,a)
            command:option(opt.long, opt.short, opt.description, opt.transform, opt.type, opt.default)
        end)
    end
    return command
end

-- function Command:argument(name, description)
--     assert(name,'arg <name> is required for '.. self.name .. ' command')
--     table.insert(self.args, {name = name, description = description or "", conversor = function(param) return param end})
--     return self
-- end

-- Add a flag option
-- @param @req short <string> Short flag prefixed by "-".
-- @param @req long <string> Long flag prefixed by "--".
-- @param description <string> Flag option description. Default = ""
-- @param transform <function> Transform paramameter before execute Command action. Default = function(param) return param end
-- @return Command instance
function Command:option(long, short, description, transform, type, default)
    assert(short,'opt <short> is required for '.. self.name .. ' command')
    assert(long,'opt <long> is required for '.. self.name .. ' command')
    table.insert(self.opts, {
        short = "-"..short,
        long = "--"..long,
        name = long,
        description = description or "",
        type = type or "normal",
        default = default or false,
        transform = transform or function(param) return param end
    })
    table.sort(self.opts, function(a,b) return a.name < b.name end)
    return self
end

-- Print Command usage
-- @param flag_usage <boolean> Prefix messge with "Usage:".
function Command:usage(flag_usage,lummander_tag)
    if(not self.hide) then return end
    local cmd_prev = ""
    if(flag_usage)then cmd_prev = "Usage:" end
    cmd_prev = cmd_prev .. "  "
    print(cmd_prev..Colorizer.green((lummander_tag and lummander_tag ..' ' or '') ..self:usage_cmd()).." => " .. self.description)
end

function Command:usage_extended(lummander_tag)
    local usage = Colorizer.green((lummander_tag and lummander_tag ..' ' or '') ..self:usage_cmd()).." => " .. self.description .. "\n"
    if (#self.opts > 0) then
        for _, opt in ipairs(self.opts) do
            usage = usage .. "  [".. opt.long .. "/" .. opt.short .. ((opt.type == "normal" and (" " .. opt.name)) or "") .. "]" .. " => " .. opt.description .. (opt.default and " (Default: " .. opt.default .. ")" or "") .. "\n"
        end
    end
    print(usage)
end

function Command:usage_cmd()
    local usage = self.name .. " "
    if (#self.args > 0) then
        for _, argumment in ipairs(self.args) do
            local left, right
            if(argumment.type == "req")then left = "<";right = ">" else left = "[";right = "]" end
            usage = usage .. left .. argumment.name .. right .. " "
        end
    end
    if (#self.opts > 0) then
        for _, opt in ipairs(self.opts) do
            usage = usage .. "[".. opt.long .. "/" .. opt.short .. ((opt.type == "normal" and (" " .. opt.name)) or "") .. "]" .. " "
        end
    end
    return usage
end

-- Add action function to Command
-- @param @req fn <function> Set action function for command. Default: funciton(parsed) end. parsed is a parsed used command
-- @return Command
function Command:action(fn)
    assert(fn,'fn <function> is required for '.. self.name .. ' command')
    self.fn = fn
    return self
end

-- Executa Command Action
-- @param ... is parsed table for this command with input message
-- @return Command Action function value
function Command:run(...)
    return self.fn(...)
end

-- Parse schema command
-- @param @req schema <string> Schema to parse.
-- @return Arguments parsed with type
function Schema_parser(schema)
    local result = {}
    local inputs = utils.string.split(schema,"%S+")
    utils.table.for_each(inputs, function(input)
        local word = input:match("[%w_-]+")
        if(word == input)then
            table.insert(result, argumment_creator(word,"cmd")) -- Command. Literal
        elseif(input == "<" .. word .. ">")then
            table.insert(result, argumment_creator(word,"req")) -- Required Argument
        elseif(input == "[" .. word .. "]")then
            table.insert(result, argumment_creator(word,"opt")) -- Optional arguments
        else
            error("Defining error at command argumment. Schema: ".. schema.. " word: "..word)
        end
    end)
    return result
end

-- Argument creator
-- @param arg <string> Argument name. Default = ""
-- @param type <table> Argument type. Default = ""
-- @return Argument creator {name : table}
function argumment_creator(argumment, type)
    return {name = argumment, type = type}
end

return Command
