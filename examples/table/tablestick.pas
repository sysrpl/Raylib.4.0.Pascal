unit TableStick;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  TableModel,
  TableVars;

{ TTableStick }

type
  TTableStick = record
  private
    FStick: TTableModel;
    FWrap: TTexture2D;
  public
    Pos: TVec2;
    Angle: TVec2;
    Power: Single;
    procedure Load;
    procedure Unload;
    procedure Draw(Camera: TCamera3D; Light: TVec3);
  end;

implementation

{ TTableStick }

procedure TTableStick.Load;
begin
  FWrap := LoadTexture('assets/wrap.png');
  SetTextureFilter(FWrap, TEXTURE_FILTER_BILINEAR);
  GenTextureMipmaps(FWrap);
  FStick.Load('stick', 'stick');
  FStick.TexId2 := FWrap.id;
  FStick.TexName2 := 'wrap';
end;

procedure TTableStick.Unload;
begin
  FStick.Unload;
end;

function Max(A, B: Single): Single;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

procedure TTableStick.Draw(Camera: TCamera3D; Light: TVec3);

  function CheckBalls(A: Single): Single;
  var
    C, V: TVec2;
    D, Scale: Single;
    I: Integer;
  begin
    C := State.BallPos[0];
    for I := 1 to High(State.BallPos) do
    begin
      V := State.BallPos[I];
      D := V.Distance(C);
      if D > 4 * BallDiameter then
        Continue;
      V := (C - V);
      V.Normalize;
      Scale := V.Dot(State.StickDir);
      if Scale < 0.01 then
        Continue;
      Scale := Scale * Scale;
      D := RadToDeg(ArcTan((BallRadius + 0.015) / D));
      A := Max(A, D * Scale);
    end;
    Result := A;
  end;

const
  RailH = 0.0125;
var
  Dist, Angle: Single;
  M: TMat4;
begin
  if State.Moving or State.Sinking then
    Exit;
  M.Identity;
  M.Translate(BallRadius * 1.2 + + (Sin(TimeQuery * 1.5) + 1) * 0.06, 0, 0);
  { Set the vertical angle of the cue stick }
  Angle := 8;
  if (State.StickDir.Y < 0) and (State.BallPos[0].Y > 0) then
  begin
    Dist := SlateHalfZ - Abs(State.BallPos[0].Y);
    Dist := Dist / Abs(State.StickDir.Y);
    Angle := Max(RadToDeg(ArcTan(RailH / Dist)), Angle);
  end;
  if (State.StickDir.Y > 0) and (State.BallPos[0].Y < 0) then
  begin
    Dist := SlateHalfZ - Abs(State.BallPos[0].Y);
    Dist := Dist / Abs(State.StickDir.Y);
    Angle := Max(RadToDeg(ArcTan(RailH / Dist)), Angle);
  end;
  if (State.StickDir.X < 0) and (State.BallPos[0].X > 0) then
  begin
    Dist := SlateHalfX - Abs(State.BallPos[0].X);
    Dist := Dist / Abs(State.StickDir.X);
    Angle := Max(RadToDeg(ArcTan(RailH / Dist)), Angle);
  end;
  if (State.StickDir.X > 0) and (State.BallPos[0].X < 0) then
  begin
    Dist := SlateHalfX - Abs(State.BallPos[0].X);
    Dist := Dist / Abs(State.StickDir.X);
    Angle := Max(RadToDeg(ArcTan(RailH / Dist)), Angle);
  end;
  { Adjust for nearby balls }
  Angle := CheckBalls(Angle);
  M.Rotate(0, 0, Angle);

  M.RotateRad(0, Pi + State.StickDir.Angle([1, 0]), 0);
  M.Translate(State.BallPos[0].x, BallRadius, State.BallPos[0].y);
  FStick.Model.transform := M;
  State.StickPos[0] := M * Vec(0, 0, 0);
  State.StickPos[1] := M * Vec(1.5, 0, 0);
  BeginMode3D(Camera);
  FStick.Draw(Camera.position, Light);
  EndMode3D;
end;

end.

