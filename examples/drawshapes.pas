program DrawShapes;

{$mode delphi}
{$ifdef windows}{$apptype gui}{$endif}

uses
  Raylib;

const
  W = 800;
  H = 450;
begin
  SetTargetFPS(60);
  InitWindow(W, H, 'Raylib Draw Shapes Test');
  while not WindowShouldClose do
  begin
    ClearBackground(WHITE);
    BeginDrawing;
      DrawText('Some basic shapes available on raylib', 20, 20, 20, DARKGRAY);
      DrawCircle(W div 5, 120, 35, DARKBLUE);
      DrawCircleGradient(W div 5, 220, 60, GREEN, SKYBLUE);
      DrawCircleLines(W div 5, 340, 80, DARKBLUE);
      DrawRectangle(W div 4 * 2 - 60, 100, 120, 60, RED);
      DrawRectangleGradientH(W div 4 * 2 - 90, 170, 180, 130, MAROON, GOLD);
      DrawRectangleLines(W div 4 *2 - 40, 320, 80, 60, ORANGE);
      DrawTriangle(Vec(W / 4 * 3, 80), Vec(W / 4 * 3 - 60, 150),
        Vec(W / 4 * 3 + 60, 150), VIOLET);
      DrawTriangleLines(Vec(W / 4 * 3, 160), Vec(W / 4 * 3 - 20, 230),
        Vec(W / 4 * 3 + 20, 230), DARKBLUE);
      DrawPoly(Vec(W / 4 * 3, 320), 6, 80, 0, BROWN);
      DrawPolyLinesEx(Vec(W / 4 * 3, 320), 6, 80, 0, 6, BEIGE);
      DrawLine(18, 42, W - 18, 42, BLACK);
    EndDrawing;
  end;
  CloseWindow;
end.

