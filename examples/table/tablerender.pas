unit TableRender;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  TableModel,
  TableVars;

{ TTableRender }

type
  TTableRender = record
  private
    FSkybox: TTableModel;
    FShapes: TTableModel;
    FFeet: TTableModel;
    FSlate: TTableModel;
    FRails: TTableModel;
    FCabinet: TTableModel;
    FMetal: TTableModel;
    FPlastic: TTableModel;
    FSlateStick0: TUniformVec3;
    FSlateStick1: TUniformVec3;
    FSlateCollides: TUniformBool;
    FSlateCollidePoint: TUniformVec2;
    FSlateCollideIndex: TUniformInt;
    FSlateMoving: TUniformBool;
    FRailsStick0: TUniformVec3;
    FRailsStick1: TUniformVec3;
    FRailsMoving: TUniformBool;
    FCabinetStick0: TUniformVec3;
    FCabinetStick1: TUniformVec3;
    FCabinetMoving: TUniformBool;
    FBalls: array[0..15] of TUniformVec2;
    FPower: IBitmapBrush;
  public
    Test: Boolean;
    procedure Load;
    procedure Unload;
    procedure Draw(Canvas: ICanvas); overload;
    procedure Draw(Camera: TCamera3D; Light: TVec3); overload;
  end;

implementation

{ TTableRender }

procedure TTableRender.Load;
var
  S: string;
  I: Integer;
begin
  State.SkyTex := LoadTexture('assets/probe.png');
  GenTextureMipmaps(State.SkyTex);
  SetTextureFilter(State.SkyTex, TEXTURE_FILTER_BILINEAR);

  FSkybox.Load('skybox');
  FSkybox.TexId := State.SkyTex.id;
  FSkybox.TexName := 'probe';
  FSkybox.Locked := True;

  FShapes.Load('shapes', 'shapes');
  FFeet.Load('feet');
  FSlate.Load('slate');
  FRails.Load('rails');
  FCabinet.Load('cabinet');

  FMetal.Load('metal');
  FMetal.TexId := State.SkyTex.id;
  FMetal.TexName := 'probe';

  FPlastic.Load('plastic');

  for I := Low(FBalls) to High(FBalls) do
  begin
    S := 'balls['  + IntToStr(I) + ']';
    FSlate.Shader.GetUniform(PChar(S), FBalls[I]);
  end;

  FSlate.Shader.GetUniform('stick[0]', FSlateStick0);
  FSlate.Shader.GetUniform('stick[1]', FSlateStick1);
  FSlate.Shader.GetUniform('collides', FSlateCollides);
  FSlate.Shader.GetUniform('collidepoint', FSlateCollidePoint);
  FSlate.Shader.GetUniform('collideindex', FSlateCollideIndex);
  FSlate.Shader.GetUniform('moving', FSlateMoving);
  FRails.Shader.GetUniform('stick[0]', FRailsStick0);
  FRails.Shader.GetUniform('stick[1]', FRailsStick1);
  FRails.Shader.GetUniform('moving', FRailsMoving);
  FCabinet.Shader.GetUniform('stick[0]', FCabinetStick0);
  FCabinet.Shader.GetUniform('stick[1]', FCabinetStick1);
  FCabinet.Shader.GetUniform('moving',  FCabinetMoving);
end;

procedure TTableRender.Unload;
begin
  UnloadTexture(State.SkyTex);
  FPlastic.Unload;
  FMetal.Unload;
  FCabinet.Unload;
  FRails.Unload;
  FSlate.Unload;
  FFeet.Unload;
  FSkybox.Unload;
  FShapes.Unload;
end;

