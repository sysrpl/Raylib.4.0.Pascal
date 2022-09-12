{ Raylib 4.0 Pascal bindings for Windows, macOS, Linux, and Raspberry Pi

  Author: Anthony Walter <admim@getlazarus.org>
  Git repository: https://www.github.com/sysrpl/Raylib.4.0.Pascal
  License: MIT No Attribution

  Modified: August 2022

  This package includes complete pascal bindings of the following packages:

    Raylib (raylib.pas)
    Raylib GL (raylib.gl.pas)
    Raylib GUI (raylib.gui.pas)

  A BIG NOTE ON COMPILING AND RUNNING

  Windows:
    The file dlls/raylib.dll must be copied to a folder in your path.
    You can do this by copying raylib.dll to your program folder, or
    by copying raylib.dll to C:\Windows\System32 one time.

  Linux, MacOS, and Raspberry Pi:
    Static libaries are used and everything is built into your programs.

  When compiling from the command line, make sure the src folder is included
  in your unit path.

  Example:

  fpc helloworld.pas -Fu../src  }

(**********************************************************************************************
*
*   raylib v4.0 - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
*                        MacOS, Haiku, Android, Raspberry Pi, DRM native, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3, 4.3 or ES2 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Animated 3D models supported (skeletal bones animation) (IQM)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
*       - VR stereo rendering with configurable HMD device parameters
*       - Bindings to multiple programming languages available!
*
*   NOTES:
*       - One default Font is loaded on InitWindow()->LoadFontDefault() [core, text]
*       - One default Texture2D is loaded on rlglInit(), 1x1 white pixel R8G8B8A8 [rlgl] (OpenGL 3.3 or ES2)
*       - One default Shader is loaded on rlglInit()->rlLoadShaderDefault() [rlgl] (OpenGL 3.3 or ES2)
*       - One default RenderBatch is loaded on rlglInit()->rlLoadRenderBatch() [rlgl] (OpenGL 3.3 or ES2)
*
*   DEPENDENCIES (included):
*       [rcore] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input (PLATFORM_DESKTOP)
*       [rlgl] glad (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (PLATFORM_DESKTOP)
*       [raudio] miniaudio (David Reid - github.com/mackron/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [rcore] msf_gif (Miles Fogle) for GIF recording
*       [rcore] sinfl (Micha Mettke) for DEFLATE decompression algorythm
*       [rcore] sdefl (Micha Mettke) for DEFLATE compression algorythm
*       [rtextures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [rtextures] stb_image_write (Sean Barret) for image writing (BMP, TGA, PNG, JPG)
*       [rtextures] stb_image_resize (Sean Barret) for image resizing algorithms
*       [rtext] stb_truetype (Sean Barret) for ttf fonts loading
*       [rtext] stb_rect_pack (Sean Barret) for rectangles packing
*       [rmodels] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [rmodels] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [rmodels] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [raudio] dr_wav (David Reid) for WAV audio file loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2021 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************)

unit Raylib;

{$i raylib.inc}

interface

{ Raylib version }

const
  RAYLIB_VERSION = '4.0';
  
{ Some basic defines }

  DEG2RAD = PI / 180;
  RAD2DEG = 180 / PI;

type
  TGetProcAddress = function(ProcName: PChar): Pointer; cdecl;

  TSingleArray = array of Single;
  TByteArray = array of Byte;

{ TVec2, 2 components }

  TVec2 = record
    x, y: Single;
    class operator Implicit(const A: TSingleArray): TVec2;
    class operator Implicit(const V: TVec2): TSingleArray;
    class operator Negative(const A: TVec2): TVec2;
    class operator Equal(const A, B: TVec2): Boolean;
    class operator NotEqual(const A, B: TVec2): Boolean;
    class operator Add(const A, B: TVec2): TVec2;
    class operator Subtract(const A, B: TVec2): TVec2;
    class operator Multiply(const A, B: TVec2): TVec2;
    class operator Multiply(const A: TVec2; B: Single): TVec2;
    class operator Divide(const A, B: TVec2): TVec2;
    class operator Divide(const A: TVec2; B: Single): TVec2;
    function Equals(const Value: TVec2): Boolean;
    function Angle: Single; overload;
    function Angle(X, Y: Single): Single; overload;
    function Angle(const V: TVec2): Single; overload;
    function Dot(const V: TVec2): Single; overload;
    function Distance: Single; overload;
    function Distance(X, Y: Single): Single; overload;
    function Distance(const V: TVec2): Single; overload;
    procedure Offset(X, Y: Single); overload;
    procedure Offset(const V: TVec2); overload;
    function Move(X, Y: Single): TVec2; overload;
    function Move(const V: TVec2): TVec2; overload;
    function Mix(const V: TVec2; Value: Single): TVec2;
    procedure Normalize;
    function Normal: TVec2;
    function Binormal: TVec2;
    function Mid(const V: TVec2): TVec2;
    function Extend(const V: TVec2; Dist: Single): TVec2;
    function Reflect(N: TVec2): TVec2;
    function Rotate(Angle: Single): TVec2; overload;
    function Rotate(const V: TVec2; Angle: Single): TVec2; overload;
  end;
  PVec2 = ^TVec2;
  TVector2 = TVec2;
  PVector2 = PVec2;

{ TVec3, 3 components }

  TVec3 = record
    x, y, z: Single;
    class operator Implicit(const A: TSingleArray): TVec3;
    class operator Implicit(const V: TVec3): TSingleArray;
    class operator Negative(const A: TVec3): TVec3;
    class operator Equal(const A, B: TVec3): Boolean;
    class operator NotEqual(const A, B: TVec3): Boolean;
    class operator Add(const A, B: TVec3): TVec3;
    class operator Subtract(const A, B: TVec3): TVec3;
    class operator Multiply(const A, B: TVec3): TVec3;
    class operator Divide(const A, B: TVec3): TVec3;
    function Equals(const Value: TVec3): Boolean;
    function Cross(const V: TVec3): TVec3;
    function Dot(const V: TVec3): Single;
    function Distance: Single;
    procedure Normalize;
  end;
  PVec3 = ^TVec3;
  TVector3 = TVec3;
  PVector3 = PVec3;

{ TVec4, 4 components }

  TVec4 = record
    x, y, z, w: Single;
    class operator Implicit(const A: TSingleArray): TVec4;
    class operator Implicit(const V: TVec4): TSingleArray;
    class operator Negative(const A: TVec4): TVec4;
    class operator Equal(const A, B: TVec4): Boolean;
    class operator NotEqual(const A, B: TVec4): Boolean;
    class operator Multiply(const A, B: TVec4): TVec4;
    class operator Divide(const A, B: TVec4): TVec4;
    function Equals(const Value: TVec4): Boolean;
    function Distance: Single;
    procedure Normalize;
  end;
  PVec4 = ^TVec4;
  TVector4 = TVec4;
  PVector4 = PVec4;

{ Quaternion, 4 components (Vec4 alias) }

  TQuaternion = TVec4;
  PQuaternion = ^PVec4;

{ TMat4, 4x4 components }

  TTransformOrder = (toTRS, toRST, toSTR, toTSR, toSRT, toRTS);
  TRotationOrder = (roXYZ, roYZX, roZXY, roXZY, roZYX, roYXZ);
  TMatrixOrder = (moPrepend, moAppend);

  TMat4 = record
  public
    class operator Equal(const A, B: TMat4): Boolean;
    class operator NotEqual(const A, B: TMat4): Boolean;
    class operator Add(const A, B: TMat4): TMat4;
    class operator Subtract(const A, B: TMat4): TMat4;
    class operator Multiply(const A: TMat4; const B: TVec2): TVec2; overload;
    class operator Multiply(const A: TMat4; const B: TVec3): TVec3; overload;
    class operator Multiply(const A, B: TMat4): TMat4; overload;
    class operator Divide(const A, B: TMat4): TMat4;
    function Equals(const Value: TMat4): Boolean;
    procedure Identity;
    function IsIdentity: Boolean;
    function CanInvert: Boolean;
    function Invert: Boolean;
    procedure Transpose;
    procedure Rotate(X, Y, Z: Single); overload;
    procedure Rotate(X, Y, Z: Single; Order: TRotationOrder); overload;
    procedure RotateAt(X, Y, Z: Single; const Pivot: TVec3); overload;
    procedure RotateAt(X, Y, Z: Single; const Pivot: TVec3; Order: TRotationOrder); overload;
    procedure Scale(X, Y, Z: Single);
    procedure ScaleAt(X, Y, Z: Single; const Pivot: TVec3);
    procedure Translate(X, Y, Z: Single);
    function Transform(const V: TVec2): TVec2; overload;
    function Transform(const V: TVec3): TVec3; overload;
    function Transform(const M: TMat4): TMat4; overload;
    procedure Perspective(FoV, AspectRatio, NearPlane, FarPlane: Single);
    procedure Frustum(Left, Right, Top, Bottom, NearPlane, FarPlane: Single);
    procedure LookAt(Eye, Center, Up: TVec3);
    case Integer of
      0: (m: array[0..3, 0..3] of Single);
      1: (m0, m1, m2, m3: array[0..3] of Single);
      2: (v: array[0..15] of Single);
  end;
  PMat4 = ^TMat4;
  TMatrix = TMat4;
  PMatrix = PMat4;

{ TColorB, 4 components, R8G8B8A8 (32bit) }

  TColorB = record
    r, g, b, a: Byte;
    class operator Implicit(const Value: LongWord): TColorB;
    class operator Implicit(const A: TByteArray): TColorB;
    function Mix(Color: TColorB; Percent: Single): TColorB;
    function Fade(Alpha: Single): TColorB;
  end;
  PColorB = ^TColorB;
  TColor = TColorB;
  PColor = PColorB;

{ TRect, 4 components }

  TRect = record
    x, y, width, height: Single;
    class operator Implicit(const Value: TVec2): TRect;
    class operator Implicit(const A: TSingleArray): TRect;
    class operator Implicit(const R: TRect): TSingleArray;
    procedure Inflate(DX, DY: Single);
    procedure Move(DX, DY: Single);
    procedure Resize(W, H: Single);
    function IsEmpty: Boolean;
  end;
  PRect = ^TRect;
  TRectangle = TRect;
  PRectangle = PRect;

{ TImage, pixel data stored in CPU memory (RAM) }

  TImage = record
    { TImage raw data }
    data: Pointer;
    { TImage base width }
    width: Integer;
    { TImage base height }
    height: Integer;
    { Mipmap levels, 1 by default }
    mipmaps: Integer;
    { Data format (PixelFormat type) }
    format: Integer;
  end;
  PImage = ^TImage;

{ Texture, tex data stored in GPU memory (VRAM) }

  TTexture = record
    { OpenGL texture id }
    id: LongWord;
    { Texture base width }
    width: Integer;
    { Texture base height }
    height: Integer;
    { Mipmap levels, 1 by default }
    mipmaps: Integer;
    { Data format (PixelFormat type) }
    format: Integer;
  end;
  PTexture = ^TTexture;

{ TTexture2D, same as Texture }

  TTexture2D = TTexture;
  PTexture2D = PTexture;

{ TTextureCubemap, same as Texture }

  TTextureCubemap = TTexture;
  PTextureCubemap = PTexture;

{ RenderTexture, fbo for texture rendering }

  TRenderTexture = record
    { OpenGL framebuffer object id }
    id: LongWord;
    { TColorB buffer attachment texture }
    texture: TTexture;
    { Depth buffer attachment texture }
    depth: TTexture;
  end;
  PRenderTexture = ^TRenderTexture;

{ TRenderTexture2D, same as RenderTexture }

  TRenderTexture2D = TRenderTexture;
  PRenderTexture2D = PRenderTexture;

{ TNPatchInfo, n-patch layout info }

  TNPatchInfo = record
    { Texture source rectangle }
    source: TRect;
    { Left border offset }
    left: Integer;
    { Top border offset }
    top: Integer;
    { Right border offset }
    right: Integer;
    { Bottom border offset }
    bottom: Integer;
    { Layout of the n-patch: 3x3, 1x3 or 3x1 }
    layout: Integer;
  end;
  PNPatchInfo = ^TNPatchInfo;

{ TGlyphInfo, font characters glyphs info }

  TGlyphInfo = record
    { Character value (Unicode) }
    value: Integer;
    { Character offset X when drawing }
    offsetX: Integer;
    { Character offset Y when drawing }
    offsetY: Integer;
    { Character advance position X }
    advanceX: Integer;
    { Character image data }
    image: TImage;
  end;
  PGlyphInfo = ^TGlyphInfo;

{ TFont, font texture and TGlyphInfo array data }

  TFont = record
    { Base size (default chars height) }
    baseSize: Integer;
    { Number of glyph characters }
    glyphCount: Integer;
    { Padding around the glyph characters }
    glyphPadding: Integer;
    { Texture atlas containing the glyphs }
    texture: TTexture2D;
    { TRects in texture for the glyphs }
    recs: PRect;
    { Glyphs info data }
    glyphs: PGlyphInfo;
  end;
  PFont = ^TFont;

{ Camera, defines position/orientation in 3d space }

  TCamera3D = record
    { Camera position (rotation over its axis) }
    position: TVec3;
    { Camera target it looks-at }
    target: TVec3;
    { Camera up vector (rotation over its axis) }
    up: TVec3;
    { Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic }
    fovy: Single;
    { Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC }
    projection: Integer;
  end;
  PCamera3D = ^TCamera3D;

  TCamera = TCamera3D;
  PCamera = PCamera3D;

{ Camera2D, defines position/orientation in 2d space }

  TCamera2D = record
    { Camera offset (displacement from target) }
    offset: TVec2;
    { Camera target (rotation and zoom origin) }
    target: TVec2;
    { Camera rotation in degrees }
    rotation: Single;
    { Camera zoom (scaling), should be 1.0f by default }
    zoom: Single;
  end;
  PCamera2D = ^TCamera2D;

{ TMesh, vertex data and vao/vbo }
{ OpenGL Vertex Buffer Objects id (default vertex data) }

  TMesh = record
    { Number of vertices stored in arrays }
    vertexCount: Integer;
    { Number of triangles stored (indexed or not) }
    triangleCount: Integer;
    { Vertex position (XYZ - 3 components per vertex) (shader-location = 0) }
    vertices: PSingle;
    { Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1) }
    texcoords: PSingle;
    { Vertex second texture coordinates (useful for lightmaps) (shader-location = 5) }
    texcoords2: PSingle;
    { Vertex normals (XYZ - 3 components per vertex) (shader-location = 2) }
    normals: PSingle;
    { Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4) }
    tangents: PSingle;
    { Vertex colors (RGBA - 4 components per vertex) (shader-location = 3) }
    colors: PByte;
    { Vertex indices (in case vertex data comes indexed) }
    indices: PWord;
    { Animated vertex positions (after bones transformations) }
    animVertices: PSingle;
    { Animated normals (after bones transformations) }
    animNormals: PSingle;
    { Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) }
    boneIds: PByte;
    { Vertex bone weight, up to 4 bones influence by vertex (skinning) }
    boneWeights: PSingle;
    { OpenGL Vertex Array Object id }
    vaoId: LongWord;
    { OpenGL Vertex Buffer Objects id (default vertex data) }
    vboId: PLongWord;
  end;
  PMesh = ^TMesh;

{ TUniformInt }

  TUniformInt = record
    location: Integer;
    value: Integer;
  end;

  TUniformSingle = record
    location: Integer;
    value: Single;
  end;

  TUniformVec2 = record
    location: Integer;
    value: TVec2;
  end;

  TUniformVec3 = record
    location: Integer;
    value: TVec3;
  end;

  TUniformVec4 = record
    location: Integer;
    value: TVec4;
  end;

  TUniformSampler2d = record
    location: Integer;
    value: Integer;
  end;

{ Shader }

  TShader = record
    { Shader program id }
    id: LongWord;
    { Shader locations array (RL_MAX_SHADER_LOCATIONS) }
    locs: PInteger;
    procedure Load(vertFile, fragFile: PChar);
    procedure Unload;
    function GetUniformLocation(name: PChar): Integer;
    procedure GetUniform(name: PChar; out uniform: TUniformInt); overload;
    procedure GetUniform(name: PChar; out uniform: TUniformSingle); overload;
    procedure GetUniform(name: PChar; out uniform: TUniformVec2); overload;
    procedure GetUniform(name: PChar; out uniform: TUniformVec3); overload;
    procedure GetUniform(name: PChar; out uniform: TUniformVec4); overload;
    procedure GetUniform(name: PChar; out uniform: TUniformSampler2d); overload;
    procedure SetUniform(const uniform: TUniformInt); overload;
    procedure SetUniform(const uniform: TUniformSingle); overload;
    procedure SetUniform(const uniform: TUniformVec2); overload;
    procedure SetUniform(const uniform: TUniformVec3); overload;
    procedure SetUniform(const uniform: TUniformVec4); overload;
    procedure SetUniform(const uniform: TUniformSampler2d); overload;
  end;
  PShader = ^TShader;

{ TMaterialMap }

  TMaterialMap = record
    { TMaterial map texture }
    texture: TTexture2D;
    { TMaterial map color }
    color: TColorB;
    { TMaterial map value }
    value: Single;
  end;
  PMaterialMap = ^TMaterialMap;

{ TMaterial, includes shader and maps }

  TMaterial = record
    { TMaterial shader }
    shader: TShader;
    { TMaterial maps array (MAX_MATERIAL_MAPS) }
    maps: PMaterialMap;
    { TMaterial generic parameters (if required) }
    params: array[0..3] of Single;
  end;
  PMaterial = ^TMaterial;

{ Transform, vectex transformation data }

  TTransform = record
    { Translation }
    translation: TVec3;
    { Rotation }
    rotation: TQuaternion;
    { Scale }
    scale: TVec3;
  end;
  PTransform = ^TTransform;

{ Bone, skeletal animation bone }

  TBoneInfo = record
    { Bone name }
    name: array[0..31] of Char;
    { Bone parent }
    parent: Integer;
  end;
  PBoneInfo = ^TBoneInfo;

{ TModel, meshes, materials and animation data }

  TModel = record
    { Local transform  }
    transform: TMat4;
    { Number of meshes }
    meshCount: Integer;
    { Number of materials }
    materialCount: Integer;
    { TMeshes array }
    meshes: PMesh;
    { TMaterials array }
    materials: PMaterial;
    { TMesh material number }
    meshMaterial: PInteger;
    { Number of bones }
    boneCount: Integer;
    { Bones information (skeleton) }
    bones: PBoneInfo;
    { Bones base transformation (pose) }
    bindPose: PTransform;
  end;
  PModel = ^TModel;

{ TModelAnimation }

  TModelAnimation = record
    { Number of bones }
    boneCount: Integer;
    { Number of animation frames }
    frameCount: Integer;
    { Bones information (skeleton) }
    bones: PBoneInfo;
    { Poses array by frame }
    framePoses: ^PTransform;
  end;
  PModelAnimation = ^TModelAnimation;

{ TRay, ray for raycasting }

  TRay = record
    { TRay position (origin) }
    position: TVec3;
    { TRay direction }
    direction: TVec3;
  end;
  PRay = ^TRay;

{ TRayCollision, ray hit information }

  TRayCollision = record
    { Did the ray hit something? }
    hit: Boolean;
    { Distance to nearest hit }
    distance: Single;
    { Point of nearest hit }
    point: TVec3;
    { Surface normal of hit }
    normal: TVec3;
  end;
  PRayCollision = ^TRayCollision;

{ TBoundingBox }

  TBoundingBox = record
    { Minimum vertex box-corner }
    min: TVec3;
    { Maximum vertex box-corner }
    max: TVec3;
  end;
  PBoundingBox = TBoundingBox;

