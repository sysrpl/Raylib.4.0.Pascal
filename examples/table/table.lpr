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
  TableLogic,
  TableHelp;

type
  TTableScene = class(TScene)
  private
    FBackground: IBrush;
    FView: TTableView;
    FHelp: TTableHelp;
    FRenderer: TTableRender;
    FStick: TTableStick;
    FBalls: TTableBalls;
    FLogic: TTableLogic;
    FTimeCheck: Int64;
    FLowFps: Double;
    FFrame: Int64;
    FFrameAccum: Double;
  protected
    procedure Load; override;
    procedure Unload; override;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); override;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); override;
  end;

procedure TTableScene.Load;
begin
  inherited Load;
  State.Help := True;
  RenderOptions.Shadows := True;
  RenderOptions.Smoothing := 2;
  RenderOptions.Assist := 1;
  Font := Canvas.LoadFont('assets/contrail_one_regular.ttf');
  Font.Color := colorWhite;
  Font.Size := 20;
  FView.Init;
  FHelp.Load(Canvas);
  FRenderer.Load;
  FBalls.Load;
  FStick.Load;
  FLogic.Load(FBalls, FStick);
  FBackground := NewBrush(Vec(0, 0), Vec(0, WindowHeight), colorGray, colorBlack);
  FLowFps := 9999;
end;

procedure TTableScene.Unload;
begin
  FLogic.Unload;
  FStick.Unload;
  FBalls.Unload;
  FRenderer.Unload;
  FHelp.Unload;
  inherited Unload;
end;

procedure TTableScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
var
  L: Double;
  I: Integer;
begin
  State.Fps := StopWatch.Fps;
  State.TimeFrame := StopWatch.TimeFrame;
  State.TimeNow := StopWatch.Time;
  Inc(FFrame);
  if FFrame mod 2 = 0 then
  begin
    FFrameAccum := StopWatch.Time - FFrameAccum;
    if FFrameAccum > 0 then
      L := 2 / FFrameAccum
    else
      L := 99999;
    if L < FLowFps then
      FLowFps := L;
    FFrameAccum := StopWatch.Time;
  end;
  I := Trunc(State.TimeNow);
  if I > FTimeCheck then
  begin
    FTimeCheck := I;
    State.LowFps := Round(FLowFps);
    FLowFps := 99999;
  end;
  if IsKeyPressed(KEY_F1) then
    State.Help := True;
  if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
    State.Help := False;
  FLogic.Track;
  FLogic.Think;
end;

procedure TTableScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
{.$define debug}
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
  if State.Help then
    FHelp.Draw(Canvas)
  else
  begin
    FHelp.DrawFps(Canvas);
    FRenderer.Draw(Canvas);
    if IsKeyDown(KEY_P) then
      FLogic.Debug(Canvas);
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
    if IsKeyDown(KEY_P) then
      FLogic.Debug(Canvas);
    WriteLine(S);
    {$endif}
  end;
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
