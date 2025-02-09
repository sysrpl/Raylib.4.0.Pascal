program Table;

uses
  Raylib,
  Raylib.Gl,
  Raylib.System,
  Raylib.Graphics,
  Raylib.App,
  Raylib.Glfw,
  TableView,
  TableRender,
  TableSky,
  TableBalls,
  TableModel,
  TableStick,
  TableVars,
  TableLogic;

type
  TTableScene = class(TScene)
  private
    FBackground: IBrush;
    FView: TTableView;
    FRenderer: TTableRender;
    FStick: TTableStick;
    FBalls: TTableBalls;
    FLogic: TTableLogic;
  protected
    procedure Load; override;
    procedure Unload; override;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); override;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); override;
  end;

procedure TTableScene.Load;
begin
  inherited Load;
  Font := Canvas.LoadFont('assets/contrail_one_regular.ttf');
  Font.Color := colorWhite;
  Font.Size := 20;
  FView.Init;
  FRenderer.Load;
  FBalls.Load;
  FStick.Load;
  FLogic.Load(FBalls, FStick);
  FBackground := NewBrush(Vec(0, 0), Vec(0, WindowHeight), colorGray, colorBlack);
end;

procedure TTableScene.Unload;
begin
  FLogic.Unload;
  FStick.Unload;
  FBalls.Unload;
  FRenderer.Unload;
  inherited Unload;
end;

procedure TTableScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
begin
  State.TimeFrame := StopWatch.TimeFrame;
  FLogic.Track;
  FLogic.Think;
end;

procedure TTableScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
{$ifdef debug}
const
  CameraModes: array[TCameraMode] of string = ('Orbit', 'Overhead', 'Free');
var
  S: string;
{$endif}
begin
  inherited;
  State.Triangles := 0;
  State.TimeFrame := StopWatch.TimeFrame;
  BeginCanvas(Width, Height);
  Canvas.Rect(0, 0, Width, Height);
  Canvas.Fill(FBackground);
  EndCanvas;
  FView.Track;
  FView.Light.X := Sin(StopWatch.Time / 8) * 30;
  FView.Light.Z := Cos(StopWatch.Time / 8) * 30;
  FRenderer.Draw(FView.Camera, FView.Light);
  if not FRenderer.Test then
  begin
    FBalls.Draw(FView.Camera, FView.Light);
    FStick.Draw(FView.Camera, FView.Light);
  end;
  BeginCanvas(Width, Height);
  FRenderer.Draw(Canvas);
  { Optional debug information }
  {$ifdef debug}
  with FView.Camera.position do
    S := StrFormat('Mode: %s | Camera: %.2f %.2f %.2f',
      [CameraModes[FView.Mode], X, Y, Z]);
  with FView.Light do
    S := S + StrFormat(' | Light: %.2f %.2f %.2f', [X, Y, Z]);
  S := S + StrFormat(' | Zoom: %.2f', [FView.Zoom]);
  WriteLine(S);
  S := StrFormat('Framerate: %d | Triangles: %d', [StopWatch.Fps, State.Triangles]);
  S := S + StrFormat(' | Angle: %.2f | %.3f %.3f', [State.StickAngle, MouseAt.X, MouseAt.Y]);
  FLogic.Debug(Canvas);
  WriteLine(S);
  {$endif}
  EndCanvas;
end;

begin
  SetTraceLogLevel(LOG_ALL);
  SetConfigFlags(FLAG_MSAA_4X_HINT);
  Application.Title := 'Pool Table';
  Application.Width := WindowWidth;
  Application.Height := WindowHeight;
  Application.Run(TTableScene);
end.
