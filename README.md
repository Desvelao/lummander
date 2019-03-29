# Lualog
Create a simple command-line interface (CLI) application with Lua. It's inspired by JavaScript's [commander](https://github.com/tj/commander.js/).

# Features
- Define required positional argumments, optional or flagged options for a command.
- Add commands directly to lummander instance or from a folder.

*Require [LuaFileSystem](https://keplerproject.github.io/luafilesystem/)*

# Installation

# Usage
```lua
-- Require "lummander"
local Lummander = require "lummander"

-- Create a lummander instance
local lum = Lummander.new{
        title = "My Custom App", -- <string> title for CLI. Default: ""
        tag = "myapp", -- <string> CLI Command to execute your program. Default: "". 
        description = "My App description", -- <string> CLI description. Default: ""
        version = "0.1.1" -- <string> CLI version. Default: "0.1.0"
        prevent_help = false -- <boolean> Prevent help message if not command found. Default: false
    }

-- Add commands
lum:command("mycmd", "My command description")
    :action(function(parsed, command, lum)
        print("You activated `mycmd` command")
    end)

lum:command("sum <value1> <value2>", "Sum 2 values")
     :action(function(parsed, command, lum)
        print("".. parsed.value1.. "+"..parsed.value2.." = " .. (parsed.value1 + parsed.value2))
     end)

-- Parse and execute the command wrote
lum:parse(arg) -- parse arg and execute if a command was written
```

# Create a instance
```lua
local Lummander = require"lummander"

local lum = Lummander.new{
    title = "CLI title",
    tag = "myapp", -- define command to launch this script at terminal
    description = "My App description", -- <string> CLI description. Default: ""
    version = "0.1.1", -- define cli version
    prevent_help = false -- prevent show help when :parse() doesn't find a valid command to execute
}
```

# Commands

## Adding commands

```lua
lum:command(schema, description, config)
```
- <a href="#command-schema">schema</a>: string - command schema
- description: string or table - command description
- <a href="#command-config">config</a>: table or nil - command config

*Note: if description is a table, then is treated like config.*

## <div name="#command-schema">Command schema</div>
It's a string what should have a main command word. It can have required positional argumments (<>) or optionals ([]).

Example: `mymaincmd <required_positional_argument1> <required_positional_argument2> <optional_positional_argument1>`

## <div name="#command-config">Command configuration</div>
```lua
{
    schema = "mycmd <arg1> <arg2> [opt_arg]", -- ignored if add command with lum:command and taken if load from a file.
    description = "Description for my command", -- string. Default: ""
    hide = false, -- hide from help command. Default: false
    options = {}, -- see Command options
    action = function(parsed, commnad, lum)
        -- command action defined here
    end
}
```
## Command methods

- <a href="#command-option-flag">`cmd:option(...)`</a>: add a flagged option.
- <a href="#command-action">`cmd:action(fn)`</a>: set a function to execute for this command.

See docs to see more methods.

## <div name="#command-options">Command options</div>

```lua
cmd:option(long_name, short_name, description, transform, type, default)
```

- short_name: string - option short name
- long_name: string - option long name
- description: string - option description
- transform: function - transform value received for this option before execute action
- type: `normal` or `flag`. Default `normal`
- default: option default value

Example:
```lua
lum:command("mycmd","My cmd description")
    :option("output", "o", "My flagged option description", function(value) return "./"..value..".txt" end, "normal", "my_default_value")
```

You can add so many flagged options like you want.

You can define too this config in a table when you create the command. The example from above would be:

```lua
lum:command("mycmd","My cmd description", {
    options = {
        {long = "output", short = "o", description = "My flagged option description", transform = function(value) return "./"..value..".txt" end, type = "normal", default = "my_defautl_value"}
    }
})

-- You can pass command config table in description argumment and add to table the description field

lum:command("mycmd", {
    description = "My cmd description", -- includes in command config argumment
    options = {
        {long = "output", short = "o", description = "My flagged option description", transform = function(value) return "./"..value..".txt" end, type = "normal", default = "my_defautl_value"}
    }
})
```

## <div name="#command-action">Command action</div>

Set a action to execute when the command is activated.
```lua
cmd:action(fn)
```

- `fn` function - set a action to execute when the comamnd is activated.

```lua
cmd:action(function(parsed, command, lum)
    -- parsed: table with command parsed. Include required positional argumments, optional positional argumments, and flagged options (with long name)
    -- command: command himself
    -- lum: lummander instance
end)
```

You can print parsed table with `parsed:print()` to see values that contains.

## Add commands from a directory

You can add commands from a folder with .lua files.

```lua
lum:commands_dir("folderpath")
```

### Command file

```lua
-- folderpath/mycommand.lua
return {
    schema = "mycmd <req_arg> [opt_arg]", -- Schema to parse
    description = "Command description", -- Description
    options = { -- Add flags arguments
        {long = "yes", short = "y", description = "Accept", transform : function(param) end} -- same command:option("y","yes", "Accept", function(param) end)
    },
    hide = false, -- hide from help command
    fn = function(parsed, command, lum) -- same command:action(function)
        parsed:print()
        local sufix = ""
        if(parsed.yes)then sufix = " -y" end
        os.execute("npm init"..sufix)
    end
}

```

## Command examples

```lua
-- Command with only a command word.
-- Argumments:
    -- - cmd: time

lum:command("time", "Show time")
    :action( -- Join a action to execute
        function(parsed, command, lum) -- lum is lummander instance
            print(os.date("Time is: %I:%M:%S"))
        end
)

-- Command with only a command word and a required positional argumment.
-- Argumments:
    -- - cmd: hi
    -- - req_arg1: name (closed in <> means is required)
lum:command("hi <name>", "Say hi to someone")
    :action(
        function(parsed, command, lum)
            -- parsed is a table that includes a field called "name" due to <name> at command schema
            -- <name> is a required positional argumment and is needed to trigger this function
            -- parsed = { name }
            print("Hi " ..tostring(parsed.name))
        end
)

-- Command with only a command word, a required positional argumment and an option.
-- Argumments:
    -- - cmd: hi
    -- - rea_arg1: name (closed in <> means is required)
    -- - flag: hello/h 

lum:command("hi <name>", "Say hello/hi to someone")
    :option("hello", "h","Say hello instead") -- include a option. Example: myapp hi MyName -h. Then parsed.hello = true 
    :action(
        function(parsed, command, lum)
            -- parsed = {name, hello}
            local saludation = "Hi"
            if(parsed.hello) then saludation = "Hello" end
            print(saludation .. " " ..tostring(parsed.name))
            -- `hi Lummander` => Hi Lummander
            -- `hi Lummander -h` => Hello Lummander
            -- `hi Lummander --hello` => Hello Lummander
        end
)

-- Command with a command word, 1 required positional argumment, 1 optional positional and 1 option 
-- Argumments:
    -- - cmd: hi
    -- - req_arg1: text (closed in <> means is required)
    -- - opt_arg2: othertext (closed in [] means is required)
    -- - option: -o, --output

lum:command("save <text> [othertext]", "Save a file")
    :option("output", "o", "Output path") 
    :action(
        function(parsed)
            -- parsed = {text, othertext, output}
            local default_path = "mypath/file.txt"
            local filename = parsed.output or default_path
            my_write_file_function(filename, parsed.text)
            -- `save "My text"` => Save a file at default_path
            -- `save "My text" -o otherpath/myotherfile.txt` => Save a file at "otherpath/myotherfile.txt"
            -- `save "My text" --output otherpath/myotherfile.txt` => Save a file at "otherpath/myotherfile.txt"
        end
)
```

# Parsing a message
```lua
lum:parse(arg) -- Parse an table like-array (space/comilla separated arguments). `arg` variable in Lua is an array that contains arguments passed when it executed. This is REQUIRED. Execute a command if is found.

-- lummaner.parsed property is created after this
```

# Lummander instance methods

Note: `lum` is lummander instance.

## Logs methods

- `lum.info(...)`: info log
- `lum.warn(...)`: warning log
- `lum.error(...)`: error log

## Advanced methods

- `lum:execute(cmd, [fn])`: like os.execute but returns text or callback function with value returned by cmd executed.

```lua
lum:execute("cd", function(value)
    -- do something with value or after terminal execute is finished
end)

-- this is the same:
local value = lum:execute("cd")
-- do something with value or after termnal execute is finished
```

- `lum:find_cmd(cmd_name)`: find a lum command by name

- <a href="#lummander-pcall">`lum.pcall(fn)`</a>: execute a function as pcall()

### <div name="#lummander-pcall">Lummander.pcall</div>

- `pcall(fn)`: create a pcall instance with a function to check.
- `pcall:pass(fn)`: function to execute if pcall success.
- `pcall:fail(fn)`: function to execute if pcall failed. Call pcall:done().
- `pcall:done()`: execute the pcall

```lua
lum.pcall(function() -- check function to use in pcall
    print("hi")
    error("Error found on this function")
end)
    :pass(function() -- execute if check function doesn't raise errors
    -- code..
end):fail(function() -- execute if chech function raise some error
    -- code...
end)
```

# Add the CLI to your terminal/console
## Windows
Create a `.bat` or `.cmd` file what contains:

```
lua "absolute_path_to_your_cli_script.lua" %*
```

The name of this file will be CLI command to init your CLI script.

*Note: `lua.exe` should be in a folder what is in os PATH variable, if not, add the folder path to os PATH variable.*

Example:
```
lua "C:/path_to_cli/mycli.lua" %*
```

# License
MIT