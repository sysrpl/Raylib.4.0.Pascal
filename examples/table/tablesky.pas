unit TableSky;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  Raylib.Gl,
  Raylib.Rl;

{ TSkybox }

type
  TSkybox = record
  private
    Camera: TCamera3D;
    Up, Down, Left, Right, Front, Back: TTexture2D;
  public
    procedure Load;
    procedure Unload;
    procedure Render;
  end;

implementation

{ TSkybox }

procedure TSkybox.Load;

  procedure Load(var T: TTexture2D; const Name: string);
  begin
    T := LoadTexture(PChar('assets/' + Name + '.png'));
  end;

begin
  Load(Up, 'up');
  Load(Down, 'down');
  Load(Left, 'left');
  Load(Right, 'right');
  Load(Front, 'front');
  Load(Back, 'back');
  Camera.position := Vec(0, 0, 0);
  Camera.target := Vec(0, 0, -1);
  Camera.projection := CAMERA_PERSPECTIVE;
  Camera.up := Vec(0, 1, 0);
  Camera.fovy := 60;
  WriteLn('***************************** ', Front.Width);
end;

procedure TSkybox.Unload;
begin
  UnloadTexture(Up);
  UnloadTexture(Down);
  UnloadTexture(Left);
  UnloadTexture(Right);
  UnloadTexture(Front);
  UnloadTexture(Back);
end;

procedure TSkybox.Render;
const
  S = 1024;
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  BeginMode3D(Camera);
  DrawBillboardPro(Camera, Left, Rect(0, 0, S, S), Vec(0, 0, -50),
    Vec(0, 1, 0), Vec(50, 50), Vec(0, 0), 0, WHITE);
  DrawBillboardPro(Camera, Front, Rect(0, 0, Front.width, Front.height), Vec(0, 0, -50),
    Vec(0, 1, 0), Vec(50, 50), Vec(0, 0), 0, WHITE);
  EndMode3D;
  glClear(GL_DEPTH_BUFFER_BIT);
end;

end.

