# IDEAL-Love2D-gamestate
A guideline for a Love2D project that utilizes gamestates. It contains an optimized Love2D gameloop (run function) that has less if-statements and integrates the gamestate system. 

# The System
## 1. Gameloop
The gameloop is a modified and more optimized version of the default ```love.run``` callback function. It cuts the if-statements that check if certain love libraries are avaliable, and defines delta time directly into the update function using ```love.timer.step```. The callback also uses local variables stored outside the gameloop to reduce access-time-complexity in the gameloop and preload section. We see this locality being mainly applied to functions provided by the Love2D library that are called every frame. These include: ```love.graphics.origin```, ```love.graphics.clear```, ```love.graphics.present```, ```love.timer.step```, ```love.graphics.sleep```, ```love.event.pump```, and ```love.event.poll```. 

The gamestate and its primary components are stored in local variables outside the gameloop and inside the callback. We store its ```draw```, ```update```, ```exit```, and ```input-hashmap``` to reduce access-time-complexity in the mainloop. The ```input-hashmap``` is utilized during the event-processing part of the gameloop where it checks if the event-name is hashed to a function inside the hashmap. __Only store proper Love2D callbacks returned by ```love.event.poll``` inside this function__. The

