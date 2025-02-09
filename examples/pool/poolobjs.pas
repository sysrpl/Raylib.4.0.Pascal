unit PoolObjs;

{$mode delphi}

interface

uses
  RayLib, Raylib.Graphics, Raylib.GL, Raylib.RL, SysUtils, Math;

const
  PixelW = 1100;
  PixelH = 600;
  CX = PixelW div 2;
  CY = PixelH div 2;

  BallDiameter = 2.25;
  BallRadius = BallDiameter / 2;
  TableLong = 100;
  TableShort = 50;
  StickLong = 60;

  SinkTime = 0.001;

  SideTop = 1;
  SideRight = 2;
  SideBottom = 3;
  SideLeft = 4;

type
  PBallTrack = ^TBallTrack;
  TBallTrack = record
    Pos: TVec2;
    Color: LongWord;
    Next: PBallTrack;
    procedure Add(const Pos: TVec2);
    procedure Release;
  end;

  TBallTracks = array of TBallTrack;

  TPoolBall = record
    Pos: TVec2;
    Dir: TVec2;
    Speed: Double;
    Color: LongWord;
    Touched: Boolean;
    Sinking: Single;
    SinkPocket: Integer;
    SinkPos: TVec2;
    Pocketed: Boolean;
    Index: Integer;
  end;

  TPoolBalls = array of TPoolBall;

  TPoolPocket = record
    Pos: TVec2;
    Radius: Single;
  end;

  TPoolPockets = array of TPoolPocket;

  TPoolRail = record
    A, B, Mid: TVec2;
    Normal: TVec2;
    Side: Integer;
  end;

  TPoolRails = array of TPoolRail;

  { TPoolTable }

  TPoolTable = record
  private
    Offset: TVec2;
    ScaleX: Single;
    ScaleY: Single;
    Table: ISprite;
    Skirt: ISprite;
    Stick: ISprite;
    Help: ISprite;
    Pockets: TPoolPockets;
    Rails: TPoolRails;
    Power: IBitmapBrush;
    AimTime: Double;
    ShootTime: Double;
    Tracks: TBallTracks;
    RackSounds: array[0..3] of TSound;
    SoftShotSounds: array[0..2] of TSound;
    Preview: TVec2;
    PreviewTarget: TVec2;
    PreviewIndex: Integer;
    NeedsPreview: Boolean;
    PriorStickAngle: Double;
    function ShortestDistance(out Collide: TVec2; out Target: Integer): Boolean;
  public
    Balls: TPoolBalls;
    StickAngle: Double;
    Strength: Double;
    Aim: Boolean;
    Laser: Integer;
    Walls: Boolean;
    Tracking: Boolean;
    Moving: Boolean;
    Zoom: Double;
    Pan: TVec2;
    PanZoom: Boolean;
    Helping: Boolean;
    procedure Init(Canvas: ICanvas);
    procedure Release;
    procedure RackCueBall;
    procedure RackBalls(Setup: Integer);
    procedure Update;
    procedure Shoot;
    procedure DrawTest(Canvas: ICanvas);
    procedure Draw(Canvas: ICanvas);
    function TableToWindow(const P: TVec2): TVec2;
    function WindowToTable(const P: TVec2): TVec2;
  end;

implementation

procedure TBallTrack.Add(const Pos: TVec2);
var
  N: PBallTrack;
begin
  if Next <> nil then
    Next.Add(Pos)
  else
  begin
    GetMem(N, SizeOf(TBallTrack));
    N.Pos := Pos;
    N.Color := Color;
    N.Next := nil;
    Next := N;
  end;
end;

procedure TBallTrack.Release;
begin
  if Next <> nil then
  begin
    Next.Release;
    FreeMem(Next);
  end;
end;

procedure TPoolTable.Init(Canvas: ICanvas);

  function RoR(const V: TVec2): TVec2;
  begin
    Result.x := -V.y;
    Result.y := V.x;
  end;

  function RoL(const V: TVec2): TVec2;
  begin
    Result.x := V.y;
    Result.y := -V.x;
  end;

  procedure RailInit(var R: TPoolRail; Index: Integer);
  begin
    R.Mid := (R.A + R.B) / 2;
    R.Normal := R.B - R.A;
    R.Normal.Normalize;
    if Index < 6 then
      R.Normal := RoR(R.Normal)
    else if Index mod 2 = 0 then
      R.Normal := RoL(R.Normal)
    else
      R.Normal := RoR(R.Normal);
    case Index of
      0, 1, 6..9: R.Side := SideTop;
      2, 10, 11: R.Side := SideRight;
      3, 4, 12..15: R.Side := SideBottom;
      5, 16, 17: R.Side := SideLeft;
    end;
  end;

const
  PocketCornerRadius = 5;
  PocketCornerOffset = 2;
  PocketSideRadius = 4;
  PocketSideOffset = 4;
  CornerRailOffset = 3.8;
  SideRailOffset = 2.75;
var
  S: Double;
  I: Integer;