{ TWave buffer data }

  TWave = record
    { TWave, audio wave data }
    frameCount: LongWord;
    { Total number of frames (considering channels) }
    sampleRate: LongWord;
    { Frequency (samples per second) }
    sampleSize: LongWord;
    { Bit depth (bits per sample): 8, 16, 32 (24 not supported) }
    channels: LongWord;
    { Number of channels (1-mono, 2-stereo, ...) }
    data: Pointer;
  end;
  PWave = TWave;

{ TAudioStream, custom audio stream }

  TAudioStream = record
    { Pointer to Integerernal data used by the audio system }
    buffer: Pointer;
    { Frequency (samples per second) }
    sampleRate: LongWord;
    { Bit depth (bits per sample): 8, 16, 32 (24 not supported) }
    sampleSize: LongWord;
    { Number of channels (1-mono, 2-stereo, ...) }
    channels: LongWord;
  end;
  PAudioStream = TAudioStream;

{ TSound }

  TSound = record
    { Audio stream }
    stream: TAudioStream;
    { Total number of frames (considering channels) }
    frameCount: LongWord;
  end;
  PSound = TSound;

{ TMusic, audio stream, anything longer than ~10 seconds should be streamed }

  TMusic = record
    { Audio stream }
    stream: TAudioStream;
    { Total number of frames (considering channels) }
    frameCount: LongWord;
    { TMusic looping enable }
    looping: Boolean;
    { Type of music context (audio filetype) }
    ctxType: Integer;
    { Audio context data, depends on type }
    ctxData: Pointer;
  end;
  PMusic = TMusic;

{ VrDeviceInfo, Head-Mounted-Display device parameters }

  TVrDeviceInfo = record
    { Horizontal resolution in pixels }
    hResolution: Integer;
    { Vertical resolution in pixels }
    vResolution: Integer;
    { Horizontal size in meters }
    hScreenSize: Single;
    { Vertical size in meters }
    vScreenSize: Single;
    { Screen center in meters }
    vScreenCenter: Single;
    { Distance between eye and display in meters }
    eyeToScreenDistance: Single;
    { Lens separation distance in meters }
    lensSeparationDistance: Single;
    { IPD (distance between pupils) in meters }
    IntegererpupillaryDistance: Single;
    { Lens distortion constant parameters }
    lensDistortionValues: array[0..3] of Single;
    { Chromatic aberration correction parameters }
    chromaAbCorrection: array[0..3] of Single;
  end;
  PVrDeviceInfo = TVrDeviceInfo;

{ VrStereoConfig, VR stereo rendering configuration for simulator }

  TVrStereoConfig = record
    { VR projection matrices (per eye) }
    projection: array[0..1] of TMat4;
    { VR view offset matrices (per eye) }
    viewOffset: array[0..1] of TMat4;
    { VR left lens center }
    leftLensCenter: array[0..1] of Single;
    { VR right lens center }
    rightLensCenter: array[0..1] of Single;
    { VR left screen center }
    leftScreenCenter: array[0..1] of Single;
    { VR right screen center }
    rightScreenCenter: array[0..1] of Single;
    { VR distortion scale }
    scale: array[0..1] of Single;
    { VR distortion scale in }
    scaleIn: array[0..1] of Single;
  end;
  PVrStereoConfig = TVrStereoConfig;

{ Color constants }

const
  LIGHTGRAY: TColorB = (r: 200; g: 200; b: 200; a: 255);
  GRAY: TColorB = (r: 130; g: 130; b: 130; a: 255);
  DARKGRAY: TColorB = (r: 80; g: 80; b: 80; a: 255);
  YELLOW: TColorB = (r: 253; g: 249; b: 0; a: 255);
  GOLD: TColorB = (r: 255; g: 203; b: 0; a: 255);
  ORANGE: TColorB = (r: 255; g: 161; b: 0; a: 255);
  PINK: TColorB = (r: 255; g: 109; b: 194; a: 255);
  RED: TColorB = (r: 230; g: 41; b: 55; a: 255);
  MAROON: TColorB = (r: 190; g: 33; b: 55; a: 255);
  GREEN: TColorB = (r: 0; g: 228; b: 48; a: 255);
  LIME: TColorB = (r: 0; g: 158; b: 47; a: 255);
  DARKGREEN: TColorB = (r: 0; g: 117; b: 44; a: 255);
  SKYBLUE: TColorB = (r: 102; g: 191; b: 255; a: 255);
  BLUE: TColorB = (r: 0; g: 121; b: 241; a: 255);
  DARKBLUE: TColorB = (r: 0; g: 82; b: 172; a: 255);
  PURPLE: TColorB = (r: 200; g: 122; b: 255; a: 255);
  VIOLET: TColorB = (r: 135; g: 60; b: 190; a: 255);
  DARKPURPLE: TColorB = (r: 112; g: 31; b: 126; a: 255);
  BEIGE: TColorB = (r: 211; g: 176; b: 131; a: 255);
  BROWN: TColorB = (r: 127; g: 106; b: 79; a: 255);
  DARKBROWN: TColorB = (r: 76; g: 63; b: 47; a: 255);
  WHITE: TColorB = (r: 255; g: 255; b: 255; a: 255);
  BLACK: TColorB = (r: 0; g: 0; b: 0; a: 255);
  BLANK: TColorB = (r: 0; g: 0; b: 0; a: 0);
  MAGENTA: TColorB = (r: 255; g: 0; b: 255; a: 255);
  RAYWHITE: TColorB = (r: 245; g: 245; b: 245; a: 255);

{ System/Window config flags
  NOTE: Every bit registers one state (use it with bit masks)
  By default all flags are set to 0 }

type
  TConfigFlags = Integer;

const
  { Set to try enabling V-Sync on GPU }
  FLAG_VSYNC_HINT         = $00000040;
  { Set to run program in fullscreen }
  FLAG_FULLSCREEN_MODE    = $00000002;
  { Set to allow resizable window }
  FLAG_WINDOW_RESIZABLE   = $00000004;
  { Set to disable window decoration (frame and buttons) }
  FLAG_WINDOW_UNDECORATED = $00000008;
  { Set to hide window }
  FLAG_WINDOW_HIDDEN      = $00000080;
  { Set to minimize window (iconify) }
  FLAG_WINDOW_MINIMIZED   = $00000200;
  { Set to maximize window (expanded to monitor) }
  FLAG_WINDOW_MAXIMIZED   = $00000400;
  { Set to window non focused }
  FLAG_WINDOW_UNFOCUSED   = $00000800;
  { Set to window always on top }
  FLAG_WINDOW_TOPMOST     = $00001000;
  { Set to allow windows running while minimized }
  FLAG_WINDOW_ALWAYS_RUN  = $00000100;
  { Set to allow transparent framebuffer }
  FLAG_WINDOW_TRANSPARENT = $00000010;
  { Set to support HighDPI }
  FLAG_WINDOW_HIGHDPI     = $00002000;
  { Set to try enabling MSAA 4X }
  FLAG_MSAA_4X_HINT       = $00000020;
  { Set to try enabling Integererlaced video format (for V3D) }
  FLAG_INTERLACED_HINT    = $00010000;

{ Trace log level
  NOTE: Organized by priority level }

type
  TTraceLogLevel = Integer;

const
  { Display all logs }
  LOG_ALL = 0;
  { Trace logging; Integerended for Integerernal use only }
  LOG_TRACE = LOG_ALL + 1;
  { Debug logging; used for Integerernal debugging; it should be disabled on release builds }
  LOG_DEBUG = LOG_TRACE + 1;
  { Info logging; used for program execution info }
  LOG_INFO = LOG_DEBUG + 1;
  { Warning logging; used on recoverable failures }
  LOG_WARNING = LOG_INFO + 1;
  { Error logging; used on unrecoverable failures }
  LOG_ERROR = LOG_WARNING + 1;
  { Fatal logging; used to abort program: exit(EXIT_FAILURE) }
  LOG_FATAL = LOG_ERROR + 1;
  { Disable logging }
  LOG_NONE = LOG_FATAL + 1;

{ Keyboard keys (US keyboard layout)
  NOTE: Use GetKeyPressed() to allow redefining
  required keys for alternative layouts }

type
  TKeyboardKey = Integer;

