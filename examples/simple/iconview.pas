program iconview;

{$mode delphi}
{$ifdef windows}{$apptype gui}{$endif}

uses
  Raylib,
  Raylib.Gui;

const
  W = 800;
  H = 450;
  C = 20;
var
  I: Integer;
begin
  SetTargetFPS(60);
  InitWindow(W, H, 'Raylib Gui Icon Test');
  while not WindowShouldClose do
  begin
    ClearBackground(WHITE);
    BeginDrawing;
      DrawText('These are the default raylib icons', 20, 20, 20, DARKGRAY);
      for I := RICON_FOLDER_FILE_OPEN to RICON_HIDPI do
        GuiDrawIcon(I, ((I - 1) mod C + 1) * 35, 70 + (I - 1) div C * 34 , 2, DARKGRAY);
    EndDrawing;
  end;
  CloseWindow;
end.

