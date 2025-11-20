--@auxiliary
    --//lua
        local clock   = os.clock
        local require = require
        local unpack  = unpack
    --\\
--@thread | define
    local path = "source"

--@thread | run
        

--@thread | deliver
return {
    {
        require("gamestates.menu"),
        require("gamestates.game")
    }
}