begin
  Table := NewSprite;
  Table.Bitmap := Canvas.LoadBitmap('assets/table.png');
  Table.Pivot := [0, 0];
  Skirt := NewSprite;
  Skirt.Bitmap := Canvas.LoadBitmap('assets/skirt.png');
  Skirt.Pivot := [0, 0];
  Help := NewSprite;
  Help.Bitmap := Canvas.LoadBitmap('assets/help.png');
  Help.Pivot := [0, 0];
  Offset := [50, 50];
  ScaleX := TableLong / (Table.Bitmap.Width - 100);
  ScaleY := TableShort / (Table.Bitmap.Height - 100);
  Stick := NewSprite;
  Stick.Bitmap := Canvas.LoadBitmap('assets/stick.tga');
  Power := NewBrush(Canvas.LoadBitmap('assets/power.png'));
  Stick.Position := [500, 300];
  S := StickLong / Stick.Bitmap.Width / ScaleX;
  Stick.Scale := [S, S];
  Stick.Pivot := [1, 0.5];
  Stick.Position := [300, 200];
  StickAngle := Pi / 2;
  Strength := 0.5;
  RackSounds[0] := LoadSound('assets/rack0.ogg');
  RackSounds[1] := LoadSound('assets/rack1.ogg');
  RackSounds[2] := LoadSound('assets/rack2.ogg');
  RackSounds[3] := LoadSound('assets/rack3.ogg');
  SoftShotSounds[0] := LoadSound('assets/shot2.ogg');
  SoftShotSounds[1] := LoadSound('assets/shot1.ogg');
  SoftShotSounds[2] := LoadSound('assets/shot0.ogg');
  SetLength(Pockets, 6);
  Pockets[0].Pos := [-PocketCornerOffset, -PocketCornerOffset];
  Pockets[0].Radius := PocketCornerRadius;
  Pockets[1].Pos := [TableLong / 2, -PocketSideOffset];
  Pockets[1].Radius := PocketSideRadius;
  Pockets[2].Pos := [TableLong + PocketCornerOffset, -PocketCornerOffset];
  Pockets[2].Radius := PocketCornerRadius;
  Pockets[3].Pos := [TableLong + PocketCornerOffset, TableShort + PocketCornerOffset];
  Pockets[3].Radius := PocketCornerRadius;
  Pockets[4].Pos := [TableLong / 2, TableShort + PocketSideOffset];
  Pockets[4].Radius := PocketSideRadius;
  Pockets[5].Pos := [-PocketCornerOffset, TableShort + PocketCornerOffset];
  Pockets[5].Radius := PocketCornerRadius;
  SetLength(Rails, 18);
  Rails[0].A := [CornerRailOffset, 0];
  Rails[0].B := [TableLong / 2 - SideRailOffset, 0];
  Rails[1].A := [TableLong / 2 + SideRailOffset, 0];
  Rails[1].B := [TableLong - CornerRailOffset, 0];

  Rails[2].A := [TableLong, CornerRailOffset];
  Rails[2].B := [TableLong, TableShort - CornerRailOffset];
  Rails[3].A := [TableLong - CornerRailOffset, TableShort];
  Rails[3].B := [TableLong / 2 + SideRailOffset, TableShort];

  Rails[4].A := [TableLong / 2 - SideRailOffset, TableShort];
  Rails[4].B := [CornerRailOffset, TableShort];
  Rails[5].A := [0, TableShort - CornerRailOffset];
  Rails[5].B := [0, CornerRailOffset];

  Rails[6].A := Rails[0].A;
  Rails[6].B := Rails[0].A + [-3, -3];
  Rails[7].A := Rails[0].B;
  Rails[7].B := Rails[0].B + [0.5, -3];

  Rails[8].A := Rails[1].A;
  Rails[8].B := Rails[1].A + [-0.5, -3];
  Rails[9].A := Rails[1].B;
  Rails[9].B := Rails[1].B + [3, -3];

  Rails[10].A := Rails[2].A;
  Rails[10].B := Rails[2].A + [3, -3];
  Rails[11].A := Rails[2].B;
  Rails[11].B := Rails[2].B + [3, 3];

  Rails[12].A := Rails[3].A;
  Rails[12].B := Rails[3].A + [3, 3];
  Rails[13].A := Rails[3].B;
  Rails[13].B := Rails[3].B + [-0.5, 3];

  Rails[14].A := Rails[4].A;
  Rails[14].B := Rails[4].A + [0.5, 3];
  Rails[15].A := Rails[4].B;
  Rails[15].B := Rails[4].B + [-3, 3];

  Rails[16].A := Rails[5].A;
  Rails[16].B := Rails[5].A + [-3, 3];
  Rails[17].A := Rails[5].B;
  Rails[17].B := Rails[5].B + [-3, -3];

  for I := Low(Rails) to High(Rails) do
    RailInit(Rails[I], I);
  RackCueBall;
  PanZoom := False;
  Zoom := 1;
  Pan := [0, 0];
end;

procedure TPoolTable.Release;
var
  I: Integer;
begin
  for I := Low(Tracks) to High(Tracks) do
    Tracks[I].Release;
end;

procedure TPoolTable.RackCueBall;
begin
  RackBalls(1);
end;

procedure TPoolTable.RackBalls(Setup: Integer);
const
  Colors: array[0..16] of LongWord = (colorWhite,
    colorGold, colorMediumBlue, $FFD00000, $FFA000A0, colorOrange,
    $FF00B000, colorBurgundy, $FF303030, colorCadetBlue, colorBrown,
    colorAquamarine, colorCrimson, colorBlueViolet, colorDarkGoldenRod,
    colorDarkGreen, colorDarkOrange);
var
  I: Integer;
  A, B: TVec2;
