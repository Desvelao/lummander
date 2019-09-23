package = "lummander"
version = "scm-1"
source = {
   url = "git+https://github.com/Desvelao/lummander.git",
   tag = "scm-1"
}
description = {
   summary = [[Create cli]],
   homepage = "https://github.com/Desvelao/lummander",
   license = "MIT"
}
dependencies = {
   "lua>=5.1",
   "lfs>=1.7.0"
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
