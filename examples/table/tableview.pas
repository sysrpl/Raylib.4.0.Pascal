unit TableView;

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  TableVars;

{ TCameraSweep }

type
  TCameraSweep = record
  private
    FStart: Double;
    FStop: Double;
    FSource: TCamera3D;
    FDest: TCamera3D;
  public
    Current: TCamera3D;
    Animating: Boolean;
    procedure Waypoint(Source, Dest: TCamera3D; Time: Double = 0);
    procedure Step;
  end;

  TCameraMode = (camOrbit, camOverhead, camFree);

{ TTableView }

  TTableView = record
  private

  type
    TAnimate = record
      Start: Single;
      Finish: Single;
      Complete: Double;
    end;

  private
    FDrag: Boolean;
    FOrbit: TVec2;
    FOverhead: TVec2;
    FMouse: TVec2;
    FZoomAnim: TAnimate;
    FMode: TCameraMode;
    FOrbitCamera: TCamera3D;
    FOverheadCamera: TCamera3D;
    FFreeCamera: TCamera3D;
    FFreeDir: TVec2;
    FStartTime: Double;
    procedure LimitCamera;
    procedure TrackOrbit;
    procedure TrackOverhead;
    procedure TrackFree;
  public
    Mode: TCameraMode;
    Camera: TCamera3D;
    Light: TVec3;
    Zoom: Single;
    Sweep: TCameraSweep;
    procedure Init;
    procedure Track;
  end;

implementation

const
  Dist = 2;
  DefaultZoom = 1;
  DefaultY = 1;
  SweepTime = 1;

{ TCameraSweep }

procedure TCameraSweep.Waypoint(Source, Dest: TCamera3D; Time: Double = 0);
begin
  if Time < 0.01 then
    Time := SweepTime;
  Animating := True;
  FStart := TimeQuery;
  FStop := FStart + Time;
  Current := Source;
  FSource := Source;
  FDest := Dest;
end;

procedure TCameraSweep.Step;
var
  T, R: Double;
begin
  T := TimeQuery;
  Animating := FStop > T;
  if Animating then
  begin
    T := (T - FStart) / (FStop - FStart);
    R := 1 - T;
    Current.position.x := FSource.position.x * R + FDest.position.x * T;
    Current.position.y := FSource.position.y * R + FDest.position.y * T;
    Current.position.z := FSource.position.z * R + FDest.position.z * T;
    Current.target.x := FSource.target.x * R + FDest.target.x * T;
    Current.target.y := FSource.target.y * R + FDest.target.y * T;
    Current.target.z := FSource.target.z * R + FDest.target.z * T;
    Current.up.x := FSource.up.x * R + FDest.up.x * T;
    Current.up.y := FSource.up.y * R + FDest.up.y * T;
    Current.up.z := FSource.up.z * R + FDest.up.z * T;
  end
  else
    Current := FDest;
end;

{ TTableView }

procedure TTableView.Init;
begin
  FDrag := False;

  FOrbit := Vec(0, DefaultZoom);
  FOverhead := Vec(0, 0);

  Light := Vec(0, 50, 0);
  Zoom := DefaultZoom;
  FZoomAnim.Complete := 0;
  FZoomAnim.Start := Zoom;
  FZoomAnim.Finish := Zoom;

  FOrbitCamera.position := Vec(0, DefaultY, Dist * DefaultZoom);
  FOrbitCamera.target := Vec(0, 0, 0);
  FOrbitCamera.projection := CAMERA_PERSPECTIVE;
  FOrbitCamera.up := Vec(0, 1, 0);
  FOrbitCamera.fovy := 60;

  FOverheadCamera.position := Vec(0, 1.4, 0);
  FOverheadCamera.target := Vec(0, 0, 0);
  FOverheadCamera.projection := CAMERA_PERSPECTIVE;
  FOverheadCamera.up := Vec(0, 0, -1);
  FOverheadCamera.fovy := 60;

  FFreeCamera.position := Vec(40 * Inch, 12 * Inch, 0);
  FFreeCamera.target := FFreeCamera.position + Vec(-1, 0, 0);
  FFreeCamera.projection := CAMERA_PERSPECTIVE;
  FFreeCamera.up := Vec(0, 1, 0);
  FFreeCamera.fovy := 60;
  FFreeDir := Vec(0, 0);

  Camera := FOverheadCamera;
  FMode := camOverhead;
  Mode := FMode;

  FStartTime := TimeQuery;
end;

procedure TTableView.LimitCamera;
const
  SlateLimit = Inch;
  CabinetLimit = Inch * 4;
begin
  if (Abs(Camera.position.x) < SlateX / 2) and (Abs(Camera.position.z) < SlateZ / 2) then
  begin
    if Camera.position.y < SlateLimit then
    begin
      Camera.position.y := SlateLimit;
      FOrbit.y := SlateLimit;
    end;
  end
  else if (Abs(Camera.position.x) < CabinetX / 2) and (Abs(Camera.position.z) < CabinetZ / 2) then
  begin
    if Camera.position.y < CabinetLimit then
    begin
      Camera.position.y := CabinetLimit;
      FOrbit.y := CabinetLimit;
      FOrbitCamera.position.y := CabinetLimit;
      FFreeCamera.position.y := CabinetLimit;
    end;
  end;
end;

function Mix(A, B: Single; Percent: Double): Single;
begin
  if Percent < 0 then
    Exit(A);
  if Percent > 1 then
    Exit(B);
  Result := A * (1 - Percent) + B * Percent;
end;

