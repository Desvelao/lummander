--- Command class
-- @classmod Command
local Command = {}

local ftable = require("f.table")
local fstring = require("f.string")

Command.__index = Command

-- Create a command. This function is called by Lummander.
-- @tparam string command Command to parse for extract arguments and their requirements.
-- @tparam[opt={}] table config Options.
-- @tparam[opt=""] string config.description Command description.
-- @tparam[opt={}] table config.positional_args Command description.
-- @tparam[opt] {options} config.options CommandOptions
-- @tparam[opt=false] boolean config.hide Hide from help command
-- @tparam[opt=false] boolean config.main Set as main cli command
-- @tparam[opt] function config.action Command action function.
-- @tparam Lummander lummander CommandOptions
-- @treturn Command
function Command.new(command, config, lummander)
    config = config or {}
    config.arguments = config.arguments or {}
    assert(lummander,"Lummander instance is required")
    -- Create Command table
    local cmd = {
        name = nil, -- setted on cmd:__parser if not raise an error
        description = config.description or "",
        hide = (not (config.hide == nil) and config.hide) or false,
        alias = config.alias or {},
        positional_args = config.positional_args or {},
        arguments = {},
        options = {},
        fn = config.action or function(...) end,
        lummander = lummander
    }
    setmetatable(cmd, Command)
    -- Parse command to extract arguments requirements
    cmd:__parser(command, cmd.positional_args)
    assert(cmd.name,"Command name is required")
    if(config.options)then
        ftable.for_each(config.options,function(opt,i,a)
            cmd:option(opt.long, opt.short, opt.description, opt.transform, opt.type, opt.default)
        end)
    end
    return cmd
end

--- Add action function to Command
-- @tparam function fn Set action function for command.
-- @treturn Command
-- @usage
-- cmd:action(
--    function(parsed, command, lummander)
--      -- command logic
--      -- parse is Parsed
--      -- command is command itself
--      -- lummander is lummander instance
--      print("Hello from command")
-- end)
function Command:action(fn)
    assert(fn,"fn <function> is required for ".. self.name .. " command")
    self.fn = fn
    return self
end

--- Add a argument description
-- @tparam string argname argument name.
-- @tparam string description to set in the argument.
-- @tparam string default to set in the argument.
-- @treturn Command
function Command:argument(argname, description, default)
    assert(argname,"argument for ".. self.name .. " command")
    local argument
    for k,v in pairs(self.arguments)do
        if(v == argname)then
            v.description = (not(description == nil) and description) or v.description
            v.default = (not(default == nil) and default) or v.default
        end
    end
    return self
end

--- Find a option for the command
-- @tparam string option string including - or --
-- @return Option
function Command:has_option(option)
    return ftable.find(self.options,function(value, index, array)
        if(value.long == opt or value.short == option) then return true end
    end)
end

--- Returns a table with command name and alias
-- @treturn table
function Command:names()
    local names = {self.name}
    ftable.for_each(self.alias, function(alias, index, array)
        table.insert(names, alias)
    end)
    return names
end

--- Add a flag option
-- @tparam string long Long flag will be prefixed by "--".
-- @tparam string short Short flag will be prefixed by "-".
-- @tparam[opt=""] string description Flag option description.
-- @tparam[opt] function transform Transform paramameter before execute Command action.
-- @tparam[opt="normal"] string type_opt Type flag (normal or flag).
-- @tparam[opt=nil] string default Default value.
-- @treturn Command
-- @usage
--    cmd:option("optname", "o", "Option description", function(value) return ">" .. value .. "<" end, "normal", "option_default_value")
--    -- or
--    cmd:option({
--       long = "optname",
--        short = "o",
--        description = "Option description",
--        transform = function(value) return ">" .. value .. "<" end,
--        type = "normal",
--        default = "option_default_value"
--    })
--    -- you can add multiple options
--    cmd:option("opt1",...)
--        :option("opt2",...)

