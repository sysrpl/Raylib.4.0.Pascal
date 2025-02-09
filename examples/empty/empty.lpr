program Empty;

{@delphi}

uses
  Raylib, Raylib.Glfw, Raylib.Gl;

const
  Width = 512;
  Height = 512;

procedure Run;
var
  Shader: TShader;
  Size, Ball: TUniformInt;
  Vbo: LongWord;
  V: TVec3;
begin
  InitWindow(Width, Height, 'Empty');
  SetTargetFPS(60);
  Shader.Load('colors.vs', 'colors.fs');
  Shader.GetUniform('size', Size);
  Size.value := Width;
  Shader.SetUniform(Size);
  Shader.GetUniform('ball', Ball);
  Ball.value := 2;
  Shader.SetUniform(Ball);
  LoadGL(@glfwGetProcAddress);
  glGenBuffers(1, @Vbo);
  glBindBuffer(GL_ARRAY_BUFFER, Vbo);
  V := [0, 0, 0];
  glBufferData(GL_ARRAY_BUFFER, SizeOf(V), @V, GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, SizeOf(V), nil);
  while not WindowShouldClose do
  begin
    BeginDrawing;
    ClearBackground(BLACK);
    BeginShaderMode(Shader);
    //glBindBuffer(GL_ARRAY_BUFFER, Vbo);
    //glDrawArrays(GL_POINTS, 0, 1);
    DrawRectangle(0, 0, Width, Height, WHITE);
    EndShaderMode;
    EndDrawing;
  end;
  Shader.Unload;
  CloseWindow;
end;

begin
  Run;
end.

