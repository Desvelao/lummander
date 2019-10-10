# Lummander
Create a simple command-line interface (CLI) application with Lua. It's inspired by JavaScript's [commander](https://github.com/tj/commander.js/).

# Index
- <a href="#features">Features</a>
- <a href="#installation">Installation</a>
- <a href="#usage">Usage</a>
- <a href="#create-instance">Create a instance</a>
- <a href="#add-commands">Add commands</a>
    - <a href="#add-commands-using-lummander">a) Add command using lummander instance methods</a>
        - <a href="#command-schema">Command schema</a>
        - <a href="#command-option">Command option</a>
        - <a href="#command-action">Command action</a>
    - <a href="#add-commands-from-directory">b) Add commands from a directory</a>
        - <a href="#command-file">Command file</a>
- <a href="#command-examples">Command examples</a>
- <a href="#parse-input">Parse input</a>
- <a href="#lummander-instance-methods">Lummander instance methods</a>
    - <a href="#lummander-instance-log">Logs methods</a>
    - <a href="#lummander-instance-advanced">Advanced methods</a>
    - <a href="#lummander-instance-pcall">Pcall</a>
- <a href="#lummander-apply-theme">Theme</a>
- <a href="#cli-to-path">Add the CLI to the PATH</a>

# <div id="features">Features</div>
- Define required positional arguments, optional or flagged options for a command.
- Add commands directly to lummander instance or from a folder.