function Command:option(long, short, description, transform, type_opt, default)
    assert(long,"opt <long> is required for ".. self.name .. " command")
    local config
    if(type(long) == "table")then
        config = long
    else
        assert(short,"opt <short> is required for ".. self.name .. " command")
        -- if(transform)then assert(type(transform) == "function","opt <transform> is not a function for ".. self.name .. " command") end 
        config = {long = long, short = short, description = description, transform = transform, type = type_opt, default = default}
    end
    -- Command Option
    -- @type CommandOption
    local option = self:option_creator(config)
    table.insert(self.options, option)
    table.sort(self.options, function(a,b) return a.name < b.name end)
    return self
end

-- Execute Command Action
-- @param ... is parsed table for this command with input message
-- @return Command Action function value
function Command:run(...)
    return self.fn(...)
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
-- @tparam boolean flag_usage Prefix messge with "Usage:".
-- @tparam string lummander_tag Lummander tag.
function Command:usage(flag_usage, lummander_tag)
    if(self.hide) then return end
    local cmd_prev = ""
    if(flag_usage)then cmd_prev = self.lummander.theme.command.category.color("Usage:") end
    cmd_prev = cmd_prev .. "  "
    print(cmd_prev..self.lummander.theme.command.definition.color((lummander_tag and lummander_tag .." " or "") ..self:usage_cmd()).." => " .. self.lummander.theme.command.description.color(self.description))
end

-- Print Command usage extended
-- @tparam string lummander_tag Lummander tag.
function Command:usage_extended(lummander_tag)
    local usage = self.lummander.theme.command.category.color("Usage: ").. self.lummander.theme.command.definition.color((lummander_tag and lummander_tag .." " or "") ..self:usage_cmd()) --.." => " .. self.description .. "\n"
    usage = usage .. self.lummander.theme.command.category.color("\nName: ") .. self.name
    if(#self.alias > 0) then usage = usage .. self.lummander.theme.command.category.color("; alias: ") .. ftable.join(self.alias, ", ") end
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
        ftable.for_each(self.options, function(opt, index, t)
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
        ftable.for_each(self.options,function(opt, index, t)
            usage = usage .. opt:render() .. " "
        end)
    end
    return usage
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
    ftable.for_each(required, function(value, index, array)
        err = err .. value.name .. ", "
    end)
    if(not(#required == 0))then self.lummander:error(err) end
    return (#required == 0)
end

-- Parse command command
function Command:__parser(command, defaults)
    local result = {}
    defaults = defaults or {}
    local inputs = fstring.split(command,"%S+")
    ftable.for_each(inputs, function(input, index)
        local word = input:match("[%w_-]+")
        local config = defaults[word]
        if(not(type(config) == "table"))then
            config = {description = (type(config) == "string" and config) or "", default = nil}
        end
        if(word == input and index == 1)then -- Command
            self.name = word
        elseif(input == "<" .. word .. ">")then -- Required Argument
            table.insert(self.arguments, self:argument_creator({name = word, type = "req", description = config.description, default = config.default}))
        elseif(input == "[" .. word .. "]")then -- Optional arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "opt", description = config.description, default = config.default}))
        elseif(input == "[" .. word .. "...]")then -- Optional List arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "optlist", description = config.description, default = config.default}))
        elseif(input == "[..." .. word .. "]")then -- Optional List arguments
            table.insert(self.arguments, self:argument_creator({name = word, type = "optlist", description = config.description, default = config.default}))
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
function argument_creator(argument, description, type, default)
    return {name = argument, description = description, type = type, default = default}
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
        transform = (type(options.transform) == "function" and options.transform) or function(param) return param end
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
                return self.lummander.theme.command.argument.color(t:render()) .. self.lummander.theme.command.description.color(t.description and " " .. t.description or "") ..self.lummander.theme.command.description.color(t.default and " (Default: " .. t.default .. ")" or "")
            end,
        }
    })
end

return Command
