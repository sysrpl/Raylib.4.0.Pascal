# Raylib 4.0 Pascal Bindings

This package includes a complete set of Pascal bindings for [Raylib](https://www.raylib.com/), the popular educational game development toolkit. This package supports the following Raylib modules:

* Raylib Core (raylib.pas)
  * Shapes
  * Text
  * Images
  * Models
  * Windowing and Input
  * Music and Audio
  * Collision Detection
* Raylib GL (raylib.gl.pas)
  * Simplified OpenGL Interface
* Raylib GUI (raylib.gui.pas)
  * Basic UI Controls
  * Icons

## Examples

If you would like to see what can be done with Raylib, [this page](https://www.raylib.com/examples.html) contains many examples alongside with source code.

## Documentation

Raylib has a fairly complete [cheatsheet page](https://www.raylib.com/cheatsheet/cheatsheet.html) you can use as a reference. All the functions are easy to use and are pretty self explanatory.


## A BIG NOTE ON COMPILING AND RUNNING

Here are a few notes you should be aware of when using the Pascal bindings in this package.

### Windows
>    The file dlls/raylib.dll must be copied to a folder in your path.
>    You can do this by copying raylib.dll to your program folder, or
>    by copying raylib.dll to C:\Windows\System32 one time.

###, MacOS, and Raspberry Pi
> Static libraries are used and everything is built into your programs.

  When compiling from the command line, make sure the src folder is included
  in your unit path.

**Example**

> fpc hellotest.pas -Fu../src 
