# CH4_ISA_Box_Model
A simple box model for assessing the changes in the methane mixing ratio and it's RF by assuming different trends in emissions. 

# USAGE 
I'm sure in time this could be run on the cloud but for now it should just run if you download the code and run in R. As it states in the header you will require the deSolve library. 

The main aim of this code is to allow you to play around with the coupled CH4-CO-OH system. This is an ideal test case for coupled reactions with feedbacks and my code is inspired by that of Paul Griffiths. Paul has led some box modelling in a nice paper from our team have submitted which includes some nice global modelling led by Ines Heimann too. 

The model will also allow you to have a look at the effects of changing emissions of Cl atoms. Cl atoms can remove methane from the atmosphere and have been proposed as a way of helping prevent methane increases in the future becoming dangerous (for climate!). 

At the moment, the code will allow you to ramp up emissions using a linear scaling factor. This could be useful for exploring what happens to methane if methane emissions increase -- or what happens to methane if CO emissions increase. It's quite fascinating actually. 

Here is an example of some of the output -- in this case looking at drastic increases in methane emissions!
![delCH4](https://user-images.githubusercontent.com/15714566/78791915-5f62d280-79a8-11ea-8076-aba86f848a44.png)

I will try to update the code as I go but note the license details below.

# LICENSE
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to http://unlicense.org/
