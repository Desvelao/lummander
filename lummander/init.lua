local Command = require "lummander.command"
local utils = require "lummander.utils"
local Colorizer = require "lummander.colorizer"
local lfs = require "lfs"
local Pcall = require"lummander.pcall"
local Lummander = {}
Lummander.__index = Lummander

--- Create a Lummander instance
-- @param setup <table> Options
-- @param setup.title <string> Title message for your CLI. Default: ""
-- @param setup.tag <string> CLI Command to execute your program. Default: ""
-- @param setup.description <string> CLI description. Default: ""
-- @param setup.version <string> CLI version. Default: "0.0.1"
-- @param setup.prevent_help <boolean> Prevent help message if not command found. Default: false
-- @return Lummander instance
function Lummander.new(setup)
    setup = setup or {}
    local config = {
        title = setup.title or '',
        tag = setup.tag or '',
        description = setup.description or '',
        version = setup.version or '0.1.0',
        root_path = setup.root_path or '',
        prevent_help = setup.prevent_help or false,
        devmode = setup.devmode or false,
        __cmds = {} -- Store commands
    }
    local lummander = setmetatable(config, Lummander)
    
    -- Adding default commands
    -- Help command
    lummander:command('help [cmd]','Help command'):action(function(parsed)
        if(parsed.cmd)then
            local command = lummander:find_cmd(parsed.cmd)
            if(command)then command:usage_extended(lummander.tag) else lummander:help(true) end
        else
            lummander:help(true)
        end
    end)
    -- Version
    lummander:command('v','Version'):action(function(parsed)
        print(lummander.tag .. ": " .. lummander.version)
    end)
    --Version extended
    lummander:command('version','Version'):action(function(parsed)
        print(lummander.tag .. ": " .. lummander.version)
    end)
    
    return lummander
end

-- Create a new command
-- @param schema <string> Parse that string to extract arguments names and their requirement. Default: ""
-- @param description <string|table> Command description. Default: ""
-- @param config <table> CLI Command to execute your program. Default: ""
-- @return Command instance
function Lummander:command(schema, description, config)
    if(type(description) == "table")then
        config = description
    end
    config = config or {}
    if(type(description) == "string" and description)then config.description = description end
    local cmd = Command.new(schema, config) -- Create command with config and store it in a table
    table.insert(self.__cmds, cmd)
    table.sort(self.__cmds, function(a,b) return a.name < b.name end)
    return cmd
end

-- Search a command by name
-- @param name <string> Command name to search at Lummander.__cmds table.
-- @return Command found or nil
function Lummander:find_cmd(cmd_name)
    return utils.table.find(
        self.__cmds,
        function(cmd)
            return cmd.name == cmd_name
        end
    )
end

-- Load command of a directory
-- @param name <string> Command name to search at Lummander.__cmds table.
-- @return Command found or nil
function Lummander:commands_dir(folderpath)
    -- local cwd = lfs.currentdir() .. "\\" .. folderpath
    local base_directory = self.root_path .. "\\" .. folderpath
    for filename,i in lfs.dir(base_directory) do
        if( utils.string.ends_with(filename, ".lua"))then
            -- if not pcall(function()
            --     local data = require(folderpath .. "." .. filename:sub(1,-5))
            --     self:command(data.schema, data.description, data)
            -- end) then
            --     self.warn('Command adding from file', folderpath .. "/" .. filename:sub(1,-5))
            -- end
            self.pcall(function()
                local data = require(folderpath .. "." .. filename:sub(1,-5))
                self:command(data.schema, data.description, data)
            end)
                :fail(function(err)
                    self.error('Command adding from file', folderpath .. "/" .. filename:sub(1,-5).. "\n\t".. err)
                end)
            
        end
    end
    -- local cwd = io.popen"cd":read'*l' .. "\\" .. folderpath
    -- for filename in io.popen("dir \"" .. cwd.. "\" /b"):lines() do
    --     if( utils.string.ends_with(filename, ".lua"))then
    --         if not pcall(function()
    --             local data = require(folderpath .. "." .. filename:sub(1,-5))
    --             self:command(data.schema, data.description, data)
    --         end) then
    --             self.warn('Command adding from file', folderpath .. "/" .. filename:sub(1,-5))
    --         end
            
    --     end
    -- end
    return self
end

