unit Raylib.App;

{$i raylib.inc}
{$WARN 5024 off : Parameter "$1" not used}

interface

uses
  RayLib, RayLib.System, RayLib.Glfw, RayLib.Gl, Raylib.NanoVG, Raylib.Graphics;

const
  DefTitle = 'Raylib Scene';
  DefWidth = 800;
  DefHeight = 450;

{ TCanvasHelper }

type
  TCanvasHelper = type helper for ICanvas
  public
    procedure DrawTextStrong(Font: IFont; const Text: string; X, Y: Single);
  end;

{ TCreateParams }

  TCreateParams = record
    Title: string;
    Width: Integer;
    Height: Integer;
    FullScreen: Boolean;
    MultiSampling: Boolean;
    Resizable: Boolean;
    Undecorated: Boolean;
    Monitor: Integer;
  end;

{ TStopWatch }

  TStopWatch = class
  private
    FTime: Double;
    FTimeFrame: Double;
    FFps: Integer;
  public
    { Time in seconds since the application started }
    property Time: Double read FTime;
    { Time in seconds since the last frame }
    property TimeFrame: Double read FTimeFrame;
    { The number of frames rendered in the last second }
    property Fps: Integer read FFps;
  end;

{ TScene }

  TScene = class
  private
    FClientRect: TRect;
    FCanvasActive: Boolean;
    FCanvas: ICanvas;
    FFont: IFont;
    FFontX: Single;
    FFontY: Single;
  protected
    procedure CreateParams(var Params: TCreateParams); virtual;
    procedure Load; virtual;
    procedure Unload; virtual;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); virtual;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); virtual;
    procedure BeginCanvas(Width, Height: Integer);
    procedure EndCanvas;
    procedure WriteLine(const S: string); overload;
    procedure WriteLine(const S: string; Args: array of const); overload;
    procedure WriteMove(X, Y: Single);
    property ClientRect: TRect read FClientRect;
    property Canvas: ICanvas read FCanvas;
    property Font: IFont read FFont write FFont;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TSceneClass = class of TScene;

{ TApplication }

  TApplication = class
  private
    FTerminated: Boolean;
    FTitle: string;
    FWidth: Integer;
    FHeight: Integer;
    FScene: TScene;
    FLoaded: Boolean;
    procedure Init;
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
  public
    constructor Create;
    procedure Terminate;
    procedure Run(SceneClass: TSceneClass);
    property Title: string read GetTitle write SetTitle;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Scene: TScene read FScene;
  end;

function Application: TApplication;

implementation

procedure TCanvasHelper.DrawTextStrong(Font: IFont; const Text: string; X, Y: Single);
begin
  Font.Color := colorBlack;
  Self.DrawText(Font, Text, X - 1, Y - 1);
  Self.DrawText(Font, Text, X + 1, Y + 1);
  Font.Color := colorWhite;
  Self.DrawText(Font, Text, X, Y);
end;

{ TScene }

constructor TScene.Create;
begin
  inherited Create;
  FCanvas := nil;
end;

destructor TScene.Destroy;
begin
  if FCanvas <> nil then
    (FCanvas as IDisposable).Dispose;
  FCanvas := nil;
  inherited Destroy;
end;

procedure TScene.CreateParams(var Params: TCreateParams);
begin
end;

procedure TScene.Load;
begin
end;

procedure TScene.Unload;
begin
end;

procedure TScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
begin
  if IsKeyPressed(KEY_ESCAPE) then
    Application.Terminate;
end;

procedure TScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
begin
  ClearBackground(BLUE);
end;

procedure TScene.BeginCanvas(Width, Height: Integer);
begin
  if FCanvasActive then Exit;
  FCanvasActive := True;
  (FCanvas as ICanvasFrame).BeginFrame(Width, Height);
  FFontX := 10;
  FFontY := 10;
end;

procedure TScene.EndCanvas;
begin
  if not FCanvasActive then Exit;
  FCanvasActive := False;
  (FCanvas as ICanvasFrame).EndFrame;
end;

procedure TScene.WriteLine(const S: string);
begin
  if not FCanvasActive then Exit;
  if FFont = nil then
    Exit;
  if S = '' then
  begin
    FFontY := FFontY + FCanvas.MeasureText(FFont, 'Wg').y * 1.25;
    Exit;
  end;
  if FFont.Color = colorBlack then
  begin
    FFont.Color := colorSilver;
    FCanvas.DrawText(FFont, S, FFontX + 1, FFontY + 1);
    FFont.Color := colorBlack;
    FCanvas.DrawText(FFont, S, FFontX, FFontY);
  end
  else if FFont.Color = colorWhite then
  begin
    FFont.Color := colorBlack;
    FCanvas.DrawText(FFont, S, FFontX + 1, FFontY + 1);
    FFont.Color := colorWhite;
    FCanvas.DrawText(FFont, S, FFontX, FFontY);
  end
  else
    FCanvas.DrawText(FFont, S, FFontX, FFontY);
  FFontY := FFontY + FCanvas.MeasureText(FFont, 'Wg').y * 1.25;
