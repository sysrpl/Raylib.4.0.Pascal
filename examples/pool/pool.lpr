program Pool;

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  Raylib.App,
  PoolObjs,
  PoolBalls;

type
  TPoolScene = class(TScene)
  private
    Status: IFont;
    StatusText: string;
    Horiz: Boolean;
    Table: TPoolTable;
    Delayed: Double;
    FineTime: Double;
    PriorZoom: Single;
    PriorPan: TVec2;
  protected
    procedure Load; override;
    procedure Unload; override;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); override;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); override;
  end;

procedure TPoolScene.Load;
begin
  inherited Load;
  Table.Init(Canvas);
  Table.Laser := 0;
  Table.Zoom := 1;
  Table.Pan := [0, 0];
  Table.Helping := True;
  PriorZoom := 2;
  PriorPan := Table.Pan;
  Font := Canvas.LoadFont('assets/contrail_one_regular.ttf');
  Font.Color := colorWhite;
  Font.Size := 28;
  Status := Canvas.LoadFont('assets/chela_one_regular.ttf');
  Status.Align := fontRight;
  Status.Size := 36;
  Horiz := True;
  Table.Strength := 1;

end;

procedure TPoolScene.Unload;
begin
  Table.Release;
end;

function Min(A, B: Single): Single; inline;
begin
  if A < B then Result := A else Result := B;
end;

function Max(A, B: Single): Single; inline;
begin
  if A > B then Result := A else Result := B;
end;

procedure TPoolScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
var
  FineSpeed: Double;
  A, B: TVec2;
  I: Integer;
