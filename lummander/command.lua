--[[
#Command class file
```lua
```
]]

--- Command data
-- @classmod Command
local Command = {}

local utils = require "lummander.utils"
-- local Colorizer = require "lummander.colorizer"

Command.__index = Command

--- Create a command
-- @tparam string command Command command to parse for extract arguments and their requirements.
-- @tparam[opt={}] table config Options.
-- @tparam[opt=""] string config.description Command description.
-- @tparam[opt] function config.action Command Action function.
-- @tparam {CommandOptions,...} config.options CommandOptions
-- @tparam Lummander lummander CommandOptions
-- @treturn Command
function Command.new(command, config, lummander)
    config = config or {}
    config.arguments = config.arguments or {}
    assert(lummander,"Lummander instance is required")
    -- Create Command table
    local cmd = {
        name = nil, -- setted on cmd:parser if not raise an error
        description = config.description or "",
        hide = (not (config.hide == nil) and config.hide) or false,
        alias = config.alias or {},
        default_args = config.default_args or {},
        arguments = {},
        options = {},
        fn = config.action or function(...) end,
        lummander = lummander
    }
    setmetatable(cmd, Command)
    -- Parse command to extract arguments requirements
    cmd:parser(command, cmd.default_args)
    assert(cmd.name,"Command name is required")
    if(config.options)then
        utils.table.for_each(config.options,function(opt,i,a)
            cmd:option(opt.long, opt.short, opt.description, opt.transform, opt.type, opt.default)
        end)
    end
    return cmd
end

-- function Command:argument(name, description)
--     assert(name,"arg <name> is required for ".. self.name .. " command")
--     table.insert(self.arguments, {name = name, description = description or "", conversor = function(param) return param end})
--     return self
-- end

--- Add a flag option
-- @tparam string long Long flag prefixed by "--".
-- @tparam string short Short flag prefixed by "-".
-- @tparam[opt=""] string description Flag option description. Default = ""
-- @tparam[opt] function transform Transform paramameter before execute Command action.
-- @tparam[opt="normal"] string type_opt Type flag (normal or flag).
-- @tparam[opt] string default Default value.
-- @treturn Command
function Command:option(long, short, description, transform, type_opt, default)
    assert(short,"opt <short> is required for ".. self.name .. " command")
    assert(long,"opt <long> is required for ".. self.name .. " command")
    if(transform)then assert(type(transform) == "function","opt <transform> is not a funciton for ".. self.name .. " command") end 
    -- Command Option
    -- @type CommandOption
    local option = self:option_creator({long = long, short = short, description = description, transform = transform, type = type_opt, default = default})
    table.insert(self.options, option)
    table.sort(self.options, function(a,b) return a.name < b.name end)
    return self
end

--- Set alias for the command
-- @tparam string|table alias Alias to set.
-- @treturn Command
function Command:set_alias(alias)
    asset(type(alias) == "table" or type(alias) == "string", "Alias should be a table (like-array) or a string")
    if(type(alias) == "table")then
        self.alias = alias
    else
        self.alias = {alias}
    end
    return self
end

-- Print Command usage
-- @param boolean flag_usage Prefix messge with "Usage:".
-- @param string lummander_tag Lummander tag.
function Command:usage(flag_usage, lummander_tag)
    if(self.hide) then return end
    local cmd_prev = ""
    if(flag_usage)then cmd_prev = self.lummander.theme.command.category.color("Usage:") end
    cmd_prev = cmd_prev .. "  "
    print(cmd_prev..self.lummander.theme.command.definition.color((lummander_tag and lummander_tag .." " or "") ..self:usage_cmd()).." => " .. self.lummander.theme.command.description.color(self.description))
end

