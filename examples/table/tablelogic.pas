unit TableLogic;

{$mode Delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  Math,
  TableBalls,
  TableStick,
  TableVars;


type
  TPocket = record
    Pos: TVec2;
    Radius: Single;
  end;

  TPockets = array of TPocket;

  TRail = record
    A, B, Mid: TVec2;
    Normal: TVec2;
    Side: Integer;
  end;

  TRails = array of TRail;

  TableSounds = record
  private
    FRack: array[0..3] of TSound;
    FShot: array[0..1] of TSound;
    FTap: array[0..3] of TSound;
    FPocket: array[0..1] of TSound;
  public
    procedure Load;
    procedure Unload;
    procedure Rack;
    procedure Shot(Strong: Boolean);
    procedure Tap(Strong: Boolean);
    procedure Pocket;
  end;

{ TTableLogic }

  TTableLogic = record
  private
    FPockets: TPockets;
    FRails: TRails;
    FCenter: TVec2;
    FBalls: ^TTableBalls;
    FStick: ^TTableStick;
    FSounds: TableSounds;
    procedure Shuffle;
    procedure Rack(Index: Integer);
    function ShortestDistance(out Collide: TVec2; out Target: Integer): Boolean;
    procedure Update;
    procedure Shoot;
  public
    procedure Debug(C: ICanvas);
    procedure Load(var Balls: TTableBalls; var Stick: TTableStick);
    procedure Unload;
    { Process input }
    procedure Track;
    { React to movement and physics }
    procedure Think;
  end;

implementation

var
  Breaking: Boolean;

procedure TableSounds.Load;
begin
  Randomize;
  FRack[0] := LoadSound('assets/rack0.ogg');
  FRack[1] := LoadSound('assets/rack1.ogg');
  FRack[2] := LoadSound('assets/rack2.ogg');
  FRack[3] := LoadSound('assets/rack3.ogg');
  FShot[0] := LoadSound('assets/shot0.ogg');
  FShot[1] := LoadSound('assets/shot1.ogg');
  FTap[0] := LoadSound('assets/tap0.ogg');
  FTap[1] := LoadSound('assets/tap1.ogg');
  FTap[2] := LoadSound('assets/tap2.ogg');
  FTap[3] := LoadSound('assets/tap3.ogg');
  FPocket[0] := LoadSound('assets/pocket0.mp3');
  FPocket[1] := LoadSound('assets/pocket1.mp3');
  PlaySoundMulti(FPocket[0]);
end;

procedure TableSounds.Unload;
begin
  UnloadSound(FRack[0]);
  UnloadSound(FRack[1]);
  UnloadSound(FRack[2]);
  UnloadSound(FRack[3]);
  UnloadSound(FShot[0]);
  UnloadSound(FShot[1]);
  UnloadSound(FTap[0]);
  UnloadSound(FTap[1]);
  UnloadSound(FTap[2]);
  UnloadSound(FTap[3]);
  UnloadSound(FPocket[0]);
  UnloadSound(FPocket[1]);
end;

procedure TableSounds.Rack;
begin
  PlaySoundMulti(FRack[Random(4)]);
end;

procedure TableSounds.Shot(Strong: Boolean);
begin
  if Strong then
    PlaySoundMulti(FShot[1])
  else
    PlaySoundMulti(FShot[0]);
end;

procedure TableSounds.Tap(Strong: Boolean);
var
  I: Integer;
begin
  I := 0;
  if Strong then
    I := 2;
  PlaySoundMulti(FTap[Random(2) + I])
end;

procedure TableSounds.Pocket;
begin
  PlaySoundMulti(FPocket[Random(2)]);
end;

{ TTableLogic }

const
  SinkTime = 0.001;
  SideTop = 1;
  SideRight = 2;
  SideBottom = 3;
  SideLeft = 4;

  Slice = 0.0001;
  LowLimit = 0.005;
  SpeedLossRail = 0.5;
  SpeedLossHit = 0.975;
  SpeedLossFixed = 0.05;

function Clamp(Value, Min, Max: Double): Double;
begin
  if Value < Min then
    Result := Min
  else if Value > Max then
    Result := Max
  else
    Result := Value;
end;

procedure MoveTo(C: ICanvas; V: TVec2);
begin
  V := V * [PixelsX, PixelsY];
  C.MoveTo(V.X + CenterX, V.Y + CenterY);
end;

procedure LineTo(C: ICanvas; V: TVec2);
begin
  V := V * [PixelsX, PixelsY];
  C.LineTo(V.X + CenterX, V.Y + CenterY);
end;

procedure Circle(C: ICanvas; V: TVec2; R: Single);
begin
  V := V * [PixelsX, PixelsY];
  C.Circle(V.X + CenterX, V.Y + CenterY, R * PixelsX);
end;

procedure Stroke(C: ICanvas; Color: TColorF);
begin
  C.Stroke(Color, 3);
end;

procedure TTableLogic.Debug(C: ICanvas);
var
  V: TVec2;
  I: Integer;
begin
  if not State.Aiming then
    Exit;
  if not IsKeyDown(KEY_W) then
    Exit;
  for I := Low(FPockets) to High(FPockets) do
    Circle(C, FPockets[I].Pos, FPockets[I].Radius);
  Stroke(C, colorYellow);
  for I := Low(FRails) to High(FRails) do
  begin
    MoveTo(C, FRails[I].A);
    LineTo(C, FRails[I].B);
    case FRails[I].Side of
      SideTop: Stroke(C, colorBlue);
      SideBottom: Stroke(C, colorRed);
      SideLeft: Stroke(C, colorLime);
      SideRight: Stroke(C, colorFuchsia);
    end
  end;
  for I := Low(FRails) to High(FRails) do
  begin
    MoveTo(C, FRails[I].Mid);
    V := FRails[I].Mid + FRails[I].Normal * 0.04;
    LineTo(C, V);
    Stroke(C, colorAquamarine);
  end;
end;

{$region loading}
procedure TTableLogic.Load(var Balls: TTableBalls; var Stick: TTableStick);

  procedure RailInit(var R: TRail; Index: Integer);
  begin
    R.Mid := (R.A + R.B) / 2;
    R.Normal := R.B - R.A;
    R.Normal.Normalize;
    case Index of
      4..7, 12..16: R.Normal := R.Normal.RoL;
    else
      R.Normal := R.Normal.RoR;
    end;
    case Index of
      1..3, 13..15: R.Side := SideTop;
      0, 4, 16: R.Side := SideRight;
      5..7, 9..11: R.Side := SideBottom;
      8, 12, 17: R.Side := SideLeft;
    end;
  end;

var
  I: Integer;
begin
  FSounds.Load;
  FBalls := @Balls;
  FStick := @Stick;
  FCenter := [CenterX, CenterY];
  SetLength(FPockets, 6);
  { Six pockets }
  FPockets[0].Pos := TVec2(CornerCenter);
  FPockets[0].Radius := CornerRadius;
  FPockets[1].Pos := TVec2(SideCenter);
  FPockets[1].Radius := SideRadius;
  FPockets[2].Pos := TVec2(CornerCenter) * [-1, 1];
  FPockets[2].Radius := CornerRadius;
  FPockets[3].Pos := TVec2(CornerCenter) * [1, -1];
  FPockets[3].Radius := CornerRadius;
  FPockets[4].Pos := TVec2(SideCenter) * [1, -1];
  FPockets[4].Radius := SideRadius;
  FPockets[5].Pos := TVec2(CornerCenter) * [-1, -1];
  FPockets[5].Radius := CornerRadius;
  SetLength(FRails, 18);
  { Top right }
  FRails[0].A := [WallQuadrant[0], WallQuadrant[1]];
  FRails[0].B := [WallQuadrant[2], WallQuadrant[3]];
  FRails[1].A := [WallQuadrant[4], WallQuadrant[5]];
  FRails[1].B := [WallQuadrant[6], WallQuadrant[7]];
  FRails[2].A := [WallQuadrant[6], WallQuadrant[7]];
  FRails[2].B := [WallQuadrant[8], WallQuadrant[9]];
  FRails[3].A := [WallQuadrant[8], WallQuadrant[9]];
  FRails[3].B := [WallQuadrant[10], WallQuadrant[11]];
  { Bottom right }
  FRails[4].A := [WallQuadrant[0], -WallQuadrant[1]];
  FRails[4].B := [WallQuadrant[2], -WallQuadrant[3]];
  FRails[5].A := [WallQuadrant[4], -WallQuadrant[5]];
  FRails[5].B := [WallQuadrant[6], -WallQuadrant[7]];
  FRails[6].A := [WallQuadrant[6], -WallQuadrant[7]];
  FRails[6].B := [WallQuadrant[8], -WallQuadrant[9]];
  FRails[7].A := [WallQuadrant[8], -WallQuadrant[9]];
  FRails[7].B := [WallQuadrant[10], -WallQuadrant[11]];
  { Bottom left }
  FRails[8].A := [-WallQuadrant[0], -WallQuadrant[1]];
  FRails[8].B := [-WallQuadrant[2], -WallQuadrant[3]];
  FRails[9].A := [-WallQuadrant[4], -WallQuadrant[5]];
  FRails[9].B := [-WallQuadrant[6], -WallQuadrant[7]];
  FRails[10].A := [-WallQuadrant[6], -WallQuadrant[7]];
  FRails[10].B := [-WallQuadrant[8], -WallQuadrant[9]];
  FRails[11].A := [-WallQuadrant[8], -WallQuadrant[9]];
  FRails[11].B := [-WallQuadrant[10], -WallQuadrant[11]];
  { Top left }
  FRails[12].A := [-WallQuadrant[0], WallQuadrant[1]];
  FRails[12].B := [-WallQuadrant[2], WallQuadrant[3]];
  FRails[13].A := [-WallQuadrant[4], WallQuadrant[5]];
  FRails[13].B := [-WallQuadrant[6], WallQuadrant[7]];
  FRails[14].A := [-WallQuadrant[6], WallQuadrant[7]];
  FRails[14].B := [-WallQuadrant[8], WallQuadrant[9]];
  FRails[15].A := [-WallQuadrant[8], WallQuadrant[9]];
  FRails[15].B := [-WallQuadrant[10], WallQuadrant[11]];
  { Right }
  FRails[16].A := [WallQuadrant[0], WallQuadrant[1]];
  FRails[16].B := [WallQuadrant[0], -WallQuadrant[1]];
  { Left }
  FRails[17].A := [-WallQuadrant[0], WallQuadrant[1]];
  FRails[17].B := [-WallQuadrant[0], -WallQuadrant[1]];
  for I := Low(FRails) to High(FRails) do
    RailInit(FRails[I], I);
  Shuffle;
  State.StickPower := 0.25;
end;

procedure TTableLogic.Unload;
begin
  FSounds.Unload;
end;
{$endregion}

{$region racking}
procedure TTableLogic.Shuffle;
const
  Radius = 1.25 / 12 / 3.2808;
  Width = 100 / 12 / 3.2808 - Radius * 2;
  Depth = 50 / 12 / 3.2808 - Radius * 2;

  function NoCollide(Index: Integer): Boolean;
  var
    J: Integer;
  begin
    Result := True;
    for J := 0 to Index - 1 do
    begin
      if FBalls.Items[J].Pocketed then
        Continue;
      Result := FBalls.Items[J].Pos.Distance(FBalls.Items[Index].Pos) > BallDiameter + 0.0001;
      if not Result then
        Break;
    end;
  end;

var
  M: TMat4;
  I: Integer;
begin
  Breaking := False;
  for I := Low(FBalls.Items) to High(FBalls.Items) do
  begin
    FBalls.Items[I].Reset;
    FBalls.Items[I].Pocketed := (Random < 0.2) and (I > 0);
    if FBalls.Items[I].Pocketed then
    begin
      State.BallPos[I] := FBalls.Items[I].Pos;
      Continue;
    end;
    M.Identity;
    M.Rotate(Random * 360, Random * 360, Random * 360);
    FBalls.Items[I].Matrix := M;
    repeat
      FBalls.Items[I].Pos.x := Random * Width - Width / 2;
      FBalls.Items[I].Pos.y := Random * Depth - Depth / 2;
    until NoCollide(I);
    State.BallPos[I] := FBalls.Items[I].Pos;
  end;
  State.StickDir := [-1, 0];
  State.StickAngle := Pi;
  State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
  FSounds.Rack;
end;

procedure TTableLogic.Rack(Index: Integer);
const
  S = 0.0001;
  RackX = 1.732050808 * BallRadius + 0.001;
  RackY = BallDiameter / 2 + 0.001;
var
  A, B: TVec2;
  M: TMat4;
  I: Integer;
begin
  Breaking := False;
  for I := Low(FBalls.Items) to High(FBalls.Items) do
  begin
    FBalls.Items[I].Reset;
    M.Identity;
    M.Rotate(Random * 360, Random * 360, Random * 360);
    FBalls.Items[I].Matrix := M;
  end;
  FBalls.Items[0].Pocketed := False;
  FBalls.Items[0].Pos := Vec(SlateX / 4, 0);
  case Index of
    2:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[1].Pos := [SlateX / -4, 0];
      end;
    3:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[1].Pos := [SlateX * -0.25, 0];
        FBalls.Items[2].Pos := [SlateX * -0.25 - BallDiameter - S, 0];
      end;
    4:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[1].Pos := [SlateX * -0.25 - BallDiameter - S, 0];
        FBalls.Items[2].Pos := [SlateX * -0.25, 0];
        FBalls.Items[3].Pos := [SlateX * -0.25 + BallDiameter + S, 0];
      end;
    5:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[1].Pos := [-0.4, -0.1];
        A := FBalls.Items[1].Pos;
        B := A - [-SlateHalfX, SlateHalfZ];
        B.Normalize;
        B := A + B * BallRadius * 2.01;
        FBalls.Items[2].Pos := B;
        FBalls.Items[3].Pos := [-0.6, -0.05];
      end;
    6:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[4].Pocketed := False;
        FBalls.Items[5].Pocketed := False;
        FBalls.Items[6].Pocketed := False;
        FBalls.Items[1].Pos := [SlateX * -0.25, -(SlateZ / 2 - BallRadius - S)];
        FBalls.Items[2].Pos := [SlateX * -0.25 - BallDiameter - S,  -(SlateZ / 2 - BallRadius - S)];
        FBalls.Items[3].Pos := [SlateX * -0.20, BallDiameter + S];
        FBalls.Items[4].Pos := [SlateX * -0.20, -(BallDiameter + S)];
        FBalls.Items[5].Pos := [SlateX * -0.20, 0];
        FBalls.Items[6].Pos := [SlateX * -0.20, (SlateZ / 2 - BallRadius - S)];
      end;
    7:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[4].Pocketed := False;
        FBalls.Items[5].Pocketed := False;
        FBalls.Items[6].Pocketed := False;
        FBalls.Items[1].Pos := [SlateX * -0.25, 0];
        FBalls.Items[2].Pos := [SlateX * -0.25 - BallDiameter, BallRadius + 0.001];
        FBalls.Items[3].Pos := [SlateX * -0.25 - BallDiameter, -BallRadius - 0.001];
        FBalls.Items[4].Pos := [SlateX * -0.25 - BallDiameter * 2, +BallDiameter + 0.001];
        FBalls.Items[5].Pos := [SlateX * -0.25 - BallDiameter * 2, 0];
        FBalls.Items[6].Pos := [SlateX * -0.25 - BallDiameter * 2, -BallDiameter - 0.001];
      end;
    8:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[4].Pocketed := False;
        FBalls.Items[5].Pocketed := False;
        FBalls.Items[6].Pocketed := False;
        FBalls.Items[7].Pocketed := False;
        FBalls.Items[8].Pocketed := False;
        FBalls.Items[9].Pocketed := False;
        FBalls.Items[1].Pos := [-0.63500,  0.00000];
        FBalls.Items[2].Pos := [-0.68667,  0.02983];
        FBalls.Items[3].Pos := [-0.68667, -0.02983];
        FBalls.Items[4].Pos := [-0.73833,  0.05965];
        FBalls.Items[9].Pos := [-0.73833,  0.00000];
        FBalls.Items[5].Pos := [-0.73833, -0.05965];
        FBalls.Items[6].Pos := [-0.78998,  0.02983];
        FBalls.Items[7].Pos := [-0.84163,  0.00000];
        FBalls.Items[8].Pos := [-0.78998, -0.02983];
        { Give the breaks a bit of extra power }
        Breaking := True;
      end;
    9:
      begin
        FBalls.Items[1].Pocketed := False;
        FBalls.Items[2].Pocketed := False;
        FBalls.Items[3].Pocketed := False;
        FBalls.Items[4].Pocketed := False;
        FBalls.Items[5].Pocketed := False;
        FBalls.Items[6].Pocketed := False;
        FBalls.Items[7].Pocketed := False;
        FBalls.Items[8].Pocketed := False;
        FBalls.Items[9].Pocketed := False;
        FBalls.Items[10].Pocketed := False;
        FBalls.Items[11].Pocketed := False;
        FBalls.Items[12].Pocketed := False;
        FBalls.Items[13].Pocketed := False;
        FBalls.Items[14].Pocketed := False;
        FBalls.Items[15].Pocketed := False;
        A := [-SlateHalfX / 2,  0.00000];
        FBalls.Items[1].Pos := A;
        FBalls.Items[2].Pos := [A.X - RackX * 2, RackY * 2];
        FBalls.Items[3].Pos := [A.X - RackX * 4, RackY * 4];
        FBalls.Items[4].Pos := [A.X - RackX * 2, RackY * -2];
        FBalls.Items[5].Pos := [A.X - RackX * 3, RackY * -1];
        FBalls.Items[6].Pos := [A.X - RackX * 4, RackY * -4];
        FBalls.Items[7].Pos := [A.X - RackX * 4, 0];
        FBalls.Items[8].Pos := [A.X - RackX * 2, 0];
        FBalls.Items[9].Pos := [A.X - RackX, RackY];
        FBalls.Items[10].Pos := [A.X - RackX * 4, RackY * 2];
        FBalls.Items[11].Pos := [A.X - RackX, -RackY];
        FBalls.Items[12].Pos := [A.X - RackX * 3, RackY * 1];
        FBalls.Items[13].Pos := [A.X - RackX * 3, RackY * 3];
        FBalls.Items[14].Pos := [A.X - RackX * 4, RackY * -2];
        FBalls.Items[15].Pos := [A.X - RackX * 3, RackY * -3];
        Breaking := True;
      end;
  end;
  State.StickDir := [-1, 0];
  State.StickAngle := Pi;
  State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
  FSounds.Rack;
end;
{$endregion}

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

procedure CollideAB(var A, B: TBall; out AH, BH: TCollideInfo);
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
    D := A.Dir.DotClamp(BH.Dir);
    { Energy transfer to B }
    BH.Speed := A.Speed * D * SpeedLossHit;
    if Breaking then
      BH.Speed := BH.Speed * 2;
    Breaking := False;
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

procedure CollideBalls(var A, B: TBall);
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

function DistToRailNeg(P: TVec2; var Rail: TRail): Double;
var
  A, B: TVec2;
  D: Double;
begin
  A := P - Rail.A;
  B := Rail.B - Rail.A;
  D := Clamp(A.Dot(B) / B.Dot(B), 0.0, 1.0);
  D := TVec2(A - B * D).Distance;
  A := P - Rail.A;
  A.Normalize;
  if Rail.Normal.Dot(A) < 0 then
    Result := -D
  else
    Result := D;
end;

function DistToRail(P: TVec2; var Rail: TRail): Double;
var
  A, B: TVec2;
begin
  A := P - Rail.A;
  B := Rail.B - Rail.A;
  Result := Clamp(A.Dot(B) / B.Dot(B), 0.0, 1.0);
  Result := TVec2(A - B * Result).Distance;
end;

function CircleCollision(const A, B, Dir: TVec2; R: Single; out C: TVec2): Boolean;
var
  AB: TVec2;
  ProjectionLength, ClosestDistanceSquared, MovementDistanceSquared: Single;
begin
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

function TTableLogic.ShortestDistance(out Collide: TVec2; out Target: Integer): Boolean;
var
  Bounds: TRect;
  A, B, D, V: TVec2;
  M: Single;
  I: Integer;
begin
  Result := False;
  Collide := Vec(5000, 5000);
  Target := -1;
  if FBalls.Items[0].Pocketed then
    Exit;
  Bounds.X := SlateX / -2 + BallRadius;
  Bounds.Y := SlateZ / -2 + BallRadius;
  Bounds.Width := SlateX - BallRadius * 2;
  Bounds.Height := SlateZ - BallRadius * 2;
  M := 0;
  A := FBalls.Items[0].Pos;
  V := State.StickDir;
  for I := 1 to High(FBalls.Items) do
  begin
    if FBalls.Items[I].Pocketed then
      Continue;
    B := FBalls.Items[I].Pos;
    if CircleCollision(A, B, V, BallRadius, D) then
    begin
      if (D.x < Bounds.Left) or (D.y < Bounds.Top) or
        (D.x > Bounds.Right) or (D.y > Bounds.Bottom) then
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

procedure TTableLogic.Shoot;
const
  MinStrength = 0.01;
var
  I: Integer;
begin
  { Shooting is not allowed while balls are moving or the cue ball is sinking }
  if FBalls.Items[0].Pocketed or (FBalls.Items[0].Sinking > 0) or State.Moving then
    Exit;
  { Do not shoot if the strength is below a minimum value }
  if State.StickPower < MinStrength then
    Exit;
  State.TimeShoot := State.TimeNow;
  { Turn off aiming and turn on moving }
  State.Aiming := False;
  State.Moving := True;
  { Play a pool stick shooting sound }
  FSounds.Shot(State.StickPower > 0.5);
  { Computer the cue ball vector and speed }
  FBalls.Items[0].Dir := State.StickDir;
  FBalls.Items[0].Speed := Power(State.StickPower, 2) * SlateX * 2;
  { Reset the prior shot tracking nodes }
  for I := Low(FBalls.Items) to High(FBalls.Items) do
  begin
    FBalls.Items[I].History.Release;
    FBalls.Items[I].History.Pos := FBalls.Items[I].Pos;
    FBalls.Items[I].History.Time := State.TimeNow;
  end;
end;

procedure TTableLogic.Track;
var
  Slow: Single;
  I: Integer;
begin
  State.TimeNow := TimeQuery;
  if State.Moving then
    Exit;
  if IsKeyPressed(KEY_SPACE) then
  begin
    { Shoot begins ball movement setting State.Moving to True }
    Shoot;
    Exit;
  end;
  for I := KEY_ONE to KEY_NINE do
    if IsKeyPressed(I) then
    begin
      Rack(I - KEY_ONE + 1);
      Break;
    end;
  if IsKeyPressed(KEY_F5) then
    Shuffle;
  if (IsKeyDown(KEY_LEFT_SHIFT) or IsKeyDown(KEY_RIGHT_SHIFT)) then
    Slow := 0.05
  else
    Slow := 1;
  if IsKeyDown(KEY_UP) or IsKeyDown(KEY_DOWN) then
  begin
    if IsKeyDown(KEY_UP) then
      State.StickPower := State.StickPower + Slow * State.TimeFrame;
    if IsKeyDown(KEY_DOWN) then
      State.StickPower := State.StickPower - Slow * State.TimeFrame;
    State.StickPower := Clamp(State.StickPower, 0.01, 1);
  end;
  if IsKeyDown(KEY_LEFT) or IsKeyDown(KEY_RIGHT) then
  begin
    if IsKeyDown(KEY_LEFT) then
      State.StickDir := State.StickDir.Rotate(Slow * State.TimeFrame);
    if IsKeyDown(KEY_RIGHT) then
      State.StickDir := State.StickDir.Rotate(-Slow * State.TimeFrame);
    State.StickDir.Normalize;
    State.StickAngle := State.StickDir.Angle([1, 0]);
    State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
  end;
  State.Aiming := False;
  if State.Overhead then
  begin
    State.Aiming := IsMouseButtonDown(MOUSE_BUTTON_LEFT);
    if State.Aiming then
    begin
      State.StickDir := GetMousePosition;
      State.StickPower := State.StickDir.Distance(FCenter) / (WindowHeight / 2 - 20);
      if State.StickPower > 1 then
        State.StickPower := 1;
      State.StickDir := State.StickDir - FCenter;
      State.StickDir.Normalize;
      State.StickAngle := State.StickDir.Angle([1, 0]);
      State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
    end;
  end;
end;

procedure TTableLogic.Update;

  function Intersecting(var Ball: TBall; Side: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    { Test if the ball is still touching the rail or rail endpoints }
    for I := Low(FRails) to High(FRails) do
    begin
      if FRails[I].Side <> Side then
        Continue;
      if DistToRail(Ball.Pos, FRails[I]) < (BallRadius + 0.001) then
        Exit(True);
    end;
  end;

  procedure CheckRail(var Ball: TBall; Side: Integer);
  var
    A, B: Double;
    R: TVec2;
    I: Integer;
  begin
    { While checking for rail collision we also check for pocket collision }
    for I := Low(FPockets) to High(FPockets) do
      if FPockets[I].Pos.Distance(Ball.Pos) < FPockets[I].Radius then
      begin
        Ball.SinkPos := Ball.Pos;
        Ball.SinkPocket := I;
        Ball.Sinking := Slice;
        Break;
      end;
    { Set our distance from a rail an reflect vector to invalid values }
    A := 5000;
    R := [0, 0];
    for I := Low(FRails) to High(FRails) do
    begin
      { If the rail is not on the side we've been asked to check then continue }
      if FRails[I].Side <> Side then
        Continue;
      { Find the distance from the ball to the rail }
      B := DistToRail(Ball.Pos, FRails[I]);
      { If it's less than our last reflect }
      if (B < BallRadius) and (B < A) then
      begin
        A := B;
        R := FRails[I].Normal;
        { Test rail endpoint A }
        B := Ball.Pos.Distance(FRails[I].A) - 0.001;
        if B < A then
        begin
          A := B;
          R := Ball.Pos - FRails[I].A;
          R.Normalize;
        end;
        { Test rail endpoint B }
        B := Ball.Pos.Distance(FRails[I].B) - 0.001;
        if B < A then
        begin
          A := B;
          R := Ball.Pos - FRails[I].B;
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
      Ball.Pos := Ball.Pos + Ball.Dir * Slice * 10; // ONE * 10;
    until not Intersecting(Ball, Side);
    { Reduce ball speed due to impact }
    Ball.Speed := Ball.Speed * SpeedLossRail;
    { And track the collision }
    Ball.History.Add(Ball.Pos);
  end;

var
  Move: Double;
  A, B: PBall;
  T, S: Double;
  I, J: Integer;
  V, R: TVec2;
begin
  { Replace the cue ball if it was pocketed }
  if (not State.Moving) and FBalls.Items[0].Pocketed then
  begin
    B := @FBalls.Items[0];
    B.Dir := [0, 1];
    B.Pocketed := False;
    B.Sinking := 0;
    B.Speed := 0;
    B.SinkPocket := 0;
    B.SinkPos := [0, 0];
    B.Dir := [0, 1];
    B.Pos := [SlateZ * 0.5, 0];
    State.StickDir := [-1, 0];
    State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
  end;
  { Animate sinking balls outside our simulation loop }
  for I := Low(FBalls.Items) to High(FBalls.Items) do
  begin
    B := @FBalls.Items[I];
    if B.Pocketed then
      Continue
    else if B.Sinking > 0 then
    begin
      S := B.Sinking + Slice;
      if S > SinkTime then
      begin
        B.Reset;
        B.Sinking := SinkTime;
        FSounds.Pocket;
        Continue;
      end;
      B.Sinking := S;
      B.Pos :=
        FPockets[B.SinkPocket].Pos * (S / SinkTime) +
        B.SinkPos * (1 - S / SinkTime);
      Continue;
    end;
  end;
  { If there is no movement then there is no more to update }
  if not State.Moving then
    Exit;
  //NeedsPreview := True;
  T := State.TimeNow;
  while State.TimeShoot < T do
  begin
    { Step through time slices }
    State.TimeShoot := State.TimeShoot + Slice;
    { Reset total table ball movement }
    Move := 0;
    for I := Low(FBalls.Items) to High(FBalls.Items) do
    begin
      B := @FBalls.Items[I];
      B.Touched := False;
      { Ignore pocketed, sinking, and balls with no movement }
      if B.Pocketed then
        Continue;
      if B.Sinking > 0 then
        Continue;
      if B.Speed = 0 then
        Continue;
      { Apply movement }
      V := B.Pos;
      B.Pos := B.Pos + B.Dir * B.Speed * Slice;
      { Apply rolling rotation }
      R := B.Dir.RoL;
      B.Matrix := B.Matrix * RotateAxis(V.Distance(B.Pos) / BallRadius, Vec(R.X, 0, R.Y));
      { Apply dampening / friction / air resistance }
      B.Speed := B.Speed - SpeedLossFixed * Slice;
      { Check for rail collisions }
      if B.Pos.x < -SlateHalfX + BallRadius then
        CheckRail(B^, SideLeft)
      else if B.Pos.x > SlateHalfX - BallRadius then
        CheckRail(B^, SideRight)
      else if B.Pos.y > SlateHalfZ - BallRadius then
        CheckRail(B^, SideTop)
      else if B^.Pos.y < -SlateHalfZ + BallRadius  then
        CheckRail(B^, SideBottom);
      { Any ball moving at less than LowLimit is considered stopped }
      if B.Speed < LowLimit then
        B.Speed := 0;
      { Compute the total table ball movement }
      Move := Move + B.Speed;
    end;
    { Check for ball collision }
    for I := Low(FBalls.Items) to High(FBalls.Items) do
      for J := Low(FBalls.Items) to High(FBalls.Items) do
      begin
        { A ball cannot collide with itself }
        if I = J then Continue;
        A := @FBalls.Items[I];
        B := @FBalls.Items[J];
        { Ignore collisions for pocketed or sinking balls }
        if A.Pocketed or (A.Sinking > 0) then Continue;
        if B.Pocketed or (B.Sinking > 0) then Continue;
        { If the ball we are hitting has already been touched then continue }
        if B.Touched then Continue;
        { If balls are not colliding then continue }
        if A.Pos.Distance(B.Pos) >= BallDiameter then Continue;
        { Mark the current ball as touched }
        A.Touched := True;
        { Make sure balls are no longer touching }
        V := A.Pos - B.Pos;
        V.Normalize;
        V := V * TouchDiameter;
        A.Pos := B.Pos + V;
        { Track the collision }
        A.History.Add(A.Pos);
        B.History.Add(B.Pos);
        { Alter the two balls direction and speed }
        CollideBalls(A^, B^);
        FSounds.Tap(A.Speed + B.Speed > 1.5);
      end;
    { Stop the simulation if there is zero total ball movement }
    if Move = 0 then
    begin
      { Track the end position }
      for I := Low(FBalls.Items) to High(FBalls.Items) do
        FBalls.Items[I].History.Add(FBalls.Items[I].Pos);
      { Point the cue stick at the center of the table }
      State.StickDir := Vec(0, 0) - FBalls.Items[0].Pos;
      State.StickDir.Normalize;
      State.StickAngle := State.StickDir.Angle([1, 0]);
      State.Collides := ShortestDistance(State.CollidePoint, State.CollideIndex);
      State.Moving := False;
      Break;
    end;
  end;
end;

procedure TTableLogic.Think;
begin
  Update;
end;

end.