begin
  Table.Aim := False;
  StatusText := '';
  if IsKeyPressed(KEY_F1) then
    Table.Helping := not Table.Helping;
  if IsMouseButtonReleased(0) then
    Table.Helping := False;
  if Table.Helping then
  begin
    Table.PanZoom := False;
    Table.Zoom := 1;
    Table.Pan := [0, 0];
    Exit;
  end;
  if IsKeyPressed(KEY_Z) then
  begin
    Table.PanZoom := not Table.PanZoom;
    if Table.PanZoom then
    begin
      Table.Zoom := PriorZoom;
      Table.Pan := PriorPan;
    end
    else
    begin
      Table.Zoom := 1;
      Table.Pan := [0, 0];
    end;
    Table.Aim := False;
  end;
  if Table.PanZoom then
  begin
    A.y := GetMouseWheelMove;
    if A.y > 0 then
    begin
      Table.Zoom := Table.Zoom + 0.25;
      Table.Pan := Table.Pan - GetMousePosition / 2;
    end
    else if A.y < 0 then
    begin
      Table.Zoom := Table.Zoom - 0.25;
      Table.Pan := Table.Pan + GetMousePosition / 2;
    end;
    if Table.Zoom > 5 then
      Table.Zoom := 5
    else if Table.Zoom < 1 then
      Table.Zoom := 1;
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
    begin
      Table.Pan := Table.Pan + GetMouseDelta;
    end;
    Table.Pan.x := Min(Table.Pan.x, 0);
    Table.Pan.y := Min(Table.Pan.y, 0);
    Table.Pan.x := Max(Table.Pan.x, -Width * (Table.Zoom - 1));
    Table.Pan.y := Max(Table.Pan.y, -Height * (Table.Zoom - 1));
    if Table.Zoom = 1 then
      Table.Pan := [0, 0];
    if Table.PanZoom then
    begin
      PriorZoom := Table.Zoom;
      PriorPan := Table.Pan;
    end;
  end;
  if IsKeyDown(KEY_X) then
    StatusText := 'Toggle path tracking';
  for I := KEY_ONE to KEY_NINE do
    if IsKeyPressed(I) then
    begin
      Table.RackBalls(I + 1 - KEY_ONE);
      Exit;
    end;
  if IsKeyPressed(KEY_X) then
    Table.Tracking := not Table.Tracking;
  Table.Update;
  if Table.Moving then
  begin
    case Round(GetTime * 5) mod 4 of
      0: StatusText := '/ Simulating';
      1: StatusText := '- Simulating';
      2: StatusText := '\ Simulating';
      3: StatusText := '| Simulating';
    end;
    Exit;
  end;
  if IsKeyPressed(KEY_SPACE) then
    Table.Shoot;
  if Table.Moving then
  begin
    ShowCursor;
    Exit;
  end;
  if IsKeyPressed(KEY_S) then
    Table.Laser := (Table.Laser + 1) mod 5;
  if IsKeyPressed(KEY_W) then
    Table.Walls := not Table.Walls;
  if IsKeyDown(KEY_S) then
    case Table.Laser of
      0: StatusText := 'Cycle laser sight (off)';
      1: StatusText := 'Cycle laser sight (on)';
      2: StatusText := 'Cycle laser sight (on with walls)';
      3: StatusText := 'Cycle laser sight (on with collide)';
      4: StatusText := 'Cycle laser sight (on with paths)';
    else
      StatusText := 'Cycle laser sight';
    end;
  if IsKeyDown(KEY_W) then
    StatusText := 'Toggle draw walls';
  { Fine Control }
  Table.Aim := True;
  if GetTime - FineTime < 0.3 then
    FineSpeed := 240
  else if GetTime - FineTime < 1.3 then
    FineSpeed := 120
  else if GetTime - FineTime < 3 then
    FineSpeed := 40
  else
    FineSpeed := 10;
  if IsKeyDown(KEY_UP) then
  begin
    Table.StickAngle := Table.StickAngle + GetFrameTime / FineSpeed;
    StatusText := 'Fine control';
  end
  else if IsKeyDown(KEY_DOWN) then
  begin
    Table.StickAngle := Table.StickAngle - GetFrameTime / FineSpeed;
    StatusText := 'Fine control';
  end
  else
    FineTime := GetTime;
  if IsKeyDown(KEY_LEFT) then
    Table.Strength := Table.Strength - GetFrameTime / 5
  else if IsKeyDown(KEY_RIGHT) then
    Table.Strength := Table.Strength + GetFrameTime / 5;
  if Table.Strength <= 0 then
    StatusText := 'Fine control no strength';
  if IsKeyPressed(KEY_H) and (not Horiz) then
  begin
    Horiz := True;
    SetWindowSize(PixelW, PixelH)
  end
  else if IsKeyPressed(KEY_V) and Horiz then
  begin
    Horiz := False;
    SetWindowSize(PixelH, PixelW);
  end;
  if (not Table.PanZoom) and IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
  begin
    StatusText := 'Aiming';
    Table.Aim := True;
    A := [CX, CY];
    B := GetMousePosition;
    Table.StickAngle := B.Angle(A);
    Table.Strength := (A.Distance(B) - 25) / 130;
    if Table.Strength > 1 then
      ShowCursor
    else
      HideCursor;
    if Table.Strength <= 0 then
      StatusText := 'Aiming no strength';
  end
  else
    ShowCursor;
end;

procedure TPoolScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
begin
  BeginCanvas(Width, Height);
  if not Horiz then
  begin
    Canvas.Matrix.Rotate(Pi / 2);
    Canvas.Matrix.Translate(PixelH, 0);
  end;
  Table.Draw(Canvas);
  Canvas.Matrix.Identity;
  if Table.PanZoom then
    WriteMove(5, 5)
  else
    WriteMove(100, 5);
  if not Table.Helping then
  begin
    if Table.PanZoom then
    begin
      WriteLine('Press "z" to exit pan / zoom mode');
      WriteLine('Zoom: %.2f', [Table.Zoom]);
    end;
    if Table.Tracking then
      WriteLine('Press "x" to exit tracking mode');
    if Table.Aim then
      WriteLine('Angle %.2f° / Strength %.2f', [Table.StickAngle * RAD2DEG, Table.Strength]);
    Canvas.DrawTextStrong(Status, StatusText, Width - 110, Height - 35);
  end;
  EndCanvas;
end;

begin
  Application.Title := 'Pool Simulation';
  Application.Width := PixelW;
  Application.Height := PixelH;
  Application.Run(TPoolScene);
end.

