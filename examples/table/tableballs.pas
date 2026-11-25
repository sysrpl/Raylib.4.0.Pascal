unit TableBalls;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.Gl,
  Raylib.Rl,
  Raylib.System,
  Raylib.Graphics,
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
    { How fast a sinking ball rolls into its pocket }
    SinkSpeed: Single;
    { How far and how fast a sinking ball has fallen into its pocket }
    SinkDrop: Single;
    SinkFall: Single;
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
    FBallShader: TShader;
    FPathShader: TShader;
    FNumbers: TTexture2D;
    FEye: TUniformVec3;
    FLight: TUniformVec3;
    FStick0: TUniformVec3;
    FStick1: TUniformVec3;
    FShadows: TUniformBool;
    FReflections: TUniformBool;
    FSmoothing: TUniformInt;
    { The locations of the arrays used by the ball shader }
    FCenters: Integer;
    FTurns: array[0..2] of Integer;
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
  SinkSpeed := 0;
  SinkDrop := 0;
  SinkFall := 0;
  Speed := 0;
  Pos := Vec(5000, 5000);
end;

{ TTableBalls }

{ The tangent of half the field of view }

function ViewTangent(const Camera: TCamera3D): Single;
var
  A: Single;
begin
  A := Camera.fovy * Pi / 360;
  Result := Sin(A) / Cos(A);
end;

const
  { The texture units used by the ball shader }
  ProbeUnit: Integer = 1;
  NumbersUnit: Integer = 2;

procedure TTableBalls.Load;
var
  I: Integer;
begin
  FNumbers := LoadTexture('assets/numbers.png');
  SetTextureFilter(FNumbers, TEXTURE_FILTER_BILINEAR);
  GenTextureMipmaps(FNumbers);
  FBallShader := LoadShader('shaders/ball.vert', 'shaders/ball.frag');
  FBallShader.GetUniform('eye', FEye);
  FBallShader.GetUniform('light', FLight);
  FBallShader.GetUniform('stick[0]', FStick0);
  FBallShader.GetUniform('stick[1]', FStick1);
  FBallShader.GetUniform('shadows', FShadows);
  FBallShader.GetUniform('reflections', FReflections);
  FBallShader.GetUniform('smoothing', FSmoothing);
  FCenters := GetShaderLocation(FBallShader, 'centers');
  FTurns[0] := GetShaderLocation(FBallShader, 'turnx');
  FTurns[1] := GetShaderLocation(FBallShader, 'turny');
  FTurns[2] := GetShaderLocation(FBallShader, 'turnz');
  SetShaderValue(FBallShader, GetShaderLocation(FBallShader, 'probe'),
    @ProbeUnit, SHADER_UNIFORM_INT);
  SetShaderValue(FBallShader, GetShaderLocation(FBallShader, 'numbers'),
    @NumbersUnit, SHADER_UNIFORM_INT);
  for I := Low(Items) to High(Items) do
  begin
    Items[I].Index := I;
    Items[I].Pos := [5000, 5000];
    Items[I].Dir := [1, 0];
    Items[I].Matrix.Identity;
  end;
  FPathShader := LoadShader('shaders/path.vert', 'shaders/path.frag');
end;

procedure TTableBalls.Unload;
var
  I: Integer;
