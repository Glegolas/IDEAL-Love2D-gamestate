return {

    --@priority
    3,

    --@update
    function(dt)
    end,

    --@draw
    function()
        love.graphics.printf("Menuscreen", 0, 0, 10000, "left")
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