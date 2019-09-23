package = "lummander"
version = "0.1.0-1"
source = {
   url = "git://github.com/Desvelao/lummander",
   tag = "v0.1.0"
}
description = {
   summary = [[Create a cli. Status: alpha]],
   homepage = "https://github.com/Desvelao/lummander",
   license = "MIT"
}
dependencies = {
   "lua>=5.1",
   "luafilesystem>=1.7.0"
}
build = {
   type = "builtin",
   modules = {
      ["lummander.colorizer"] = "lummander/colorizer.lua",
      ["lummander.command"] = "lummander/command.lua",
      ["lummander.init"] = "lummander/init.lua",
      ["lummander.lummander"] = "lummander/lummander.lua",
      ["lummander.parsed"] = "lummander/parsed.lua",
      ["lummander.parsedlist"] = "lummander/parsedlist.lua",
      ["lummander.pcall"] = "lummander/pcall.lua",
      ["lummander.themecolor"] = "lummander/themecolor.lua",
      ["lummander.themes.acid"] = "lummander/themes/acid.lua",
      ["lummander.themes.default"] = "lummander/themes/default.lua",
      ["lummander.utils"] = "lummander/utils.lua"
   },
   copy_directories = {
      "docs"
   }
}
