{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RaylibCorePackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  Raylib.App, Raylib, Raylib.Rl, Raylib.Graphics, Raylib.System, RayLib.Gl, 
  Raylib.NanoVG, Raylib.Collections, RayLib.Constants, Raylib.Core, 
  Raylib.Glfw, Raylib.Gui, Raylib.OpenGL, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('raylib_core', @Register);
end.