const
  { Key: NULL, used for no key pressed }
  KEY_NULL            = 0;
  { Key: ' }
  KEY_APOSTROPHE      = 39;
  { Key: , }
  KEY_COMMA           = 44;
  { Key: - }
  KEY_MINUS           = 45;
  { Key: . }
  KEY_PERIOD          = 46;
  { Key: / }
  KEY_SLASH           = 47;
  { Key: 0 }
  KEY_ZERO            = 48;
  { Key: 1 }
  KEY_ONE             = 49;
  { Key: 2 }
  KEY_TWO             = 50;
  { Key: 3 }
  KEY_THREE           = 51;
  { Key: 4 }
  KEY_FOUR            = 52;
  { Key: 5 }
  KEY_FIVE            = 53;
  { Key: 6 }
  KEY_SIX             = 54;
  { Key: 7 }
  KEY_SEVEN           = 55;
  { Key: 8 }
  KEY_EIGHT           = 56;
  { Key: 9 }
  KEY_NINE            = 57;
  { Key: ; }
  KEY_SEMICOLON       = 59;
  { Key: = }
  KEY_EQUAL           = 61;
  { Key: A | a }
  KEY_A               = 65;
  { Key: B | b }
  KEY_B               = 66;
  { Key: C | c }
  KEY_C               = 67;
  { Key: D | d }
  KEY_D               = 68;
  { Key: E | e }
  KEY_E               = 69;
  { Key: F | f }
  KEY_F               = 70;
  { Key: G | g }
  KEY_G               = 71;
  { Key: H | h }
  KEY_H               = 72;
  { Key: I | i }
  KEY_I               = 73;
  { Key: J | j }
  KEY_J               = 74;
  { Key: K | k }
  KEY_K               = 75;
  { Key: L | l }
  KEY_L               = 76;
  { Key: M | m }
  KEY_M               = 77;
  { Key: N | n }
  KEY_N               = 78;
  { Key: O | o }
  KEY_O               = 79;
  { Key: P | p }
  KEY_P               = 80;
  { Key: Q | q }
  KEY_Q               = 81;
  { Key: R | r }
  KEY_R               = 82;
  { Key: S | s }
  KEY_S               = 83;
  { Key: T | t }
  KEY_T               = 84;
  { Key: U | u }
  KEY_U               = 85;
  { Key: V | v }
  KEY_V               = 86;
  { Key: W | w }
  KEY_W               = 87;
  { Key: X | x }
  KEY_X               = 88;
  { Key: Y | y }
  KEY_Y               = 89;
  { Key: Z | z }
  KEY_Z               = 90;
  { Key: [ }
  KEY_LEFT_BRACKET    = 91;
  { Key: '\' }
  KEY_BACKSLASH       = 92;
  { Key: ] }
  KEY_RIGHT_BRACKET   = 93;
  { Key: ` }
  KEY_GRAVE           = 96;
  { Key: Space }
  KEY_SPACE           = 32;
  { Key: Esc }
  KEY_ESCAPE          = 256;
  { Key: Enter }
  KEY_ENTER           = 257;
  { Key: Tab }
  KEY_TAB             = 258;
  { Key: Backspace }
  KEY_BACKSPACE       = 259;
  { Key: Ins }
  KEY_INSERT          = 260;
  { Key: Del }
  KEY_DELETE          = 261;
  { Key: Cursor right }
  KEY_RIGHT           = 262;
  { Key: Cursor left }
  KEY_LEFT            = 263;
  { Key: Cursor down }
  KEY_DOWN            = 264;
  { Key: Cursor up }
  KEY_UP              = 265;
  { Key: Page up }
  KEY_PAGE_UP         = 266;
  { Key: Page down }
  KEY_PAGE_DOWN       = 267;
  { Key: Home }
  KEY_HOME            = 268;
  { Key: End }
  KEY_END             = 269;
  { Key: Caps lock }
  KEY_CAPS_LOCK       = 280;
  { Key: Scroll down }
  KEY_SCROLL_LOCK     = 281;
  { Key: Num lock }
  KEY_NUM_LOCK        = 282;
  { Key: PrInteger screen }
  KEY_PRINT_SCREEN    = 283;
  { Key: Pause }
  KEY_PAUSE           = 284;
  { Key: F1 }
  KEY_F1              = 290;
  { Key: F2 }
  KEY_F2              = 291;
  { Key: F3 }
  KEY_F3              = 292;
  { Key: F4 }
  KEY_F4              = 293;
  { Key: F5 }
  KEY_F5              = 294;
  { Key: F6 }
  KEY_F6              = 295;
  { Key: F7 }
  KEY_F7              = 296;
  { Key: F8 }
  KEY_F8              = 297;
  { Key: F9 }
  KEY_F9              = 298;
  { Key: F10 }
  KEY_F10             = 299;
  { Key: F11 }
  KEY_F11             = 300;
  { Key: F12 }
  KEY_F12             = 301;
  { Key: Shift left }
  KEY_LEFT_SHIFT      = 340;
  { Key: Control left }
  KEY_LEFT_CONTROL    = 341;
  { Key: Alt left }
  KEY_LEFT_ALT        = 342;
  { Key: Super left }
  KEY_LEFT_SUPER      = 343;
  { Key: Shift right }
  KEY_RIGHT_SHIFT     = 344;
  { Key: Control right }
  KEY_RIGHT_CONTROL   = 345;
  { Key: Alt right }
  KEY_RIGHT_ALT       = 346;
  { Key: Super right }
  KEY_RIGHT_SUPER     = 347;
  { Key: KB menu }
  KEY_KB_MENU         = 348;
  { Keypad keys }
  { Key: Keypad 0 }
  KEY_KP_0            = 320;
  { Key: Keypad 1 }
  KEY_KP_1            = 321;
  { Key: Keypad 2 }
  KEY_KP_2            = 322;
  { Key: Keypad 3 }
  KEY_KP_3            = 323;
  { Key: Keypad 4 }
  KEY_KP_4            = 324;
  { Key: Keypad 5 }
  KEY_KP_5            = 325;
  { Key: Keypad 6 }
  KEY_KP_6            = 326;
  { Key: Keypad 7 }
  KEY_KP_7            = 327;
  { Key: Keypad 8 }
  KEY_KP_8            = 328;
  { Key: Keypad 9 }
  KEY_KP_9            = 329;
  { Key: Keypad . }
  KEY_KP_DECIMAL      = 330;
  { Key: Keypad / }
  KEY_KP_DIVIDE       = 331;
  { Key: Keypad * }
  KEY_KP_MULTIPLY     = 332;
  { Key: Keypad - }
  KEY_KP_SUBTRACT     = 333;
  { Key: Keypad + }
  KEY_KP_ADD          = 334;
  { Key: Keypad Enter }
  KEY_KP_ENTER        = 335;
  { Key: Keypad = }
  KEY_KP_EQUAL        = 336;
  { Android key buttons }
  { Key: Android back button }
  KEY_BACK            = 4;
  { Key: Android menu button }
  KEY_MENU            = 82;
  { Key: Android volume up button }
  KEY_VOLUME_UP       = 24;
  { Key: Android volume down button }
  KEY_VOLUME_DOWN     = 25;

{ Mouse buttons }

type
  TMouseButton = Integer;

const
  { Mouse button left }
  MOUSE_BUTTON_LEFT    = 0;
  { Mouse button right }
  MOUSE_BUTTON_RIGHT   = 1;
  { Mouse button middle (pressed wheel) }
  MOUSE_BUTTON_MIDDLE  = 2;
  { Mouse button side (advanced mouse device) }
  MOUSE_BUTTON_SIDE    = 3;
  { Mouse button extra (advanced mouse device) }
  MOUSE_BUTTON_EXTRA   = 4;
  { Mouse button fordward (advanced mouse device) }
  MOUSE_BUTTON_FORWARD = 5;
  { Mouse button back (advanced mouse device) }
  MOUSE_BUTTON_BACK    = 6;
  { Add backwards compatibility support for deprecated names}
  MOUSE_LEFT_BUTTON = MOUSE_BUTTON_LEFT;
  MOUSE_RIGHT_BUTTON = MOUSE_BUTTON_RIGHT;
  MOUSE_MIDDLE_BUTTON = MOUSE_BUTTON_MIDDLE;

{ Mouse cursor }

type
  TMouseCursor = Integer;

const
  { Default pointer shape }
  MOUSE_CURSOR_DEFAULT       = 0;
  { Arrow shape }
  MOUSE_CURSOR_ARROW         = 1;
  { Text writing cursor shape }
  MOUSE_CURSOR_IBEAM         = 2;
  { Cross shape }
  MOUSE_CURSOR_CROSSHAIR     = 3;
  { Pointing hand cursor }
  MOUSE_CURSOR_POINTING_HAND = 4;
  { Horizontal resize/move arrow shape }
  MOUSE_CURSOR_RESIZE_EW     = 5;
  { Vertical resize/move arrow shape }
  MOUSE_CURSOR_RESIZE_NS     = 6;
  { Top-left to bottom-right diagonal resize/move arrow shape }
  MOUSE_CURSOR_RESIZE_NWSE   = 7;
  { The top-right to bottom-left diagonal resize/move arrow shape }
  MOUSE_CURSOR_RESIZE_NESW   = 8;
  { The omni-directional resize/move cursor shape }
  MOUSE_CURSOR_RESIZE_ALL    = 9;
  { The operation-not-allowed shape }
  MOUSE_CURSOR_NOT_ALLOWED   = 10;

{ Gamepad buttons }

type
  TGamepadButton = Integer;

const
  { Unknown button, just for error checking }
  GAMEPAD_BUTTON_UNKNOWN = 0;
  { Gamepad left DPAD up button }
  GAMEPAD_BUTTON_LEFT_FACE_UP = GAMEPAD_BUTTON_UNKNOWN;
  { Gamepad left DPAD right button }
  GAMEPAD_BUTTON_LEFT_FACE_RIGHT = GAMEPAD_BUTTON_LEFT_FACE_UP + 1;
  { Gamepad left DPAD down button }
  GAMEPAD_BUTTON_LEFT_FACE_DOWN = GAMEPAD_BUTTON_LEFT_FACE_RIGHT + 1;
  { Gamepad left DPAD left button }
  GAMEPAD_BUTTON_LEFT_FACE_LEFT = GAMEPAD_BUTTON_LEFT_FACE_DOWN + 1;
  { Gamepad right button up (i.e. PS3: Triangle; Xbox: Y) }
  GAMEPAD_BUTTON_RIGHT_FACE_UP = GAMEPAD_BUTTON_LEFT_FACE_LEFT + 1;
  { Gamepad right button right (i.e. PS3: Square; Xbox: X) }
  GAMEPAD_BUTTON_RIGHT_FACE_RIGHT = GAMEPAD_BUTTON_RIGHT_FACE_UP + 1;
  { Gamepad right button down (i.e. PS3: Cross; Xbox: A) }
  GAMEPAD_BUTTON_RIGHT_FACE_DOWN = GAMEPAD_BUTTON_RIGHT_FACE_RIGHT + 1;
  { Gamepad right button left (i.e. PS3: Circle; Xbox: B) }
  GAMEPAD_BUTTON_RIGHT_FACE_LEFT = GAMEPAD_BUTTON_RIGHT_FACE_DOWN + 1;
  { Gamepad top/back trigger left (first), it could be a trailing button }
  GAMEPAD_BUTTON_LEFT_TRIGGER_1 = GAMEPAD_BUTTON_RIGHT_FACE_LEFT + 1;
  { Gamepad top/back trigger left (second); it could be a trailing button }
  GAMEPAD_BUTTON_LEFT_TRIGGER_2 = GAMEPAD_BUTTON_LEFT_TRIGGER_1 + 1;
  { Gamepad top/back trigger right (one); it could be a trailing button }
  GAMEPAD_BUTTON_RIGHT_TRIGGER_1 = GAMEPAD_BUTTON_LEFT_TRIGGER_2 + 1;
  { Gamepad top/back trigger right (second), it could be a trailing button }
  GAMEPAD_BUTTON_RIGHT_TRIGGER_2 = GAMEPAD_BUTTON_RIGHT_TRIGGER_1 + 1;
  { Gamepad center buttons, left one (i.e. PS3: Select) }
  GAMEPAD_BUTTON_MIDDLE_LEFT = GAMEPAD_BUTTON_RIGHT_TRIGGER_2 + 1;
  { Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX) }
  GAMEPAD_BUTTON_MIDDLE = GAMEPAD_BUTTON_MIDDLE_LEFT + 1;
  { Gamepad center buttons, right one (i.e. PS3: Start) }
  GAMEPAD_BUTTON_MIDDLE_RIGHT = GAMEPAD_BUTTON_MIDDLE + 1;
  { Gamepad joystick pressed button left }
  GAMEPAD_BUTTON_LEFT_THUMB = GAMEPAD_BUTTON_MIDDLE_RIGHT + 1;
  { Gamepad joystick pressed button right }
  GAMEPAD_BUTTON_RIGHT_THUMB = GAMEPAD_BUTTON_LEFT_THUMB + 1;

{ Gamepad axis }

type
  TGamepadAxis = Integer;

const
  { Gamepad left stick X axis }
  GAMEPAD_AXIS_LEFT_X        = 0;
  { Gamepad left stick Y axis }
  GAMEPAD_AXIS_LEFT_Y        = 1;
  { Gamepad right stick X axis }
  GAMEPAD_AXIS_RIGHT_X       = 2;
  { Gamepad right stick Y axis }
  GAMEPAD_AXIS_RIGHT_Y       = 3;
  { Gamepad back trigger left; pressure level: [1..-1] }
  GAMEPAD_AXIS_LEFT_TRIGGER  = 4;
  { Gamepad back trigger right; pressure level: [1..-1] }
  GAMEPAD_AXIS_RIGHT_TRIGGER = 5;

{ TMaterial map index }

type
  TMaterialMapIndex = Integer;

const
  { Albedo material (same as: MATERIAL_MAP_DIFFUSE) }
  MATERIAL_MAP_ALBEDO = 0;
  { Metalness material (same as: MATERIAL_MAP_SPECULAR)  = 0; }
  MATERIAL_MAP_METALNESS = MATERIAL_MAP_ALBEDO + 1;
  { Normal material  SS; }
  MATERIAL_MAP_NORMAL = MATERIAL_MAP_METALNESS + 1;
  { Roughness material }
  MATERIAL_MAP_ROUGHNESS = MATERIAL_MAP_NORMAL + 1;
  { Ambient occlusion material }
  MATERIAL_MAP_OCCLUSION = MATERIAL_MAP_ROUGHNESS + 1;
  { Emission material }
  MATERIAL_MAP_EMISSION = MATERIAL_MAP_OCCLUSION + 1;
  { Heightmap material }
  MATERIAL_MAP_HEIGHT = MATERIAL_MAP_EMISSION + 1;
  { Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP) }
  MATERIAL_MAP_CUBEMAP = MATERIAL_MAP_HEIGHT + 1;
  { Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP) }
  MATERIAL_MAP_IRRADIANCE = MATERIAL_MAP_CUBEMAP + 1;
  { Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP) }
  MATERIAL_MAP_PREFILTER = MATERIAL_MAP_IRRADIANCE + 1;
  { Brdf material }
  MATERIAL_MAP_BRDF = MATERIAL_MAP_PREFILTER + 1;

  MATERIAL_MAP_DIFFUSE = MATERIAL_MAP_ALBEDO;
  MATERIAL_MAP_SPECULAR = MATERIAL_MAP_METALNESS;

{ Shader location index }

type
  TShaderLocationIndex = Integer;

const
  { Shader location: vertex attribute: position }
  SHADER_LOC_VERTEX_POSITION = 0;
  { Shader location: vertex attribute: texcoord01 }
  SHADER_LOC_VERTEX_TEXCOORD01 = SHADER_LOC_VERTEX_POSITION + 1;
  { Shader location: vertex attribute: texcoord02 }
  SHADER_LOC_VERTEX_TEXCOORD02 = SHADER_LOC_VERTEX_TEXCOORD01 + 1;
  { Shader location: vertex attribute: normal }
  SHADER_LOC_VERTEX_NORMAL = SHADER_LOC_VERTEX_TEXCOORD02 + 1;
  { Shader location: vertex attribute: tangent }
  SHADER_LOC_VERTEX_TANGENT = SHADER_LOC_VERTEX_NORMAL + 1;
  { Shader location: vertex attribute: color }
  SHADER_LOC_VERTEX_COLOR = SHADER_LOC_VERTEX_TANGENT + 1;
  { Shader location: matrix uniform: model-view-projection }
  SHADER_LOC_MATRIX_MVP = SHADER_LOC_VERTEX_COLOR + 1;
  { Shader location: matrix uniform: view (camera transform) }
  SHADER_LOC_MATRIX_VIEW = SHADER_LOC_MATRIX_MVP + 1;
  { Shader location: matrix uniform: projection }
  SHADER_LOC_MATRIX_PROJECTION = SHADER_LOC_MATRIX_VIEW + 1;
  { Shader location: matrix uniform: model (transform) }
  SHADER_LOC_MATRIX_MODEL = SHADER_LOC_MATRIX_PROJECTION + 1;
  { Shader location: matrix uniform: normal }
  SHADER_LOC_MATRIX_NORMAL = SHADER_LOC_MATRIX_MODEL + 1;
  { Shader location: vector uniform: view }
  SHADER_LOC_VECTOR_VIEW = SHADER_LOC_MATRIX_NORMAL + 1;
  { Shader location: vector uniform: diffuse color }
  SHADER_LOC_COLOR_DIFFUSE = SHADER_LOC_VECTOR_VIEW + 1;
  { Shader location: vector uniform: specular color }
  SHADER_LOC_COLOR_SPECULAR = SHADER_LOC_COLOR_DIFFUSE + 1;
  { Shader location: vector uniform: ambient color }
  SHADER_LOC_COLOR_AMBIENT = SHADER_LOC_COLOR_SPECULAR + 1;
  { Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE) }
  SHADER_LOC_MAP_ALBEDO = SHADER_LOC_COLOR_AMBIENT + 1;
  { Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR) }
  SHADER_LOC_MAP_METALNESS = SHADER_LOC_MAP_ALBEDO + 1;
  { Shader location: sampler2d texture: normal }
  SHADER_LOC_MAP_NORMAL = SHADER_LOC_MAP_METALNESS + 1;
  { Shader location: sampler2d texture: roughness }
  SHADER_LOC_MAP_ROUGHNESS = SHADER_LOC_MAP_NORMAL + 1;
  { Shader location: sampler2d texture: occlusion }
  SHADER_LOC_MAP_OCCLUSION = SHADER_LOC_MAP_ROUGHNESS + 1;
  { Shader location: sampler2d texture: emission }
  SHADER_LOC_MAP_EMISSION = SHADER_LOC_MAP_OCCLUSION + 1;
  { Shader location: sampler2d texture: height }
  SHADER_LOC_MAP_HEIGHT = SHADER_LOC_MAP_EMISSION + 1;
  { Shader location: samplerCube texture: cubemap }
  SHADER_LOC_MAP_CUBEMAP = SHADER_LOC_MAP_HEIGHT + 1;
  { Shader location: samplerCube texture: irradiance }
  SHADER_LOC_MAP_IRRADIANCE = SHADER_LOC_MAP_CUBEMAP + 1;
  { Shader location: samplerCube texture: prefilter }
  SHADER_LOC_MAP_PREFILTER = SHADER_LOC_MAP_IRRADIANCE + 1;
  { Shader location: sampler2d texture: brdf }
  SHADER_LOC_MAP_BRDF = SHADER_LOC_MAP_PREFILTER + 1;

  SHADER_LOC_MAP_DIFFUSE = SHADER_LOC_MAP_ALBEDO;
  SHADER_LOC_MAP_SPECULAR = SHADER_LOC_MAP_METALNESS;

{ Shader uniform data type }

type
  TShaderUniformDataType = Integer;

const
  { Shader uniform type: Single }
  SHADER_UNIFORM_FLOAT = 0;
  { Shader uniform type: vec2 (2 Single) }
  SHADER_UNIFORM_VEC2 = SHADER_UNIFORM_FLOAT + 1;
  { Shader uniform type: vec3 (3 Single) }
  SHADER_UNIFORM_VEC3 = SHADER_UNIFORM_VEC2 + 1;
  { Shader uniform type: vec4 (4 Single) }
  SHADER_UNIFORM_VEC4 = SHADER_UNIFORM_VEC3 + 1;
  { Shader uniform type: Integer }
  SHADER_UNIFORM_INT = SHADER_UNIFORM_VEC4 + 1;
  { Shader uniform type: ivec2 (2 Integer) }
  SHADER_UNIFORM_IVEC2 = SHADER_UNIFORM_INT + 1;
  { Shader uniform type: ivec3 (3 Integer) }
  SHADER_UNIFORM_IVEC3 = SHADER_UNIFORM_IVEC2 + 1;
  { Shader uniform type: ivec4 (4 Integer) }
  SHADER_UNIFORM_IVEC4 = SHADER_UNIFORM_IVEC3 + 1;
  { Shader uniform type: sampler2d }
  SHADER_UNIFORM_SAMPLER2D = SHADER_UNIFORM_IVEC4 + 1;

{ Shader attribute data types }

type
  TShaderAttributeDataType = Integer;

const
  { Shader attribute type: Single }
  SHADER_ATTRIB_FLOAT = 0;
  { Shader attribute type: vec2 (2 Single) }
  SHADER_ATTRIB_VEC2 = SHADER_ATTRIB_FLOAT + 1;
  { Shader attribute type: vec3 (3 Single) }
  SHADER_ATTRIB_VEC3 = SHADER_ATTRIB_VEC2 + 1;
  { Shader attribute type: vec4 (4 Single) }
  SHADER_ATTRIB_VEC4 = SHADER_ATTRIB_VEC3 + 1;

{ Pixel formats
  NOTE: Support depends on OpenGL version and platform }

type
  TPixelFormat = Integer;

const
  { 8 bit per pixel (no alpha) }
  PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1;
  { 8*2 bpp (2 channels) }
  PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA = PIXELFORMAT_UNCOMPRESSED_GRAYSCALE + 1;
  { 16 bpp }
  PIXELFORMAT_UNCOMPRESSED_R5G6B5 = PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA + 1;
  { 24 bpp }
  PIXELFORMAT_UNCOMPRESSED_R8G8B8 = PIXELFORMAT_UNCOMPRESSED_R5G6B5 + 1;
  { 16 bpp (1 bit alpha) }
  PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 = PIXELFORMAT_UNCOMPRESSED_R8G8B8 + 1;
  { 16 bpp (4 bit alpha) }
  PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 = PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 + 1;
  { 32 bpp }
  PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 + 1;
  { 32 bpp (1 channel - Single) }
  PIXELFORMAT_UNCOMPRESSED_R32 = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 + 1;
  { 32*3 bpp (3 channels - Single) }
  PIXELFORMAT_UNCOMPRESSED_R32G32B32 = PIXELFORMAT_UNCOMPRESSED_R32 + 1;
  { 32*4 bpp (4 channels - Single) }
  PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 = PIXELFORMAT_UNCOMPRESSED_R32G32B32 + 1;
  { 4 bpp (no alpha) }
  PIXELFORMAT_COMPRESSED_DXT1_RGB = PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 + 1;
  { 4 bpp (1 bit alpha) }
  PIXELFORMAT_COMPRESSED_DXT1_RGBA = PIXELFORMAT_COMPRESSED_DXT1_RGB + 1;
  { 8 bpp }
  PIXELFORMAT_COMPRESSED_DXT3_RGBA = PIXELFORMAT_COMPRESSED_DXT1_RGBA + 1;
  { 8 bpp }
  PIXELFORMAT_COMPRESSED_DXT5_RGBA = PIXELFORMAT_COMPRESSED_DXT3_RGBA + 1;
  { 4 bpp }
  PIXELFORMAT_COMPRESSED_ETC1_RGB = PIXELFORMAT_COMPRESSED_DXT5_RGBA + 1;
  { 4 bpp }
  PIXELFORMAT_COMPRESSED_ETC2_RGB = PIXELFORMAT_COMPRESSED_ETC1_RGB + 1;
  { 8 bpp }
  PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA = PIXELFORMAT_COMPRESSED_ETC2_RGB + 1;
  { 4 bpp }
  PIXELFORMAT_COMPRESSED_PVRT_RGB = PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA + 1;
  { 4 bpp }
  PIXELFORMAT_COMPRESSED_PVRT_RGBA = PIXELFORMAT_COMPRESSED_PVRT_RGB + 1;
  { 8 bpp }
  PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA = PIXELFORMAT_COMPRESSED_PVRT_RGBA + 1;
  { 2 bpp }
  PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA = PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA + 1;

{ Texture parameters: filter mode
  NOTE 1: Filtering considers mipmaps if available in the texture
  NOTE 2: Filter is accordingly set for minification and magnification }

type
  TTextureFilter = Integer;

const
  { No filter; just pixel aproximation }
  TEXTURE_FILTER_POINT = 0;
  { Linear filtering }
  TEXTURE_FILTER_BILINEAR = TEXTURE_FILTER_POINT + 1;
  { Trilinear filtering (linear with mipmaps) }
  TEXTURE_FILTER_TRILINEAR = TEXTURE_FILTER_BILINEAR + 1;
  { Anisotropic filtering 4x }
  TEXTURE_FILTER_ANISOTROPIC_4X = TEXTURE_FILTER_TRILINEAR + 1;
  { Anisotropic filtering 8x }
  TEXTURE_FILTER_ANISOTROPIC_8X = TEXTURE_FILTER_ANISOTROPIC_4X + 1;
  { Anisotropic filtering 16x }
  TEXTURE_FILTER_ANISOTROPIC_16X = TEXTURE_FILTER_ANISOTROPIC_8X + 1;

{ Texture parameters: wrap mode }

type
  TTextureWrap = Integer;

const
  { Repeats texture in tiled mode }
  TEXTURE_WRAP_REPEAT = 0;
  { Clamps texture to edge pixel in tiled mode }
  TEXTURE_WRAP_CLAMP = TEXTURE_WRAP_REPEAT + 1;
  { Mirrors and repeats the texture in tiled mode }
  TEXTURE_WRAP_MIRROR_REPEAT = TEXTURE_WRAP_CLAMP + 1;
  { Mirrors and clamps to border the texture in tiled mode }
  TEXTURE_WRAP_MIRROR_CLAMP = TEXTURE_WRAP_MIRROR_REPEAT + 1;

{ Cubemap layouts }

type
  TCubemapLayout = Integer;

const
  { Automatically detect layout type }
  CUBEMAP_LAYOUT_AUTO_DETECT = 0;
  { Layout is defined by a vertical line with faces }
  CUBEMAP_LAYOUT_LINE_VERTICAL = CUBEMAP_LAYOUT_AUTO_DETECT + 1;
  { Layout is defined by an horizontal line with faces }
  CUBEMAP_LAYOUT_LINE_HORIZONTAL = CUBEMAP_LAYOUT_LINE_VERTICAL + 1;
  { Layout is defined by a 3x4 cross with cubemap faces }
  CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR = CUBEMAP_LAYOUT_LINE_HORIZONTAL + 1;
  { Layout is defined by a 4x3 cross with cubemap faces }
  CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE = CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR + 1;
  { Layout is defined by a panorama image (equirectangular map) }
  CUBEMAP_LAYOUT_PANORAMA = CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE + 1;

{ Font type defines generation method }

type
  TFontType = Integer;

const
  { Default font generation; anti-aliased }
  FONT_DEFAULT = 0;
  { Bitmap font generation; no anti-aliasing }
  FONT_BITMAP = FONT_DEFAULT + 1;
  { SDF font generation; requires external shader }
  FONT_SDF = FONT_BITMAP + 1;

{ TColorB blending modes (pre-defined) }

type
  TBlendMode = Integer;

const
  { Blend textures considering alpha (default) }
  BLEND_ALPHA = 0;
  { Blend textures adding colors }
  BLEND_ADDITIVE = BLEND_ALPHA + 1;
  { Blend textures multiplying colors }
  BLEND_MULTIPLIED = BLEND_ADDITIVE + 1;
  { Blend textures adding colors (alternative) }
  BLEND_ADD_COLORS = BLEND_MULTIPLIED + 1;
  { Blend textures subtracting colors (alternative) }
  BLEND_SUBTRACT_COLORS = BLEND_ADD_COLORS + 1;
  { Belnd textures using custom src/dst factors (use rlSetBlendMode()) }
  BLEND_CUSTOM = BLEND_SUBTRACT_COLORS + 1;

{ Gesture
  NOTE: It could be used as flags to enable only some gestures }

type
  TGesture = Integer;

const
  { No gesture }
  GESTURE_NONE        = 0;
  { Tap gesture }
  GESTURE_TAP         = 1;
  { Double tap gesture }
  GESTURE_DOUBLETAP   = 2;
  { Hold gesture }
  GESTURE_HOLD        = 4;
  { Drag gesture }
  GESTURE_DRAG        = 8;
  { Swipe right gesture }
  GESTURE_SWIPE_RIGHT = 16;
  { Swipe left gesture }
  GESTURE_SWIPE_LEFT  = 32;
  { Swipe up gesture }
  GESTURE_SWIPE_UP    = 64;
  { Swipe down gesture }
  GESTURE_SWIPE_DOWN  = 128;
  { Pinch in gesture }
  GESTURE_PINCH_IN    = 256;
  { Pinch out gesture }
  GESTURE_PINCH_OUT   = 512;

{ Camera system modes }
type
  TCameraMode = Integer;

const
  { Custom camera }
  CAMERA_CUSTOM = 0;
  { Free camera }
  CAMERA_FREE = CAMERA_CUSTOM + 1;
  { Orbital camera }
  CAMERA_ORBITAL = CAMERA_FREE + 1;
  { First person camera }
  CAMERA_FIRST_PERSON = CAMERA_ORBITAL + 1;
  { Third person camera }
  CAMERA_THIRD_PERSON = CAMERA_FIRST_PERSON + 1;

{ Camera projection }

type
  TCameraProjection = Integer;

const
  { Perspective projection }
  CAMERA_PERSPECTIVE = 0;
  { Orthographic projection }
  CAMERA_ORTHOGRAPHIC = CAMERA_PERSPECTIVE + 1;

{ N-patch layout }

type
  TNPatchLayout = Integer;

const
  { Npatch layout: 3x3 tiles }
  NPATCH_NINE_PATCH = 0;
  { Npatch layout: 1x3 tiles }
  NPATCH_THREE_PATCH_VERTICAL = NPATCH_NINE_PATCH + 1;
  { Npatch layout: 3x1 tiles }
  NPATCH_THREE_PATCH_HORIZONTAL = NPATCH_THREE_PATCH_VERTICAL + 1;

{ Initialize window and OpenGL context }
procedure InitWindow(width, height: Integer; title: PChar); cdecl; external;
{ Check if KEY_ESCAPE pressed or Close icon pressed }
function WindowShouldClose: Boolean; cdecl; external;
{ Close window and unload OpenGL context }
procedure CloseWindow; cdecl; external;
{ Check if window has been initialized successfully }
function IsWindowReady: Boolean; cdecl; external;
{ Check if window is currently fullscreen }
function IsWindowFullscreen: Boolean; cdecl; external;
{ Check if window is currently hidden (only PLATFORM_DESKTOP) }
function IsWindowHidden: Boolean; cdecl; external;
{ Check if window is currently minimized (only PLATFORM_DESKTOP) }
function IsWindowMinimized: Boolean; cdecl; external;
{ Check if window is currently maximized (only PLATFORM_DESKTOP) }
function IsWindowMaximized: Boolean; cdecl; external;
{ Check if window is currently focused (only PLATFORM_DESKTOP) }
function IsWindowFocused: Boolean; cdecl; external;
{ Check if window has been resized last frame }
function IsWindowResized: Boolean; cdecl; external;
{ Check if one specific window flag is enabled }
function IsWindowState(flag: LongWord): Boolean; cdecl; external;
{ Set window configuration state using flags }
procedure SetWindowState(flags: LongWord); cdecl; external;
{ Clear window configuration state flags }
procedure ClearWindowState(flags: LongWord); cdecl; external;
{ Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP) }
procedure ToggleFullscreen; cdecl; external;
{ Set window maximized: state:; if resizable (only PLATFORM_DESKTOP) }
procedure MaximizeWindow; cdecl; external;
{ Set window minimized: state:; if resizable (only PLATFORM_DESKTOP) }
procedure MinimizeWindow; cdecl; external;
{ Set window state: not minimized/maximized (only PLATFORM_DESKTOP) }
procedure RestoreWindow; cdecl; external;
{ Set icon for window (only PLATFORM_DESKTOP) }
procedure SetWindowIcon(image: TImage); cdecl; external;
{ Set title for window (only PLATFORM_DESKTOP) }
procedure SetWindowTitle(title: PChar); cdecl; external;
{ Set window position on screen (only PLATFORM_DESKTOP) }
procedure SetWindowPosition(x, y: Integer); cdecl; external;
{ Set monitor for the current window (fullscreen mode) }
procedure SetWindowMonitor(monitor: Integer); cdecl; external;
{ Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE) }
procedure SetWindowMinSize(width, height: Integer); cdecl; external;
{ Set window dimensions }
procedure SetWindowSize(width, height: Integer); cdecl; external;
{ Get native window handle }
function GetWindowHandle: Pointer; cdecl; external;
{ Get current screen width }
function GetScreenWidth: Integer; cdecl; external;
{ Get current screen height }
function GetScreenHeight: Integer; cdecl; external;
{ Get number of connected monitors }
function GetMonitorCount: Integer; cdecl; external;
{ Get current connected monitor }
function GetCurrentMonitor: Integer; cdecl; external;
{ Get specified monitor position }
function GetMonitorPosition(monitor: Integer): TVec2; cdecl; external;
{ Get specified monitor width (max available by monitor) }
function GetMonitorWidth(monitor: Integer): Integer; cdecl; external;
{ Get specified monitor height (max available by monitor) }
function GetMonitorHeight(monitor: Integer): Integer; cdecl; external;
{ Get specified monitor physical width in millimetres }
function GetMonitorPhysicalWidth(monitor: Integer): Integer; cdecl; external;
{ Get specified monitor physical height in millimetres }
function GetMonitorPhysicalHeight(monitor: Integer): Integer; cdecl; external;
{ Get specified monitor refresh rate }
function GetMonitorRefreshRate(monitor: Integer): Integer; cdecl; external;
{ Get window position XY on monitor }
function GetWindowPosition: TVec2; cdecl; external;
{ Get window scale DPI factor }
function GetWindowScaleDPI: TVec2; cdecl; external;
{ Get the readable: human; UTF-8 encoded name of the primary monitor }
function GetMonitorName(monitor: Integer): PChar; cdecl; external;
{ Set clipboard text content }
procedure SetClipboardText(text: PChar); cdecl; external;
{ Get clipboard text content }
function GetClipboardText: PChar; cdecl; external;

{ Custom frame control functions
  NOTE: Those functions are Integerended for advance users that want full
  control over the frame processing. By default EndDrawing() does this
  job: draws everything + SwapScreenBuffer() + manage frame timming +
  PollInputEvents(). To avoid that behaviour and control frame processes,
  manually enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL }

{ Swap back buffer with front buffer (screen drawing) }
procedure SwapScreenBuffer; cdecl; external;
{ Register all input events }
procedure PollInputEvents; cdecl; external;
{ Wait for some milliseconds (halt program execution) }
procedure WaitTime(ms: Single); cdecl; external;

{ Cursor-related functions }

{ Shows cursor }
procedure ShowCursor; cdecl; external;
{ Hides cursor }
procedure HideCursor; cdecl; external;
{ Check if cursor is not visible }
function IsCursorHidden: Boolean; cdecl; external;
{ Enables cursor (unlock cursor) }
procedure EnableCursor; cdecl; external;
{ Disables cursor (lock cursor) }
procedure DisableCursor; cdecl; external;
{ Check if cursor is on the screen }
function IsCursorOnScreen: Boolean; cdecl; external;

{ Drawing-related functions }

{ Set background color (framebuffer clear color) }
procedure ClearBackground(color: TColorB); cdecl; external;
{ Setup canvas (framebuffer) to start drawing }
procedure BeginDrawing; cdecl; external;
{ End canvas drawing and swap buffers (double buffering) }
procedure EndDrawing; cdecl; external;
{ Begin 2D mode with custom camera (2D) }
procedure BeginMode2D(camera: TCamera2D); cdecl; external;
{ Ends 2D mode with custom camera }
procedure EndMode2D; cdecl; external;
{ Begin 3D mode with custom camera (3D) }
procedure BeginMode3D(camera: TCamera3D); cdecl; external;
{ Ends 3D mode and returns to default 2D orthographic mode }
procedure EndMode3D; cdecl; external;
{ Begin drawing to render texture }
procedure BeginTextureMode(target: TRenderTexture2D); cdecl; external;
{ Ends drawing to render texture }
procedure EndTextureMode; cdecl; external;
{ Begin custom shader drawing }
procedure BeginShaderMode(shader: TShader); cdecl; external;
{ End custom shader drawing (use default shader) }
procedure EndShaderMode; cdecl; external;
{ Begin blending alpha: additive: multiplied: subtract: mode custom) }
procedure BeginBlendMode(mode: Integer); cdecl; external;
{ End blending mode (reset to default: alpha blending) }
procedure EndBlendMode; cdecl; external;
{ Begin scissor mode (define screen area for following drawing) }
procedure BeginScissorMode(x, y, width, height: Integer); cdecl; external;
{ End scissor mode }
procedure EndScissorMode; cdecl; external;
{ Begin stereo rendering (requires VR simulator) }
procedure BeginVrStereoMode(config: TVrStereoConfig); cdecl; external;
{ End stereo rendering (requires VR simulator) }
procedure EndVrStereoMode; cdecl; external;

{ VR stereo config functions for VR simulator }

{ Load VR stereo config for VR simulator device parameters }
function LoadVrStereoConfig(device: TVrDeviceInfo): TVrStereoConfig; cdecl; external;
{ Unload VR stereo config }
procedure UnloadVrStereoConfig(config: TVrStereoConfig); cdecl; external;

{ Shader management functions
  NOTE: Shader functionality is not available on OpenGL 1.1 }

{ Load shader from files and bind default locations }
function LoadShader(vsFileName, fsFileName: PChar): TShader; cdecl; external;
{ Load shader from code strings and bind default locations }
function LoadShaderFromMemory(vsCode, fsCode: PChar): TShader; cdecl; external;
{ Get shader uniform location }
function GetShaderLocation(shader: TShader; uniformName: PChar): Integer; cdecl; external;
{ Get shader attribute location }
function GetShaderLocationAttrib(shader: TShader; attribName: PChar): Integer; cdecl; external;
{ Set shader uniform value }
procedure SetShaderValue(shader: TShader; locIndex: Integer; value: Pointer; uniformType: Integer); cdecl; external;
{ Set shader uniform value vector }
procedure SetShaderValueV(shader: TShader; locIndex: Integer; value: Pointer; uniformType, count: Integer); cdecl; external;
{ Set shader uniform value (matrix 4x4) }
procedure SetShaderValueMatrix(shader: TShader; locIndex: Integer; mat: TMat4); cdecl; external;
{ Set shader uniform value for texture (sampler2d) }
procedure SetShaderValueTexture(shader: TShader; locIndex: Integer; texture: TTexture2D); cdecl; external;
{ Unload shader from GPU memory (VRAM) }
procedure UnloadShader(shader: TShader); cdecl; external;

{ Screen-space-related functions }

{ Get a ray trace from mouse position }
function GetMouseRay(mousePosition: TVec2; camera: TCamera): TRay; cdecl; external;
{ Get camera transform matrix (view matrix) }
function GetCameraMatrix(camera: TCamera): TMat4; cdecl; external;
{ Get camera 2d transform matrix }
function GetCameraMatrix2D(camera: TCamera2D): TMat4; cdecl; external;
{ Get the screen space position for a 3d world space position }
function GetWorldToScreen(position: TVec3; camera: TCamera): TVec2; cdecl; external;
{ Get size position for a 3d world space position }
function GetWorldToScreenEx(position: TVec3; camera: TCamera; width: Integer; height: Integer): TVec2; cdecl; external;
{ Get the screen space position for a 2d camera world space position }
function GetWorldToScreen2D(position: TVec2; camera: TCamera2D): TVec2; cdecl; external;
{ Get the world space position for a 2d camera screen space position }
function GetScreenToWorld2D(position: TVec2; camera: TCamera2D): TVec2; cdecl; external;

{ Timing-related functions }

{ Set target FPS (maximum) }
procedure SetTargetFPS(fps: Integer); cdecl; external;
{ Get current FPS }
function GetFPS: Integer; cdecl; external;
{ Get time in seconds for last frame drawn (delta time) }
function GetFrameTime: Single; cdecl; external;
{ Get elapsed time in seconds since InitWindow() }
function GetTime: double; cdecl; external;

{ Misc. functions }

{ Get a random value between min and max (both included) }
function GetRandomValue(min: Integer; max: Integer): Integer; cdecl; external;
{ Set the seed for the random number generator }
procedure SetRandomSeed(seed: LongWord); cdecl; external;
{ Takes a screenshot of current screen (filename extension defines format) }
procedure TakeScreenshot(fileName: PChar); cdecl; external;
{ Setup init configuration flags (view FLAGS) }
procedure SetConfigFlags(flags: LongWord); cdecl; external;

{ Show trace log LOG_DEBUG: LOG_INFO: LOG_WARNING: messages ;;; LOG_ERROR...) }
//procedure TraceLog(logLevel: Integer; PChar; ...: text:); cdecl; external;
{ Set the current threshold (minimum) log level }
procedure SetTraceLogLevel(logLevel: Integer); cdecl; external;
{ Internal memory allocator }
function MemAlloc(size: Integer): Pointer; cdecl; external;
{ Internal memory reallocator }
function MemRealloc(ptr: Pointer; size: Integer): Pointer; cdecl; external;
{ Internal memory free }
procedure MemFree(ptr: Pointer); cdecl; external;

{ Set custom callbacks
  WARNING: Callbacks setup is Integerended for advance users }

type
  TTraceLogCallback = procedure(logLevel: Integer; text: PChar); cdecl; // , va_list args
  TLoadFileDataCallback = function(fileName: PChar; out bytesRead: LongWord): PChar; cdecl;
  TSaveFileDataCallback = function(fileName: PChar; data: Pointer; bytesToWrite: LongWord): Boolean; cdecl;
  TLoadFileTextCallback = function(fileName: PChar): PChar; cdecl;
  TSaveFileTextCallback = function(fileName, text: PChar): Boolean; cdecl;

{ Set custom trace log }
procedure SetTraceLogCallback(callback: TTraceLogCallback); cdecl; external;
{ Set custom file binary data loader }
procedure SetLoadFileDataCallback(callback: TLoadFileDataCallback); cdecl; external;
{ Set custom file binary data saver }
procedure SetSaveFileDataCallback(callback: TSaveFileDataCallback); cdecl; external;
{ Set custom file text data loader }
procedure SetLoadFileTextCallback(callback: TLoadFileTextCallback); cdecl; external;
{ Set custom file text data saver }
procedure SetSaveFileTextCallback(callback: TSaveFileTextCallback); cdecl; external;

{ Files management functions }

{ Load file data as byte array (read) }
function LoadFileData(fileName: PChar; out bytesRead: LongWord): Pointer; cdecl; external;
{ Unload file data allocated by LoadFileData() }
procedure UnloadFileData(data: Pointer); cdecl; external;
{ Save data to file from byte write): array ; returns true on success }
function SaveFileData(fileName: PChar; data: Pointer; bytesToWrite: LongWord): Boolean; cdecl; external;
{ Load text data from read): file ; returns a '\0' terminated string }
function LoadFileText(fileName: PChar): PChar; cdecl; external;
{ Unload file text data allocated by LoadFileText() }
procedure UnloadFileText(text: PChar); cdecl; external;
{ Save text data to write): file ; string must be '\terminated: 0'; returns true on success }
function SaveFileText(fileName: PChar; text: PChar): Boolean; cdecl; external;
{ Check if file exists }
function FileExists(fileName: PChar): Boolean; cdecl; external;
{ Check if a directory path exists }
function DirectoryExists(dirPath: PChar): Boolean; cdecl; external;
{ Check file extension (including png: point: ; .wav) }
function IsFileExtension(fileName, ext: PChar): Boolean; cdecl; external;
{ Get pointer to extension for a filename string (includes dot: '.png') }
function GetFileExtension(fileName: PChar): PChar; cdecl; external;
{ Get pointer to filename for a path string }
function GetFileName(filePath: PChar): PChar; cdecl; external;
{ Get filename string without extension (uses static string) }
function GetFileNameWithoutExt(filePath: PChar): PChar; cdecl; external;
{ Get full path for a given fileName with path (uses static string) }
function GetDirectoryPath(filePath: PChar): PChar; cdecl; external;
{ Get previous directory path for a given path (uses static string) }
function GetPrevDirectoryPath(dirPath: PChar): PChar; cdecl; external;
{ Get current working directory (uses static string) }
function GetWorkingDirectory: PChar; cdecl; external;
{ Get filenames in a directory path (memory should be freed) }
function GetDirectoryFiles(dirPath: PChar; out count: PInteger): PChar; cdecl; external;
{ Clear directory files paths buffers (free memory) }
procedure ClearDirectoryFiles; cdecl; external;
{ Change directory: working; return true on success }
function ChangeDirectory(dir: PChar): Boolean; cdecl; external;
{ Check if a file has been dropped into window }
function IsFileDropped: Boolean; cdecl; external;
{ Get dropped files names (memory should be freed) }
function GetDroppedFiles(count: PInteger): PPChar; cdecl; external;
{ Clear dropped files paths buffer (free memory) }
procedure ClearDroppedFiles; cdecl; external;
{ Get file modification time (last write time) }
function GetFileModTime(fileName: PChar): QWord; cdecl; external;

{ Compression/Encoding functionality }

{ Compress data (DEFLATE algorithm) }
function CompressData(data: Pointer; dataLength: Integer; out compDataLength: Integer): Pointer; cdecl; external;
{ Decompress data (DEFLATE algorithm) }
function DecompressData(compData: Pointer; compDataLength: Integer; out dataLength: Integer): Pointer; cdecl; external;
{ Encode data to Base64 string }
function EncodeDataBase64(const data: Pointer; dataLength: Integer; out outputLength: Integer): PChar; cdecl; external;
{ Decode Base64 string data }
function DecodeDataBase64(data: Pointer; out outputLength: Integer): Pointer; cdecl; external;

{ Persistent storage management }

{ Save integer value to storage file (to position): defined; returns true on success }
function SaveStorageValue(position: LongWord; value: Integer): Boolean; cdecl; external;
{ Load integer value from storage file (from defined position) }
function LoadStorageValue(position: LongWord): Integer; cdecl; external;

{ Open URL with default system browser (if available) }
procedure OpenURL(url: PChar); cdecl; external;

{ Input Handling Functions (Module: core) }
{ Input-related functions: keyboard }

{ Check if a key has been pressed once }
function IsKeyPressed(key: Integer): Boolean; cdecl; external;
{ Check if a key is being pressed }
function IsKeyDown(key: Integer): Boolean; cdecl; external;
{ Check if a key has been released once }
function IsKeyReleased(key: Integer): Boolean; cdecl; external;
{ Check if a key is NOT being pressed }
function IsKeyUp(key: Integer): Boolean; cdecl; external;
{ Set a custom key to exit program (default is ESC) }
procedure SetExitKey(key: Integer); cdecl; external;
{ Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty }
function GetKeyPressed: Integer; cdecl; external;
{ Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty }
function GetCharPressed: Integer; cdecl; external;

{ Input-related functions: gamepads }

{ Check if a gamepad is available }
function IsGamepadAvailable(gamepad: Integer): Boolean; cdecl; external;
{ Get gamepad Integerernal name id }
function GetGamepadName(gamepad: Integer): PChar; cdecl; external;
{ Check if a gamepad button has been pressed once }
function IsGamepadButtonPressed(gamepad, button: Integer): Boolean; cdecl; external;
{ Check if a gamepad button is being pressed }
function IsGamepadButtonDown(gamepad, button: Integer): Boolean; cdecl; external;
{ Check if a gamepad button has been released once }
function IsGamepadButtonReleased(gamepad, button: Integer): Boolean; cdecl; external;
{ Check if a gamepad button is NOT being pressed }
function IsGamepadButtonUp(gamepad, button: Integer): Boolean; cdecl; external;
{ Get the last gamepad button pressed }
function GetGamepadButtonPressed: Integer; cdecl; external;
{ Get gamepad axis count for a gamepad }
function GetGamepadAxisCount(gamepad: Integer): Integer; cdecl; external;
{ Get axis movement value for a gamepad axis }
function GetGamepadAxisMovement(gamepad, axis: Integer): Single; cdecl; external;
{ Set Integerernal gamepad mappings (SDL_GameControllerDB) }
function SetGamepadMappings(mappings: PChar): Integer; cdecl; external;

{ Input-related functions: mouse }

{ Check if a mouse button has been pressed once }
function IsMouseButtonPressed(button: Integer): Boolean; cdecl; external;
{ Check if a mouse button is being pressed }
function IsMouseButtonDown(button: Integer): Boolean; cdecl; external;
{ Check if a mouse button has been released once }
function IsMouseButtonReleased(button: Integer): Boolean; cdecl; external;
{ Check if a mouse button is NOT being pressed }
function IsMouseButtonUp(button: Integer): Boolean; cdecl; external;
{ Get mouse position X }
function GetMouseX: Integer; cdecl; external;
{ Get mouse position Y }
function GetMouseY: Integer; cdecl; external;
{ Get mouse position XY }
function GetMousePosition: TVec2; cdecl; external;
{ Get mouse delta between frames }
function GetMouseDelta: TVec2; cdecl; external;
{ Set mouse position XY }
procedure SetMousePosition(x, y: Integer); cdecl; external;
{ Set mouse offset }
procedure SetMouseOffset(offsetX, offsetY: Integer); cdecl; external;
{ Set mouse scaling }
procedure SetMouseScale(scaleX, scaleY: Single); cdecl; external;
{ Get mouse wheel movement Y }
function GetMouseWheelMove: Single; cdecl; external;
{ Set mouse cursor }
procedure SetMouseCursor(cursor: Integer); cdecl; external;

{ Input-related functions: touch }

{ Get touch position X for touch point 0 (relative to screen size) }
function GetTouchX: Integer; cdecl; external;
{ Get touch position Y for touch point 0 (relative to screen size) }
function GetTouchY: Integer; cdecl; external;
{ Get touch position XY for a touch point index (relative to screen size) }
function GetTouchPosition(index: Integer): TVec2; cdecl; external;
{ Get touch point identifier for given index }
function GetTouchPointId(index: Integer): Integer; cdecl; external;
{ Get number of touch points }
function GetTouchPointCount: Integer; cdecl; external;

{ Gestures and Touch Handling Functions (Module: rgestures) }

{ Enable a set of gestures using flags }
procedure SetGesturesEnabled(flags: LongWord); cdecl; external;
{ Check if a gesture have been detected }
function IsGestureDetected(gesture: Integer): Boolean; cdecl; external;
{ Get latest detected gesture }
function GetGestureDetected: Integer; cdecl; external;
{ Get gesture hold time in milliseconds }
function GetGestureHoldDuration: Single; cdecl; external;
{ Get gesture drag vector }
function GetGestureDragVector: TVec2; cdecl; external;
{ Get gesture drag angle }
function GetGestureDragAngle: Single; cdecl; external;
{ Get gesture pinch delta }
function GetGesturePinchVector: TVec2; cdecl; external;
{ Get gesture pinch angle }
function GetGesturePinchAngle: Single; cdecl; external;

{ TCamera System Functions (Module: rcamera) }

{ Set camera mode (multiple camera modes available) }
procedure SetCameraMode(camera: TCamera; mode: Integer); cdecl; external;
{ Update camera position for selected mode }
procedure UpdateCamera(var camera: TCamera); cdecl; external;
{ Set camera pan key to combine with mouse movement (free camera) }
procedure SetCameraPanControl(keyPan: Integer); cdecl; external;
{ Set camera alt key to combine with mouse movement (free camera) }
procedure SetCameraAltControl(keyAlt: Integer); cdecl; external;
{ Set camera smooth zoom key to combine with mouse (free camera) }
procedure SetCameraSmoothZoomControl(keySmoothZoom: Integer); cdecl; external;
{ Set camera move controls (1st person and 3rd person cameras) }
procedure SetCameraMoveControls(keyFront, keyBack, keyRight, keyLeft, keyUp, keyDown: Integer); cdecl; external;

{ Basic Shapes Drawing Functions (Module: shapes)
  Set texture and rectangle to be used on shapes drawing
  NOTE: It can be useful when using basic shapes and one font: single;
  defining a font char white rectangle would allow drawing everything in a single draw call }

{ Set texture and rectangle to be used on shapes drawing }
procedure SetShapesTexture(texture: TTexture2D; source: TRect); cdecl; external;

{ Basic shapes drawing functions }

{ Draw a pixel }
procedure DrawPixel(posX: Integer; posY: Integer; color: TColorB); cdecl; external;
{ Draw a pixel (Vector version) }
procedure DrawPixelV(position: TVec2; color: TColorB); cdecl; external;
{ Draw a line }
procedure DrawLine(startPosX: Integer; startPosY: Integer; endPosX: Integer; endPosY: Integer; color: TColorB); cdecl; external;
{ Draw a line (Vector version) }
procedure DrawLineV(startPos: TVec2; endPos: TVec2; color: TColorB); cdecl; external;
{ Draw a line defining thickness }
procedure DrawLineEx(startPos: TVec2; endPos: TVec2; thick: Single; color: TColorB); cdecl; external;
{ Draw a line using cubic-bezier curves in-out }
procedure DrawLineBezier(startPos: TVec2; endPos: TVec2; thick: Single; color: TColorB); cdecl; external;
{ Draw line using quadratic bezier curves with a control point }
procedure DrawLineBezierQuad(startPos: TVec2; endPos: TVec2; controlPos: TVec2; thick: Single; color: TColorB); cdecl; external;
{ Draw line using cubic bezier curves with 2 control points }
procedure DrawLineBezierCubic(startPos: TVec2; endPos: TVec2; startControlPos: TVec2; endControlPos: TVec2; thick: Single; color: TColorB); cdecl; external;
{ Draw lines sequence }
procedure DrawLineStrip(points: PVec2; pointCount: Integer; color: TColorB); cdecl; external;
{ Draw a color-filled circle }
procedure DrawCircle(centerX, centerY: Integer; radius: Single; color: TColorB); cdecl; external;
{ Draw a piece of a circle }
procedure DrawCircleSector(center: TVec2; radius, startAngle, endAngle: Single; segments: Integer; color: TColorB); cdecl; external;
{ Draw circle sector outline }
procedure DrawCircleSectorLines(center: TVec2; radius: Single; startAngle: Single; endAngle: Single; segments: Integer; color: TColorB); cdecl; external;
{ Draw a gradient-filled circle }
procedure DrawCircleGradient(centerX: Integer; centerY: Integer; radius: Single; color1: TColorB; color2: TColorB); cdecl; external;
{ Draw a color-filled circle (Vector version) }
procedure DrawCircleV(center: TVec2; radius: Single; color: TColorB); cdecl; external;
{ Draw circle outline }
procedure DrawCircleLines(centerX: Integer; centerY: Integer; radius: Single; color: TColorB); cdecl; external;
{ Draw ellipse }
procedure DrawEllipse(centerX: Integer; centerY: Integer; radiusH: Single; radiusV: Single; color: TColorB); cdecl; external;
{ Draw ellipse outline }
procedure DrawEllipseLines(centerX: Integer; centerY: Integer; radiusH: Single; radiusV: Single; color: TColorB); cdecl; external;
{ Draw ring }
procedure DrawRing(center: TVec2; innerRadius: Single; outerRadius: Single; startAngle: Single; endAngle: Single; segments: Integer; color: TColorB); cdecl; external;
{ Draw ring outline }
procedure DrawRingLines(center: TVec2; innerRadius: Single; outerRadius: Single; startAngle: Single; endAngle: Single; segments: Integer; color: TColorB); cdecl; external;
{ Draw a color-filled rectangle }
procedure DrawRectangle(posX: Integer; posY: Integer; width: Integer; height: Integer; color: TColorB); cdecl; external;
{ Draw a color-filled rectangle (Vector version) }
procedure DrawRectangleV(position: TVec2; size: TVec2; color: TColorB); cdecl; external;
{ Draw a color-filled rectangle }
procedure DrawRectangleRec(rec: TRect; color: TColorB); cdecl; external;
{ Draw a color-filled rectangle with pro parameters }
procedure DrawRectanglePro(rec: TRect; origin: TVec2; rotation: Single; color: TColorB); cdecl; external;
{ Draw a vertical-gradient-filled rectangle }
procedure DrawRectangleGradientV(posX: Integer; posY: Integer; width: Integer; height: Integer; color1: TColorB; color2: TColorB); cdecl; external;
{ Draw a horizontal-gradient-filled rectangle }
procedure DrawRectangleGradientH(posX: Integer; posY: Integer; width: Integer; height: Integer; color1: TColorB; color2: TColorB); cdecl; external;
{ Draw a gradient-filled rectangle with custom vertex colors }
procedure DrawRectangleGradientEx(rec: TRect; col1: TColorB; col2: TColorB; col3: TColorB; col4: TColorB); cdecl; external;
{ Draw rectangle outline }
procedure DrawRectangleLines(posX: Integer; posY: Integer; width: Integer; height: Integer; color: TColorB); cdecl; external;
{ Draw rectangle outline with extended parameters }
procedure DrawRectangleLinesEx(rec: TRect; lineThick: Single; color: TColorB); cdecl; external;
{ Draw rectangle with rounded edges }
procedure DrawRectangleRounded(rec: TRect; roundness: Single; segments: Integer; color: TColorB); cdecl; external;
{ Draw rectangle with rounded edges outline }
procedure DrawRectangleRoundedLines(rec: TRect; roundness: Single; segments: Integer; lineThick: Single; color: TColorB); cdecl; external;
{ Draw a color-filled triangle (vertex in counter-clockwise order!) }
procedure DrawTriangle(v1: TVec2; v2: TVec2; v3: TVec2; color: TColorB); cdecl; external;
{ Draw triangle outline (vertex in counter-clockwise order!) }
procedure DrawTriangleLines(v1: TVec2; v2: TVec2; v3: TVec2; color: TColorB); cdecl; external;
{ Draw a triangle fan defined by points (first vertex is the center) }
procedure DrawTriangleFan(points: PVec2; pointCount: Integer; color: TColorB); cdecl; external;
{ Draw a triangle strip defined by points }
procedure DrawTriangleStrip(points: PVec2; pointCount: Integer; color: TColorB); cdecl; external;
{ Draw a regular polygon (Vector version) }
procedure DrawPoly(center: TVec2; sides: Integer; radius: Single; rotation: Single; color: TColorB); cdecl; external;
{ Draw a polygon outline of n sides }
procedure DrawPolyLines(center: TVec2; sides: Integer; radius: Single; rotation: Single; color: TColorB); cdecl; external;
{ Draw a polygon outline of n sides with extended parameters }
procedure DrawPolyLinesEx(center: TVec2; sides: Integer; radius: Single; rotation: Single; lineThick: Single; color: TColorB); cdecl; external;

{ Basic shapes collision detection functions }

{ Check collision between two rectangles }
function CheckCollisionRecs(rec1: TRect; rec2: TRect): Boolean; cdecl; external;
{ Check collision between two circles }
function CheckCollisionCircles(center1: TVec2; radius1: Single; center2: TVec2; radius2: Single): Boolean; cdecl; external;
{ Check collision between circle and rectangle }
function CheckCollisionCircleRec(center: TVec2; radius: Single; rec: TRect): Boolean; cdecl; external;
{ Check if point is inside rectangle }
function CheckCollisionPointRec(point: TVec2; rec: TRect): Boolean; cdecl; external;
{ Check if point is inside circle }
function CheckCollisionPointCircle(point: TVec2; center: TVec2; radius: Single): Boolean; cdecl; external;
{ Check if point is inside a triangle }
function CheckCollisionPointTriangle(point: TVec2; p1: TVec2; p2: TVec2; p3: TVec2): Boolean; cdecl; external;
{ Check the collision between two lines defined by two each: points; returns collision point by reference }
function CheckCollisionLines(startPos1: TVec2; endPos1: TVec2; startPos2: TVec2; endPos2: TVec2; collisionPoint: PVec2): Boolean; cdecl; external;
{ Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold] }
function CheckCollisionPointLine(point: TVec2; p1: TVec2; p2: TVec2; threshold: Integer): Boolean; cdecl; external;
{ Get collision rectangle for two rectangles collision }
function GetCollisionRec(rec1, rec2: TRect): TRect; cdecl; external;

{ Texture Loading and Drawing Functions (Module: textures) }

{ TImage loading functions
  NOTE: This functions do not require GPU access }

{ Load image from file into CPU memory (RAM) }
function LoadImage(fileName: PChar): TImage; cdecl; external;
{ Load image from RAW file data }
function LoadImageRaw(fileName: PChar; width: Integer; height: Integer; format: Integer; headerSize: Integer): TImage; cdecl; external;
{ Load image sequence from file (frames appended to image.data) }
function LoadImageAnim(fileName: PChar; frames: PInteger): TImage; cdecl; external;
{ Load image from buffer: memory; fileType refers to extension: i.e. '.png' }
function LoadImageFromMemory(fileType: PChar; const fileData: Pointer; dataSize: Integer): TImage; cdecl; external;
{ Load image from GPU texture data }
function LoadImageFromTexture(texture: TTexture2D): TImage; cdecl; external;
{ Load image from screen buffer and (screenshot) }
function LoadImageFromScreen: TImage; cdecl; external;
{ Unload image from CPU memory (RAM) }
procedure UnloadImage(image: TImage); cdecl; external;
{ Export image data file returns true on success }
function ExportImage(image: TImage; fileName: PChar): Boolean; cdecl; external;
{ Export image as code file defining an array bytes: of; returns true on success }
function ExportImageAsCode(image: TImage; fileName: PChar): Boolean; cdecl; external;

{ TImage generation functions }

{ Generate image: plain color }
function GenImageColor(width, height: Integer; color: TColorB): TImage; cdecl; external;
{ Generate image: vertical gradient }
function GenImageGradientV(width, height: Integer; top, bottom: TColorB): TImage; cdecl; external;
{ Generate image: horizontal gradient }
function GenImageGradientH(width, height: Integer; left, right: TColorB): TImage; cdecl; external;
{ Generate image: radial gradient }
function GenImageGradientRadial(width, height: Integer; density: Single; inner, outer: TColorB): TImage; cdecl; external;
{ Generate image: checked }
function GenImageChecked(width, height, checksX, checksY: Integer; col1, col2: TColorB): TImage; cdecl; external;
{ Generate image: white noise }
function GenImageWhiteNoise(width, height: Integer; factor: Single): TImage; cdecl; external;
{ Generate image: algorithm: cellular; bigger tileSize means bigger cells }
function GenImageCellular(width, height, tileSize: Integer): TImage; cdecl; external;

{ TImage manipulation functions }

{ Create an image duplicate (useful for transformations) }
function ImageCopy(image: TImage): TImage; cdecl; external;
{ Create an image from another image piece }
function ImageFromImage(image: TImage; rec: TRect): TImage; cdecl; external;
{ Create an image from text (default font) }
function ImageText(text: PChar; fontSize: Integer; color: TColorB): TImage; cdecl; external;
{ Create an image from text (custom sprite font) }
function ImageTextEx(font: TFont; text: PChar; fontSize: Single; spacing: Single; tint: TColorB): TImage; cdecl; external;
{ Convert image data to desired format }
procedure ImageFormat(var image: TImage; newFormat: Integer); cdecl; external;
{ Convert image to POT (power-of-two) }
procedure ImageToPOT(var image: TImage; fill: TColorB); cdecl; external;
{ Crop an image to a defined rectangle }
procedure ImageCrop(var image: TImage; crop: TRect); cdecl; external;
{ Crop image depending on alpha value }
procedure ImageAlphaCrop(var image: TImage; threshold: Single); cdecl; external;
{ Clear alpha channel to desired color }
procedure ImageAlphaClear(var image: TImage; color: TColorB; threshold: Single); cdecl; external;
{ Apply alpha mask to image }
procedure ImageAlphaMask(var image: TImage; alphaMask: TImage); cdecl; external;
{ Premultiply alpha channel }
procedure ImageAlphaPremultiply(var image: TImage); cdecl; external;
{ Resize image (Bicubic scaling algorithm) }
procedure ImageResize(var image: TImage; newWidth, newHeight: Integer); cdecl; external;
{ Resize image (Nearest-Neighbor scaling algorithm) }
procedure ImageResizeNN(var image: TImage; newWidth, newHeight: Integer); cdecl; external;
{ Resize canvas and fill with color }
procedure ImageResizeCanvas(var image: TImage; newWidth, newHeight, offsetX, offsetY: Integer; fill: TColorB); cdecl; external;
{ Compute all mipmap levels for a provided image }
procedure ImageMipmaps(var image: TImage); cdecl; external;
{ Dither image data to 16bpp or lower (Floyd-Steinberg dithering) }
procedure ImageDither(var image: TImage; rBpp, gBpp, bBpp, aBpp: Integer); cdecl; external;
{ Flip image vertically }
procedure ImageFlipVertical(var image: TImage); cdecl; external;
{ Flip image horizontally }
procedure ImageFlipHorizontal(var image: TImage); cdecl; external;
{ Rotate image clockwise 90deg }
procedure ImageRotateCW(var image: TImage); cdecl; external;
{ Rotate image counter-clockwise 90deg }
procedure ImageRotateCCW(var image: TImage); cdecl; external;
{ Modify image color: tint }
procedure ImageColorTInteger(var image: TImage; color: TColorB); cdecl; external;
{ Modify image color: invert }
procedure ImageColorInvert(var image: TImage); cdecl; external;
{ Modify image color: grayscale }
procedure ImageColorGrayscale(var image: TImage); cdecl; external;
{ Modify image color: contrast (-100 to 100) }
procedure ImageColorContrast(var image: TImage; contrast: Single); cdecl; external;
{ Modify image color: brightness (-255 to 255) }
procedure ImageColorBrightness(var image: TImage; brightness: Integer); cdecl; external;
{ Modify image color: replace color }
procedure ImageColorReplace(var image: TImage; color, replace: TColorB); cdecl; external;
{ Load color data from image as a TColorB array (RGBA - 32bit) }
function LoadImageColors(image: TImage): PColorB; cdecl; external;
{ Load colors palette from image as a TColorB array (RGBA - 32bit) }
function LoadImagePalette(image: TImage; maxPaletteSize: Integer; colorCount: PInteger): PColorB; cdecl; external;
{ Unload color data loaded with LoadImageColors() }
procedure UnloadImageColors(colors: PColorB); cdecl; external;
{ Unload colors palette loaded with LoadImagePalette() }
procedure UnloadImagePalette(colors: PColorB); cdecl; external;
{ Get image alpha border rectangle }
function GetImageAlphaBorder(image: TImage; threshold: Single): TRect; cdecl; external;
{ Get image pixel color x: at ; y) position }
function GetImageColor(image: TImage; x: Integer; y: Integer): TColorB; cdecl; external;

{ TImage drawing functions
  NOTE: Image software-rendering functions (CPU) }

{ Clear image background with given color }
procedure ImageClearBackground(var dst: TImage; color: TColorB); cdecl; external;
{ Draw pixel within an image }
procedure ImageDrawPixel(var dst: TImage; posX: Integer; posY: Integer; color: TColorB); cdecl; external;
{ Draw pixel within an image (Vector version) }
procedure ImageDrawPixelV(var dst: TImage; position: TVec2; color: TColorB); cdecl; external;
{ Draw line within an image }
procedure ImageDrawLine(var dst: TImage; startPosX: Integer; startPosY: Integer; endPosX: Integer; endPosY: Integer; color: TColorB); cdecl; external;
{ Draw line within an image (Vector version) }
procedure ImageDrawLineV(var dst: TImage; start: TVec2; _end: TVec2; color: TColorB); cdecl; external;
{ Draw circle within an image }
procedure ImageDrawCircle(var dst: TImage; centerX: Integer; centerY: Integer; radius: Integer; color: TColorB); cdecl; external;
{ Draw circle within an image (Vector version) }
procedure ImageDrawCircleV(var dst: TImage; center: TVec2; radius: Integer; color: TColorB); cdecl; external;
{ Draw rectangle within an image }
procedure ImageDrawRectangle(var dst: TImage; posX: Integer; posY: Integer; width: Integer; height: Integer; color: TColorB); cdecl; external;
{ Draw rectangle within an image (Vector version) }
procedure ImageDrawRectangleV(var dst: TImage; position: TVec2; size: TVec2; color: TColorB); cdecl; external;
{ Draw rectangle within an image }
procedure ImageDrawRectangleRec(var dst: TImage; rec: TRect; color: TColorB); cdecl; external;
{ Draw rectangle lines within an image }
procedure ImageDrawRectangleLines(var dst: TImage; rec: TRect; thick: Integer; color: TColorB); cdecl; external;
{ Draw a source image within a destination image (tint applied to source) }
procedure ImageDraw(var dst: TImage; src: TImage; srcRec: TRect; dstRec: TRect; tint: TColorB); cdecl; external;
{ Draw text (using default font) within an image (destination) }
procedure ImageDrawText(var dst: TImage; text: PChar; posX: Integer; posY: Integer; fontSize: Integer; color: TColorB); cdecl; external;
{ Draw text (custom sprite font) within an image (destination) }
procedure ImageDrawTextEx(var dst: TImage; font: TFont; text: PChar; position: TVec2; fontSize: Single; spacing: Single; tint: TColorB); cdecl; external;

{ Texture loading functions
  NOTE: These functions require GPU access }

{ Load texture from file into GPU memory (VRAM) }
function LoadTexture(fileName: PChar): TTexture2D; cdecl; external;
{ Load texture from image data }
function LoadTextureFromImage(image: TImage): TTexture2D; cdecl; external;
{ Load cubemap image: from; multiple image cubemap layouts supported }
function LoadTextureCubemap(image: TImage; layout: Integer): TTextureCubemap; cdecl; external;
{ Load texture for rendering (framebuffer) }
function LoadRenderTexture(width: Integer; height: Integer): TRenderTexture2D; cdecl; external;
{ Unload texture from GPU memory (VRAM) }
procedure UnloadTexture(texture: TTexture2D); cdecl; external;
{ Unload render texture from GPU memory (VRAM) }
procedure UnloadRenderTexture(target: TRenderTexture2D); cdecl; external;
{ Update GPU texture with new data }
procedure UpdateTexture(texture: TTexture2D; pixels: Pointer); cdecl; external;
{ Update GPU texture rectangle with new data }
procedure UpdateTextureRec(texture: TTexture2D; rec: TRect; pixels: Pointer); cdecl; external;

{ Texture configuration functions }

{ Generate GPU mipmaps for a texture }
procedure GenTextureMipmaps(var texture: TTexture2D); cdecl; external;
{ Set texture scaling filter mode }
procedure SetTextureFilter(texture: TTexture2D; filter: Integer); cdecl; external;
{ Set texture wrapping mode }
procedure SetTextureWrap(texture: TTexture2D; wrap: Integer); cdecl; external;

{Texture drawing functions }

{ Draw a TTexture2D }
procedure DrawTexture(texture: TTexture2D; posX: Integer; posY: Integer; tint: TColorB); cdecl; external;
{ Draw a TTexture2D with position defined as TVec2 }
procedure DrawTextureV(texture: TTexture2D; position: TVec2; tint: TColorB); cdecl; external;
{ Draw a TTexture2D with extended parameters }
procedure DrawTextureEx(texture: TTexture2D; position: TVec2; rotation: Single; scale: Single; tint: TColorB); cdecl; external;
{ Draw a part of a texture defined by a rectangle }
procedure DrawTextureRec(texture: TTexture2D; source: TRect; position: TVec2; tint: TColorB); cdecl; external;
{ Draw texture quad with tiling and offset parameters }
procedure DrawTextureQuad(texture: TTexture2D; tiling: TVec2; offset: TVec2; quad: TRect; tint: TColorB); cdecl; external;
{ Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest. }
procedure DrawTextureTiled(texture: TTexture2D; source: TRect; dest: TRect; origin: TVec2; rotation: Single; scale: Single; tint: TColorB); cdecl; external;
{ Draw a part of a texture defined by a rectangle with 'pro' parameters }
procedure DrawTexturePro(texture: TTexture2D; source: TRect; dest: TRect; origin: TVec2; rotation: Single; tint: TColorB); cdecl; external;
{ Draws a texture (or part of it) that stretches or shrinks nicely }
procedure DrawTextureNPatch(texture: TTexture2D; nPatchInfo: TNPatchInfo; dest: TRect; origin: TVec2; rotation: Single; tint: TColorB); cdecl; external;
{ Draw a textured polygon }
procedure DrawTexturePoly(texture: TTexture2D; center: TVec2; points: PVec2; texcoords: PVec2; pointCount: Integer; tint: TColorB); cdecl; external;

{ TColorB/pixel related functions }

{ Get color with applied: alpha; alpha goes from 0.0f to 1.0f }
function Fade(color: TColorB; alpha: Single): TColorB; cdecl; external;
{ Get hexadecimal value for a TColorB }
function ColorToInt(color: TColorB): Integer; cdecl; external;
{ Get TColorB normalized as Single [0..1] }
function ColorNormalize(color: TColorB): TVec4; cdecl; external;
{ Get TColorB from normalized values [0..1] }
function ColorFromNormalized(normalized: TVec4): TColorB; cdecl; external;
{ Get HSV values for TColorB: a; hue [360]: 0.; saturation/value [0..1] }
function ColorToHSV(color: TColorB): TVec3; cdecl; external;
{ Get a TColorB from values: HSV; hue [360]: 0.; saturation/value [0..1] }
function ColorFromHSV(hue: Single; saturation: Single; value: Single): TColorB; cdecl; external;
{ Get color with applied: alpha; alpha goes from 0.0f to 1.0f }
function ColorAlpha(color: TColorB; alpha: Single): TColorB; cdecl; external;
{ Get src alpha-blended into dst color with tint }
function ColorAlphaBlend(dst: TColorB; src: TColorB; tint: TColorB): TColorB; cdecl; external;
{ Get TColorB structure from hexadecimal value }
function GetColor(hexValue: LongWord): TColorB; cdecl; external;
{ Get TColorB from a source pixel pointer of certain format }
function GetPixelColor(srcPtr: Pointer; format: Integer): TColorB; cdecl; external;
{ Set color formatted into destination pixel pointer }
procedure SetPixelColor(dstPtr: Pointer; color: TColorB; format: Integer); cdecl; external;
{ Get pixel data size in bytes for certain format }
function GetPixelDataSize(width, height, format: Integer): Integer; cdecl; external;

{ Font Loading and Text Drawing Functions (Module: text) }
{ Font loading/unloading functions }

{ Get the default TFont }
function GetFontDefault: TFont; cdecl; external;
{ Load font from file into GPU memory (VRAM) }
function LoadFont(fileName: PChar): TFont; cdecl; external;
{ Load font from file with extended parameters }
function LoadFontEx(fileName: PChar; fontSize: Integer; fontChars: PInteger; glyphCount: Integer): TFont; cdecl; external;
{ Load font from TImage (XNA style) }
function LoadFontFromImage(image: TImage; key: TColorB; firstChar: Integer): TFont; cdecl; external;
{ Load font from buffer: memory; fileType refers to extension: i.e. '.ttf' }
function LoadFontFromMemory(fileType: PChar; fileData: Pointer; dataSize: Integer; fontSize: Integer; fontChars: PInteger; glyphCount: Integer): TFont; cdecl; external;
{ Load font data for further use }
function LoadFontData(fileData: Pointer; dataSize, fontSize: Integer; fontChars: PInteger; glyphCount, _type: Integer): PGlyphInfo; cdecl; external;
{ Generate image font atlas using chars info }
function GenImageFontAtlas(chars: PGlyphInfo; recs: PRect; glyphCount: Integer; fontSize: Integer; padding: Integer; packMethod: Integer): TImage; cdecl; external;
{ Unload font chars info data (RAM) }
procedure UnloadFontData(chars: PGlyphInfo; glyphCount: Integer); cdecl; external;
{ Unload font from GPU memory (VRAM) }
procedure UnloadFont(font: TFont); cdecl; external;

{ Text drawing functions }

{ Draw current FPS }
procedure DrawFPS(posX: Integer; posY: Integer); cdecl; external;
{ Draw text (using default font) }
procedure DrawText(text: PChar; posX: Integer; posY: Integer; fontSize: Integer; color: TColorB); cdecl; external;
{ Draw text using font and additional parameters }
procedure DrawTextEx(font: TFont; text: PChar; position: TVec2; fontSize: Single; spacing: Single; tint: TColorB); cdecl; external;
{ Draw text using font and pro parameters (rotation) }
procedure DrawTextPro(font: TFont; text: PChar; position: TVec2; origin: TVec2; rotation: Single; fontSize: Single; spacing: Single; tint: TColorB); cdecl; external;
{ Draw one character (codepoint) }
procedure DrawTextCodepoint(font: TFont; codepoint: Integer; position: TVec2; fontSize: Single; tint: TColorB); cdecl; external;

{ Text font info functions }

{ Measure string width for default font }
function MeasureText(text: PChar; fontSize: Integer): Integer; cdecl; external;
{ Measure string size for font }
function MeasureTextEx(font: TFont; text: PChar; fontSize: Single; spacing: Single): TVec2; cdecl; external;
{ Get glyph index position in font for a codepoint (character): unicode; fallback to '?' if not found }
function GetGlyphIndex(font: TFont; codepoint: Integer): Integer; cdecl; external;
{ Get glyph font info data for a codepoint (character): unicode; fallback to '?' if not found }
function GetGlyphInfo(font: TFont; codepoint: Integer): TGlyphInfo; cdecl; external;
{ Get glyph rectangle in font atlas for a codepoint (character): unicode; fallback to '?' if not found }
function GetGlyphAtlasRec(font: TFont; codepoint: Integer): TRect; cdecl; external;

{ Text codepoints management functions (unicode characters) }

{ Load all codepoints from a UTF-8 string: text; codepoints count returned by parameter }
function LoadCodepoints(text: PChar; out count: Integer): PInteger; cdecl; external;
{ Unload codepoints data from memory }
procedure UnloadCodepoints(codepoints: PInteger); cdecl; external;
{ Get total number of codepoints in a UTF-8 encoded string }
function GetCodepointCount(text: PChar): Integer; cdecl; external;
{ Get next codepoint in a UTF-8 string: encoded; 0x3f('?') is returned on failure }
function GetCodepoint(text: PChar; out bytesProcessed: Integer): Integer; cdecl; external;
{ Encode one codepoint into UTF-8 byte array (array length returned as parameter) }
function CodepointToUTF8(codepoint: Integer; out byteSize: Integer): PChar; cdecl; external;
{ Encode text as codepoints array into UTF-8 text string (WARNING: memory must be freed!) }
function TextCodepointsToUTF8(codepoints: PInteger; length: Integer): PPChar; cdecl; external;

{ Text strings management functions (no UTF-strings: 8; only byte chars)
  NOTE: Some strings allocate memory Integerernally for strings: returned; just be careful! }

{ Copy one string another: to; returns bytes copied }
function TextCopy(dst: PChar; src: PChar): Integer; cdecl; external;
{ Check if two text string are equal }
function TextIsEqual(text1: PChar; text2: PChar): Boolean; cdecl; external;
{ Get length: text; checks for '\0' ending }
function TextLength(text: PChar): LongWord; cdecl; external;
{ Text formatting with variables (sprIntegerf() style) }
function TextFormat(text: PChar): PChar; cdecl; varargs; external;
{ Get a piece of a text string }
function TextSubtext(text: PChar; position: Integer; length: Integer): PChar; cdecl; external;
{ Replace text string (WARNING: memory must be freed!) }
function TextReplace(text: PChar; replace: PChar; by: PChar): PPChar; cdecl; external;
{ Insert text in a position (WARNING: memory must be freed!) }
function TextInsert(text: PChar; insert: PChar; position: Integer): PPChar; cdecl; external;
{ Join text strings with delimiter }
function TextJoin(textList: PPChar; count: Integer; delimiter: PChar): PChar; cdecl; external;
{ Split text into multiple strings }
function TextSplit(text: PChar; delimiter: char; count: PInteger): PPChar; cdecl; external;
{ Append text at specific position and move cursor! }
procedure TextAppend(text: PChar; append: PChar; position: PInteger); cdecl; external;
{ Find first text occurrence within a string }
function TextFindIndex(text: PChar; find: PChar): Integer; cdecl; external;
{ Get upper case version of provided string }
function TextToUpper(text: PChar): PChar; cdecl; external;
{ Get lower case version of provided string }
function TextToLower(text: PChar): PChar; cdecl; external;
{ Get Pascal case notation version of provided string }
function TextToPascal(text: PChar): PChar; cdecl; external;
{ Get integer value from text (negative values not supported) }
function TextToInteger(text: PChar): Integer; cdecl; external;

{ Basic 3d Shapes Drawing Functions (Module: models) }
{ Basic geometric 3D shapes drawing functions}

{ Draw a line in 3D world space }
procedure DrawLine3D(startPos: TVec3; endPos: TVec3; color: TColorB); cdecl; external;
{ Draw a point in space: 3D; actually a small line }
procedure DrawPoint3D(position: TVec3; color: TColorB); cdecl; external;
{ Draw a circle in 3D world space }
procedure DrawCircle3D(center: TVec3; radius: Single; rotationAxis: TVec3; rotationAngle: Single; color: TColorB); cdecl; external;
{ Draw a color-filled triangle (vertex in counter-clockwise order!) }
procedure DrawTriangle3D(v1: TVec3; v2: TVec3; v3: TVec3; color: TColorB); cdecl; external;
{ Draw a triangle strip defined by points }
procedure DrawTriangleStrip3D(points: PVec3; pointCount: Integer; color: TColorB); cdecl; external;
{ Draw cube }
procedure DrawCube(position: TVec3; width: Single; height: Single; length: Single; color: TColorB); cdecl; external;
{ Draw cube (Vector version) }
procedure DrawCubeV(position: TVec3; size: TVec3; color: TColorB); cdecl; external;
{ Draw cube wires }
procedure DrawCubeWires(position: TVec3; width: Single; height: Single; length: Single; color: TColorB); cdecl; external;
{ Draw cube wires (Vector version) }
procedure DrawCubeWiresV(position: TVec3; size: TVec3; color: TColorB); cdecl; external;
{ Draw cube textured }
procedure DrawCubeTexture(texture: TTexture2D; position: TVec3; width: Single; height: Single; length: Single; color: TColorB); cdecl; external;
{ Draw cube with a region of a texture }
procedure DrawCubeTextureRec(texture: TTexture2D; source: TRect; position: TVec3; width: Single; height: Single; length: Single; color: TColorB); cdecl; external;
{ Draw sphere }
procedure DrawSphere(centerPos: TVec3; radius: Single; color: TColorB); cdecl; external;
{ Draw sphere with extended parameters }
procedure DrawSphereEx(centerPos: TVec3; radius: Single; rings: Integer; slices: Integer; color: TColorB); cdecl; external;
{ Draw sphere wires }
procedure DrawSphereWires(centerPos: TVec3; radius: Single; rings: Integer; slices: Integer; color: TColorB); cdecl; external;
{ Draw a cylinder/cone }
procedure DrawCylinder(position: TVec3; radiusTop: Single; radiusBottom: Single; height: Single; slices: Integer; color: TColorB); cdecl; external;
{ Draw a cylinder with base at startPos and top at endPos }
procedure DrawCylinderEx(startPos: TVec3; endPos: TVec3; startRadius: Single; endRadius: Single; sides: Integer; color: TColorB); cdecl; external;
{ Draw a cylinder/cone wires }
procedure DrawCylinderWires(position: TVec3; radiusTop: Single; radiusBottom: Single; height: Single; slices: Integer; color: TColorB); cdecl; external;
{ Draw a cylinder wires with base at startPos and top at endPos }
procedure DrawCylinderWiresEx(startPos: TVec3; endPos: TVec3; startRadius: Single; endRadius: Single; sides: Integer; color: TColorB); cdecl; external;
{ Draw a plane XZ }
procedure DrawPlane(centerPos: TVec3; size: TVec2; color: TColorB); cdecl; external;
{ Draw a ray line }
procedure DrawRay(ray: TRay; color: TColorB); cdecl; external;
{ Draw a grid (centered 0: 0: at ;; 0)) }
procedure DrawGrid(slices: Integer; spacing: Single); cdecl; external;

{ Model 3d Loading and Drawing Functions (Module: models) }
{ Model management functions }

{ Load model from files (meshes and materials) }
function LoadModel(fileName: PChar): TModel; cdecl; external;
{ Load model from generated mesh (default material) }
function LoadModelFromMesh(mesh: TMesh): TModel; cdecl; external;
{ Unload model (including meshes) from memory (RAM and/or VRAM) }
procedure UnloadModel(model: TModel); cdecl; external;
{ Unload model (but not meshes) from memory (RAM and/or VRAM) }
procedure UnloadModelKeepMeshes(model: TModel); cdecl; external;
{ Compute model bounding box limits (considers all meshes) }
function GetModelBoundingBox(model: TModel): TBoundingBox; cdecl; external;

{ TModel drawing functions }

{ Draw a model (with texture if set) }
procedure DrawModel(model: TModel; position: TVec3; scale: Single; tint: TColorB); cdecl; external;
{ Draw a model with extended parameters }
procedure DrawModelEx(model: TModel; position: TVec3; rotationAxis: TVec3; rotationAngle: Single; scale: TVec3; tint: TColorB); cdecl; external;
{ Draw a model wires (with texture if set) }
procedure DrawModelWires(model: TModel; position: TVec3; scale: Single; tint: TColorB); cdecl; external;
{ Draw a model wires (with texture if set) with extended parameters }
procedure DrawModelWiresEx(model: TModel; position: TVec3; rotationAxis: TVec3; rotationAngle: Single; scale: TVec3; tint: TColorB); cdecl; external;
{ Draw bounding box (wires) }
procedure DrawBoundingBox(box: TBoundingBox; color: TColorB); cdecl; external;
{ Draw a billboard texture }
procedure DrawBillboard(camera: TCamera; texture: TTexture2D; position: TVec3; size: Single; tint: TColorB); cdecl; external;
{ Draw a billboard texture defined by source }
procedure DrawBillboardRec(camera: TCamera; texture: TTexture2D; source: TRect; position: TVec3; size: TVec2; tint: TColorB); cdecl; external;
{ Draw a billboard texture defined by source and rotation }
procedure DrawBillboardPro(camera: TCamera; texture: TTexture2D; source: TRect; position: TVec3; up: TVec3; size: TVec2; origin: TVec2; rotation: Single; tint: TColorB); cdecl; external;

{ TMesh management functions }

{ Upload mesh vertex data in GPU and provide VAO/VBO ids }
procedure UploadMesh(var mesh: TMesh; _dynamic: Boolean); cdecl; external;
{ Update mesh vertex data in GPU for a specific buffer index }
procedure UpdateMeshBuffer(mesh: TMesh; index: Integer; data: Pointer; dataSize: Integer; offset: Integer); cdecl; external;
{ Unload mesh data from CPU and GPU }
procedure UnloadMesh(mesh: TMesh); cdecl; external;
{ Draw a 3d mesh with material and transform }
procedure DrawMesh(mesh: TMesh; material: TMaterial; transform: TMat4); cdecl; external;
{ Draw multiple mesh instances with material and different transforms }
procedure DrawMeshInstanced(mesh: TMesh; material: TMaterial; transforms: PMat4; instances: Integer); cdecl; external;
{ Export mesh data to file, returns true on success }
function ExportMesh(mesh: TMesh; fileName: PChar): Boolean; cdecl; external;
{ Compute mesh bounding box limits }
function GetMeshBoundingBox(mesh: TMesh): TBoundingBox; cdecl; external;
{ Compute mesh tangents }
procedure GenMeshTangents(var mesh: TMesh); cdecl; external;
{ Compute mesh binormals }
procedure GenMeshBinormals(var mesh: TMesh); cdecl; external;

{ TMesh generation functions }

{ Generate polygonal mesh }
function GenMeshPoly(sides: Integer; radius: Single): TMesh; cdecl; external;
{ Generate plane mesh (with subdivisions) }
function GenMeshPlane(width: Single; length: Single; resX: Integer; resZ: Integer): TMesh; cdecl; external;
{ Generate cuboid mesh }
function GenMeshCube(width: Single; height: Single; length: Single): TMesh; cdecl; external;
{ Generate sphere mesh (standard sphere) }
function GenMeshSphere(radius: Single; rings: Integer; slices: Integer): TMesh; cdecl; external;
{ Generate half-sphere mesh (no bottom cap) }
function GenMeshHemiSphere(radius: Single; rings: Integer; slices: Integer): TMesh; cdecl; external;
{ Generate cylinder mesh }
function GenMeshCylinder(radius: Single; height: Single; slices: Integer): TMesh; cdecl; external;
{ Generate cone/pyramid mesh }
function GenMeshCone(radius: Single; height: Single; slices: Integer): TMesh; cdecl; external;
{ Generate torus mesh }
function GenMeshTorus(radius, size: Single; radSeg, sides: Integer): TMesh; cdecl; external;
{ Generate trefoil knot mesh }
function GenMeshKnot(radius: Single; size: Single; radSeg: Integer; sides: Integer): TMesh; cdecl; external;
{ Generate heightmap mesh from image data }
function GenMeshHeightmap(heightmap: TImage; size: TVec3): TMesh; cdecl; external;
{ Generate cubes-based map mesh from image data }
function GenMeshCubicmap(cubicmap: TImage; cubeSize: TVec3): TMesh; cdecl; external;

{ TMaterial loading/unloading functions }

{ Load materials from model file }
function LoadMaterials(fileName: PChar; out materialCount: Integer): PMaterial; cdecl; external;
{ Load default material (DIFFUSE: SPECULAR: Supports:;; NORMAL maps) }
function LoadMaterialDefault: TMaterial; cdecl; external;
{ Unload material from GPU memory (VRAM) }
procedure UnloadMaterial(material: TMaterial); cdecl; external;
{ Set texture for a material map MATERIAL_MAP_DIFFUSE: type ; MATERIAL_MAP_SPECULAR...) }
procedure SetMaterialTexture(var material: TMaterial; mapType: Integer; texture: TTexture2D); cdecl; external;
{ Set material for a mesh }
procedure SetModelMeshMaterial(var model: TModel; meshId: Integer; materialId: Integer); cdecl; external;

{ TModel animations loading/unloading functions }

{ Load model animations from file }
function LoadModelAnimations(fileName: PChar; out count: LongWord): PModelAnimation; cdecl; external;
{ Update model animation pose }
procedure UpdateModelAnimation(model: TModel; anim: TModelAnimation; frame: Integer); cdecl; external;
{ Unload animation data }
procedure UnloadModelAnimation(anim: TModelAnimation); cdecl; external;
{ Unload animation array data }
procedure UnloadModelAnimations(animations: PModelAnimation; count: LongWord); cdecl; external;
{ Check model animation skeleton match }
function IsModelAnimationValid(model: TModel; anim: TModelAnimation): Boolean; cdecl; external;

{ Collision detection functions }

{ Check collision between two spheres }
function CheckCollisionSpheres(center1: TVec3; radius1: Single; center2: TVec3; radius2: Single): Boolean; cdecl; external;
{ Check collision between two bounding boxes }
function CheckCollisionBoxes(box1: TBoundingBox; box2: TBoundingBox): Boolean; cdecl; external;
{ Check collision between box and sphere }
function CheckCollisionBoxSphere(box: TBoundingBox; center: TVec3; radius: Single): Boolean; cdecl; external;
{ Get collision info between ray and sphere }
function GetRayCollisionSphere(ray: TRay; center: TVec3; radius: Single): TRayCollision; cdecl; external;
{ Get collision info between ray and box }
function GetRayCollisionBox(ray: TRay; box: TBoundingBox): TRayCollision; cdecl; external;
{ Get collision info between ray and model }
function GetRayCollisionModel(ray: TRay; model: TModel): TRayCollision; cdecl; external;
{ Get collision info between ray and mesh }
function GetRayCollisionMesh(ray: TRay; mesh: TMesh; transform: TMat4): TRayCollision; cdecl; external;
{ Get collision info between ray and triangle }
function GetRayCollisionTriangle(ray: TRay; p1, p2, p3: TVec3): TRayCollision; cdecl; external;
{ Get collision info between ray and quad }
function GetRayCollisionQuad(ray: TRay; p1, p2, p3, p4: TVec3): TRayCollision; cdecl; external;

{ Audio Loading and Playing Functions (Module: audio) }
{ Audio device management functions }

{ Initialize audio device and context }
procedure InitAudioDevice; cdecl; external;
{ Close the audio device and context }
procedure CloseAudioDevice; cdecl; external;
{ Check if audio device has been initialized successfully }
function IsAudioDeviceReady: Boolean; cdecl; external;
{ Set master volume (listener) }
procedure SetMasterVolume(volume: Single); cdecl; external;

{ TWave/Sound loading/unloading functions }

{ Load wave data from file }
function LoadWave(fileName: PChar): TWave; cdecl; external;
{ Load wave from buffer: memory; fileType refers to extension: i.e. '.wav' }
function LoadWaveFromMemory(fileType: PChar; const fileData: Pointer; dataSize: Integer): TWave; cdecl; external;
{ Load sound from file }
function LoadSound(fileName: PChar): TSound; cdecl; external;
{ Load sound from wave data }
function LoadSoundFromWave(wave: TWave): TSound; cdecl; external;
{ Update sound buffer with new data }
procedure UpdateSound(sound: TSound; data: Pointer; sampleCount: Integer); cdecl; external;
{ Unload wave data }
procedure UnloadWave(wave: TWave); cdecl; external;
{ Unload sound }
procedure UnloadSound(sound: TSound); cdecl; external;
{ Export wave data file: to; returns true on success }
function ExportWave(wave: TWave; fileName: PChar): Boolean; cdecl; external;
{ Export wave sample data to h): code (; returns true on success }
function ExportWaveAsCode(wave: TWave; fileName: PChar): Boolean; cdecl; external;

{ TWave/Sound management functions }

{ Play a sound }
procedure PlaySound(sound: TSound); cdecl; external;
{ Stop playing a sound }
procedure StopSound(sound: TSound); cdecl; external;
{ Pause a sound }
procedure PauseSound(sound: TSound); cdecl; external;
{ Resume a paused sound }
procedure ResumeSound(sound: TSound); cdecl; external;
{ Play a sound (using multichannel buffer pool) }
procedure PlaySoundMulti(sound: TSound); cdecl; external;
{ Stop any sound playing (using multichannel buffer pool) }
procedure StopSoundMulti; cdecl; external;
{ Get number of sounds playing in the multichannel }
function GetSoundsPlaying: Integer; cdecl; external;
{ Check if a sound is currently playing }
function IsSoundPlaying(sound: TSound): Boolean; cdecl; external;
{ Set volume for a sound (1.0 is max level) }
procedure SetSoundVolume(sound: TSound; volume: Single); cdecl; external;
{ Set pitch for a sound (1.0 is base level) }
procedure SetSoundPitch(sound: TSound; pitch: Single); cdecl; external;
{ Convert wave data to desired format }
procedure WaveFormat(wave: PWave; sampleRate: Integer; sampleSize: Integer; channels: Integer); cdecl; external;
{ Copy a wave to a new wave }
function WaveCopy(wave: TWave): TWave; cdecl; external;
{ Crop a wave to defined samples range }
procedure WaveCrop(wave: PWave; initSample: Integer; finalSample: Integer); cdecl; external;
{ Load samples data from wave as a Singles array }
function LoadWaveSamples(wave: TWave): Single; cdecl; external;
{ Unload samples data loaded with LoadWaveSamples() }
procedure UnloadWaveSamples(samples: Single); cdecl; external;

{ TMusic management functions }

{ Load music stream from file }
function LoadMusicStream(fileName: PChar): TMusic; cdecl; external;
{ Load music stream from data }
function LoadMusicStreamFromMemory(fileType: PChar; data: Pointer; dataSize: Integer): TMusic; cdecl; external;
{ Unload music stream }
procedure UnloadMusicStream(music: TMusic); cdecl; external;
{ Start music playing }
procedure PlayMusicStream(music: TMusic); cdecl; external;
{ Check if music is playing }
function IsMusicStreamPlaying(music: TMusic): Boolean; cdecl; external;
{ Updates buffers for music streaming }
procedure UpdateMusicStream(music: TMusic); cdecl; external;
{ Stop music playing }
procedure StopMusicStream(music: TMusic); cdecl; external;
{ Pause music playing }
procedure PauseMusicStream(music: TMusic); cdecl; external;
{ Resume playing paused music }
procedure ResumeMusicStream(music: TMusic); cdecl; external;
{ Seek music to a position (in seconds) }
procedure SeekMusicStream(music: TMusic; position: Single); cdecl; external;
{ Set volume for music (1.0 is max level) }
procedure SetMusicVolume(music: TMusic; volume: Single); cdecl; external;
{ Set pitch for a music (1.0 is base level) }
procedure SetMusicPitch(music: TMusic; pitch: Single); cdecl; external;
{ Get music time length (in seconds) }
function GetMusicTimeLength(music: TMusic): Single; cdecl; external;
{ Get current music time played (in seconds) }
function GetMusicTimePlayed(music: TMusic): Single; cdecl; external;

{ TAudioStream management functions }

{ Load audio stream (to stream raw audio pcm data) }
function LoadAudioStream(sampleRate, sampleSize, channels: LongWord): TAudioStream; cdecl; external;
{ Unload audio stream and free memory }
procedure UnloadAudioStream(stream: TAudioStream); cdecl; external;
{ Update audio stream buffers with data }
procedure UpdateAudioStream(stream: TAudioStream; data: Pointer; frameCount: Integer); cdecl; external;
{ Check if any audio stream buffers requires refill }
function IsAudioStreamProcessed(stream: TAudioStream): Boolean; cdecl; external;
{ Play audio stream }
procedure PlayAudioStream(stream: TAudioStream); cdecl; external;
{ Pause audio stream }
procedure PauseAudioStream(stream: TAudioStream); cdecl; external;
{ Resume audio stream }
procedure ResumeAudioStream(stream: TAudioStream); cdecl; external;
{ Check if audio stream is playing }
function IsAudioStreamPlaying(stream: TAudioStream): Boolean; cdecl; external;
{ Stop audio stream }
procedure StopAudioStream(stream: TAudioStream); cdecl; external;
{ Set volume for audio stream (1.0 is max level) }
procedure SetAudioStreamVolume(stream: TAudioStream; volume: Single); cdecl; external;
{ Set pitch for audio stream (1.0 is base level) }
procedure SetAudioStreamPitch(stream: TAudioStream; pitch: Single); cdecl; external;
{ Default size for new audio streams }
procedure SetAudioStreamBufferSizeDefault(size: Integer); cdecl; external;

function Clamp(Value: Single; Min: Single = 0; Max: Single = 1): Single;
function Vec2: TVec2;
function Vec3: TVec3;
function Vec4: TVec4;
function Vec(x, y: Single): TVec2; overload;
function Vec(x, y, z: Single): TVec3; overload;
function Vec(x, y, z, w: Single): TVec4; overload;
function Rgba(r, g, b: Byte; a: Byte = $FF): TColorB; overload;
function Rect(width, height: Single): TRect; overload;
function Rect(x, y, width, height: Single): TRect; overload;

const
  StockMatrix: TMatrix = (M: (
    (1, 0, 0, 0),
    (0, 1, 0, 0),
    (0, 0, 1, 0),
    (0, 0, 0, 1)));

var
  DefaultRotationOrder: TRotationOrder = roZXY;

implementation

{$ifdef linux}
  {$linklib c}
  {$linklib m}
  {$linklib dl}
  {$linklib pthread}
  {.$linklib glfw3-linux}
  {$ifdef gl2}
    {$linklib raylib-gl2-linux}
  {$else}
    {$linklib raylib-gl3-linux}
  {$endif}
{$endif}
{$ifdef windows}
  {$linklib raylib-win64}
{$endif}

const
  Epsilon = 0.0001;

function FloatEqual(A, B: Single): Boolean; inline;
begin
  Result := Abs(A - B) < Epsilon;
end;

procedure SinCos(const X: Extended; out S, C: Extended);
begin
  S := Sin(X);
  C := Cos(X);
end;

function Tan(const X: Extended): Extended;
begin
  Result := Sin(X) / Cos(X);
end;

function MemCompare(const A, B; Size: LongWord): Boolean;
var
  C, D: PByte;
begin
  C := @A;
  D := @B;
  if (C = nil) or (D = nil) then
    Exit(False);
  while Size > 0 do
  begin
    if C^ <> D^ then
      Exit(False);
    Inc(C);
    Inc(D);
    Dec(Size);
  end;
  Result := True;
end;

{ TVec2 }

class operator TVec2.Implicit(const A: TSingleArray): TVec2;
begin
  FillChar(Result, SizeOf(Result), 0);
  case Length(A) of
    0: ;
    1: Result.x := A[0];
  else
    Result.x := A[0]; Result.y := A[1];
  end;
end;

class operator TVec2.Implicit(const V: TVec2): TSingleArray;
begin
  Result := [V.x, V.y];
end;

class operator TVec2.Negative(const A: TVec2): TVec2;
begin
  Result.X := -A.x;
  Result.y := -A.y;
end;

class operator TVec2.Equal(const A, B: TVec2): Boolean;
begin
  Result := FloatEqual(A.x, B.x) and FloatEqual(A.y, B.y);
end;

class operator TVec2.NotEqual(const A, B: TVec2): Boolean;
begin
  Result := not (FloatEqual(A.x, B.x) and FloatEqual(A.y, B.y));
end;

class operator TVec2.Add(const A, B: TVec2): TVec2;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
end;

class operator TVec2.Subtract(const A, B: TVec2): TVec2;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
end;

class operator TVec2.Multiply(const A, B: TVec2): TVec2;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
end;

class operator TVec2.Multiply(const A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
end;

class operator TVec2.Divide(const A, B: TVec2): TVec2;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
end;

class operator TVec2.Divide(const A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
end;

function TVec2.Equals(const Value: TVec2): Boolean;
begin
  Result := Self = Value;
end;

function TVec2.Angle: Single;
const
  Origin: TVec2 = (x: 0; y: 0);
begin
  Result := Origin.Angle(Self);
end;

function TVec2.Angle(x, y: Single): Single;
begin
  Result := Angle(Vec(X, Y));
end;

function TVec2.Angle(const V: TVec2): Single;
var
  X, Y: Single;
begin
  X := Self.x - V.x;
  Y := Self.y - V.y;
  if X = 0 then
    if Y < 0 then
      Exit(Pi)
    else
      Exit(0);
  Result := Arctan(Y / X) + Pi / 2;
  if X > 0 then
    Result := Result + Pi;
end;

function TVec2.Dot(const V: TVec2): Single;
begin
  Result := x * V.x + y * V.y;
end;

function TVec2.Distance: Single;
begin
  Result := Sqrt(x * x + y * y);
end;

function TVec2.Distance(X, Y: Single): Single;
begin
  Result := (Self - Vec(X, Y)).Distance;
end;

function TVec2.Distance(const V: TVec2): Single;
begin
  Result := (Self - V).Distance;
end;

procedure TVec2.Offset(X, Y: Single);
begin
  Self.x :=  Self.x + X;
  Self.y :=  Self.y + Y;
end;

procedure TVec2.Offset(const V: TVec2);
begin
  x :=  x + V.x;
  y :=  y + V.y;
end;

function TVec2.Move(X, Y: Single): TVec2;
begin
  Result.x := Self.x + X;
  Result.y := Self.y + Y;
end;

function TVec2.Move(const V: TVec2): TVec2;
begin
  Result.x := x + V.x;
  Result.y := y + V.y;
end;

function TVec2.Mix(const V: TVec2; Value: Single): TVec2;
var
  C: Single;
begin
  Value := Clamp(Value);
  C := 1 - Value;
  Result.x := x * C + V.x * Value;
  Result.y := y * C + V.y * Value;
end;

procedure TVec2.Normalize;
var
  N: Single;
begin
  N := x * x + y * y;
  if N = 0 then Exit;
  if N = 1 then Exit;
  N := 1 / Sqrt(N);
  x := x * N; y := y * N;
end;

function TVec2.Normal: TVec2;
begin
  Result := Self;
  Result.Normalize;
end;

function TVec2.Binormal: TVec2;
var
  F: Single;
begin
  Result := Normal;
  F := Result.x;
  Result.x := Result.y;
  Result.y := -F;
end;

function TVec2.Mid(const V: TVec2): TVec2;
begin
  Result.x := (x + V.x) / 2;
  Result.y := (y + V.y) / 2;
end;

function TVec2.Extend(const V: TVec2; Dist: Single): TVec2;
var
  X, Y, R: Single;
begin
  X := Self.x - V.x;
  Y := Self.y - V.y;
  R := Sqrt(X * X + Y * Y);
  if R = 0 then
    Exit(Self);
  R := 1 / R;
  Result.x := Self.x - X * R * Dist;
  Result.y := Self.y - Y * R * Dist;
end;

function TVec2.Reflect(N: TVec2): TVec2;
var
  D: Single;
begin
  D := x * N.x + y * N.y;
  Result.x := x - 2 * D * N.x;
  Result.y := y - 2 * D * N.y;
end;

function TVec2.Rotate(Angle: Single): TVec2;
var
  S, C: Extended;
begin
  if Angle = 0 then
    Exit(Self);
  SinCos(Angle, S, C);
  Result.x := (C * Self.x) + (S * Self.y);
  Result.y := (C * Self.y) - (S * Self.x);
end;

function TVec2.Rotate(const V: TVec2; Angle: Single): TVec2;
var
  S, C: Extended;
  X, Y: Single;
begin
  if Angle = 0 then
    Exit(V);
  Angle := Angle / 180 * Pi;
  SinCos(Angle, S, C);
  X := Self.y * S - Self.x * C + Self.x;
  Y := -Self.x * S - Self.y * C + Self.y;
  Result.x := V.x * C - V.y * S + X;
  Result.y := V.x * S + V.y * C + Y;
end;

{ TVec3 }

class operator TVec3.Implicit(const A: TSingleArray): TVec3;
begin
  FillChar(Result, SizeOf(Result), 0);
  case Length(A) of
    0: ;
    1: Result.x := A[0];
    2: begin Result.x := A[0]; Result.y := A[1]; end;
  else
    Result.x := A[0]; Result.y := A[1]; Result.z := A[2];
  end;
end;

class operator TVec3.Implicit(const V: TVec3): TSingleArray;
begin
  Result := [V.x, V.y, V.z];
end;

class operator TVec3.Negative(const A: TVec3): TVec3;
begin
  Result.x := -A.x;
  Result.y := -A.y;
  Result.z := -A.z;
end;

class operator TVec3.Equal(const A, B: TVec3): Boolean;
begin
  Result := FloatEqual(A.x, B.x) and FloatEqual(A.y, B.y) and FloatEqual(A.z, B.z);
end;

class operator TVec3.NotEqual(const A, B: TVec3): Boolean;
begin
  Result := not (FloatEqual(A.x, B.x) and FloatEqual(A.y, B.y) and FloatEqual(A.z, B.z));
end;

class operator TVec3.Add(const A, B: TVec3): TVec3;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
  Result.z := A.z + B.z;
end;

class operator TVec3.Subtract(const A, B: TVec3): TVec3;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
  Result.z := A.z - B.z;
end;

class operator TVec3.Multiply(const A, B: TVec3): TVec3;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
end;

class operator TVec3.Divide(const A, B: TVec3): TVec3;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
  Result.z := A.z / B.z;
end;

function TVec3.Equals(const Value: TVec3): Boolean;
begin
  Result := Self = Value;
end;

function TVec3.Cross(const V: TVec3): TVec3;
begin
  Result.x := (y * V.z) - (V.y * z);
  Result.y := (z * V.x) - (V.z * x);
  Result.z := (x * V.y) - (V.x * y);
end;

function TVec3.Dot(const V: TVec3): Single;
begin
  Result := x * V.x + y * V.y + z * V.z;
end;

function TVec3.Distance: Single;
begin
  Result := Sqrt(x * x + y * y + z * z);
end;

procedure TVec3.Normalize;
var
  N: Single;
begin
  N := x * x + y * y + z * z;
  if N = 0 then Exit;
  if N = 1 then Exit;
  N := 1 / Sqrt(N);
  x := x * N; y := y * N; z := z * N;
end;

{ TVec4 }

class operator TVec4.Implicit(const A: TSingleArray): TVec4;
begin
  FillChar(Result, SizeOf(Result), 0);
  case Length(A) of
    0: ;
    1: Result.x := A[0];
    2: begin Result.x := A[0]; Result.y := A[1]; end;
    3: begin Result.x := A[0]; Result.y := A[1]; Result.z := A[2]; end;
  else
    Result.x := A[0]; Result.y := A[1]; Result.z := A[2]; Result.w := A[3];
  end;
end;

class operator TVec4.Implicit(const V: TVec4): TSingleArray;
begin
  Result := [V.x, V.y, V.z, V.w];
end;

class operator TVec4.Negative(const A: TVec4): TVec4;
begin
  Result.X := -A.X;
  Result.Y := -A.Y;
  Result.Z := -A.Z;
  Result.W := -A.W;
end;

class operator TVec4.Equal(const A, B: TVec4): Boolean;
begin
  Result := FloatEqual(A.X, B.X) and FloatEqual(A.Y, B.Y) and FloatEqual(A.Z, B.Z) and FloatEqual(A.W, B.W);
end;

class operator TVec4.NotEqual(const A, B: TVec4): Boolean;
begin
  Result := not (FloatEqual(A.X, B.X) and FloatEqual(A.Y, B.Y) and FloatEqual(A.Z, B.Z) and FloatEqual(A.W, B.W));
end;

function TVec4.Equals(const Value: TVec4): Boolean;
begin
  Result := Self = Value;
end;

class operator TVec4.Multiply(const A, B: TVec4): TVec4;
begin
  Result.X := A.X * B.X;
  Result.Y := A.Y * B.Y;
  Result.Z := A.Z * B.Z;
  Result.W := A.W * B.W;
end;

class operator TVec4.Divide(const A, B: TVec4): TVec4;
begin
  Result.X := A.X / B.X;
  Result.Y := A.Y / B.Y;
  Result.Z := A.Z / B.Z;
  Result.W := A.W / B.W;
end;

function TVec4.Distance: Single;
begin
  Result := Sqrt(x * x + y * y + z * z + w * w);
end;

procedure TVec4.Normalize;
var
  N: Single;
begin
  N := x * x + y * y + z * z + w * w;
  if N = 0 then Exit;
  if N = 1 then Exit;
  N := 1 / Sqrt(N);
  x := x * N; y := y * N; z := z * N; ; w := w * N;
end;

{ TColorB }

class operator TColorB.Implicit(const Value: LongWord): TColorB;
begin
  Result.r := Value and $FF0000 shr 16; Result.g := Value and $FF00 shr 8; Result.b := Value and $FF;
  if Value and $FF000000 > 0 then
    Result.a := Value shr 24
  else
    Result.a := $FF;
end;

class operator TColorB.Implicit(const A: TByteArray): TColorB;
begin
  Result := BLACK;
  case Length(A) of
    0: ;
    1: Result.r := A[0];
    2: begin Result.r := A[0]; Result.g := A[1]; end;
    3: begin Result.r := A[0]; Result.g := A[1]; Result.b := A[2]; end;
  else
    Result.r := A[0]; Result.g := A[1]; Result.b := A[2]; Result.a := A[3];
  end;
end;

function TColorB.Mix(Color: TColorB; Percent: Single): TColorB;
var
  C: Single;
begin
  Percent := Clamp(Percent);
  C := 1 - Percent;
  Result.r := Round(r * C + Color.r * Percent);
  Result.g := Round(g * C + Color.g * Percent);
  Result.b := Round(b * C + Color.b * Percent);
  Result.a := Round(a * C + Color.a * Percent);
end;

function TColorB.Fade(Alpha: Single): TColorB;
begin
  Result := Self;
  Result.a := Round(Clamp(Alpha) * $FF);
end;

{ TMat4 }

class operator TMat4.Equal(const A, B: TMat4): Boolean;
begin
  Result := MemCompare(A, B, SizeOf(TMat4));
end;

class operator TMat4.NotEqual(const A, B: TMat4): Boolean;
begin
  Result := not MemCompare(A, B, SizeOf(TMat4));
end;

class operator TMat4.Add(const A, B: TMat4): TMat4;
var
  X, Y: Integer;
begin
  for Y := 0 to 3 do
    for X := 0 to 3 do
      Result.m[X, Y] := A.m[X, Y] + B.m[X, Y];
end;

class operator TMat4.Subtract(const A, B: TMat4): TMat4;
var
  X, Y: Integer;
begin
  for Y := 0 to 3 do
    for X := 0 to 3 do
      Result.m[X, Y] := A.m[X, Y] - B.m[X, Y];
end;

class operator TMat4.Multiply(const A: TMat4; const B: TVec2): TVec2;
begin
  Result.X := A.m[0, 0] * B.X + A.m[1, 0] * B.Y + A.m[3, 0];
  Result.Y := A.m[0, 1] * B.X + A.m[1, 1] * B.Y + A.m[3, 1];
end;

class operator TMat4.Multiply(const A: TMat4; const B: TVec3): TVec3;
begin
  Result.X := A.m[0, 0] * B.X + A.m[1, 0] * B.Y + A.m[2, 0] * B.Z + A.m[3, 0];
  Result.Y := A.m[0, 1] * B.X + A.m[1, 1] * B.Y + A.m[2, 1] * B.Z + A.m[3, 1];
  Result.Z := A.m[0, 2] * B.X + A.m[1, 2] * B.Y + A.m[2, 2] * B.Z + A.m[3, 2];
end;

class operator TMat4.Multiply(const A, B: TMat4): TMat4;
var
  X, Y: Integer;
begin
  for Y := 0 to 3 do
    for X := 0 to 3 do
      Result.m[X, Y] := A.m[0, Y] * B.m[X, 0] + A.m[1, Y] * B.m[X, 1] + A.m[2, Y] *
        B.m[X, 2] + A.m[3, Y] * B.m[X, 3];
end;

class operator TMat4.Divide(const A, B: TMat4): TMat4;
var
  X, Y: Integer;
begin
  for Y := 0 to 3 do
    for X := 0 to 3 do
      Result.m[X, Y] := A.m[0, Y] / B.m[X, 0] + A.m[1, Y] / B.m[X, 1] + A.m[2, Y] /
        B.m[X, 2];
end;

function TMat4.Equals(const Value: TMat4): Boolean;
begin
  Result := Self = Value;
end;

procedure TMat4.Identity;
begin
  Self := StockMatrix;
end;

function TMat4.IsIdentity: Boolean;
begin
  Result := Self = StockMatrix;
end;

function TMat4.CanInvert: Boolean;
var
  A0, A1, A2, A3, A4, A5, B0, B1, B2, B3, B4, B5: Single;
begin
  A0 := v[0] * v[5] - v[1] * v[4];
  A1 := v[0] * v[6] - v[2] * v[4];
  A2 := v[0] * v[7] - v[3] * v[4];
  A3 := v[1] * v[6] - v[2] * v[5];
  A4 := v[1] * v[7] - v[3] * v[5];
  A5 := v[2] * v[7] - v[3] * v[6];
  B0 := v[8] * v[13] - v[9] * v[12];
  B1 := v[8] * v[14] - v[10] * v[12];
  B2 := v[8] * v[15] - v[11] * v[12];
  B3 := v[9] * v[14] - v[10] * v[13];
  B4 := v[9] * v[15] - v[11] * v[13];
  B5 := v[10] * v[15] - v[11] * v[14];
  Result := A0 * B5 - A1 * B4 + A2 * B3 + A3 * B2 - A4 * B1 + A5 * B0 <> 0;
end;

function TMat4.Invert: Boolean;
var
  M: TMat4;
  A0, A1, A2, A3, A4, A5, B0, B1, B2, B3, B4, B5, D: Single;
begin
  A0 := v[0] * v[5] - v[1] * v[4];
  A1 := v[0] * v[6] - v[2] * v[4];
  A2 := v[0] * v[7] - v[3] * v[4];
  A3 := v[1] * v[6] - v[2] * v[5];
  A4 := v[1] * v[7] - v[3] * v[5];
  A5 := v[2] * v[7] - v[3] * v[6];
  B0 := v[8] * v[13] - v[9] * v[12];
  B1 := v[8] * v[14] - v[10] * v[12];
  B2 := v[8] * v[15] - v[11] * v[12];
  B3 := v[9] * v[14] - v[10] * v[13];
  B4 := v[9] * v[15] - v[11] * v[13];
  B5 := v[10] * v[15] - v[11] * v[14];
  D := A0 * B5 - A1 * B4 + A2 * B3 + A3 * B2 - A4 * B1 + A5 * B0;
  if D = 0 then
    Exit(False);
  M := Self;
  v[0] := M.v[5] * B5 - M.v[6] * B4 + M.v[7] * B3;
  v[4] := -M.v[4] * B5 + M.v[6] * B2 - M.v[7] * B1;
  v[8] := M.v[4] * B4 - M.v[5] * B2 + M.v[7] * B0;
  v[12] := -M.v[4] * B3 + M.v[5] * B1 - M.v[6] * B0;
  v[1] := -M.v[1] * B5 + M.v[2] * B4 - M.v[3] * B3;
  v[5] := M.v[0] * B5 - M.v[2] * B2 + M.v[3] * B1;
  v[9] := -M.v[0] * B4 + M.v[1] * B2 - M.v[3] * B0;
  v[13] := M.v[0] * B3 - M.v[1] * B1 + M.v[2] * B0;
  v[2] := M.v[13] * A5 - M.v[14] * A4 + M.v[15] * A3;
  v[6] := -M.v[12] * A5 + M.v[14] * A2 - M.v[15] * A1;
  v[10] := M.v[12] * A4 - M.v[13] * A2 + M.v[15] * A0;
  v[14] := -M.v[12] * A3 + M.v[13] * A1 - M.v[14] * A0;
  v[3] := -M.v[9] * A5 + M.v[10] * A4 - M.v[11] * A3;
  v[7] := M.v[8] * A5 - M.v[10] * A2 + M.v[11] * A1;
  v[11] := -M.v[8] * A4 + M.v[9] * A2 - M.v[11] * A0;
  v[15] := M.v[8] * A3 - M.v[9] * A1 + M.v[10] * A0;
  D := 1 / D;
  v[0] := v[0] * D;
  v[1] := v[1] * D;
  v[2] := v[2] * D;
  v[3] := v[3] * D;
  v[4] := v[4] * D;
  v[5] := v[5] * D;
  v[6] := v[6] * D;
  v[7] := v[7] * D;
  v[8] := v[8] * D;
  v[9] := v[9] * D;
  v[10] := v[10] * D;
  v[11] := v[11] * D;
  v[12] := v[12] * D;
  v[13] := v[13] * D;
  v[14] := v[14] * D;
  v[15] := v[15] * D;
  Result := True;
end;

procedure TMat4.Transpose;
var
  F: Single;
begin
  F := m[0, 1]; m[0, 1] := m[1, 0]; m[1, 0] := F;
  F := m[0, 2]; m[0, 2] := m[2, 0]; m[2, 0] := F;
  F := m[0, 3]; m[0, 3] := m[3, 0]; m[3, 0] := F;
  F := m[1, 2]; m[1, 2] := m[2, 1]; m[2, 1] := F;
  F := m[1, 3]; m[1, 3] := m[3, 1]; m[3, 1] := F;
  F := m[2, 3]; m[2, 3] := m[3, 2]; m[3, 2] := F;
end;

procedure TMat4.Rotate(X, Y, Z: Single);
begin
  Rotate(X, Y, Z, DefaultRotationOrder);
end;

procedure TMat4.Rotate(X, Y, Z: Single; Order: TRotationOrder);
var
  A, B: TMatrix;

  procedure RotateX;
  begin
    if X <> 0 then
    begin
      B := StockMatrix;
      B.m[1, 1] := Cos(X);
      B.m[1, 2] := Sin(X);
      B.m[2, 1] := -B.m[1, 2];
      B.m[2, 2] := B.m[1, 1];
      A := A * B;
    end;
  end;

  procedure RotateY;
  begin
    if Y <> 0 then
    begin
      B := StockMatrix;
      B.m[0, 0] := Cos(Y);
      B.m[2, 0] := Sin(Y);
      B.m[0, 2] := -B.m[2, 0];
      B.m[2, 2] := B.m[0, 0];
      A := A * B;
    end;
  end;

  procedure RotateZ;
  begin
    if Z <> 0 then
    begin
      B := StockMatrix;
      B.m[0, 0] := Cos(Z);
      B.m[1, 0] := Sin(Z);
      B.m[0, 1] := -B.m[1, 0];
      B.m[1, 1] := B.m[0, 0];
      A := A * B;
    end;
  end;

begin
  A := Self;
  X := X * (PI / 180);
  Y := Y * (PI / 180);
  Z := Z * (PI / 180);
  case Order of
    roXYZ:
      begin
        RotateX;
        RotateY;
        RotateZ;
      end;
    roYZX:
      begin
        RotateY;
        RotateZ;
        RotateX;
      end;
    roZXY:
      begin
        RotateZ;
        RotateX;
        RotateY;
      end;
    roXZY:
      begin
        RotateX;
        RotateZ;
        RotateY;
      end;
    roZYX:
      begin
        RotateZ;
        RotateY;
        RotateX;
      end;
    roYXZ:
      begin
        RotateY;
        RotateX;
        RotateZ;
      end;
  end;
  Self := A;
end;

procedure TMat4.RotateAt(X, Y, Z: Single; const Pivot: TVec3);
begin
  RotateAt(X, Y, Z, Pivot, DefaultRotationOrder)
end;

procedure TMat4.RotateAt(X, Y, Z: Single; const Pivot: TVec3; Order: TRotationOrder);
begin
  Translate(Pivot.X, Pivot.Y, Pivot.Z);
  Rotate(X, Y, Z, Order);
  Translate(-Pivot.X, -Pivot.Y, -Pivot.Z);
end;

procedure TMat4.Scale(X, Y, Z: Single);
var
  S: TMatrix;
begin
  S := StockMatrix;
  S.m[0, 0] := X;
  S.m[1, 1] := Y;
  S.m[2, 2] := Z;
  Self := Self * S;
end;

procedure TMat4.ScaleAt(X, Y, Z: Single; const Pivot: TVec3);
begin
  Translate(Pivot.X, Pivot.Y, Pivot.Z);
  Scale(X, Y, Z);
  Translate(-Pivot.X, -Pivot.Y, -Pivot.Z);
end;

procedure TMat4.Translate(X, Y, Z: Single);
var
  T: TMatrix;
begin
  T := StockMatrix;
  T.m[3, 0] := X;
  T.m[3, 1] := Y;
  T.m[3, 2] := Z;
  Self := Self * T;
end;

function TMat4.Transform(const V: TVec2): TVec2;
begin
  Result := Self * V;
end;

function TMat4.Transform(const V: TVec3): TVec3;
begin
  Result := Self * V;
end;

function TMat4.Transform(const M: TMat4): TMat4;
begin
  Result := Self * M;
end;

procedure TMat4.Perspective(FoV, AspectRatio, NearPlane, FarPlane: Single);
var
  XMax, YMax: Single;
begin
  YMax := NearPlane * Tan(FoV * PI / 360);
  XMax := YMax * AspectRatio;
  Frustum(-XMax, XMax, YMax, -YMax, NearPlane, FarPlane);
end;

procedure TMat4.Frustum(Left, Right, Top, Bottom, NearPlane, FarPlane: Single);
var
  F1, F2, F3, F4: Single;
begin
  F1 := 2.0 * NearPlane;
  F2 := Right - Left;
  F3 := Top - Bottom;
  F4 := FarPlane - NearPlane;
  v[0] := F1 / F2;
  v[1] := 0;
  v[2] := 0;
  v[3] := 0;
  v[4] := 0;
  v[5] := F1 / F3;
  v[6] := 0;
  v[7] := 0;
  v[8] := (Right + Left) / F2;
  v[9] := (Top + Bottom) / F3;
  v[10] := (-FarPlane - NearPlane) / F4;
  v[11] := -1;
  v[12] := 0;
  v[13] := 0;
  v[14] := (-F1 * FarPlane) / F4;
  v[15] := 0;
end;

{ from https://developer.tizen.org/community/code-snippet/native-code-snippet/set-lookat-matrix-opengl-es-2.0 }

procedure TMat4.LookAt(Eye, Center, Up: TVec3);
var
  F, S, U: TVec3;
begin
  F := Center - Eye;
  F.Normalize;
  S := F.Cross(Up);
  S.Normalize;
  if (S.x = 0) and (S.y = 0) and (S.z = 0) then
    Exit;
  U := S.Cross(F);
  v[0] := S.X;
  v[1] := U.X;
  v[2] := -F.X;
  v[3] := 0;
  v[4] := S.Y;
  v[5] := U.Y;
  v[6] := -F.Y;
  v[7] := 0;
  v[8] := S.Z;
  v[9] := U.Z;
  v[10] := -F.Z;
  v[11] := 0;
  v[12] := 0;
  v[13] := 0;
  v[14] := 0;
  v[15] := 1;
  Translate(-Eye.X, -Eye.Y, -Eye.Z);
end;

class operator TRect.Implicit(const Value: TVec2): TRect;
begin
  Result.x := 0; Result.y := 0; Result.width := Value.x; Result.height := Value.y;
end;

class operator TRect.Implicit(const A: TSingleArray): TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  case Length(A) of
    0: ;
    1: Result.width := A[0];
    2: begin Result.width := A[0]; Result.height := A[1]; end;
    3: begin Result.x := A[0]; Result.x := A[1]; Result.width := A[2]; end;
  else
    Result.x := A[0]; Result.y := A[1]; Result.width := A[2]; Result.height := A[3];
  end;
end;

class operator TRect.Implicit(const R: TRect): TSingleArray;
begin
  Result := [R.x, R.y, R.width, r.height];
end;

procedure TRect.Inflate(DX, DY: Single);
begin
  x := x - DX;
  y := y - DX;
  width := width + DX * 2;
  height := height + DX * 2;
end;

procedure TRect.Move(DX, DY: Single);
begin
  x := x + DX;
  y := y + DY;
end;

procedure TRect.Resize(W, H: Single);
begin
  x := x + width / 2; x := x - W / 2;
  y := y + height / 2; y := y - H / 2;
  width := W;
  height := H;
end;

function TRect.IsEmpty: Boolean;
begin
  Result := (width <= 0) or (height <= 0);
end;

function Clamp(Value: Single; Min: Single = 0; Max: Single = 1): Single;
begin
  if Value < Min then
    Result := Min
  else if Result > Max then
    Result := Max
  else
    Result := Value;
end;

function Vec2: TVec2;
begin
  Result.x := 0; Result.y := 0;
end;

function Vec3: TVec3;
begin
  Result.x := 0; Result.y := 0; Result.z := 0;
end;

function Vec4: TVec4;
begin
  Result.x := 0; Result.y := 0; Result.z := 0; Result.w := 0;
end;

function Vec(x, y: Single): TVec2;
begin
  Result.x := x; Result.y := y;
end;

function Vec(x, y, z: Single): TVec3;
begin
  Result.x := x; Result.y := y; Result.z := z;
end;

function Vec(x, y, z, w: Single): TVec4;
begin
  Result.x := x; Result.y := y; Result.z := z; Result.w := w;
end;

function Rgba(r, g, b: Byte; a: Byte = $FF): TColorB;
begin
  Result.r := r; Result.g := g; Result.b := b; Result.a := a;
end;

function Rect(width, height: Single): TRect;
begin
  Result.x := 0; Result.y := 0; Result.width := width; Result.height := height;
end;

function Rect(x, y, width, height: Single): TRect;
begin
  Result.x := x; Result.y := y; Result.width := width; Result.height := height;
end;

{ TShader }

procedure TShader.Load(vertFile, fragFile: PChar);
begin
  Self := LoadShader(vertFile, fragFile);
end;

procedure TShader.Unload;
begin
  UnloadShader(Self);
end;

function TShader.GetUniformLocation(name: PChar): Integer;
begin
  Result := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformInt);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformSingle);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformVec2);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformVec3);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformVec4);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.GetUniform(name: PChar; out uniform: TUniformSampler2d);
begin
  uniform.location := GetShaderLocation(Self, name);
end;

procedure TShader.SetUniform(const uniform: TUniformInt);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_INT);
end;

procedure TShader.SetUniform(const uniform: TUniformSingle);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_FLOAT);
end;

procedure TShader.SetUniform(const uniform: TUniformVec2);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_VEC2);
end;

procedure TShader.SetUniform(const uniform: TUniformVec3);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_VEC3);
end;

procedure TShader.SetUniform(const uniform: TUniformVec4);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_VEC4);
end;

procedure TShader.SetUniform(const uniform: TUniformSampler2d);
begin
  SetShaderValue(Self, uniform.location, @uniform.value, SHADER_UNIFORM_VEC4);
end;

end.
