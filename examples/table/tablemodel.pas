unit TableModel;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  Raylib.Gl,
  TableVars;

{ TTableModel }

type
  TTableModel = record
  public
    Model: TModel;
    Shader: TShader;
    Time: TUniformFloat;
    Eye: TUniformVec3;
    Light: TUniformVec3;
    Smoothing: TUniformInt;
    Shadows: TUniformBool;
    TexId1: Integer;
    TexName1: string;
    TexLoc1: Integer;
    TexId2: Integer;
    TexName2: string;
    TexLoc2: Integer;
    Locked: Boolean;
    procedure Load(const FragName: string; VertName: string = '');
    procedure Unload;
    procedure Draw(const CameraPos, LightPos: TVec3);
  end;

implementation

procedure TTableModel.Load(const FragName: string; VertName: string = '');
var
  F, V: string;
begin
  F := 'shaders/' +  FragName + '.frag';
  if VertName = '' then
    V := 'shaders/base.vert'
  else
    V := 'shaders/' +  VertName + '.vert';
  Shader := LoadShader(PChar(V), PChar(F));
  Shader.GetUniform('time', Time);
  Shader.GetUniform('eye', Eye);
  Shader.GetUniform('light', Light);
  Shader.GetUniform('shadows', Shadows);
  Shader.GetUniform('smoothing', Smoothing);
  F := 'assets/pool-' +  FragName + '.obj';
  Model := LoadModel(PChar(F));
  Model.transform.Identity;
  Model.transform.Rotate(90, 0, 0);
  Model.materials.shader := Shader;
end;

procedure TTableModel.Unload;
begin
  UnloadModel(Model);
  UnloadShader(Shader);
end;

procedure TTableModel.Draw(const CameraPos, LightPos: TVec3);

    procedure Follow;
    var
      M: TMat4;
    begin
      M.Identity;
      M.Rotate(90, 0, 0);
      M.Translate(CameraPos.x, CameraPos.y, CameraPos.z);
      Model.transform := M;
    end;

begin
  Time.Update(TimeQuery);
  Eye.Update(CameraPos);
  Light.Update(LightPos);
  if Locked then
    Follow;
  if TexName1 <> '' then
  begin
    // This is a work around for the raylib problem that does not allow
    // usage of aditional textures in custom shaders
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, TexId1);
    if TexLoc1 = 0 then
      TexLoc1 := glGetUniformLocation(Shader.id, PChar(TexName1));
    glUniform1i(TexLoc1, 1)
  end;
  if TexName2 <> '' then
  begin
    // Multitexture support
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, TexId2);
    if TexLoc2 = 0 then
      TexLoc2 := glGetUniformLocation(Shader.id, PChar(TexName2));
    glUniform1i(TexLoc2, 2)
  end;
  Shadows.Update(RenderOptions.Shadows);
  Smoothing.Update(RenderOptions.Smoothing);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  DrawModel(Model, Vec(0, 0, 0), 1, WHITE);
  Inc(State.Triangles, Model.meshes.triangleCount);
end;

end.