begin
  NeedsPreview := True;
  PreviewIndex := -1;
  Randomize;
  case Setup of
    2:
      begin
        SetLength(Balls, 2);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
      end;
    3:
      begin
        SetLength(Balls, 3);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2 - 0.001, TableShort / 2];
      end;
    4:
      begin
        SetLength(Balls, 4);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2, TableShort / 2];
        Balls[3].Pos := [TableLong * 0.25 - BallRadius * 4, TableShort / 2];
      end;
    5:
      begin
        SetLength(Balls, 4);
        Balls[1].Pos := [TableLong * 0.25 + 6, TableShort / 2 - 7];
        A := Balls[1].Pos;
        B := [0, TableShort];
        B := B - A;
        B.Normalize;
        B := A + B * BallRadius * 2.01;
        Balls[2].Pos := B;
        Balls[3].Pos := [TableLong * 0.25 - 5, TableShort / 2 - 6];
      end;
    6:
      begin
        SetLength(Balls, 7);
        Balls[1].Pos := [TableLong * 0.25 + 4, BallRadius + 0.01];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort - BallRadius - 0.01];
        Balls[3].Pos := [TableLong * 0.25 + 4 - BallRadius * 2 - 0.01, BallRadius + 0.01];
        Balls[4].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 + BallRadius * 2 + 0.01];
        Balls[5].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2];
        Balls[6].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 - BallRadius * 2 - 0.01];
        Balls[6].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 - BallRadius * 2 - 0.01];
      end;
    7:
      begin
        SetLength(Balls, 7);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 + BallRadius + 0.01];
        Balls[3].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 - BallRadius - 0.01];
        Balls[4].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 + BallRadius * 2 + 0.01];
        Balls[5].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2];
        Balls[6].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 - BallRadius * 2 - 0.01];
      end;
    8:
      begin
        SetLength(Balls, 10);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 + BallRadius + 0.01];
        Balls[3].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 - BallRadius - 0.01];
        Balls[4].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 + BallRadius * 2 + 0.01];
        Balls[5].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2];
        Balls[6].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 - BallRadius * 2 - 0.01];
        Balls[7].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 + BallRadius + 0.01];
        Balls[8].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 - BallRadius - 0.01];
        Balls[9].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2];
      end;
    9:
      begin
        SetLength(Balls, 16);
        Balls[1].Pos := [TableLong * 0.25, TableShort / 2];
        Balls[2].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 + BallRadius + 0.01];
        Balls[3].Pos := [TableLong * 0.25 - BallRadius * 2 + 0.2, TableShort / 2 - BallRadius - 0.01];
        Balls[4].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 + BallRadius * 2 + 0.01];
        Balls[5].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2];
        Balls[6].Pos := [TableLong * 0.25 - BallRadius * 4 + 0.4, TableShort / 2 - BallRadius * 2 - 0.01];

        Balls[7].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 + (BallRadius + 0.01) * 3];
        Balls[8].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 - (BallRadius + 0.01) * 3];
        Balls[9].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 + BallRadius + 0.01];
        Balls[10].Pos := [TableLong * 0.25 - BallRadius * 6 + 0.6, TableShort / 2 - BallRadius + 0.01];

        Balls[11].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2 + BallRadius * 4 + 0.02];
        Balls[12].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2 - BallRadius * 4 + 0.02];
        Balls[13].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2];
        Balls[14].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2 + BallRadius * 2 + 0.01];
        Balls[15].Pos := [TableLong * 0.25 - BallRadius * 8 + 1, TableShort / 2 - BallRadius * 2 + 0.01];
      end;
  else
    SetLength(Balls, 1);
  end;
  for I := Low(Balls) to High(Balls) do
  begin
    Balls[I].Index := I;
    Balls[I].Color := Colors[I];
    Balls[I].Dir := [0, 0];
    Balls[I].Pocketed := False;
    Balls[I].Sinking := 0;
    Balls[I].Speed := 0;
    Balls[I].SinkPocket := 0;
    Balls[I].SinkPos := [0, 0];
  end;
  Balls[0].Color := colorWhite;
  Balls[0].Dir := [0, 0];
  Balls[0].Pos := [TableLong * 0.75, TableShort / 2];
  Balls[0].Dir := [0, 0];
  PlaySoundMulti(RackSounds[Random(High(RackSounds) + 1)]);
  for I := Low(Tracks) to High(Tracks) do
    Tracks[I].Release;
  SetLength(Tracks, Length(Balls));
  for I := Low(Balls) to High(Balls) do
  begin
    Tracks[I].Color := Balls[I].Color;
    Tracks[I].Pos := Balls[I].Pos;
    Tracks[I].Next := nil;
  end;
end;

const
  Slice = 0.0001;
  LowLimit = 0.1;
  SpeedLossRail = 0.5;
  SpeedLossHit = 0.95;
  SpeedLossFixed = 2.5;

{ Check if P is left of line L0->L1 }

function IsLeft(const P, L0, L1: TVec2): Boolean;
begin
  Result := ((L1.x - L0.x) * (P.y - L0.y) - (L1.y - L0.y) * (P.x - L0.x)) > 0;
end;

type
  TCollideInfo = record
    Dir: TVec2;
    Speed: Double;
  end;

procedure CollideAB(var A, B: TPoolBall; out AH, BH: TCollideInfo);
var
  D: Double;
begin
  FillChar(AH{%H-}, SizeOf(AH), 0);
  FillChar(BH{%H-}, SizeOf(BH), 0);
  { We are calculating changes of ball A hitting ball B }
  if A.Speed > 0 then
  begin
    { The new direction of B is a vector from A through B }
    BH.Dir := B.Pos - A.Pos;
    BH.Dir.Normalize;
    { D holds the energy percentage tranfered to B }
    D := A.Dir.Dot(BH.Dir);
    { Energy transfer to B }
    BH.Speed := A.Speed * D * SpeedLossHit;
    { The wrong way: A.Speed * (1 - D) * SpeedLossHit;
      Instead we need the angle to calculate percentage retained by A }
    D := ArcCos(D);
    { Energy retained by A }
    AH.Speed := A.Speed * Sin(D) * SpeedLossHit;
    { Finally calculate the output vector of A }
    if IsLeft(B.Pos, A.Pos, A.Pos + A.Dir) then
    begin
      AH.Dir := BH.Dir;
      AH.Dir.x := BH.Dir.y;
      AH.Dir.y := -BH.Dir.x;
    end
    else
    begin
      AH.Dir := BH.Dir;
      AH.Dir.x := -BH.Dir.y;
      AH.Dir.y := BH.Dir.x;
    end;
  end;
  if AH.Speed < 0 then
    AH.Speed := 0;
  if BH.Speed < 0 then
    BH.Speed := 0;
end;

procedure CollideBalls(var A, B: TPoolBall);
var
  AH0, AH1, BH0, BH1: TCollideInfo;
  V: TVec2;
begin
  { If neither ball is moving we have nothing to do }
  if (A.Speed = 0) and (B.Speed = 0) then
    Exit;
  { Calculate velocity and vector changes from A hitting B }
  CollideAB(A, B, AH0, BH0);
  { Calculate velocity and vector changes from B hitting A }
  CollideAB(B, A, BH1, AH1);
  { For ball A add the vectors with magnitudes }
  V := AH0.Dir * AH0.Speed + AH1.Dir * AH1.Speed;
  { The distance of the added vectors is the new speed }
  A.Speed := V.Distance;
  V.Normalize;
  { Finally ball A the has new direction that is normalized }
  A.Dir := V;
  { Repeat for ball B }
  V := BH0.Dir * BH0.Speed + BH1.Dir * BH1.Speed;
  B.Speed := V.Distance;
  V.Normalize;
  B.Dir := V;
