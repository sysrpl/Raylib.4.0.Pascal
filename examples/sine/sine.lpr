program Sine;

uses
  RayLib,
  Raylib.System,
  Raylib.Graphics,
  Raylib.App;

const
  W = 1100;
  H = 450;
  CX = W div 2;
  CY = H div 2;

type
  TSineScene = class(TScene)
  private
    Velocity: Single;
    Pos: Single;
    Radius: Single;
    DrawTriangle: Boolean;
    DrawSin: Boolean;
    Zoom: Single;
    Ground: IBitmapBrush;
    Status: IFont;
    StatusText: string;
  protected
    procedure Load; override;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); override;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); override;
  end;

procedure TSineScene.Load;
begin
  inherited Load;
  Ground := NewBrush(Canvas.LoadBitmap('ground.png'));
  Font := Canvas.LoadFont('contrail_one_regular.ttf');
  Font.Color := colorWhite;
  Font.Size := 20;
  Status := Canvas.LoadFont('chela_one_regular.ttf');
  Status.Align := fontRight;
  Status.Size := 36;
  Radius := 100;
  Zoom := 1;
end;

procedure TSineScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
const
  Speed = 50;
  Brake = 30;
begin
  StatusText := '';
  if IsKeyDown(KEY_EQUAL) then
  begin
    StatusText := 'Zooming In';
    Zoom := Zoom + StopWatch.TimeFrame;
    if Zoom > 2 then
      Zoom := 2;
  end
  else if IsKeyDown(KEY_MINUS) then
  begin
    StatusText := 'Zooming Out';
    Zoom := Zoom - StopWatch.TimeFrame;
    if Zoom < 1 then
      Zoom := 1;
  end;
  if IsKeyDown(KEY_T) then
    StatusText := 'Toggle Triangle';
  if IsKeyPressed(KEY_T) then
    DrawTriangle := not DrawTriangle;
  if IsKeyDown(KEY_S) then
    StatusText := 'Toggle Sin(a)';
  if IsKeyPressed(KEY_S) then
    DrawSin := not DrawSin;
  if IsKeyDown(KEY_UP) then
  begin
    StatusText := 'Growing Radius';
    Radius := Radius + StopWatch.TimeFrame * 20
  end
  else if IsKeyDown(KEY_DOWN) then
  begin
    StatusText := 'Shrinking Radius';
    Radius := Radius - StopWatch.TimeFrame * 20;
  end;
  if Radius < 50 then
    Radius := 50
  else if Radius > 200 then
    Radius := 200;
  if IsKeyDown(KEY_LEFT) then
  begin
    StatusText := 'Roll Left';
    Velocity := Velocity - Speed * StopWatch.TimeFrame
  end
  else if IsKeyDown(KEY_RIGHT) then
  begin
    StatusText := 'Roll Right';
    Velocity := Velocity + Speed * StopWatch.TimeFrame
  end
  else if Velocity > 0 then
    Velocity := Velocity - Brake * StopWatch.TimeFrame
  else if Velocity < 0 then
    Velocity := Velocity + Brake * StopWatch.TimeFrame;
  if Abs(Velocity) < 0.5 then
    Velocity := 0;
  Pos := Pos + Velocity * GetFrameTime;
  if Pos < -Width / 2 + Radius then
  begin
    Velocity := -Velocity;
    Pos := -Width / 2 + Radius;
  end;
  if Pos > Width / 2 - Radius then
  begin
    Velocity := -Velocity;
    Pos := Width / 2 - Radius;
  end;
end;

procedure TSineScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
const
  Nubs = 42;
  Spokes = 28;
var
  X, A: Single;
  B: IGradientBrush;
  P: IPen;
  R: TRect;
  I: Integer;
