program Sine;

uses
  RayLib,
  Raylib.Graphics,
  Raylib.App;

type
  TJumperScene = class(TScene)
  protected
    Background: IBitmap;
    Run: ISprite;
    Idle: ISprite;
    Jump: ISprite;
    Sprite: ISprite;
    Dir: Integer;
    X, Y: Single;
    Ground: Single;
    Velocity: Single;
    Boost: Boolean;
    Jumping: Boolean;
    JumpShort: Boolean;
    JumpTime: Double;
    JumpVelocity: Single;
    Animation: Single;
    procedure Load; override;
    procedure Logic(Width, Height: Integer; StopWatch: TStopWatch); override;
    procedure Render(Width, Height: Integer; StopWatch: TStopWatch); override;
  end;

procedure TJumperScene.Load;
begin
  inherited Load;
  Background := Canvas.LoadBitmap('background.png');
  Run := NewSprite;
  Run.Bitmap := Canvas.LoadBitmap('run.tga');
  Run.Cols := 10;
  Idle := NewSprite;
  Idle.Bitmap := Canvas.LoadBitmap('idle.tga');
  Idle.Cols := 10;
  Jump := NewSprite;
  Jump.Bitmap := Canvas.LoadBitmap('jump.tga');
  Jump.Cols := 10;
  Sprite := Idle;
  Sprite.Position := Vec(100, 260);
  Dir := 1;
  Ground := 360;
  X := 100;
  Y := Ground;
end;

procedure TJumperScene.Logic(Width, Height: Integer; StopWatch: TStopWatch);
const
  Accel = 200;
  Speed = 300;
  JumpSpeed = 800;
  Edge = 40;
var
  WasPositive: Boolean;
  WasNegative: Boolean;
begin
  if not Jumping then
    Boost := IsKeyDown(KEY_LEFT_SHIFT);
  if IsKeyPressed(KEY_SPACE) and not Jumping then
  begin
    Jumping := True;
    JumpShort := False;
    JumpVelocity := JumpSpeed;
    JumpTime := StopWatch.Time;
  end;
  if IsKeyDown(KEY_LEFT) then
  begin
    Velocity := Velocity - StopWatch.TimeFrame * Accel;
  end
  else if IsKeyDown(KEY_RIGHT) then
  begin
    Velocity := Velocity + StopWatch.TimeFrame * Accel;
  end
  else
  begin
    if not Jumping then
      Boost := False;
    WasPositive := Velocity > 0;
    WasNegative := Velocity < 0;
    if Velocity <> 0 then
    begin
      Velocity :=  Velocity - StopWatch.TimeFrame * Accel * Dir * 2;
      if (Velocity < 0) and WasPositive then
        Velocity := 0
      else if (Velocity > 0) and WasNegative then
        Velocity := 0;
    end;
  end;
  if Velocity <> 0 then
    if Abs(Velocity) > Speed then
      Velocity := Speed * Dir;
  if Velocity <> 0 then
    if Boost then
      X := X + Velocity * 2 * StopWatch.TimeFrame
    else
      X := X + Velocity * StopWatch.TimeFrame;
  if X < Edge then
  begin
    X := Edge;
    Boost := False;
    Velocity := 0;
  end;
  if X > Width - Edge then
  begin
    X := Width - Edge;
    Boost := False;
    Velocity := 0;
  end;
  if Velocity = 0 then
    Sprite := Idle
  else
    Sprite := Run;
  if Jumping then
  begin
    Sprite := Jump;
    if (StopWatch.Time - JumpTime < 1) and (not JumpShort) and (not IsKeyDown(KEY_SPACE)) then
    begin
      JumpShort := True;
      JumpVelocity := JumpVelocity - StopWatch.TimeFrame * 15000;
    end;
    JumpVelocity := JumpVelocity - StopWatch.TimeFrame * 2000;
    Y := Y - JumpVelocity * StopWatch.TimeFrame;
    if Y > Ground then
    begin
      Y := Ground;
      Jumping := False;
      if Velocity = 0 then
        Sprite := Idle
      else
        Sprite := Run;
    end;
  end;
  if Velocity > 0 then
    Dir := 1
  else if Velocity < 0 then
    Dir := -1;
  Sprite.Scale := Vec(Dir, 1);
  Sprite.Position := Vec(X, Y);
  if Jumping then
  begin
    Sprite.Cell := Trunc((StopWatch.Time - JumpTime) * 10);
    if Sprite.Cell > Sprite.Cols - 1 then
      Sprite.Cell := Sprite.Cols - 1;
  end
  else if Velocity = 0 then
    Sprite.Cell := Trunc(StopWatch.Time * 20) mod 11
  else
  begin
    Animation := Animation + Abs(Velocity) * StopWatch.TimeFrame / 8;
    while Animation >= Sprite.Cols do
      Animation := Animation - Sprite.Cols;
    Sprite.Cell := Trunc(Animation);
  end;
end;

procedure TJumperScene.Render(Width, Height: Integer; StopWatch: TStopWatch);
var
  R: TRect;
begin
  inherited;
  BeginCanvas(Width, Height);
  R := Background.ClientRect;
  R.y := Height - R.height + 100;
  Canvas.DrawImage(Background, Background.ClientRect, R);
  Canvas.DrawSprite(Sprite);
  EndCanvas;
end;

begin
  Application.Title := 'Ninja';
  Application.Run(TJumperScene);
end.