procedure TTableView.TrackOrbit;
const
  Delay = 0.5;
var
  Time: Double;
  M, Delta: TVec2;
  Z: Single;
begin
  Time := TimeQuery;
  Z := GetMouseWheelMove;
  with FZoomAnim do
  begin
    if Z <> 0 then
    begin
      Start := Zoom;
      Finish := Finish + Z * -0.1;
      Complete := Time + Delay;
      if Finish < 0.1 then
        Finish := 0.1;
      if Finish > 2 then
        Finish := 2;
    end;
    if Time > Complete then
      Zoom := Finish
    else
      Zoom := Mix(Start, Finish, 1 - (Complete - Time) / Delay);
  end;
  FOrbitCamera.position := Vec(Sin(FOrbit.X) * Dist * Zoom + Camera.target.x, FOrbit.Y, Cos(FOrbit.X) * Dist * Zoom + Camera.target.z);
  M := GetMousePosition;
  if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
  begin
    if FDrag then
    begin
      Delta := M - FMouse;
      FOrbit.X := FOrbit.X + (Delta.X / 100) * (Zoom * 1.5);
      FOrbit.Y := FOrbit.Y + (Delta.Y / 100) * (Zoom * 1.5);
      FOrbitCamera.position := Vec(Sin(FOrbit.X) * Dist * Zoom, FOrbit.Y, Cos(FOrbit.X) * Dist * Zoom);
    end;
    FDrag := True;
  end
  else
    FDrag := False;
  Camera := FOrbitCamera;
  FMouse := M;
end;

procedure TTableView.TrackOverhead;
const
  Scaling = 310 * (1200 / 900);
var
  M, Delta: TVec2;
begin
  M := GetMousePosition;
  if IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then
  begin
    if FDrag then
    begin
      Delta := M - FMouse;
      FOverhead.X := FOverhead.X + Delta.X / Scaling;
      FOverhead.Y := FOverhead.Y + Delta.Y / Scaling;
      FOverheadCamera.position.X := -FOverhead.X;
      FOverheadCamera.position.Z := -FOverhead.Y;
      FOverheadCamera.target := Vec(-FOverhead.X, 0, -FOverhead.Y);
    end;
    FDrag := True;
  end
  else
    FDrag := False;
  Camera := FOverheadCamera;
  FMouse := M;
end;

procedure TTableView.TrackFree;
const
  SpeedDown = 2;
var
  Matrix: TMat4;
  M, Delta: TVec2;
  V, S: TVec3;
  T: Single;
begin
  M := GetMousePosition;
  if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
  begin
    Delta := M - FMouse;
    FFreeDir.X := FFreeDir.X + Delta.X / 2;
    FFreeDir.Y := FFreeDir.Y + Delta.Y / 2;
    if FFreeDir.Y > 80 then
      FFreeDir.Y := 80;
    if FFreeDir.Y < -80 then
      FFreeDir.Y := -80;
  end;
  V := Vec(-1, 0, 0);
  Matrix.Identity;
  Matrix.Rotate(0, FFreeDir.X, FFreeDir.Y);
  V := Matrix * V;
  S := Vec(0, 0, 0);
  if IsKeyDown(KEY_A) or IsKeyDown(KEY_D) then
  begin
    S := V;
    S.Y := 0;
    S.Normalize;
    T := S.X;
    S.X := -S.Z;
    S.Z := T;
    if IsKeyDown(KEY_A) then
      S := S * -1;
    FFreeCamera.position := FFreeCamera.position + S * (State.TimeFrame / SpeedDown);
  end;
  if IsKeyDown(KEY_W) then
    FFreeCamera.position := FFreeCamera.position + V * (State.TimeFrame / SpeedDown)
  else if IsKeyDown(KEY_S) then
    FFreeCamera.position := FFreeCamera.position - V * (State.TimeFrame / SpeedDown);
  FFreeCamera.target := FFreeCamera.position + V;
  Camera := FFreeCamera;
  FMouse := M;
end;

procedure TTableView.Track;
begin
  State.Overhead := False;
  if TimeQuery - FStartTime < 1 then
  begin
    FMouse := GetMousePosition;
    Exit;
  end;
  if Sweep.Animating then
  begin
    Sweep.Step;
    Camera := Sweep.Current;
    LimitCamera;
    Exit;
  end;
  if FMode <> Mode then
  begin
    FDrag := False;
    FMode := Mode;
  end;
  case FMode of
    camOrbit: TrackOrbit;
    camOverhead: TrackOverhead;
    camFree: TrackFree;
  end;
  if IsKeyPressed(KEY_C) then
  begin
    if Mode <> High(Mode) then
      Mode := Succ(Mode)
    else
      Mode := Low(Mode);
    if Mode = camOrbit then
    begin
      FOverheadCamera.position := Vec(0, 1.4, 0);
      FOverheadCamera.target := Vec(0, 0, 0);
      FOverheadCamera.projection := CAMERA_PERSPECTIVE;
      FOverheadCamera.up := Vec(0, 0, -1);
      FOverheadCamera.fovy := 60;
      FOverhead := Vec(0, 0);
    end;
    case Mode of
      camOrbit: Sweep.Waypoint(FFreeCamera, FOrbitCamera);
      camOverhead: Sweep.Waypoint(FOrbitCamera, FOverheadCamera);
      camFree: Sweep.Waypoint(FOverheadCamera, FFreeCamera);
    end;
  end;
  State.Overhead := (FMode = camOverhead) and (Mode = camOverhead);
  LimitCamera;
end;

end.

