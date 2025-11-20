# IDEAL-Love2D-gamestate
A guideline for a Love2D project that utilizes gamestates. It contains an optimized [Love2D gameloop](https://love2d.org/wiki/love.run) (run callback) that has less if-statements and integrates the gamestate system. 

# The System
## 1. Gameloop
##### (NOTE: some side-effects that are not relevant to the overall topic will be highlighted at the bottom of this section. Please take a look at these to make sure they fit inline with your design decisions.)

The gameloop is a modified and more optimized version of the default ```love.run``` callback function. It cuts the if-statements that check if certain love libraries are avaliable, and defines delta time directly into the update function using ```love.timer.step```. The callback also uses local variables stored outside the gameloop to reduce access-time-complexity in the gameloop and preload section. We see this locality being mainly applied to functions provided by the Love2D library that are called every frame. These include: ```love.graphics.origin```, ```love.graphics.clear```, ```love.graphics.present```, ```love.timer.step```, ```love.timer.sleep```, ```love.event.pump```, and ```love.event.poll```. 

The gamestate and its primary components are stored locally inside the callback but outside the gameloop. The components we store are its ```draw```, ```update```, ```exit```, and ```input-hashmap``` to remove an additional condition check (referring to accessing the exit function directly inside the gamestate) and reduce access-time-complexity in the gameloop. 
The ```input-hashmap``` is utilized during the event-polling part of the gameloop where it checks if the event name is hashed to a function inside the hashmap. 
__ONLY STORE PROPER LOVE2D CALLBACKS CONTAINED IN__ ```love.handlers``` __INSIDE THIS FUNCTION__.

Inside the callback and under ```--@thread | step```, we call ```love.timer.step()``` which measures the time between two frames. __DO NOT LOAD THINGS UNDER THIS FUNCTION CALL (under ```--@thread | step```), instead put any code that is meant for preloading under the ```--@thread | preload``` tag__. The time measurement will be inaccurate and will influence the ```dt```, or [```deltaTime```](https://en.wikipedia.org/wiki/Delta_timing), which can lead to unpredictable behavior from the gamestate's ```update``` function.

#### Here are some side effects of my implementation that are completely optional to keep: 

- The usage of an external folder to handle the initalization labelled ```source```. If you seek to change this, you must change the code under the ```--@import``` tag in the callback to fit your needs of importing the gamestates table.
```
--@import
    local src = require("source.init")
    local gamestates = src[1]
```
This code is executing the code stored inside the ```init``` file inside of the ```source``` directory which returns a table that stores every single gamestate in an ordered manner.  

As long as the gamestates variable contains a list of recognizable gamestates, the program will run just fine.
An example of another implementation that does not use an external file to fetch gamestates is this:
```
--@import
    local gamestates = {
        {3, function()end, function()end, function()end, function()end, nil}, --menu
        {1, function()end, function()end, function()end, function()end, {keypressed = function(key) print(key) end}) --game
    }
```
- Using ```love.graphics.push("all")``` and ```love.graphics.pop()``` to create a new graphics state every frame to disallow persistent graphical changes across frames. I feel fairly
confident that this can have an impact on performance, but I do not mind this for the benefits it provides. Still, if you seek to remove this, go over to the ```--@draw``` tag listed inside the gameloop and remove the ```lg_push("all")``` and ```lg_pop()``` calls. If you do not intend to use these functions any further in the callback, I suggest removing their local variables under the ```--@auxiliary``` tag.



