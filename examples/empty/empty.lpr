program Empty;

uses
  Raylib;

const
  Width = 512;
  Height = 512;

procedure Run;
var
  Shader: TShader;
  T: TTexture2D;
begin
  InitWindow(Width, Height, 'Billiard Ball');
  SetTargetFPS(60);
  Shader.Load(nil, 'colors.fs');
  while not WindowShouldClose do
  begin
    BeginDrawing;
    ClearBackground(BLACK);
    BeginShaderMode(Shader);
    DrawTextureRec(T, [0, 0, Width, Height], [0, 0], WHITE);
    EndShaderMode;
    EndDrawing;
  end;
  Shader.Unload;
  CloseWindow;
end;

begin
  Run;
end.