end;

procedure TScene.WriteLine(const S: string; Args: array of const); overload;
begin
  WriteLine(S.Format(Args));
end;

procedure TScene.WriteMove(X, Y: Single);
begin
  FFontX := X;
  FFontY := Y;
end;

{ TApplication }

constructor TApplication.Create;
begin
  inherited Create;
  FTitle := DefTitle;
  FWidth := DefWidth;
  FHeight := DefHeight;
end;

procedure TApplication.Terminate;
begin
  FTerminated := True;
end;

function TApplication.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TApplication.SetTitle(const Value: string);
begin
  if Value = FTitle then Exit;
  FTitle := Value;
  if FScene <> nil then
    SetWindowTitle(PChar(FTitle));
end;

function TApplication.GetWidth: Integer;
begin
  if FScene <> nil then
    Result := GetScreenWidth
  else
    Result := FWidth;
end;

procedure TApplication.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  if FWidth < 1 then
    FWidth := 1;
  if FScene <> nil then
    SetWidth(FWidth);
end;

function TApplication.GetHeight: Integer;
begin
  if FScene <> nil then
    Result := GetScreenHeight
  else
    Result := FHeight;
end;

procedure TApplication.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  if FHeight < 1 then
    FHeight := 1;
  if FScene <> nil then
    SetHeight(FHeight);
end;

procedure TApplication.Init;
var
  P: TCreateParams;
  F: LongWord;
  V: TVec2;
begin
  P.Title := FTitle;
  P.Width := FWidth;
  P.Height := Height;
  P.FullScreen := False;
  P.MultiSampling := True;
  P.Resizable := False;
  P.Undecorated := False;
  FScene.CreateParams(P);
  F := FLAG_VSYNC_HINT;
  if P.FullScreen then F := F or FLAG_FULLSCREEN_MODE;
  if P.MultiSampling then F := F or FLAG_MSAA_4X_HINT;
  if P.Resizable then F := F or FLAG_WINDOW_RESIZABLE;
  if P.Undecorated then F := F or FLAG_WINDOW_UNDECORATED;
  SetConfigFlags(F);
  if P.Monitor > 0 then
    SetWindowMonitor(P.Monitor - 1)
  else
    SetWindowMonitor(0);
  if P.FullScreen then
  begin
    FWidth := GetMonitorWidth(0);
    FHeight := GetMonitorHeight(0);
  end;
  InitWindow(FWidth, FHeight, PChar(FTitle));
  if P.Monitor > 0 then
  begin
    V := GetMonitorPosition(P.Monitor - 1);
    SetWindowPosition(Round(V.X), Round(V.Y));
  end;
  InitAudioDevice;
end;

procedure TApplication.Run(SceneClass: TSceneClass);
var
  Frame: Integer;
  Second: Integer;
  S: TScene;
  W: TStopWatch;
begin
  if FScene <> nil then
    Exit;
  FTerminated := False;
  Frame := 0;
  Second := 0;
  S := SceneClass.Create;
  W := TStopWatch.Create;
  try
    FScene := S;
    Init;
    if not FLoaded then
    begin
      FLoaded := LoadGL(@glfwGetProcAddress);
      if not FLoaded then
      begin
        FTerminated := True;
        Exit;
      end;
      LoadNanoVG(@glfwGetProcAddress);
    end;
    FScene.FCanvas := NewCanvas;
    FScene.FClientRect := [Width, Height];
    FScene.Load;
    while not WindowShouldClose do
    begin
      if FTerminated then Break;
      W.FTime := GetTime;
      W.FTimeFrame := GetFrameTime;
      if Trunc(W.FTime) > Second then
      begin
        W.FFps := Frame;
        Frame := 1;
        Second := Trunc(W.FTime);
      end
      else
        Inc(Frame);
      FScene.FClientRect := [Width, Height];
      FScene.Logic(Width, Height, W);
      BeginDrawing;
      FScene.Render(Width, Height, W);
      EndDrawing;
    end;
    FScene.Unload;
  finally
    FScene := nil;
    S.Free;
    W.Free;
    CloseWindow;
    FTerminated := True;
  end;
end;

var
  InternalApplication: TObject;

function Application: TApplication;
begin
  if InternalApplication = nil then
    InternalApplication := TApplication.Create;
  Result := TApplication(InternalApplication);
end;

finalization
  InternalApplication.Free;
end.

