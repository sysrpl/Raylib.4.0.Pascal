unit TableVars;

{$mode delphi}

interface

uses
  Raylib;

const
  WindowWidth = 1200;
  WindowHeight = 666;
  CX = WindowWidth div 2;
  CY = WindowHeight div 2;
  Inch = 1 / 12 / 3.2808;
  BallDiameter = 2.25 * Inch;
  BallRadius = BallDiameter / 2;
  TouchDiameter = BallDiameter + 0.0001;
  StickLength = 1.5;
  SlateX = 100 * Inch;
  SlateZ = 50 * Inch;
  SlateHalfX = SlateX / 2;
  SlateHalfZ = SlateZ / 2;
  CabinetX = 120 * Inch;
  CabinetZ = 70 * Inch;

{ Wall points below are laid out in the following arrangement:

   5          2
    \--------/   1
     4      3   /
               0|
                |

  This is for the top right quadrant

  Point 4 is at Z 0.686 meters
  Point 0 is at X 1.270 meters

  The origin is at 0,0 at the cener of the table }

  WallQuadrant:
    array[0..11] of Single = (
      1.270, 0.554,
      1.321, 0.605,
      1.240, 0.686,
      1.189, 0.635,
      0.067, 0.635,
      0.053, 0.686);
  WallX = 1.270;
  WallZ = 0.635;
  SideCenter: array[0..1] of Single = (0, 0.711);
  SideRadius = 0.1524 / 2;
  CornerCenter: array[0..1] of Single = (1.295, 0.660);
  CornerRadius = 0.2032 / 2;

var
  State: record
    { Help is true when help is being displayed }
    Help: Boolean;
    { The frames per second }
    Fps: Integer;
    { The lowest frames per second }
    LowFps: Integer;
    { The number of triangles drawn }
    Triangles: Integer;
    { The seconds since the last frame }
    TimeNow: Double;
    { The seconds since the last frame }
    TimeFrame: Double;
    { Time when a shot occured }
    TimeShoot: Double;
    { Pool table ball positions }
    BallPos: array[0..15] of TVec2;
    { Pool cue end positions }
    StickPos: array[0..1] of TVec3;
    { Pool cue directon }
    StickDir: TVec2;
    { Pool cue angle in radians }
    StickAngle: Single;
    { Pool cue power }
    StickPower: Single;
    { Our global environmental map }
    SkyTex: TTexture2D;
    { Collides is true if the cue ball is will collide with another ball }
    Collides: Boolean;
    { CollidePoint is the where the collision occurs }
    CollidePoint: TVec2;
    { CollideIndex is the object ball in the collision }
    CollideIndex: Integer;
    { Overhead is true if the camera is in a valid overhead state }
    Overhead: Boolean;
    { Aiming is true if an aiming state is set }
    Aiming: Boolean;
    { Moving is true if balls are moving }
    Moving: Boolean;
    { The cue ball is sinking }
    Sinking: Boolean;
    { The cue ball is sinking }
    CameraMode: Integer;
  end;

  RenderOptions: record
    { Turn shadows on or off }
    Shadows: Boolean;
    { Apply smooth modes for vector graphics [0..2] }
    Smoothing: Integer;
    { Assist level for pool shots [0..2] }
    Assist: Integer;
  end;

const
  CenterX = WindowWidth / 2;
  CenterY = WindowHeight / 2;
  { Magic numbers from a gimp screen grab of the top view }
  PixelsX = 1068 / SlateX;
  PixelsY = 534 / SlateZ;

function WindowToMeters(V: TVec2): TVec2;
function MetersToWindow(V: TVec2): TVec2;

implementation

function WindowToMeters(V: TVec2): TVec2;
begin
  V := V - Vec(CenterX, CenterY);
  Result := V / [PixelsX, PixelsY];
end;

function MetersToWindow(V: TVec2): TVec2;
begin
  Result := V * [PixelsX, PixelsY];
  V := V + Vec(CenterX, CenterY);
end;

end.

