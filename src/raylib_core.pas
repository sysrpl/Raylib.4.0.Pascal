{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit raylib_core;

{$warn 5023 off : no warning about unused units}
interface

uses
  Raylib.App, Raylib, Raylib.Rl, Raylib.Graphics, RayLib.System, RayLib.Gl, 
  Raylib.NanoVG, RayLib.Collections, RayLib.Constants, RayLib.Core, 
  Raylib.Glfw, Raylib.Gui, RayLib.OpenGL, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('raylib_core', @Register);
end.
