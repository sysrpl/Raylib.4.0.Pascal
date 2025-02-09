unit TableBalls;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  TableModel,
  TableVars;

{ TBallTrack }

type
  PBallHistory = ^TBallHistory;
  TBallHistory = record
    Pos: TVec2;
    Time: Double;
    Next: PBallHistory;
    procedure Add(const Pos: TVec2);
    procedure Release;
  end;

{ TBalls }

  PBall = ^TBall;
  TBall = record
    Pos: TVec2;
    Dir: TVec2;
    Speed: Double;
    Color: LongWord;
    Touched: Boolean;
    Sinking: Single;
    SinkPocket: Integer;
    SinkPos: TVec2;
    Matrix: TMat4;
    Pocketed: Boolean;
    Tabled: Boolean;
    Index: Integer;
    History: TBallHistory;
    procedure Reset;
  end;

{ TTableBalls }

  TTableBalls = record
  private
    FBall: TTableModel;
    FNumbers: TTexture2D;
    FIndex: TUniformInt;
    FStick0: TUniformVec3;
    FStick1: TUniformVec3;
  public
    Items: array[0..15] of TBall;
    procedure Load;
    procedure Unload;
    procedure Draw(Camera: TCamera3D; Light: TVec3);
  end;

implementation

{ TBallHistory }

procedure TBallHistory.Add(const Pos: TVec2);
var
  N: PBallHistory;
begin
  if Next <> nil then
    Next.Add(Pos)
  else
  begin
    GetMem(N, SizeOf(TBallHistory));
    N.Pos := Pos;
    N.Time := State.TimeNow;
    N.Next := nil;
    Next := N;
  end;
end;

procedure TBallHistory.Release;
begin
  if Next <> nil then
  begin
    Next.Release;
    FreeMem(Next);
    Next := nil;
  end;
end;

procedure TBall.Reset;
begin
  Pocketed := True;
  SinkPocket := 0;
  Sinking := 0;
  Speed := 0;
  Pos := Vec(5000, 5000);
  History.Release;
end;

{ TTableBalls }

procedure TTableBalls.Load;
var
  I: Integer;
begin
  FNumbers := LoadTexture('assets/numbers.png');
  SetTextureFilter(FNumbers, TEXTURE_FILTER_BILINEAR);
  GenTextureMipmaps(FNumbers);
  FBall.Load('ball', 'ball');
  FBall.TexId := State.SkyTex.id;
  FBall.TexName := 'probe';
  FBall.TexId2 := FNumbers.id;
  FBall.TexName2 := 'numbers';
  FBall.Shader.GetUniform('index', FIndex);
  FBall.Shader.GetUniform('stick[0]', FStick0);
  FBall.Shader.GetUniform('stick[1]', FStick1);
  for I := Low(Items) to High(Items) do
  begin
    Items[I].Index := I;
    Items[I].Pos := [5000, 5000];
    Items[I].Dir := [1, 0];
    Items[I].Matrix.Identity;
  end;
end;

procedure TTableBalls.Unload;
var
  I: Integer;
begin
  for I := Low(Items) to High(Items) do
    Items[I].History.Release;
  FBall.Unload;
  UnloadTexture(FNumbers);
end;

procedure TTableBalls.Draw(Camera: TCamera3D; Light: TVec3);
var
  M: TMat4;
  V, B: TVec3;
  I: Integer;
begin
  V := Camera.target - Camera.position;
  V.Normalize;
  B.Y := BallRadius;
  BeginMode3D(Camera);
  for I := Low(Items) to High(Items) do
  begin
    State.BallPos[I] := Items[I].Pos;
    if Items[I].Pocketed then
      Continue;
    { Eliminate balls that are behind the camera }
    B.X := Items[I].Pos.X;
    B.Z := Items[I].Pos.Y;
    if V.Dot(B - Camera.position) < -BallRadius then
      Continue;
    FIndex.Update(I);
    FStick0.Update(State.StickPos[0]);
    FStick1.Update(State.StickPos[1]);
    M := Items[I].Matrix;
    M.Translate(Items[I].Pos.X, BallRadius, Items[I].Pos.Y);
    FBall.Model.transform := M;
    FBall.Draw(Camera.position, Light);
  end;
  EndMode3D;
end;

end.

