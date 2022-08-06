# Raylib 4.0 Pascal Bindings

This package includes a complete set of Pascal bindings for [Raylib](https://www.raylib.com/) version 4.0. Raylib is a popular game development toolkit in the computer programming education space. This package supports the following Raylib modules:

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

## Basic Window

The following example will give you a basic window.

```pascal
program HelloWorld;

uses
  Raylib;

const
  W = 800;
  H = 450;
begin
  // Create a 800 x 450 window
  InitWindow(W, H, 'This is a Raylib window');
  // Be nice to our GPU and limit the framerate
  SetTargetFPS(60);
  // Repeat while the window hasn't been closed
  while not WindowShouldClose do
  begin
    // Clear the screen with white
    ClearBackground(WHITE);
    BeginDrawing;
      // Draw our Hello World! message
      DrawText('Hello World!', 20, 20, 20, MAROON);
      // Draw a the current framerate
      DrawText(TextFormat('FPS is %d', GetFPS), 20, 50, 20, MAROON);
      // Draw a dark blue triangle
      DrawTriangle(Vec(W div 2, 150), Vec(W div 2 - 80, 300), Vec(W div 2 + 80, 300), DARKBLUE);
    EndDrawing;
  end;
  CloseWindow;
end.
```
This is the result:

![screenshot](https://github.com/sysrpl/Raylib.4.0.Pascal/blob/master/screenshot/raylib-hello.gif?raw=true)

## Examples

If you would like to see what can be done with Raylib, [this page](https://www.raylib.com/examples.html) contains many examples alongside with source code.

## Documentation

Raylib has a fairly complete [cheatsheet page](https://www.raylib.com/cheatsheet/cheatsheet.html) you can use as a reference. All the functions are easy to use and are pretty self explanatory.


## A Note on Compiling and Running

Here are a few notes you should be aware of when using the Pascal bindings in this package.

### Windows
>    The file dlls/raylib.dll must be copied to a folder in your path.
>    You can do this by copying raylib.dll to your program folder, or
>    by copying raylib.dll to C:\Windows\System32 one time.

### Linux, MacOS, and Raspberry Pi
> Static libraries are used and everything is built into your programs.

  When compiling from the command line, make sure the src folder is included
  in your unit path.

**Example**

> fpc helloworld.pas -Fu../src 
