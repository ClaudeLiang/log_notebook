lyaml = require("lyaml")
plterm = require("plterm")

HELP_OPT = "--help"
AUTHOR_OPT = "--author="
LEVEL_OPT = "--level="

local function welcome(ctx)
    plterm.clear()
    plterm.golc(0, 0)
    print("+---------------------------------------------------------------+         \n")
    print("              Hello "..ctx.conf.author..", welcome ~                      \n")
    print("+---------------------------------------------------------------+         \n")
    print("+              format: YYYY-MM-DD|author|level|content          +         \n")
    print("+---------------------------------------------------------------+         \n")

end

local function help(ctx)
    print("usage: lua main.lua [options]                                             \n")
    print("Available options are:                                                    \n")
    print("    --help      get help info                                             \n")
    print("    --author    set author, override author in conf.yaml                  \n")
    print("    --level     set level, override level in conf.yaml                    \n")
    print("Format:         YYYY-MM-DD|author|level|content                           \n")
    print("Output files type:                                                        \n")
    print("    .log        log file, use \\n between each line                       \n")
    print("    .dat        dat file, use %0A between each line, for data analysis,   \n")
    print("                also, you can use cat NAME.dat|sed 's/%0A/\\n/g' to read  \n")
end

local function getName(ctx) 
    local date = os.date("*t", os.time())
    local name = string.format("%04d_%02d_%02d", date.year, date.month, date.day)
    local prename = ctx.conf.prename or ""
    local sufname = ctx.conf.sufname or ""
    return ctx.conf.notepath.."/"..prename..name..sufname
end

local function getHeader(ctx)
    local date = os.date("*t", os.time())
    local time = string.format("%04d-%02d-%02d %02d:%02d:%02d",
        date.year, date.month, date.day, date.hour, date.min, date.sec)
    local header = time.."|"..ctx.conf.author.."|"..ctx.conf.level.."|"
    return header
end

local function init(ctx, arg)
    local f = io.open("./conf.yaml", "r")
    local conf = f:read("*a")
    f:close()
    if nil ~= conf and "" ~= conf then
        ctx.conf = lyaml.load(conf)
    else
        ctx.conf = {}
    end
    for k, v in pairs(arg) do
        if string.find(v, HELP_OPT) then
            return 1
        elseif string.find(v, AUTHOR_OPT) then
            ctx.conf.author = string.gsub(v, AUTHOR_OPT, "", 1)
        elseif string.find(v, LEVEL_OPT) then
            ctx.conf.level = string.gsub(v, LEVEL_OPT, "", 1)
        end
    end
    ctx.datF = io.open(getName(ctx)..".dat", "a")
    ctx.datF:write(getHeader(ctx))
    return 0
end

local function destroy(ctx)
    if (ctx.datF) then
        ctx.datF:close()
    end
    os.exit(0)
end

local function writeToViewFile(ctx, article)
    local f = io.open(getName(ctx)..".log", "a")
    f:write(getHeader(ctx)..article.."\n")
    f:close()
    destroy(ctx)
end

local function writeToDatFile(ctx, line)
    ctx.datF:write(line)
    ctx.datF:flush()
end

local function main()
    local ctx = {}
    if init(ctx, arg) == 1 then 
        help(ctx)
        destroy(ctx)
    end
    welcome(ctx)

    local article = {}
    local line = 0
    local total = 0

    while 1 do
        local text = io.read()
        if text == ctx.conf.quitlabel then break end
        if text == ctx.conf.newlinelabel then line = 0 end
        text = tostring(text)
        line = line + 1
        total = total + 1
        if line == 1 and total ~= 1 then
            writeToDatFile(ctx, getHeader(ctx))
            article[total] = getHeader(ctx)
        elseif line == 2 and total ~= 2 then
            writeToDatFile(ctx, text.."%0A")
            total = total - 1
            article[total] = article[total]..text
        else
            writeToDatFile(ctx, text.."%0A")
            article[total] = text
        end
    end
    
    writeToViewFile(ctx, table.concat(article, "\n"))
end

main()
