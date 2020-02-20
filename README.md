# A LuaJIT Runtime ![Linux](https://github.com/niess/luajit-runtime/workflows/Linux/badge.svg) ![OSX](https://github.com/niess/luajit-runtime/workflows/OSX/badge.svg) ![Windows](https://github.com/niess/luajit-runtime/workflows/Windows/badge.svg)

_Ready to go [LuaJIT][LUAJIT] runtimes are available as [rolling
releases][ROLLING_RELEASES] from the GitHub releases page or from the
[downloads](#downloads) section at the bottom of this page._


## Installation

Installation is as simple as downloading a single executable file. Note that on
_Unix_ systems you also need to explicitly _change the rights_ of the downloaded
file to be executable. For example, using `wget` the following downloads the
runtime and starts an interactive sessions on a `x86_64` Linux:
```
wget -cq https://github.com/niess/luajit-runtime/releases/download/linux/luajit-runtime-x86_64
chmod u+x luajit-runtime-x86_64
./luajit-runtime-x86_64
```

## Content

The runtime uses [OpenResty's LuaJIT 2.1][OPENRESTY_LUAJIT2]. It contains the
standard [LuaJIT extensions][LUAJIT_EXTENSIONS] as well as [OpenResty's
extensions][OPENRESTY_EXTENSIONS]. Note that LuaJIT is compiled with _enhanced
Lua 5.2 compatibility_, i.e. using the `LUAJIT_ENABLE_LUA52COMPAT` macro
definition. In addition, the following packages are also bundled with the
runtime:

- [inspect.lua][INSPECT_LUA] (`require "inspect"`),
- [LuaFileSystem][LUA_FILE_SYSTEM] (`require "lfs"`),
- [LuaSocket][LUASOCKET] (`require "socket"`),
- [strict.lua][STRICT_LUA] (`require "strict"`).


## User packages

The runtime is fully relocatable. Extra user packages are searched relative to
the runtime location. The `_PREFIX` global variable indicates the current
(relocatable) installation prefix. For example, on Unix systems the runtime is
expected to be located under `$PREFIX/bin` while Lua and C packages are searched
under `$PREFIX/share/lua/5.1` and `$PREFIX/lib/lua/5.1`.


## Downloads

[![Linux x86_64](https://img.shields.io/badge/Linux-x86_64-blue.svg)](https://github.com/niess/luajit-runtime/releases/download/linux/luajit-runtime-x86_64)
[![OSX x86_64](https://img.shields.io/badge/OSX-x86_64-blue.svg)](https://github.com/niess/luajit-runtime/releases/download/osx/luajit-runtime-x86_64)
[![Windows x86_64](https://img.shields.io/badge/Windows-x86_64-blue.svg)](https://github.com/niess/luajit-runtime/releases/download/windows/luajit-runtime-x86_64.exe)


[INSPECT_LUA]:          https://github.com/kikito/inspect.lua.git
[LUA_FILE_SYSTEM]:      https://keplerproject.github.io/luafilesystem
[LUAJIT]:               https://luajit.org/luajit.html
[LUAJIT_EXTENSIONS]:    https://luajit.org/extensions.html
[LUASOCKET]:            http://w3.impa.br/~diego/software/luasocket
[OPENRESTY_LUAJIT2]:    https://github.com/openresty/luajit2
[OPENRESTY_EXTENSIONS]: https://github.com/openresty/luajit2#openresty-extensions
[ROLLING_RELEASES]:     https://github.com/niess/luajit-runtime/releases
[STRICT_LUA]:           https://github.com/luapower/luajit/blob/master/strict.lua
