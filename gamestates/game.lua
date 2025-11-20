return {

    --@priority
    1,

    --@update
    function(dt)
    end,

    --@draw
    function()
        love.graphics.printf("Gamescreen", 0, 0, 10000, "left")
    end,

    --@enter
    function(data, prev)
    end,

    --@exit
    function(data, prev)
    end,

    --@input-hash
    {}

}