begin
  X := Pos + CX;
  BeginCanvas(Width, Height);
  { Apply the zoom }
  Canvas.Matrix.ScaleAt(Zoom, Zoom, CX + Pos, CY);
  { Draw the sky }
  B := NewBrush([0, -Height / 2], [0, Height + 200], colorDarkBlue, colorSkyBlue);
  R := ClientRect;
  R.Inflate(1000, 0);
  Canvas.FillRect(B, R);
  { Draw the tire }
  B := NewBrush([X - Radius, CY - Radius], [X + Radius, CY + Radius], $FF404040, colorBlack);
  R := [Radius * 2, Radius * 2];
  R.Move(X - Radius, CY - Radius);
  Canvas.Ellipse(R);
  P := NewPen(0, 15);
  P.LineCap := capButt;
  P.Brush := B;
  Canvas.Stroke(P);
  { Draw the tire treads }
  A := -Pos / Radius;
  for I := 1 to Nubs do
  begin
    Canvas.MoveTo(Sin(I / Nubs * Pi * 2 + A) * (Radius - 15) + X, Cos(I / Nubs * Pi * 2 + A) * (Radius - 15) + CY);
    Canvas.LineTo(Sin(I / Nubs * Pi * 2 + A) * (Radius + 9) + X, Cos(I / Nubs * Pi * 2 + A) * (Radius + 9) + CY);
  end;
  B := NewBrush([X - Radius, CY - Radius], [X + Radius, CY + Radius], $FF404040, colorBlack);
  P.Width := Radius / 10;
  P.Brush := B;
  Canvas.Stroke(P);
  { Draw the tire white wall }
  R.Inflate(-8, -8);
  Canvas.Ellipse(R);
  Canvas.Stroke(NewPen(colorWhite, 15));
  { Draw the metal rim }
  P := NewPen(0, 8);
  P.Brush := NewBrush([X - Radius, CY - Radius], [X, CY], colorBlack, colorSilver);
  R.Inflate(-6, -6);
  Canvas.Ellipse(R);
  Canvas.Stroke(P);
  { Draw the hub }
  R.Resize(42, 42);
  Canvas.Ellipse(R);
  B := NewBrush([X - 20, CY - 20], [X + 20, CY + 20], colorSilver, $FF808080);
  Canvas.Fill(B);
  { Draw the hole }
  R.Resize(6, 6);
  Canvas.Ellipse(R);
  Canvas.Stroke(NewPen($FF303030, 1), True);
  Canvas.Fill(NewBrush($FF404040));
  { Draw the spokes }
  for I := 1 to Spokes do
  begin
    Canvas.MoveTo(Sin((I + 2) / Spokes * Pi * 2 + A) * 17 + X, Cos((I + 2) / Spokes * Pi * 2 + A) * 17 + CY);
    Canvas.LineTo(Sin(I / Spokes * Pi * 2 + A) * (Radius - 15) + X, Cos(I / Spokes * Pi * 2 + A) * (Radius - 15) + CY);
  end;
  P := NewPen($80000000, 3, capRound);
  Canvas.Stroke(P, True);
  P.Width := 2;
  P.LineCap := capRound;
  P.Brush := NewBrush([X - Radius, CY - Radius], [X, CY], colorBlack, $FF909090);
  Canvas.Stroke(P);
  { Draw the sine wave }
  if DrawSin then
  begin
    I := -300;
    repeat
      X := I - CX;
      A := Sin(X / Radius) * Radius;
      Canvas.MoveTo(I, CY + A);
      I := I + 10;
      X := I - CX;
      A := Sin(X / Radius) * Radius;
      Canvas.LineTo(I, CY + A);
      I := I + 10;
    until I > Width + 300;
    P := NewPen($500000FF, 5);
    P.LineCap := capRound;
    Canvas.Stroke(P);
    X := Pos + CX;
    Canvas.MoveTo(0, CY);
    Canvas.LineTo(Width, CY);
    Canvas.MoveTo(CX, 0);
    Canvas.LineTo(CX, Height);
    Canvas.Stroke(NewPen($40FFFFFF, 1));
  end;
  A := -Pos / Radius + Pi / 2;
  { Draw the triangle }
  if DrawTriangle then
  begin
    { Draw the cosine in black }
    if (Abs(Cos(A)) * Radius > 10) and (Abs(Cos(A)) * Radius < Radius - 1) then
    begin
      Canvas.MoveTo(X, Cos(A) * Radius + CY);
      Canvas.LineTo(Sin(A) * Radius + X, Cos(A) * Radius + CY);
      if Cos(A) < 0 then
      begin
        if Sin(A) > 0 then
        begin
          Canvas.MoveTo(X + 10, Cos(A) * Radius + CY);
          Canvas.LineTo(X + 10, Cos(A) * Radius + CY + 10);
          Canvas.LineTo(X, Cos(A) * Radius + CY + 10);
        end
        else
        begin
          Canvas.MoveTo(X - 10, Cos(A) * Radius + CY);
          Canvas.LineTo(X - 10, Cos(A) * Radius + CY + 10);
          Canvas.LineTo(X, Cos(A) * Radius + CY + 10);
        end;
      end
      else
      begin
        if Sin(A) > 0 then
        begin
          Canvas.MoveTo(X + 10, Cos(A) * Radius + CY);
          Canvas.LineTo(X + 10, Cos(A) * Radius + CY - 10);
          Canvas.LineTo(X, Cos(A) * Radius + CY - 10);
        end
        else
        begin
          Canvas.MoveTo(X - 10, Cos(A) * Radius + CY);
          Canvas.LineTo(X - 10, Cos(A) * Radius + CY - 10);
          Canvas.LineTo(X, Cos(A) * Radius + CY - 10);
        end;
      end;
      Canvas.Stroke(NewPen(colorBlack, 2));
    end;
    { Draw the hypotenuse in red }
    Canvas.MoveTo(X, CY);
    Canvas.LineTo(Sin(A) * Radius + X, Cos(A) * Radius + CY);
    Canvas.Stroke(NewPen(colorRed, 2));
    { Draw the sine in green }
    Canvas.MoveTo(X, CY);
    Canvas.LineTo(X, Cos(A) * Radius + CY);
    Canvas.Stroke(NewPen(colorLime, 2));
  end;
  { Draw the ground }
  R := ClientRect;
  R.y := CY + Radius + 5;
  Ground.Offset := [0, R.y - 65];
  Canvas.FillRect(Ground, R);
  { Draw text information }
  Canvas.Matrix.Identity;
  WriteLine('Press left or right to roll the wheel, and up or down arrows to change the wheel radius');
  WriteLine('Press t to toggle the triangle legs, s to toggle the sin wave, and + / - to zoom');
  WriteMove(10, Height - 80);
  WriteLine('Position %.2f, Velocity %.2f, Zoom %.2f', [Pos, Velocity, Zoom]);
  A := Pos / Radius;
  WriteLine('Angle %.2f°, Radius %.2f', [A * RAD2DEG, Radius * 1.0]);
  WriteLine('Sin(%.2f°) = %.2f * Radius = %.2f', [A * RAD2DEG, Sin(A), Sin(A) * Radius]);
  Canvas.DrawTextStrong(Status, StatusText, Width - 10, Height - 40);
  EndCanvas;
end;

begin
  Application.Title := 'Rolling Wheel Sin(α) Function';
  Application.Width := W;
  Application.Height := H;
  Application.Run(TSineScene);
end.


