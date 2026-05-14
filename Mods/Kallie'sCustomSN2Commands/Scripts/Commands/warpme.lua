local gotocmd = require("Commands.gotocmd")

local function warpme(args)
    gotocmd({"goto", "lifepod"})
end

return warpme