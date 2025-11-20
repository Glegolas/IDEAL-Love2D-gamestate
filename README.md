# IDEAL-Love2D-gamestate
A guideline for a Love2D project that utilizes gamestates. It contains an optimized [Love2D gameloop](https://love2d.org/wiki/love.run) (run callback) that has less if-statements and integrates the gamestate system. 

# The System
## 1. Gameloop
##### (NOTE: some side-effects that are not that relevant to the overall topic will be highlighted at the bottom. Please take a look at these to make sure they fit inline with your design decisions.)

The gameloop is a modified and more optimized version of the default ```love.run``` callback function. It cuts the if-statements that check if certain love libraries are avaliable, and defines delta time directly into the update function using ```love.timer.step```. The callback also uses local variables stored outside the gameloop to reduce access-time-complexity in the gameloop and preload section. We see this locality being mainly applied to functions provided by the Love2D library that are called every frame. These include: ```love.graphics.origin```, ```love.graphics.clear```, ```love.graphics.present```, ```love.timer.step```, ```love.timer.sleep```, ```love.event.pump```, and ```love.event.poll```. 

The gamestate and its primary components are stored locally inside the callback but outside the gameloop. The components we store are its ```draw```, ```update```, ```exit```, and ```input-hashmap``` to remove an additional condition check (referring to accessing the exit function directly inside the gamestate) and reduce access-time-complexity in the gameloop. 
The ```input-hashmap``` is utilized during the event-polling part of the gameloop where it checks if the event name is hashed to a function inside the hashmap. 
__ONLY STORE PROPER LOVE2D CALLBACKS CONTAINED IN__ ```love.handlers``` __INSIDE THIS FUNCTION__.

Inside the callback and under ```--@thread | step```, we call ```love.timer.step()``` which measures the time between two frames. __Do not load things under this function call, instead put any code that is meant for preloading under the ```--@thread | preload``` tag__. If not, the time will be influenced by how long that code takes which will result in the first frame using ```deltaTime``` being inaccurate; leading to inconsistences when updating. 



