# IDEAL-Love2D-gamestate
A guideline for a Love2D project that utilizes gamestates. It contains an optimized [Love2D gameloop](https://love2d.org/wiki/love.run) (run callback) that has less if-statements and integrates the gamestate system. 

###### (NOTE: This documentation assumes the user has some knowledge of basic programming concepts, LOVE2D, and LUA)
###### (NOTE: The mentions of 'tags' and 'sub-tags' are not actual syntax of the programming language used here, but rather are reference points for people looking at my code)

# The System
## 1. Gameloop
```lua
--[[
    PROGRAMMED AS OF 11/20/2025
--]]

--@thread | load
love.run = function()

    --@import
        local src = require("source.init")
        local gamestates = src[1]

    --@auxiliary
        --//love
            --@event
            local le_poll = love.event.poll
            local le_pump = love.event.pump

            --@timer
            local lt_step = love.timer.step
            local lt_sleep = love.timer.sleep

            --@graphics
            local lg_origin = love.graphics.origin
            local lg_present = love.graphics.present
            local lg_clear = love.graphics.clear
            local lg_push = love.graphics.push
            local lg_pop = love.graphics.pop
        --\\

    --@thread | define
        --//enums
            local __def_evts__  = {}
        --\\
        --//gamestate
            local _gs, _qgs, _draw, _update, _exit, _evts = nil, nil, nil, nil, nil, __def_evts__
            local function SwitchGamestate(index, data)
                -- Define our next gamestate
                local _ngs = gamestates[index]

                -- Exit from the original gamestate 
                if _exit then _exit(data, _ngs) end

                -- Enter from the next gamestate
                if _ngs[4] then _ngs[4](data, _gs) end

                -- Finalize our switch
                _update = _ngs[2]
                _draw   = _ngs[3]
                _exit   = _ngs[5]
                _evts   = _ngs[6] or __def_evts__
                _gs  = _ngs
                _qgs = nil
            end
            _G.SwitchGamestate = SwitchGamestate

            local function DeferGamestate(index, data)

                -- Define priority.
                -- Our priority by default is fetched from the gamestate, but
                -- can be overloaded by a priority in our data packet.
                local _p = (data and data.priority) or gamestates[index][1]

                -- If there is not a queued gamestate, we don't care about comparing
                -- queue priority.
                if not _qgs then
                    _qgs = {index, _p, data}
                    return true
                end
                
                -- If there is already a queued gamestate, we will compare
                -- the priorities. (lowest & equal priority = overtake; higher priority = keep original)
                if _p >= _qgs[2] then
                    _qgs[1] = index
                    _qgs[2] = _p
                    _qgs[3] = data
                    return true
                end

                return false
            end
            _G.DeferGamestate = DeferGamestate
        --\\
    --@thread | preload
        SwitchGamestate(1)

    --@thread | step
        lt_step()

    --@thread | run
    return function()

        --//event
            le_pump()
            for name, a, b, c, d, e, f in le_poll() do
                if _evts[name] then _evts[name](a, b, c, d, e, f) end
                if name == "quit" then return a or 0 end
            end
        --\\
        --//update
            if _qgs then
                -- Define our essential variables
                local _i, _d = _qgs[1], _qgs[3] -- input, data
                local _ngs = gamestates[_i] -- next gamestate

                -- Exit from the original gamestate
                if _exit then _exit(_d, _ngs) end
                
                -- Enter to the next gamestate
                if _ngs[4] then _ngs[4](_d, _gs) end

                -- Finalize our switch
                _update = _ngs[2]
                _draw   = _ngs[3]
                _exit   = _ngs[5]
                _evts   = _ngs[6] or __def_evts__
                _gs  = _ngs
                _qgs = nil
            end

            _update(lt_step())
        --\\
        --//draw
            lg_origin()
            lg_clear(0, 0, 0)
            lg_push("all")
            _draw()
            lg_pop()
            lg_present()
        --\\

        lt_sleep(0.001)
        
    end 

end
```
The gameloop is a modified and more optimized version of the default ```love.run``` callback function. It cuts the if-statements that check if certain love libraries are avaliable, and defines delta time directly into the update function using ```love.timer.step```. The callback also uses local variables stored outside the gameloop to reduce access-time-complexity in the gameloop and preload section. We see this locality being mainly applied to functions provided by the Love2D library that are called every frame. These include: ```love.graphics.origin```, ```love.graphics.clear```, ```love.graphics.present```, ```love.timer.step```, ```love.timer.sleep```, ```love.event.pump```, and ```love.event.poll```. 

The gamestate and its primary components are stored locally inside the callback but outside the gameloop. The components we store are its ```draw```, ```update```, ```exit```, and ```input-hashmap``` to remove an additional condition check (referring to accessing the exit function directly inside the gamestate) and reduce access-time-complexity in the gameloop. 
The ```input-hashmap``` is utilized during the event-polling part of the gameloop where it checks if the event name is hashed to a function inside the hashmap. 
__ONLY STORE PROPER LOVE2D CALLBACKS CONTAINED IN__ ```love.handlers``` __INSIDE THIS FUNCTION__.

Inside the callback and under ```--@thread | step```, we call ```love.timer.step()``` which measures the time between two frames. __DO NOT LOAD THINGS UNDER THIS FUNCTION CALL (under__ ```--@thread | step``` __), instead put any code that is meant for preloading under the__ ```--@thread | preload``` __tag__. The time measurement will be inaccurate and will influence the ```dt```, or [```deltaTime```](https://en.wikipedia.org/wiki/Delta_timing), which can lead to unpredictable behavior from the gamestate's ```update``` function.

## 2. Setting The Gamestate
While I could've just put this under gameloop, it is important to highlight the distinctions between of the global functions ```DeferGamestate``` and ```SwitchGamestate```, and to explain the gamestate-queueing system. 

The gamestate-queueing system is madeup of a couple of components. The first set of components are defined under the  ```--@auxiliary --//define``` subtag that 

#### DeferGamestate
- A function that 

## 3. Gamestate
```lua
--[[
    PROGRAMMED AS OF 11/20/2025
]]
--@thread | runtime
-- reserved for anything during runtime.

--@thread | class
return {
    0, -- priority (the greater value overtakes other gamestates in queue)

    --@update
    function(dt)
    end,

    --@draw
    function()
    end,

    --@enter (optional)
    function()
    end,

    --@exit  (optional)
    function()
    end,

    --@input-map (optional)
    {
        keypressed = function(key)
            print("Test!")
        end
    }
}
```
## Side Effects Of This System:
- Every gamestate will abide by a [singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). Any changes made during a gamestate's processes are persistent and require maintenance from either the ```exit``` or ```enter``` callbacks (functions 5 and 4).
- The gamestate must be an ordered list that contains their required priority and callback functions. This means that we can only have sequential numbers as indices inside the gamestate. This is to ensure that access-time-complexity is as optimal as possible.
- The gamestate's callback functions are not self-referential. They are intended to reference from an external scope, either global or local, which cuts an additional argument for the callbacks (the argument containing the self-reference) and removes any overhead from accessing the callback function in the gameloop by directly calling it from a local variable.

## (Optional) Side Effects Of This Template:
###### (NOTE: feel free to remove or keep any of these)
- The usage of an external folder to handle the initalization labelled ```source```. If you seek to change this, you must change the code under the ```--@import``` tag in the callback to fit your needs of importing the gamestates table.
```lua
--@import
    local src = require("source.init")
    local gamestates = src[1]
```
This code is executing the code stored inside the ```init``` file inside of the ```source``` directory which returns a table that stores every single gamestate in an ordered manner.  
```lua
--[[
    INSIDE VIEW OF "source.init"
--]]
--@auxiliary
    --//lua
        local require = require
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
```

As long as the gamestates variable contains a list of recognizable gamestates, the program will run just fine.
An example of another implementation that does not use an external file to fetch gamestates is this:
```lua
--@import
    local gamestates = {
        {3, function()end, function()end, function()end, function()end, nil}, --menu
        {1, function()end, function()end, function()end, function()end, {keypressed = function(key) print(key) end}) --game
    }
```
- Using ```love.graphics.push("all")``` and ```love.graphics.pop()``` to create a new graphics state every frame to disallow persistent graphical changes across frames. I feel fairly
confident that this can have an impact on performance, but I do not mind this for the benefits it provides. Still, if you seek to remove this, go over to the ```--@draw``` tag listed inside the gameloop and remove the ```lg_push("all")``` and ```lg_pop()``` calls. If you do not intend to use these functions any further in the callback, I suggest removing their local variables under the ```--@auxiliary``` tag.
