# model

Elegant Mathematica-style model manipulation and fitting in MATLAB 

## What this is

`model` is a MATLAB [abstract class](https://www.mathworks.com/help/matlab/matlab_oop/abstract-classes-and-interfaces.html) that makes it easy for your to build your own models. Here, I mean "model" to mean any system that converts a time series of inputs and generates a time series of N outputs. 

Once you write your model to inherit from `model`, you can do all sorts of crazy stuff with it like:

1. viewing time series outputs of your model, that you can see update in real time as you vary parameters (like Mathematica's [manipulate](https://reference.wolfram.com/language/ref/Manipulate.html))
2. You can actually view any arbitrary function acting on your model while you manipulate its parameters. `model` ships with two built in functions (time series and mapping outputs vs. inputs), but you can write whatever function you want, and `model` does all the heavy lefting for you in the background to wire up outputs and UX elements. 
3. fit your model to data using all the fitting routines MATLAB has to offer. It's as simple as typing `model.fit()`. 

## License 

`model` is [free software](https://www.gnu.org/licenses/gpl-3.0.en.html).

 