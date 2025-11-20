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