begin
  for I := Low(Items) to High(Items) do
    Items[I].History.Release;
  UnloadShader(FPathShader);
  UnloadShader(FBallShader);
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
  PixelSize := 2 * ViewTangent(Camera) / GetScreenHeight;
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
  Centers: array[0..15] of TVec3;
  Turns: array[0..2, 0..15] of TVec3;
  { The balls in view from the farthest to the nearest }
  Order: array[0..15] of Integer;
  { The square of the distance to each ball in order }
  Dist: array[0..15] of Single;
  F, R, U: TVec3;
  TanH, TanV, PixelSize: Single;
  Count: Integer;

  { Determine if any part of a ball at V from the camera is in the view frustum }

  function InView(const V: TVec3): Boolean;
  var
    Z: Single;
  begin
    Z := V.Dot(F);
    Result := (Z > -BallRadius) and
      (Abs(V.Dot(R)) - Z * TanH < BallRadius * Sqrt(1 + TanH * TanH)) and
      (Abs(V.Dot(U)) - Z * TanV < BallRadius * Sqrt(1 + TanV * TanV));
  end;

  { Add a ball which is in view keeping the farthest balls first }

  procedure Insert(Index: Integer; D: Single);
  var
    J: Integer;
  begin
    J := Count;
    while (J > 0) and (Dist[J - 1] < D) do
    begin
      Order[J] := Order[J - 1];
      Dist[J] := Dist[J - 1];
      Dec(J);
    end;
    Order[J] := Index;
    Dist[J] := D;
    Inc(Count);
  end;

  { Draw a quad facing the camera just large enough to hold a ball }

  procedure Quad(Index: Integer; DistSqr: Single);

    procedure Corner(const P: TVec3);
    begin
      rlVertex3f(P.x, P.y, P.z);
    end;

  var
    C, V, A, B: TVec3;
    D, S: Single;
  begin
    C := Centers[Index];
    V := C - Camera.position;
    D := Sqrt(DistSqr);
    V.Normalize;
    A := V.Cross(Camera.up);
    if A.Distance < 0.001 then
      A := R;
    A.Normalize;
    B := A.Cross(V);
    { In perspective a ball looks larger than its radius, and the rim needs room
      for the pixels being blended }
    S := DistSqr - BallRadius * BallRadius;
    if S < BallRadius * BallRadius * 0.01 then
      S := BallRadius * BallRadius * 0.01;
    S := BallRadius * D / Sqrt(S) + 1.5 * PixelSize * D;
    A := A * S;
    B := B * S;
    rlCheckRenderBatchLimit(4);
    rlBegin(RL_QUADS);
    { A ball fades to black as it falls into a pocket }
    rlTexCoord2f(Index, Items[Index].SinkDrop / SinkDepth);
    Corner(C - A - B);
    Corner(C + A - B);
    Corner(C + A + B);
    Corner(C - A + B);
    rlEnd;
  end;

var
  V: TVec3;
  I, J: Integer;
begin
  F := Camera.target - Camera.position;
  F.Normalize;
  R := F.Cross(Camera.up);
  R.Normalize;
  U := R.Cross(F);
  TanV := ViewTangent(Camera);
  TanH := TanV * GetScreenWidth / GetScreenHeight;
  { The size of a pixel at a distance of one meter }
  PixelSize := 2 * TanV / GetScreenHeight;
  Count := 0;
  for I := Low(Items) to High(Items) do
  begin
    State.BallPos[I] := Items[I].Pos;
    Centers[I] := Vec(Items[I].Pos.X, BallRadius - Items[I].SinkDrop, Items[I].Pos.Y);
    { The columns of the matrix are the axes of the ball in the world }
    for J := 0 to 2 do
      Turns[J, I] := Vec(Items[I].Matrix.m[0, J], Items[I].Matrix.m[1, J],
        Items[I].Matrix.m[2, J]);
    if Items[I].Pocketed then
      Continue;
    V := Centers[I] - Camera.position;
    if InView(V) then
      Insert(I, V.Dot(V));
  end;
  if Count = 0 then
    Exit;
  BeginMode3D(Camera);
  BeginShaderMode(FBallShader);
  { The rims of the balls are blended }
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  FEye.Update(Camera.position);
  FLight.Update(Light);
  FShadows.Update(RenderOptions.Shadows);
  FReflections.Update(RenderOptions.Reflections);
  FSmoothing.Update(RenderOptions.Smoothing);
  if State.Moving or State.Sinking or State.Tracking then
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
  SetShaderValueV(FBallShader, FCenters, @Centers[0], SHADER_UNIFORM_VEC3, 16);
  for J := 0 to 2 do
    SetShaderValueV(FBallShader, FTurns[J], @Turns[J, 0], SHADER_UNIFORM_VEC3, 16);
  glActiveTexture(GL_TEXTURE0 + ProbeUnit);
  glBindTexture(GL_TEXTURE_2D, State.SkyTex.id);
  glActiveTexture(GL_TEXTURE0 + NumbersUnit);
  glBindTexture(GL_TEXTURE_2D, FNumbers.id);
  glActiveTexture(GL_TEXTURE0);
  for I := 0 to Count - 1 do
    Quad(Order[I], Dist[I]);
  { Ending the shader draws all the balls at once }
  EndShaderMode;
  EndMode3D;
  Inc(State.Triangles, Count * 2);
end;

end.

