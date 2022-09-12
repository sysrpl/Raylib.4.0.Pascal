program Shade;

uses
  Raylib;

const
  Width = 512;
  Height = 512;

procedure Run;
var
  Shader: TShader;
  S, H, B: TUniformInt;
  A: TUniformSingle;
  L: TUniformVec2;
  T: TTexture2D;
begin
  InitWindow(Width, Height, 'Billiard Ball');
  SetTargetFPS(60);
  Shader.Load(nil, 'ball.fs');

  Shader.GetUniform('size', S);
  S.value := Width;
  Shader.SetUniform(S);

  Shader.GetUniform('highlight', H);
  H.value := Width;
  Shader.SetUniform(H);

  Shader.GetUniform('lightpos', L);
  L.value := [-57.0, -25.0];
  Shader.SetUniform(L);

  Shader.GetUniform('angle', A);
  A.value := 0;
  Shader.SetUniform(A);

  Shader.GetUniform('ball', B);
  B.value := 8;
  Shader.SetUniform(B);

  T := LoadTexture('numbers.png');
  GenTextureMipmaps(T);
  SetTextureWrap(T, TEXTURE_WRAP_CLAMP);
  SetTextureFilter(T, TEXTURE_FILTER_TRILINEAR);

  while not WindowShouldClose do
  begin
    BeginDrawing;
    ClearBackground(BLACK);
    BeginShaderMode(Shader);
    A.value := A.value + GetFrameTime;
    Shader.SetUniform(A);
    if IsKeyPressed(KEY_LEFT) then
    begin
      B.value := B.value - 1;
      if B.value < 0 then
        B.value := 16;
      Shader.SetUniform(B);
    end;
    if IsKeyPressed(KEY_RIGHT) then
    begin
      B.value := (B.value + 1) mod 17;
      Shader.SetUniform(B);
    end;
    if IsKeyPressed(KEY_S) then
    begin
      H.value := (H.value) mod 2;
      Shader.SetUniform(H);
    end;
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
    begin
      L.value := GetMousePosition;
      L.value.x := (L.value.x - Width / 2);
      L.value.y := (L.value.y - Width / 2);
      Shader.SetUniform(L);
    end;
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

