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
