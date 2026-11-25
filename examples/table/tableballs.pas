unit TableBalls;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.Gl,
  Raylib.Rl,
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
    { Impact is true if the ball hit a rail or another ball }
    Impact: Boolean;
    Next: PBallHistory;
    procedure Add(const Pos: TVec2; Impact: Boolean);
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
    FPathShader: TShader;
    FNumbers: TTexture2D;
    FIndex: TUniformInt;
    FStick0: TUniformVec3;
    FStick1: TUniformVec3;
    FBallError: TUniformBool;
  public
    Items: array[0..15] of TBall;
    procedure Load;
    procedure Unload;
    { Draw the paths the balls took during the last shot }
    procedure DrawPaths(Camera: TCamera3D);
    procedure Draw(Camera: TCamera3D; Light: TVec3);
  end;

implementation

{ TBallHistory }

procedure TBallHistory.Add(const Pos: TVec2; Impact: Boolean);
var
  N: PBallHistory;
begin
  if Next <> nil then
    Next.Add(Pos, Impact)
  else
  begin
    GetMem(N, SizeOf(TBallHistory));
    N.Pos := Pos;
    N.Time := State.TimeNow;
    N.Impact := Impact;
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
  FBall.TexId1 := State.SkyTex.id;
  FBall.TexName1 := 'probe';
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

  FBall.Shader.GetUniform('errorcorrect', FBallError);
  FPathShader := LoadShader('shaders/path.vert', 'shaders/path.frag');
end;

procedure TTableBalls.Unload;
var
  I: Integer;
begin
  for I := Low(Items) to High(Items) do
    Items[I].History.Release;
  UnloadShader(FPathShader);
  FBall.Unload;
  UnloadTexture(FNumbers);
end;

procedure TTableBalls.DrawPaths(Camera: TCamera3D);
const
  HalfWidth = BallRadius / 4;
  MinLength = 0.001;
  { The wall thickness of hollow circles where 1 is the radius }
  HollowWall = 0.25;
  { TColor is used because Raylib.Graphics declares TColorB as a LongWord }
  Colors: array[0..8] of TColor = (
    (r: 255; g: 255; b: 255; a: 255),
    (r: 255; g: 215; b: 0; a: 255),
    (r: 255; g: 0; b: 0; a: 255),
    (r: 0; g: 0; b: 255; a: 255),
    (r: 128; g: 0; b: 128; a: 255),
    (r: 230; g: 102; b: 0; a: 255),
    (r: 0; g: 128; b: 0; a: 255),
    (r: 140; g: 0; b: 26; a: 255),
    (r: 26; g: 26; b: 26; a: 255));

var
  Eye: TVec2;
  EyeHeight, PixelSize: Single;

  { Find how far a shape of radius R reaches from point P in the direction of D, in
    units of R, with room for the pixels being blended. A pixel covers more of the
    table when it is farther away or seen from a shallow angle. }

  function Reach(const P, D: TVec2; R: Single): Single;
  var
    V: TVec2;
    Dist, Slope: Single;
  begin
    V := P - Eye;
    Dist := Sqrt(V.Dot(V) + EyeHeight * EyeHeight);
    Slope := V.Dot(D) / EyeHeight;
    Result := 1 + 1.5 * PixelSize * Dist * Sqrt(1 + Slope * Slope) / R;
  end;

  { Draw a line with round ends from A to B, or a circle if they are the same, as
    one rectangle which the shader cuts to shape. R is the radius of the ends. If
    Hollow is true then a hollow circle is drawn. See path.vert for how the values
    are used. }

  procedure Shape(const A, B: TVec2; R: Single; Hollow: Boolean; const Color: TColor);
  var
    Center, D, N: TVec2;
    L, Extent: Single;

    { Add a corner at a distance along and across the shape in units of R }

    procedure Corner(U, V: Single);
    begin
      rlTexCoord2f(U, V);
      U := U * R;
      V := V * R;
      rlVertex3f(Center.x + D.x * U + N.x * V, Extent, Center.y + D.y * U + N.y * V);
    end;

  var
    AU, AV, BU, BV: Single;
  begin
    Center := (A + B) / 2;
    L := A.Distance(B) / 2 / R;
    if L > 0 then
    begin
      D := B - A;
      D.Normalize;
    end
    else
      D := Vec(1, 0);
    N := Vec(-D.y, D.x);
    Extent := L;
    if Hollow then
      Extent := -HollowWall;
    AU := L + Reach(A, D, R);
    AV := Reach(A, N, R);
    BU := L + Reach(B, D, R);
    BV := Reach(B, N, R);
    rlCheckRenderBatchLimit(4);
    rlBegin(RL_QUADS);
    rlColor4ub(Color.r, Color.g, Color.b, Color.a);
    Corner(-AU, AV);
    Corner(BU, BV);
    Corner(BU, -BV);
    Corner(-AU, -AV);
    rlEnd;
  end;

var
  H: PBallHistory;
  A, Hit: TVec2;
  C, I: Integer;
begin
  Eye := Vec(Camera.position.x, Camera.position.z);
  EyeHeight := Camera.position.y;
  if EyeHeight < 0.01 then
    EyeHeight := 0.01;
  { The size of a pixel at a distance of one meter }
  PixelSize := Camera.fovy * Pi / 360;
  PixelSize := 2 * Sin(PixelSize) / Cos(PixelSize) / GetScreenHeight;
  BeginMode3D(Camera);
  BeginShaderMode(FPathShader);
  { Paths are blended in order and do not hide each other }
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDepthMask(GL_FALSE);
  for I := Low(Items) to High(Items) do
  begin
    C := 0;
    if I > 0 then
      C := (I - 1) mod 8 + 1;
    A := Items[I].History.Pos;
    Hit := Vec(5000, 5000);
    H := Items[I].History.Next;
    while H <> nil do
    begin
      if A.Distance(H.Pos) > MinLength then
      begin
        Shape(A, H.Pos, HalfWidth, False, Colors[C]);
        A := H.Pos;
      end;
      { Draw a ball size circle at each impact, hollow for stripes }
      if H.Impact and (Hit.Distance(H.Pos) > MinLength) then
      begin
        Shape(H.Pos, H.Pos, BallRadius, I > 8, Colors[C]);
        Hit := H.Pos;
      end;
      H := H.Next;
    end;
  end;
  { Ending the shader draws the paths }
  EndShaderMode;
  glDepthMask(GL_TRUE);
  EndMode3D;
end;

procedure TTableBalls.Draw(Camera: TCamera3D; Light: TVec3);
var
  M: TMat4;
  V, B: TVec3;
  I: Integer;
begin
  if IsKeyPressed(KEY_E) then
    FBallError.Update(not FBallError.value);
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
    if State.Tracking then
    begin
      { The stick is hidden so move its shadow off the table }
      FStick0.Update(Vec(5000, 5000, 5000));
      FStick1.Update(Vec(5001, 5000, 5000));
    end
    else
    begin
      FStick0.Update(State.StickPos[0]);
      FStick1.Update(State.StickPos[1]);
    end;
    M := Items[I].Matrix;
    M.Translate(Items[I].Pos.X, BallRadius, Items[I].Pos.Y);
    FBall.Model.transform := M;
    FBall.Draw(Camera.position, Light);
  end;
  EndMode3D;
end;

end.

