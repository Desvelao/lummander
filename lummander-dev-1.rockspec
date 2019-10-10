package = "lummander"
version = "dev-1"
source = {
   url = "git://github.com/Desvelao/lummander",
   branch = "dev"
}
description = {
   summary = [[Create a cli. Status: alpha]],
   homepage = "https://github.com/Desvelao/lummander",
   license = "MIT"
}
dependencies = {
   "lua>=5.1",
   "luafilesystem>=1.7.0",
   "chalk=dev-1",
   "ftypes=dev-1"
}
build = {
   type = "builtin",
   modules = {
      ["lummander.command"] = "lummander/command.lua",
      ["lummander.init"] = "lummander/init.lua",
      ["lummander.lummander"] = "lummander/lummander.lua",
      ["lummander.parsed"] = "lummander/parsed.lua",
      ["lummander.pcall"] = "lummander/pcall.lua",
      ["lummander.themecolor"] = "lummander/themecolor.lua",
      ["lummander.themes.acid"] = "lummander/themes/acid.lua",
      ["lummander.themes.default"] = "lummander/themes/default.lua"
   },
   copy_directories = {
      "docs"
   }
}