*Require [LuaFileSystem](https://keplerproject.github.io/luafilesystem/)*

# <div id="installation">Installation</div>

- Using Luarocks:

```bash
luarocks install lummander
```

# <div id="usage">Usage</div>
```lua
-- Require "lummander"
local Lummander = require "lummander"

-- Create a lummander instance
local cli = Lummander.new{
        title = "My Custom App", -- <string> title for CLI. Default: ""
        tag = "myapp", -- <string> CLI Command to execute your program. Default: "". 
        description = "My App description", -- <string> CLI description. Default: ""
        version = "0.1.1" -- <string> CLI version. Default: "0.1.0"
        author = "Myself", -- <string> author. Default: ""
        theme = "acid", -- Default = "default". "default" and "acid" are built-in themes
        flag_prevent_help = false -- <boolean> Prevent help message if not command found. Default: false
    }

-- Add commands
cli:command("mycmd", "My command description")
    :action(function(parsed, command, app)
        print("You activated `mycmd` command")
    end)

cli:command("sum <value1> <value2>", "Sum 2 values")
    :option(
        "option1","o","Option1 description",nil,"normal","option_default_value")
    :option(
        "option2","p","Option2 description",nil,"normal","option2_default_value")
    :action(function(parsed, command, app)
        print("".. parsed.value1.. "+"..parsed.value2.." = " .. (parsed.value1 + parsed.value2))
    end)

-- Parse and execute the command wrote
cli:parse(arg) -- parse arg and execute if a command was written
```

# <div id="create-instance">Create a instance</div>

```lua
local Lummander = require"lummander"

local cli = Lummander.new{
    title = "CLI title",
    tag = "myapp", -- define command to launch this script at terminal
    description = "My App description", -- <string> CLI description. Default: ""
    version = "0.1.1", -- define cli version
    author = "Myself", -- <string> author. Default: ""
    theme = "acid", -- Default = "default". "default" and "acid" are built-in themes
    flag_prevent_help = false -- prevent show help when :parse() doesn't find a valid command to execute
}
```

# <div id="add-commands">Add commands</div>

Ways to add commands:
a. Using lummander instance methods
b. Loading from a folder files what contain a command table defined in lua files.

## <div id="add-commands-using-lummander">a) Add command using lummander instance methods</div>

Create a command with:

```lua
cli:command(schema, description, config)
-- or
cli:command(schema, config)
-- or
cli:command(config)
```

- <a href="#command-schema">schema</a>: string - command schema
- description: string or table - command description
- <a href="#command-config">config</a>: table or nil - command config. Table with <a href="#command-file">fields</a>

*Note: if description is a table, then is treated like config.*

### <div id="command-schema">Command schema</div>
It's a string what should have a main command word. It can have required positional arguments (<>) or optionals ([]).

Example: `mycmd <required_positional_argument1> <required_positional_argument2> [optional_positional_argument1]`

Arguments:
- <argument_name> - Required argument
- [argument_name] - Optional argument
- [argument_name...] - Optional arguments (array)

## Command methods

- <a href="#command-option">`cmd:option(...)`</a>: add a flagged option.
- <a href="#command-action">`cmd:action(fn)`</a>: set a function to execute for this command.

See docs to see more methods.

## <div id="command-option">Command option</div>

Add options to a command with:
```lua
-- only long_name/long and short_name/short are required
cmd:option(long_name, short_name, description, transform, type, default)
-- or 
cmd:option({long, short, description, transform, type, default})
```

- short_name: string - option short name
- long_name: string - option long name
- description: string - option description
- transform: function - transform value received for this option before execute action
- type: `normal` or `flag`. Default `normal`. `flag` is true or false. `normal` can accept a value
- default: option default value (setted by default to `parsed` table)

Example:
```lua
cli:command("mycmd","My cmd description")
    :option("output", "o", "My flagged option description", function(value) return "./"..value..".txt" end, "normal", "my_default_value")

-- You can add multiple options
cli:command("mycmd","My cmd description")
    :option("output", "o", "My flagged option description", function(value) return "./"..value..".txt" end, "normal", "my_default_value")
    :option("mode", "m", "Option mode description")
    :option({long = "confirm", short = "c", description = "No require confirm", type = "flag"}) -- addig with table as first argument
```

You can add so many flagged options like you want.

You can define too this config in a table when you create the command. The example from above would be:

```lua
cli:command("mycmd","My cmd description", {
    options = {
        {long = "output", short = "o", description = "My flagged option description", transform = function(value) return "./"..value..".txt" end, type = "normal", default = "my_defautl_value"}
    }
})

cli:command("mycmd","My cmd description", {
    options = {
        {long = "output", short = "o", description = "My flagged option description", transform = function(value) return "./"..value..".txt" end, type = "normal", default = "my_defautl_value"},
        {long = "mode", short = "m", description = "Option mode description"}
    }
})

-- You can pass command config table in description argument and add to table the description field

cli:command("mycmd", {
    description = "My cmd description", -- includes in command config argument
    options = {
        {long = "output", short = "o", description = "My flagged option description", transform = function(value) return "./"..value..".txt" end, type = "normal", default = "my_defautl_value"}
    }
})
```

## <div name="#command-action">Command action</div>

Set an action to execute when the command is activated.
```lua
cmd:action(fn)
```

- `fn` function - trigger a function when command is activated.

```lua
cmd:action(function(parsed, command, app)
    -- parsed: table with command parsed. Include required positional arguments, optional positional arguments, and flagged options (with long name)
    -- command: command itself
    -- app: lummander instance
end)
```

You can print parsed table with `parsed:print()` to see values that contains.

## <div id="add-commands-from-directory">b) Add commands from a directory</div>

You can add commands from a folder with .lua files.

```lua
cli:commands_dir("folderpath")
```

### <div id="command-file">Command file</div>

The command file interface is:

```lua
-- folderpath/mycmd.lua
return {
    schema = "mycmd <req_arg> [opt_arg]", -- Schema to parse. Required
    description = "Command description", -- Command description
    positional_args = { -- Set description or {description, default} for positional arguments
        req_arg = "A description for a required argument",
        opt_arg = {description = "A description for a optional argument", default = "default_positional_option_value"},
    },
    options = { -- Add flags arguments
        {long = "yes", short = "y", description = "Accept", transform : function(param) end, type = "normal", default = "default_value"} -- same command:option("y","yes", "Accept", function(param) end, "normal", "default_value")
    },
    hide = false, -- hide from help command
    main = true, -- do this command default action to CLI if true. Default = nil = false
    action = function(parsed, command, app) -- same command:action(function)
        parsed:print()
        local sufix = ""
        if(parsed.yes)then sufix = " -y" end
        os.execute("npm init"..sufix)
    end
}
```

*Note: only `schema` is required*

## <div id="command-examples">Command examples</div>

```lua
-- Command with only a command word.
-- Argumments:
    -- - cmd: time

cli:command("time", "Show time")
    :action( -- Join a action to execute
        function(parsed, command, app) -- app is lummander instance
            print(os.date("Time is: %I:%M:%S"))
        end
)

-- Command with only a command word and a required positional argument.
-- Argumments:
    -- - cmd: hi
    -- - req_arg1: name (closed in <> means is required)
cli:command("hi <name>", "Say hi to someone")
    :action(
        function(parsed, command, app)
            -- parsed is a table that includes a field called "name" due to <name> at command schema
            -- <name> is a required positional argument and is needed to trigger this function
            -- parsed = { name }
            print("Hi " ..tostring(parsed.name))
        end
)

-- Command with only a command word, a required positional argument and an option.
-- Argumments:
    -- - cmd: hi
    -- - rea_arg1: name (closed in <> means is required)
    -- - option: hello/h 

cli:command("hi <name>", "Say hello/hi to someone")
    :option("hello", "h","Say hello instead") -- include a option. Example: myapp hi MyName -h. Then parsed.hello = true 
    :action(
        function(parsed, command, app)
            -- parsed = {name, hello}
            local saludation = "Hi"
            if(parsed.hello) then saludation = "Hello" end
            print(saludation .. " " ..tostring(parsed.name))
            -- `hi Lummander` => Hi Lummander
            -- `hi Lummander -h` => Hello Lummander
            -- `hi Lummander --hello` => Hello Lummander
        end
)

-- Command with a command word, 1 required positional argument, 1 optional positional and 1 option 
-- Argumments:
    -- - cmd: hi
    -- - req_arg1: text (closed in <> means is required)
    -- - opt_arg2: othertext (closed in [] means is required)
    -- - option: -o, --output

cli:command("save <text> [othertext]", "Save a file")
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

cli:command("install [packs...]")
    :option("dev", "d", "Set install mode", nil, "flag")
    :action(function(parsed, command, app)
        parsed.packs:for_each(function(pack) -- options like array is a table with special methods
            -- do something with each pack
        end)
    end)
```

## <div id="parse-input">3. Parse input</div>
```lua
cli:parse(arg) -- Parse an table like-array (space/comilla separated arguments). `arg` variable in Lua is an array that contains arguments passed when it executed. This is REQUIRED. Execute a command if is found.

-- cli.parsed property is created after this
```

# <div id="lummander-instance-methods">Lummander instance methods</div>

Note: `cli` is lummander instance.

## <div id="lummander-instance-log">Logs methods</div>

- `cli.log:info(...)`: info log
- `cli.log:warn(...)`: warning log
- `cli.log:error(...)`: error log

## <div id="lummander-instance-advanced">Advanced methods</div>

- `cli:execute(cmd, [fn])`: like os.execute but returns text or callback function with value returned by cmd executed.

```lua
cli:execute("cd", function(value)
    -- do something with value or after terminal execute is finished
end)

-- this is the same:
local value = cli:execute("cd")
-- do something with value or after termnal execute is finished
```

- `cli:find_cmd(cmd_name)`: find a cli command by name

- `cli:action(cmd_name)`: set default action. String or Command. Default (help command)

- <a href="#lummander-apply-theme">`cli:apply_theme(theme)`</a>: apply a theme

- <a href="#lummander-pcall">`cli.pcall(fn)`</a>: execute a function as pcall()

- <a href="http://keplerproject.github.io/luafilesystem/">`cli.lfs`</a>: access to LuaFileSystem

### <div id="lummander-instance-pcall">Lummander.pcall</div>

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

# <div id="lummander-apply-theme">Theme</div>

You can can create a custom theme for your terminal. Styles that you can apply are:

- text color: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- background color: `bgblack`, `bgred`, `bggreen`, `bgyellow`, `bgblue`, `bgmagenta`, `bgcyan`, `bgwhite`
- other: `bold`, `underlined` and `reversed`

Use `cli:apply_theme(theme)` to load it.

Example:
```lua
-- mytheme.lua
return {
    cli = {
        title =  "yellow",
        text = "white",
        category = "yellow"
    },
    command = {
        definition = "green",
        description = "white",
        argument = "yellow",
        option = "yellow",
        category = "red"
    },
    primary = "green",
    secondary = "red",
    success = "green",
    warning = "yellow",
    error = "red"
}
```

*Note: if you dont define some style, this will be `white` by default.*

`cli.theme` print with theme color defined the text
```lua
cli.theme.cli.title(text)
cli.theme.cli.text(text)
cli.theme.cli.category(text)
cli.theme.command.definition(text)
cli.theme.command.description(text)
cli.theme.command.argument(text)
cli.theme.command.option(text)
cli.theme.command.category(text)
cli.theme.primary(text)
cli.theme.secondary(text)
cli.theme.sucess(text)
cli.theme.warning(text)
cli.theme.error(text)
```

# <div id="cli-to-path">Add the CLI to the PATH</div>
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