end;

function BallRailDistance(var Ball: TPoolBall; var Rail: TPoolRail): Double;
var
  A, B, C, D, E: Double;
begin
  A := Ball.Pos.x - Rail.A.x;
  B := Ball.Pos.y - Rail.A.y;
  C := Rail.B.x - Rail.A.x;
  D := Rail.B.y - Rail.A.y;
  E := A * C + B * D;
  B := C * C + D * D;
  A := -1;
  if B <> 0 then
    A := E / B;
  if A < 0 then
  begin
    E := Rail.A.x;
    B := Rail.A.y;
  end
  else if A > 1 then
  begin
    E := Rail.B.x;
    B := Rail.B.y;
  end
  else
  begin
    E := Rail.A.x + A * C;
    B := Rail.A.y + A * D;
  end;
  A := Ball.Pos.x - E;
  B := Ball.Pos.y - B;
  Result := Sqrt(A * A + B * B);
end;

procedure TPoolTable.Update;

  function Intersecting(var Ball: TPoolBall; Side: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    { Test if the ball is still touching the rail or rail endpoints }
    for I := Low(Rails) to High(Rails) do
    begin
      if Rails[I].Side <> Side then
        Continue;
      if BallRailDistance(Ball, Rails[I]) < (BallRadius + 0.001) then
        Exit(True);
      if Ball.Pos.Distance(Rails[I].A) < (BallRadius + 0.001) then
        Exit(True);
      if Ball.Pos.Distance(Rails[I].B) < (BallRadius + 0.001) then
        Exit(True);
    end;
  end;

  procedure CheckRail(var Ball: TPoolBall; Side: Integer);
  var
    A, B: Double;
    R: TVec2;
    I: Integer;
  begin
    { While checking for rail collision we also check for pocket collision }
    for I := Low(Pockets) to High(Pockets) do
      if Pockets[I].Pos.Distance(Ball.Pos) < Pockets[I].Radius then
      begin
        Ball.SinkPos := Ball.Pos;
        Ball.SinkPocket := I;
        Ball.Sinking := Slice;
        Break;
      end;
    { Set our distance from a rail an reflect vector to invalid values }
    A := 5000;
    R := [0, 0];
    for I := Low(Rails) to High(Rails) do
    begin
      { If the rail is not on the side we've been asked to check then continue }
      if Rails[I].Side <> Side then
        Continue;
      { Find the distance from the ball to the rail }
      B := BallRailDistance(Ball, Rails[I]);
      { If it's less than our last reflect }
      if (B < BallRadius) and (B < A) then
      begin
        A := B;
        R := Rails[I].Normal;
        { Test rail endpoint A }
        B := Ball.Pos.Distance(Rails[I].A) - 0.001;
        if B < A then
        begin
          A := B;
          R := Ball.Pos - Rails[I].A;
          R.Normalize;
        end;
        { Test rail endpoint B }
        B := Ball.Pos.Distance(Rails[I].B) - 0.001;
        if B < A then
        begin
          A := B;
          R := Ball.Pos - Rails[I].B;
          R.Normalize;
        end;
      end;
    end;
    { Exit if there was no rail or rail endpoint reflection }
    if R.Distance = 0 then
      Exit;
    { Reflect the ball from the rail or rail endpoint }
    Ball.Dir := Ball.Dir.Reflect(R);
    repeat
      { Continue moving the ball away from the collision }
      Ball.Pos := Ball.Pos + Ball.Dir * Slice * 10;
    until not Intersecting(Ball, Side);
    { Reduce ball speed due to impact }
    Ball.Speed := Ball.Speed * SpeedLossRail;
    { And track the collision }
    Tracks[Ball.Index].Add(Ball.Pos);
  end;

var
  Move: Double;
  T, S: Double;
  I, J: Integer;
  V: TVec2;
begin
  { Replace the cue ball if it was pocketed }
  if (not Moving) and Balls[0].Pocketed then
  begin
    Balls[0].Dir := [0, 0];
    Balls[0].Pocketed := False;
    Balls[0].Sinking := 0;
    Balls[0].Speed := 0;
    Balls[0].SinkPocket := 0;
    Balls[0].SinkPos := [0, 0];
    Balls[0].Dir := [0, 0];
    Balls[0].Pos := [TableLong * 0.75, TableShort / 2];
    Balls[0].Dir := [0, 0];
    { Play a reracking sound }
    PlaySoundMulti(RackSounds[Random(High(RackSounds) + 1)]);
    NeedsPreview := True;
  end;
  { Animate sinking balls outside our simulation loop }
  for I := Low(Balls) to High(Balls) do
    if Balls[I].Pocketed then
      Continue
    else if Balls[I].Sinking > 0 then
    begin
      S := Balls[I].Sinking + Slice;
      if S > SinkTime then
      begin
        Balls[I].Sinking := SinkTime;
        Balls[I].Pocketed := True;
        Balls[I].Pos := Pockets[Balls[I].SinkPocket].Pos;
        Continue;
      end;
      Balls[I].Sinking := S;
      Balls[I].Pos :=
        Pockets[Balls[I].SinkPocket].Pos * (S / SinkTime) +
        Balls[I].SinkPos * (1 - S / SinkTime);
      Continue;
    end;
  { If there is no movement then there is no more to update }
  if not Moving then
    Exit;
  NeedsPreview := True;
  T := GetTime;
  while ShootTime < T do
  begin
    { Step through time slices }
    ShootTime := ShootTime + Slice;
    { Reset total table ball movement }
    Move := 0;
    for I := Low(Balls) to High(Balls) do
    begin
      Balls[I].Touched := False;
      { Ignore pocketed, sinking, and balls with no movement }
      if Balls[I].Pocketed then
        Continue;
      if Balls[I].Sinking > 0 then
        Continue;
      if Balls[I].Speed = 0 then
        Continue;
      { Apply movement }
      Balls[I].Pos := Balls[I].Pos + Balls[I].Dir * Balls[I].Speed  * Slice;
      { Apply dampening / friction / air resistance }
      Balls[I].Speed := Balls[I].Speed - SpeedLossFixed * Slice;
      { Check for rail collisions }
      if Balls[I].Pos.x < BallRadius then
        CheckRail(Balls[I], SideLeft)
      else if Balls[I].Pos.x > TableLong - BallRadius then
        CheckRail(Balls[I], SideRight)
      else if Balls[I].Pos.y < BallRadius then
        CheckRail(Balls[I], SideTop)
      else if Balls[I].Pos.y > TableShort - BallRadius then
        CheckRail(Balls[I], SideBottom);
      { Any ball moving at less than LowLimit is considered stopped }
      if Balls[I].Speed < LowLimit then
        Balls[I].Speed := 0;
      { Compute the total table ball movement }
      Move := Move + Balls[I].Speed;
    end;
    { Check for ball collision }
    for I := Low(Balls) to High(Balls) do
      for J := Low(Balls) to High(Balls) do
      begin
        { A ball cannot collide with itself }
        if I = J then Continue;
        { Ignore collisions for pocketed or sinking balls }
        if Balls[I].Pocketed or (Balls[I].Sinking > 0) then Continue;
        if Balls[J].Pocketed or (Balls[J].Sinking > 0) then Continue;
        { If the ball we are hitting has already been touched then continue }
        if Balls[J].Touched then Continue;
        { If balls are not colliding then continue }
        if Balls[I].Pos.Distance(Balls[J].Pos) >= BallDiameter then Continue;
        { Mark the current ball as touched }
        Balls[I].Touched := True;
        { Make sure balls are no longer touching }
        V := Balls[I].Pos - Balls[J].Pos;
        V.Normalize;
        V := V * BallDiameter;
        Balls[I].Pos := Balls[J].Pos + V;
        { Track the collision }
        Tracks[I].Add(Balls[I].Pos);
        Tracks[J].Add(Balls[J].Pos);
        { Alter the two balls direction and speed }
        CollideBalls(Balls[I], Balls[J]);
      end;
    { Stop the simulation if there is zero total ball movement }
    if Move = 0 then
    begin
      { Track the end position }
      for I := Low(Balls) to High(Balls) do
        Tracks[I].Add(Balls[I].Pos);
      { Point the cue stick at the center of the table }
      StickAngle := TableToWindow(Balls[0].Pos).Angle([CX, CY]) + Pi;
      Moving := False;
      Break;
    end;
  end;
end;

procedure TPoolTable.Shoot;
const
  MinStrength = 0.01;
var
  V: TVec2;
  I: Integer;
begin
  { Shooting is not allowed while balls are moving or the cue ball is sinking }
  if Balls[0].Pocketed or (Balls[0].Sinking > 0) or Moving then
    Exit;
  { Do not shoot if the strength is below a minimum value }
  if Strength < MinStrength then
    Exit;
  ShootTime := GetTime;
  { Turn off aiming and turn on moving }
  Aim := False;
  Moving := True;
  { Play a pool stick shootign sound }
  Randomize;
  if Strength > 0.5 then
    PlaySound(SoftShotSounds[High(SoftShotSounds)])
  else
    PlaySound(SoftShotSounds[Random(High(SoftShotSounds))]);
  { Computer the cue ball vector and speed }
  V := [1, 0];
  V := V.Rotate(Pi + Pi / 2 - StickAngle);
  Balls[0].Dir := V;
  Balls[0].Speed := Math.Power(Strength, 1.5) * TableLong * 2;
  { Erase the prior ball tracking paths }
  for I := Low(Tracks) to High(Tracks) do
    Tracks[I].Release;
  { Create new ball tracking paths }
  SetLength(Tracks, Length(Balls));
  for I := Low(Balls) to High(Balls) do
  begin
    Tracks[I].Color := Balls[I].Color;
    Tracks[I].Pos := Balls[I].Pos;
    Tracks[I].Next := nil;
  end;
end;

function CircleCollision(const A, B, Dir: TVec2; R: Single; out C: TVec2): Boolean;
var
  AB: TVec2;
  ProjectionLength, ClosestDistanceSquared, MovementDistanceSquared: Single;
begin
  // Calculate the vector from A to B
  AB := B - A;
  // Project AB onto Dir (the movement direction of A)
  ProjectionLength := AB.Dot(Dir);
  // If the projection is negative, A is moving away from B
  if ProjectionLength < 0 then
    Exit(False);
  // Calculate the point on the line where A is closest to B
  C := A + ProjectionLength * Dir;
  // Calculate the squared distance from this closest point to B
  ClosestDistanceSquared := (B - C).Dot(B - C);
  // Check if the closest distance is less than or equal to 2 * R
  if ClosestDistanceSquared > 4 * R * R then
    Exit(False);
  // If a collision occurs, adjust C to where circle A touches circle B
  MovementDistanceSquared := 4 * R * R - ClosestDistanceSquared;
  C := C - Sqrt(MovementDistanceSquared) * Dir;
  Result := True;
end;

function LeftOrRight(const A, B, V: TVec2): Integer;
var
  AB: TVec2;
  CrossProduct: Single;
begin
  // Calculate the vector from A to B
  AB := B - A;

  // Compute the 2D cross product of V and AB
  CrossProduct := V.X * AB.Y - V.Y * AB.X;
  // Determine the relative position of B
  if CrossProduct > 0 then
    Result := 1 // Circle B is to the left of the line
  else if CrossProduct < 0 then
    Result := -1 // Circle B is to the right of the line
  else
    Result := 0; // Circle B is exactly on the line
end;

function TPoolTable.ShortestDistance(out Collide: TVec2; out Target: Integer): Boolean;
var
  A, B, D, V: TVec2;
  M: Single;
  I: Integer;
begin
  Result := False;
  Collide := Vec(0, 0);
  M := 0;
  A := Balls[0].Pos;
  V := Vec(0, 1);
  V := V.Rotate(-StickAngle);
  for I := 1 to High(Balls) do
  begin
    B := Balls[I].Pos;
    if CircleCollision(A, B, V, BallRadius, D) then
    begin
      if (D.x < BallRadius) or (D.y < BallRadius) or
        (D.x > TableLong - BallRadius) or (D.y > TableShort - BallRadius) then
        Continue;

      if Result then
      begin
        if A.Distance(D) < M then
        begin
          Collide := D;
          Target := I;
          M := A.Distance(Collide);
        end;
      end
      else
      begin
        Collide := D;
        Target := I;
        M := A.Distance(Collide);
      end;
      Result := True;
    end;
  end;
end;

procedure TPoolTable.DrawTest(Canvas: ICanvas);
var
  W: Single;
  A, B, C, V: TVec2;
  I: Integer;
begin
  W := 2 * ScaleX;
  Canvas.MoveTo(0, 0);
  Canvas.LineTo(Table.Bitmap.Width, 0);
  Canvas.LineTo(Table.Bitmap.Width, Table.Bitmap.Height);
  Canvas.LineTo(0, Table.Bitmap.Height);
  Canvas.ClosePath;
  Canvas.Stroke(NewPen(colorRed, 20, capRound));
  Canvas.Matrix.Push;
  Canvas.Matrix.Scale(1 / ScaleX, 1 / ScaleY);
  Canvas.Matrix.Translate(Offset.X, Offset.Y);
  { Draw cue ball }
  A := Balls[0].Pos;
  with A do
    Canvas.Ellipse(X - BallRadius, Y - BallRadius, BallDiameter, BallDiameter);
  Canvas.Stroke(NewPen(colorYellow, W, capRound));
  { Draw other balls }
  for I := 1 to High(Balls) do
  begin
    A := Balls[I].Pos;
    with A do
      Canvas.Ellipse(X - BallRadius, Y - BallRadius, BallDiameter, BallDiameter);
    Canvas.Stroke(NewPen(colorBlack, W, capRound));
  end;
  { Draw red laser }
  A := Balls[0].Pos;
  Canvas.MoveTo(A.X, A.Y);
  B := Vec(0, 0);
  B.Y := 1000;
  B := B.Rotate(-StickAngle);
  B := A + B;
  Canvas.LineTo(B.X, B.Y);
  Canvas.Stroke(NewPen(colorRed, W / 2, capRound));
  { Draw collisions }
  if ShortestDistance(C, I) then
  begin
    with C do
      Canvas.Ellipse(X - BallRadius, Y - BallRadius, BallDiameter, BallDiameter);
    Canvas.Stroke(NewPen(colorTeal, W, capRound));
    B := Balls[I].Pos;
    V := B - C;
    V.Normalize;
    I := LeftOrRight(A, B, V);
    V := V * 1000;
    Canvas.MoveTo(C.X, C.Y);
    Canvas.LineTo(V.X + C.X, V.Y + C.Y);
    Canvas.Stroke(NewPen(colorLime, W, capRound));
    if I > 0 then
    begin
      Canvas.MoveTo(C.X, C.Y);
      Canvas.LineTo(-V.Y + C.X, V.X + C.Y);
      Canvas.Stroke(NewPen(colorLime, W, capRound));
    end
    else if I < 0 then
    begin
      Canvas.MoveTo(C.X, C.Y);
      Canvas.LineTo(V.Y + C.X, -V.X + C.Y);
      Canvas.Stroke(NewPen(colorLime, W, capRound));
    end;
  end;
  Canvas.Matrix.Pop;
end;

procedure TPoolTable.Draw(Canvas: ICanvas);

  function LeftOrRight(A, B, C: TVec2): Integer;
  var
    CrossProduct: Double;
  begin
    CrossProduct := (B.X - A.X) * (C.Y - A.Y) - (B.Y - A.Y) * (C.X - A.X);
    if CrossProduct > 0 then
      Result := -1 // C is to the left of line A-B
    else if CrossProduct < 0 then
      Result := 1 // C is to the right of line A-B
    else
      Result := 0; // C is on the line A-B
  end;

  procedure DashedLine(A, B: TVec2; Offset, Space: Double);
  var
    N, C: TVec2;
    I: Integer;
  begin
    N := B - A;
    N.Normalize;
    N := N.Rotate(Pi / 2);
    A := A + N * Offset;
    B := B + N * Offset;
    N := B - A;
    N.Normalize;
    C := A;
    I := 0;
    while C.Distance(B) > Space do
    begin
      if I mod 2 = 0 then
        Canvas.MoveTo(C.x, C.y)
      else
        Canvas.LineTo(C.x, C.y);
      C := C + N * Space;
      Inc(I);
    end;
  end;

  procedure DrawAim;
  const
    Inner = 50;
    Outer = 300;
    Max = CY - Outer / 2 + 10;
    Min = CY - Inner / 2 - 15;
  var
    S: Double;
    R: TRect;
  begin
    R := [CX - Inner / 2, CY - Inner / 2, Inner, Inner];
    Canvas.Ellipse(R);
    Canvas.Stroke(colorBlack, 2, True);
    Canvas.Fill(colorWhite);
    R := [CX - Outer / 2, CY - Outer / 2, Outer, Outer];
    Canvas.Ellipse(R);
    Canvas.Stroke(colorBlack, 6, True);
    Canvas.Stroke(colorWhite, 4);
    if Strength > 0 then
    begin
      Canvas.Matrix.Push;
      Canvas.Matrix.RotateAt(StickAngle + Pi, CX, CY);
      S := Max * Strength + Min * (1 - Strength);
      Canvas.MoveTo(CX - 15, S + 10);
      Canvas.LineTo(CX, S);
      Canvas.LineTo(CX + 15, S + 10);
      Canvas.Stroke(NewPen(colorBlack, 10, capSquare), True);
      Canvas.Stroke(NewPen(colorWhite, 8, capSquare));
      Canvas.Matrix.Pop;
    end;
  end;

  procedure DrawPower;
  const
    PY = PixelH - 75;
    PW = 200;
    PH = 50;
  begin
    Canvas.MoveTo(CX - PW / 2, PY);
    Canvas.LineTo((CX - PW / 2) + PW * Strength, PY);
    Canvas.LineTo((CX - PW / 2) + PW * Strength, PY - PH * Strength);
    Power.Offset := [CX - PW / 2, 0];
    Canvas.Fill(Power);
    Canvas.MoveTo(CX - PW / 2, PY);
    Canvas.LineTo(CX + PW / 2, PY);
    Canvas.LineTo(CX + PW / 2, PY - PH);
    Canvas.ClosePath;
    Canvas.Stroke(colorBlack, 5, True);
    Canvas.Stroke(colorWhite, 3);
  end;

  procedure GeneratePreview;
  var
    C: TVec2;
    T: Integer;
  begin
    Preview := [-1000, -1000];
    PreviewTarget := [-1100, -1100];
    PreviewIndex := -1;
    if ShortestDistance(C, T) then
    begin
      Preview := C;
      PreviewTarget := Balls[T].Pos;
      PreviewIndex := T;
    end;

  end;

  {const
    Step = 0.001;
  var
    B, V: TVec2;
    I: Integer;
  begin
    if not NeedsPreview then
      Exit;
    Preview := [-1000, -1000];
    PreviewTarget := [-1100, -1100];
    PreviewIndex := -1;
    NeedsPreview := False;
    B := Balls[0].Pos;
    V := [Step, 0];
    V := V.Rotate(Pi + Pi / 2 - StickAngle);
    repeat
      for I := 1 to High(Balls) do
      begin
        if Balls[I].Pocketed then Continue;
        if Balls[I].Sinking > 0 then Continue;
        if B.Distance(Balls[I].Pos) < BallDiameter then
        begin
          Preview := B;
          PreviewTarget := Balls[I].Pos;
          PreviewIndex := I;
          Exit;
        end;
      end;
      B := B + V;
    until (B.x < BallRadius) or (B.y < BallRadius) or
      (B.x > TableLong - BallRadius) or (B.y > TableShort - BallRadius);
  end;}

  function IsRight: Integer;
  const
    Epsilon = 0.001;
  var
    A, B, C: TVec2;
    D: Double;
  begin
    if PreviewIndex < 0 then
      Exit(0);
    A := Balls[0].Pos;
    B := Balls[PreviewIndex].Pos;
    C := Vec(0, 10);
    C := C.Rotate(-StickAngle);
    C := C + A;
    D := (B.x - A.x) * (C.y - A.y) - (B.y - A.y) * (C.x - A.x);
    if D > Epsilon then
      Result := -1
    else if D < -Epsilon then
      Result := 1
    else
      Result := 0;
  end;

var
  B: TPoolBall;
  R: TRect;
  C0, C1: TColorF;
  G: IRadialGradientBrush;
  P0, P1: TVec2;
  N: PBallTrack;
  P: TPoolPocket;
  L: TPoolRail;
  I: Integer;
begin
  Strength := Clamp(Strength);
  Canvas.Rect(-10000, -10000, 20000, 20000);
  Canvas.Fill(colorBlack);
  Canvas.Matrix.Scale(Zoom, Zoom);
  Canvas.Matrix.Translate(Pan.X, Pan.Y);
  Canvas.DrawSprite(Table);
  Canvas.Opacity := 0.5;
  if PriorStickAngle <> StickAngle then
    NeedsPreview := True;
  PriorStickAngle := StickAngle;
  if not PanZoom then
    if Aim then
    begin
      AimTime := GetTime;
      DrawAim;
      DrawPower;
    end
    else if GetTime - AimTime < 0.3 then
    begin
      Canvas.Opacity := 0.5 * (1 - (GetTime - AimTime) / 0.3);
      DrawAim;
      DrawPower;
    end;
  Canvas.Opacity := 1;
  Canvas.Matrix.Push;
  Canvas.Matrix.Identity;
  Canvas.Matrix.Translate(Offset.X, Offset.Y);
  Canvas.Matrix.ScaleAt(1 / ScaleX, 1 / ScaleY, Offset.X, Offset.Y);
  Canvas.Matrix.Scale(Zoom, Zoom);
  Canvas.Matrix.Translate(Pan.x, Pan.y);
  for B in Balls do
  begin
    if B.Pocketed then Continue;
    R := [B.Pos.x - BallRadius, B.Pos.y - BallRadius, BallDiameter, BallDiameter];
    C0 := colorBlack;
    C0.A := 0.3;
    C1 := colorBlack;
    C1.A := 0;
    R.Inflate(BallRadius / 2, BallRadius / 2);
    R.Move(BallRadius / 2, BallRadius / 2);
    Canvas.Ellipse(R);
    G := NewBrush(R, C0, C1);
    G.NearStop.Offset := 0.2;
    G.FarStop.Offset := 0.5;
    Canvas.Fill(G);
  end;
  for B in Balls do
  begin
    if B.Pocketed then Continue;
    R := [B.Pos.x - BallRadius, B.Pos.y - BallRadius, BallDiameter, BallDiameter];
    Canvas.Ellipse(R);
    R.Move(-BallRadius / 2, -BallRadius / 2);
    C0 := B.Color;
    C1 := C0.Mix(colorBlack, 0.7);
    G := NewBrush(R, C0, C1);
    if B.Sinking > 0 then
      Canvas.Opacity := 1 - B.Sinking / SinkTime;
    Canvas.Fill(G, True);
    Canvas.Stroke($FF404040, ScaleX);
    if B.Sinking > 0 then
      Canvas.Opacity := 1;
  end;
  if Walls then
    for P in Pockets do
    begin
      R := [P.Pos.x - P.Radius, P.Pos.y - P.Radius, P.Radius * 2, P.Radius * 2];
      Canvas.Ellipse(R);
      Canvas.Stroke(colorBlue, 3 * ScaleX);
    end;
  if Walls then
    for L in Rails do
    begin
      Canvas.MoveTo(L.A.x, L.A.y);
      Canvas.LineTo(L.B.x, L.B.y);
      Canvas.Stroke(colorBlue, 3 * ScaleX);
      Canvas.MoveTo(L.Mid.x, L.Mid.y);
      Canvas.LineTo(L.Mid.x + L.Normal.x, L.Mid.y + L.Normal.y);
      Canvas.Stroke(colorRed, 3 * ScaleX);
    end;
  Canvas.Opacity := 0.7;
  if Tracking then
    for I := Low(Tracks) to High(Tracks) do
    begin
      R := [Tracks[I].Pos.x - BallRadius, Tracks[I].Pos.y - BallRadius, BallDiameter, BallDiameter];
      Canvas.Ellipse(R);
      Canvas.Fill(Tracks[I].Color);
      R := [Tracks[I].Pos.x - 0.25, Tracks[I].Pos.y - 0.25, 0.5, 0.5];
      Canvas.Ellipse(R);
      Canvas.Fill(colorBlack);
      Canvas.MoveTo(Tracks[I].Pos.x, Tracks[I].Pos.y);
      N := Tracks[I].Next;
      while N <> nil do
      begin
        Canvas.LineTo(N.Pos.x, N.Pos.y);
        Canvas.Stroke(NewPen(N.Color, BallRadius, capRound));
        R := [N.Pos.x - BallRadius, N.Pos.y - BallRadius, BallDiameter, BallDiameter];
        Canvas.Ellipse(R);
        Canvas.Fill(N.Color);
        R := [N.Pos.x - 0.25, N.Pos.y - 0.25, 0.5, 0.5];
        Canvas.Ellipse(R);
        Canvas.Fill(colorBlack, False); Canvas.Fill(colorBlack, False);
        Canvas.MoveTo(N.Pos.x, N.Pos.y);
        N := N.Next;
      end;
      Canvas.Stroke(NewPen(Tracks[I].Color, BallRadius, capRound));
    end;
  Canvas.Opacity := 1;
  if Tracking then
    for I := Low(Tracks) to High(Tracks) do
    begin
      R := [Tracks[I].Pos.x - 0.1, Tracks[I].Pos.y - 0.1, 0.2, 0.2];
      Canvas.Ellipse(R);
      Canvas.Fill(colorBlack);
      N := Tracks[I].Next;
      while N <> nil do
      begin
        R := [N.Pos.x - 0.1, N.Pos.y - 0.1, 0.2, 0.2];
        Canvas.Ellipse(R);
        Canvas.Fill(colorBlack);
        N := N.Next;
      end;
      Canvas.Stroke(NewPen(Tracks[I].Color, BallRadius, capRound));
    end;
  Canvas.Matrix.Pop;
  Laser := Laser mod 5;
  if (not Balls[0].Pocketed) and (Balls[0].Sinking = 0) and
    (not Moving) and (not Tracking) then
    if Laser > 0 then
    begin
      P0 := [-BallRadius * 1.5 / ScaleX, 0];
      P0 := P0.Rotate(Pi / 2 - StickAngle);
      P1 := TableToWindow(Balls[0].Pos);
      Canvas.MoveTo(P0.x + P1.x, P0.y + P1.y);
      Canvas.LineTo(P0.x * 1000 + P1.x, P0.y * 1000 + P1.y);
      if Laser > 1 then
      begin
        DashedLine([P0.x + P1.x, P0.y + P1.y], [P0.x * 1000 + P1.x, P0.y * 1000 + P1.y],
          BallRadius / ScaleX, 5);
        DashedLine([P0.x + P1.x, P0.y + P1.y], [P0.x * 1000 + P1.x, P0.y * 1000 + P1.y],
          -BallRadius / ScaleX, 5);
      end;
      if Laser > 2 then
      begin
        GeneratePreview;
        P0 := TableToWindow(Preview);
        P1.x := BallRadius / ScaleX;
        R := [P0.x - P1.x, P0.y - P1.x, P1.x * 2, P1.x * 2];
        Canvas.Ellipse(R);
      end;
      Canvas.Stroke(NewPen($80FF0000, 2));
      if Laser > 3 then
      begin
        P1 := TableToWindow(PreviewTarget);
        P1 := (P1 - P0) * 2000 + P0;
        Canvas.MoveTo(P0.x, P0.y);
        Canvas.LineTo(P1.x, P1.y);
        Canvas.MoveTo(P0.x, P0.y);
        I := IsRight;
        if I <> 0 then
        begin
          P1 := P1.Rotate(P0, Pi / 2 * IsRight);
          Canvas.LineTo(P1.x, P1.y);
        end;
        Canvas.Stroke(NewPen($80FF00FF, 2, capRound));
      end;
    end;
  Canvas.DrawSprite(Skirt);
  if (not PanZoom) and (not Balls[0].Pocketed) and (Balls[0].Sinking = 0) and
    (not Moving) and (not Tracking) then
  begin
    P0 := TableToWindow(Balls[0].Pos);
    Stick.Rotation := StickAngle + Pi / 2;
    Stick.Position := P0;
    Stick.Pivot := [0.99 + (Sin(GetTime * 2) + 2) / 50, 0.5];
    Canvas.DrawSprite(Stick);
  {

    P0 :=  [0, 0]; // + Pan * Zoom; // TableToWindow(Balls[0].Pos);
    //Stick.Rotation := StickAngle + Pi / 2;
    // Stick.Rotation := Pi / 2;

    Stick.Position := P0;
    Stick.Pivot := [1, 0.5];
    // Stick.Pivot := [0.99 + (Sin(GetTime * 2) + 2) / 50, 0.5];
    //Canvas.Matrix.Translate(CX, CY);
    // Canvas.Matrix.Rotate(Pi * 1.75);
    Canvas.DrawSprite(Stick);
   }
  end;
  // Canvas.Clip(0, 0, 100, 1000);
  if Helping then
    Canvas.DrawSprite(Help);
  // Canvas.Unclip;
end;

function TPoolTable.WindowToTable(const P: TVec2): TVec2;
begin
  Result := P - Offset;
  Result.X := Result.X * ScaleX;
  Result.Y := Result.Y * ScaleY;
end;

function TPoolTable.TableToWindow(const P: TVec2): TVec2;
begin
  if PanZoom then
  begin
    Result.X := P.X / ScaleX;
    Result.Y := P.Y / ScaleY;
    Result := Result + Offset;
  end
  else
  begin
    Result.X := P.X / ScaleX;
    Result.Y := P.Y / ScaleY;
    Result := Result + Offset;
  end;
end;

end.

