local M = {}


M.NOTICE = string.format(
    "LuaJIT Runtime (%s)  Copyright (C) 2020 UCA, CNRS/IN2P3, LPC",
    _RUNTIME_VERSION)


-- Set the main program
function M.__main__()
    local interactive, force = true, false

    local function getarg()
        local optstr = arg[1]
        if not optstr then return end
        if #optstr == 1 or string.match(optstr, "^[^-]") then
            interactive = false
            return
        end
        table.remove(arg, 1)
        if optstr == "--" then return end

        local opt = optstr:sub(2, 2)
        if opt == "i" then return opt end

        if #optstr == 2 then
            local optarg = table.remove(arg, 1)
            return opt, optarg
        else
            return opt, optstr:sub(3)
        end
    end

    for opt, optarg in getarg do
        if opt == "e" then
            local chunk, err = loadstring(optarg)
            if err then error(err, 2) end
            chunk()
            interactive = false
        elseif opt == "i" then
            force = true
        elseif opt == "l" then
            require(optarg)
        else
            error("invalid option -" .. opt, 2)
        end
    end

    if not force and not interactive then
        local script = table.remove(arg, 1)
        if script then dofile(script) end
        return
    end

    local inspect = require "inspect"
    local jit = require "jit"
    local ffi = require "ffi"

    local linesep = jit.os == "Windows" and "\r\n" or "\n"

    io.stdout:write(M.NOTICE)
    io.stdout:write(linesep)

    local prompt, read_command = ">> "
    local has_readline, lib = pcall(ffi.load, "readline")
    if has_readline then
        ffi.cdef [[
            const char * rl_readline_name;
            char * readline(const char *);
            void add_history(const char *);
            void free(void *);
        ]]

        lib.rl_readline_name = "pumas"

        read_command = function ()
            local line = lib.readline(prompt)
            if line == nil then return end
            if line[0] ~= 0 then lib.add_history(line) end
            local command = ffi.string(line)
            ffi.C.free(line)
            return command
        end
    else
        read_command = function ()
            io.stdout:write(prompt)
            return io.stdin:read()
        end
    end

    local options = {indent = "", newline = " "}

    while true do
        local command = read_command()
        if not command then break end

        if command:find("^!") then
            os.execute(command:sub(2))
        else
            -- XXX nil should show as "nil"
            local f, result, ok
            f, result = loadstring("return " .. command, "=stdin")
            if result ~= nil then f, result = loadstring(command, "=stdin") end
            if result == nil then ok, result = pcall(f) end
            if result ~= nil then
                io.stdout:write(inspect(result, options))
                io.stdout:write(linesep)
            end
        end
    end
    io.stdout:write(linesep)
end


return M