procedure TTableRender.Draw(Canvas: ICanvas);

  procedure DrawPower;
  const
    PY = WindowHeight - 100;
    PW = 200;
    PH = 50;
  begin
    if not State.Overhead then
    begin
      Canvas.Opacity := 0.8;
      Canvas.Matrix.Push;
      Canvas.Matrix.Scale(0.5, 0.5);
      Canvas.Matrix.Translate(820, -240);
    end;
    if FPower = nil then
      FPower := NewBrush(Canvas.LoadBitmap('assets/power.png'));
    Canvas.MoveTo(CX - PW / 2, PY);
    Canvas.LineTo((CX - PW / 2) + PW * State.StickPower, PY);
    Canvas.LineTo((CX - PW / 2) + PW * State.StickPower, PY - PH * State.StickPower);
    FPower.Offset := [CX - PW / 2, 0];
    Canvas.Fill(FPower);
    Canvas.MoveTo(CX - PW / 2, PY);
    Canvas.LineTo(CX + PW / 2, PY);
    Canvas.LineTo(CX + PW / 2, PY - PH);
    Canvas.ClosePath;
    Canvas.Stroke(colorBlack, 5, True);
    Canvas.Stroke(colorWhite, 3);
    if not State.Overhead then
      Canvas.Pop;
  end;

const
  Inner = 50;
  Outer = 300;
  Max = CY - Outer / 2 + 10;
  Min = CY - Inner / 2 - 15;
var
  S: Double;
  R: TRect;
begin
  if State.Moving then
    Exit;
  R := [CX - Inner / 2, CY - Inner / 2, Inner, Inner];
  if State.Aiming then
    Canvas.Opacity := 0.5
  else
    Canvas.Opacity := 0.2;
  if State.Overhead then
  begin
    Canvas.Ellipse(R);
    Canvas.Stroke(colorBlack, 2, True);
    Canvas.Fill(colorWhite);
    R := [CX - Outer / 2, CY - Outer / 2, Outer, Outer];
    Canvas.Ellipse(R);
    Canvas.Stroke(colorBlack, 6, True);
    Canvas.Stroke(colorWhite, 4);
    if State.StickPower > 0 then
    begin
      Canvas.Matrix.Push;
      Canvas.Matrix.RotateAt(State.StickDir.Angle(1, 0) + Pi / 2, CX, CY);
      S := Max * State.StickPower + Min * (1 - State.StickPower);
      Canvas.MoveTo(CX - 15, S + 10);
      Canvas.LineTo(CX, S);
      Canvas.LineTo(CX + 15, S + 10);
      Canvas.Stroke(NewPen(colorBlack, 10, capSquare), True);
      Canvas.Stroke(NewPen(colorWhite, 8, capSquare));
      Canvas.Matrix.Pop;
    end;
  end;
  DrawPower;
  Canvas.Opacity := 1;
end;

procedure TTableRender.Draw(Camera: TCamera3D; Light: TVec3);
var
  I: Integer;
begin
  BeginMode3D(Camera);
  if IsKeyPressed(KEY_T) then
    Test := not Test;
  if Test then
    FShapes.Draw(Camera.position, Light)
  else
  begin
    { Update the shader uniforms }
    for I := Low(FBalls) to High(FBalls) do
      FBalls[I].Update(State.BallPos[I]);
    if State.Moving or State.Sinking then
    begin
      FSlateMoving.Update(True);
      FRailsMoving.Update(True);
      FCabinetMoving.Update(True);
    end
    else
    begin
      { If there is no movement and we can draw the cue stick and collision paths }
      FSlateMoving.Update(False);
      FRailsMoving.Update(False);
      FCabinetMoving.Update(False);
      FSlateStick0.Update(State.StickPos[0]);
      FSlateStick1.Update(State.StickPos[1]);
      FSlateCollides.Update(State.Collides);
      FSlateCollidePoint.Update(State.CollidePoint);
      FSlateCollideIndex.Update(State.CollideIndex);
      FRailsStick0.Update(State.StickPos[0]);
      FRailsStick1.Update(State.StickPos[1]);
      FCabinetStick0.Update(State.StickPos[0]);
      FCabinetStick1.Update(State.StickPos[1]);
    end;
    { Draw the table objects, culling the feet if the camera is over the cabinet }
    if (Abs(Camera.position.x) > CabinetX / 2) or (Abs(Camera.position.z) > CabinetZ / 2) then
      FFeet.Draw(Camera.position, Light);
    FCabinet.Draw(Camera.position, Light);
    FMetal.Draw(Camera.position, Light);
    FRails.Draw(Camera.position, Light);
    FSlate.Draw(Camera.position, Light);
    FPlastic.Draw(Camera.position, Light);
  end;
  EndMode3D;
end;

end.

