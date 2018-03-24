lyaml = require("lyaml")
plterm = require("plterm")

local function welcome(ctx)
    print("+---------------------------------------------------------------+\n")
    print("              Hello "..ctx.conf.author..", welcome ~\n")
    print("+---------------------------------------------------------------+\n")
end

local function getConf(ctx)
    local f = io.open("./conf.yaml", "r")
    local conf = f:read("*a")
    f:close()
    if nil ~= conf and "" ~= conf then
        ctx.conf = lyaml.load(conf)
    end
end

local function writeToFile(ctx, article)
    local date = os.date("*t", os.time())
    local name = string.format("%04d_%02d_%02d", date.year, date.month, date.day)
    local time = string.format("%04d-%02d-%02d %02d:%02d:%02d",
        date.year, date.month, date.day, date.hour, date.min, date.sec)
    local header = time.."|"..ctx.conf.author.."|"
    local prename = ctx.conf.prename or ""
    local sufname = ctx.conf.sufname or ""
    local f = io.open(ctx.conf.notepath.."/"..prename..name..sufname, "a")
    f:write(header..article.."\n")
    f:close()
end

local function main()
    plterm.clear()
    plterm.golc(0, 0)
    local ctx = {}
    getConf(ctx)
    welcome(ctx)

    local text
    local article = {}
    while 1 do
        text = io.read()
        if text == ctx.conf.quitlabel then 
            break 
        end
        table.insert(article, text)
        
    end
    
    writeToFile(ctx, table.concat(article, "\n"))
end

main()
