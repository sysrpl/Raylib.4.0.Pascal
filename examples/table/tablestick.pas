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

procedure TTableStick.Draw(Camera: TCamera3D; Light: TVec3);
var
  M: TMat4;
begin
  if State.Moving then
    Exit;
  BeginMode3D(Camera);
  M.Identity;
  M.Translate(BallRadius * 1.2 + + (Sin(TimeQuery * 1.5) + 1) * 0.06, 0, 0);
  M.Rotate(0, 0, 8);
  M.RotateRad(0, Pi + State.StickDir.Angle([1, 0]), 0);
  M.Translate(State.BallPos[0].x, BallRadius, State.BallPos[0].y);
  FStick.Model.transform := M;
  FStick.Draw(Camera.position, Light);
  State.StickPos[0] := M * Vec(0, 0, 0);
  State.StickPos[1] := M * Vec(1.5, 0, 0);
  EndMode3D;
end;

end.