-- Parse message
-- @param message <array> Message splited by spaces and "".
-- Execute Command if it is found
-- @return Parsed table
function Lummander:parse(message)
    -- if(type(message) == 'table') then message = table.join(message,"-") end
    local args
    if(type(message) == 'string')then
        args = {}
        local i = 1
        for s in message:gsub(
            '"([^"]+)"',
            function(x)
                return x:gsub("%s+", "\0")
            end
        ):gmatch "%S+" do
            local v = s:gsub("%z+", " ")
                table.insert(args, v)
            -- if (i > 2) then
            --     local v = s:gsub("%z+", " ")
            --     table.insert(args, v)
            -- end
            -- i = i + 1
            -- print( s:gsub("%z+", " ") )
        end
    else
        args = message
    end

    -- Create a table what contains parsed arguments. Add this to Lummander.parsed
    local parsed =
        setmetatable(
        args,
        {
            __index = {
                tostring = function(self) print(self) end,
                print = function(self) Colorizer.pgreen(parsedToString(self).."\n") end
            },
            __tostring = parsedToString
        }
    )
    self.parsed_args = {}
    for _,v in ipairs(args) do
        self.parsed_args[v] = true
    end
    if (not args[1]) then 
        self:help() 
    else
        local cmd = self:find_cmd(args[1]) -- Search a command
        if not cmd then self:help() else -- If not a command found, then execute Lummander:help()
            self:dev(function()
                parsed._cmd = cmd.name
            end)
            local indexarg = 2
            if (#cmd.args > 0) then -- Parse required and optional arguments
                for _, cmd_arg in ipairs(cmd.args) do
                    --   print('arg',args[indexarg],indexarg)
                    if (args[indexarg] and not utils.string.starts_with(args[indexarg],"-")) then
                        parsed[cmd_arg.name] = args[indexarg]
                        indexarg = indexarg + 1
                    else
                        parsed[cmd_arg.name] = nil
                        if(cmd_arg.type == "req")then -- if required argument is missing, then execute Command:usage() to show help usage
                            return cmd:usage(true,self.tag or '')
                        end
                    end
                end
            end
            for ka = indexarg, #args do -- Parse flags arguments
                local a = args[ka]
                local opt = cmd:contains_opt(a)
                if opt then
                    -- local c = a:gsub("-+", "")
                    if (args[ka + 1] and not utils.string.starts_with(args[ka + 1], "-")) then
                        parsed[opt.long:gsub("-+", "")] = opt.transform(args[ka + 1])
                        ka = ka + 2
                    else
                        parsed[opt.long:gsub("-+", "")] = opt.transform(true)
                    end
                end
            end
            self:dev(function() parsed:print() end)
            cmd:run(parsed, cmd, self) -- Execute Command:action(function(parsed)...end)
        end

    end -- if not argumments then execute Lummander:help()
    self.parsed = parsed -- Add parsed to Lummander.parsed
    return parsed
end

function parsedToString(t)
    local str = "<Parsed:"
    for k, v in pairs(t) do
        str = str .. " " .. k .. "=" .. tostring(v) ..";"
    end
    return str .. ">"
end

-- Print Help message
-- @param ignore_flag <boolean> Ignore Lummander prevent_help to show hep message. Default = false
-- If prevent_help option is placed in Lummander init, it ignores print Lummander:help() when it is called
function Lummander:help(ignore_flag)
    if self.prevent_help and not ignore_flag then return end
    print(Colorizer.green(self.title .. " (v" .. self.version .. ")\n") ..[[
----------------------------------------------
]].."\nUsage: "
    .. self.tag .. [[ <command> [options]
        
Commands:]])
    for _, cmd in pairs(self.__cmds) do
        cmd:usage()
    end
end

function Lummander:execute(command, fn)
    local handle = io.popen(command)
    local result = handle:read('*a')
    handle:close()
    if(fn) then fn(result) end
    return result
end

function Lummander:dev(...)
    local fn = ...
    if self.devmode then
        if type(fn) == 'function' then
            fn()
        else
            print(...)
        end
    end
end

function Lummander.__log(tag,color)
    return function(title, message)
        tag = tag or ""
        message = message or ""
        print(Lummander.Colorizer[color](tag..": ").."["..title.. "]: ".. message)
    end
end

Lummander.colorizer = Colorizer -- Insert Colorizer to lummander
Lummander.lfs = lfs -- Insert lfs library
Lummander.pcall = Pcall
Lummander.error = Lummander.__log('Error','red')
Lummander.warn = Lummander.__log('Warning','yellow')
Lummander.log = Lummander.__log('Info','blue')

return Lummander