-- Print Command usage extended
-- @param string lummander_tag Lummander tag.
function Command:usage_extended(lummander_tag)
    local usage = self.lummander.theme.command.category.color("Usage: ").. self.lummander.theme.command.definition.color((lummander_tag and lummander_tag .." " or "") ..self:usage_cmd()) --.." => " .. self.description .. "\n"
    usage = usage .. self.lummander.theme.command.category.color("\nName: ") .. self.name
    if(#self.alias > 0) then usage = usage .. self.lummander.theme.command.category.color("; alias: ") .. utils.table.join(self.alias, ", ") end
    usage = usage .. "\n"
    if(#self.description > 0) then usage = usage.. self.lummander.theme.command.category.color("Description: ") .. self.description .. "\n" end 
    if (#self.arguments > 0) then
        usage = usage .. self.lummander.theme.command.category.color("Arguments:\n")
        for _, argument in ipairs(self.arguments) do
            usage = usage .. "  " .. argument:render_extended() .. "\n"
        end
    end
    if (#self.options > 0) then
        usage = usage .. self.lummander.theme.command.category.color("Options:\n")
        utils.table.for_each(self.options, function(opt, index, t)
            usage = usage .. "  " .. opt:render_extended() .. "\n"
        end)
    end
    print(usage)
end

-- Print Command usage cmd

function Command:usage_cmd()
    local usage = self.name .. " "
    if (#self.arguments > 0) then
        for _, argument in ipairs(self.arguments) do
            usage = usage .. argument:render() .. " "
        end
    end
    if (#self.options > 0) then
        utils.table.for_each(self.options,function(opt, index, t)
            usage = usage .. opt:render() .. " "
        end)
    end
    return usage
end

--- Add action function to Command
-- @tparam function fn Set action function for command.
-- @treturn Command
-- @usage
-- cmd:action(
--    function(parsed, command, lum)
--      -- command logic
--      -- parse is Parsed
--      -- command is command itself
--      -- lum is lummander instance
--      print("Hello form command")
-- end)
function Command:action(fn)
    assert(fn,"fn <function> is required for ".. self.name .. " command")
    self.fn = fn
    return self
end

--- Find a option for the command
-- @tparam string option string including - or --
-- @return Option
function Command:has_option(option)
    return utils.table.find(self.options,function(value, index, array)
        if(value.long == opt or value.short == option) then return true end
    end)
end

-- Execute Command Action
-- @param ... is parsed table for this command with input message
-- @return Command Action function value
function Command:run(...)
    return self.fn(...)
end

-- Check parsed table when add a command as default to Lummander
-- @param parsed parsed table for this command
-- @return boolean
function Command:check_parsed(parsed)
    local required = {}
    if (#self.arguments > 0) then -- Parse required and optional arguments
        for _, cmd_arg in ipairs(self.arguments) do
            if(parsed[cmd_arg.name] == nil and cmd_arg.type == "req") then
                table.insert(required, { name = cmd_arg.name, type = cmd_arg.type, typearg = "argument"})
            end
        end
    end
    local err = "Default action has required arguments what are not defined: "
    utils.table.for_each(required, function(value, index, array)
        err = err .. value.name .. ", "
    end)
    if(not(#required == 0))then self.lummander:error(err) end
    return (#required == 0)
end

function Command:names()
    local names = {self.name}
    utils.table.for_each(self.alias, function(alias, index, array)
        table.insert(names, alias)
    end)
    return names
end
-- Parse command command
-- @param @req command <string> command to parse.
-- @return Arguments parsed with type
function Command:parser(command, defaults)
    local result = {}
    local inputs = utils.string.split(command,"%S+")
    utils.table.for_each(inputs, function(input, index)
        local word = input:match("[%w_-]+")
        if(word == input and index == 1)then -- Command
            self.name = word
        elseif(input == "<" .. word .. ">")then -- Required Argument
            table.insert(self.arguments, self:argument_creator({name = word, type = "req", default = defaults[word]}))
        elseif(input == "[" .. word .. "]")then -- Optional arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "opt", default = defaults[word]}))
        elseif(input == "[" .. word .. "...]")then -- Optional List arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "optlist", default = defaults[word]}))
        elseif(input == "[..." .. word .. "]")then -- Optional List arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "optlist", default = defaults[word]}))
        else
            error("Defining command argument. command: ".. command.. " word: "..word)
        end
    end)
    return result
end

-- Argument creator
-- @param arg <string> Argument name. Default = ""
-- @param type <table> Argument type. Default = ""
-- @return Argument creator {name : table}
function argument_creator(argument, type, default)
    return {name = argument, type = type, default = default}
end

function Command:option_creator(options)
    local option = {
        short = "-"..options.short,
        long = "--"..options.long,
        name = options.long,
        description = options.description or "",
        type = options.type or "normal",
        default = options.default,
        file = options.file,
        transform = options.transform or function(param) return param end
    }
    return setmetatable(option, {
        __index = {
            render = function(t) 
                return "[".. t.long .. "/" .. t.short .. ((t.type == "normal" and (" " .. t.name)) or "") .. "]"
            end,
            render_extended = function(t)
                return self.lummander.theme.command.option.color(t:render()) .. " => " .. self.lummander.theme.command.description.color(t.description .. (not (t.default == nil) and " (Default: " .. tostring(t.default) .. ")" or ""))
            end,
        }
    })
end

local Closers = {
    req = {left = "<", right = ">"},
    opt = {left = "[", right = "]"},
    optlist = {left = "[...", right = "]"}
}

Closers.get = function(self, closer)
    return self[closer] or {left = "", right = ""}
end

function Command:argument_creator(options)
    local argument = {
        name = options.name,
        description = options.description or "",
        type = options.type,
        default = options.default,
    }
    return setmetatable(argument, {
        __index = {
            render = function(t)
                local closer = Closers:get(t.type)
                return closer.left .. t.name .. closer.right
            end,
            render_extended = function(t)
                return self.lummander.theme.command.argument.color(t:render()) .. self.lummander.theme.command.description.color(t.default and " (Default: " .. t.default .. ")" or "")
            end,
        }
    })
end

return Command
