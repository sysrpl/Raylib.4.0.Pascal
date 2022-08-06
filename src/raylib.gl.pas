{ Raylib 4.0 Pascal bindings for Windows, macOS, Linux, and Raspberry Pi
  Git repository https://www.github.com/sysrpl/Raylib.4.0.Pascal
  By Anthony Walter <admim@getlazarus.org>
  Modified August 2022

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
*   rlgl v4.0 - A multi-OpenGL abstraction layer with an immediate-mode style API
*
*   An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
*   that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
*
*   When chosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
*   initialized on rlglInit() to accumulate vertex data.
*
*   When an internal state change is required all the stored vertex data is renderer in batch,
*   additioanlly, rlDrawRenderBatchActive() could be called to force flushing of the batch.
*
*   Some additional resources are also loaded for convenience, here the complete list:
*      - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
*      - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
*      - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
*
*   Internal buffer (and additional resources) must be manually unloaded calling rlglClose().
*
*
*   CONFIGURATION:
*
*   #define GRAPHICS_API_OPENGL_11
*   #define GRAPHICS_API_OPENGL_21
*   #define GRAPHICS_API_OPENGL_33
*   #define GRAPHICS_API_OPENGL_43
*   #define GRAPHICS_API_OPENGL_ES2
*       Use selected OpenGL graphics backend, should be supported by platform
*       Those preprocessor defines are only used on rlgl module, if OpenGL version is
*       required by any other module, use rlGetVersion() to check it
*
*   #define RLGL_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RLGL_RENDER_TEXTURES_HINT
*       Enable framebuffer objects (fbo) support (enabled by default)
*       Some GPUs could not support them despite the OpenGL version
*
*   #define RLGL_SHOW_GL_DETAILS_INFO
*       Show OpenGL extensions and capabilities detailed logs on init
*
*   #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
*       Enable debug context (only available on OpenGL 4.3)
*
*   rlgl capabilities could be customized just defining some internal
*   values before library inclusion (default values listed):
*
*   #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
*   #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
*   #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
*   #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
*
*   #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
*   #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
*   #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
*   #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
*
*   When loading a shader, the following vertex attribute and uniform
*   location names are tried to be set automatically:
*
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Binded by default to shader location: 0
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Binded by default to shader location: 1
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Binded by default to shader location: 2
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Binded by default to shader location: 3
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Binded by default to shader location: 4
*   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Binded by default to shader location: 5
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
*   #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
*   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
*   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
*   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
*
*   DEPENDENCIES:
*
*      - OpenGL libraries (depending on platform and OpenGL version selected)
*      - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
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

unit Raylib.Gl;

{$mode delphi}
{$a8}

interface

uses
  Raylib;

const
  RLGL_VERSION = '4.0';

{ Default internal render batch elements limits }
const
  { Default number of batch buffers (multi-buffering) }
  RL_DEFAULT_BATCH_BUFFERS                = 1;
  { Default number of batch draw calls (by state changes: mode, texture) }
  RL_DEFAULT_BATCH_DRAWCALLS            = 256;
  { Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture()) }
  RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS      = 4;
  { Maximum size of Matrix stack }
  RL_MAX_MATRIX_STACK_SIZE               = 32;
  { Maximum number of shader locations supported }
  RL_MAX_SHADER_LOCATIONS                = 32;
  { Projection matrix culling }
  { Default near cull distance }
  RL_CULL_DISTANCE_NEAR                = 0.01;
  { Default far cull distance }
  RL_CULL_DISTANCE_FAR               = 1000.0;
  { Texture parameters (equivalent to OpenGL defines) }
  RL_TEXTURE_WRAP_S                      = $2802;
  RL_TEXTURE_WRAP_T                      = $2803;
  RL_TEXTURE_MAG_FILTER                  = $2800;
  RL_TEXTURE_MIN_FILTER                  = $2801;
  RL_TEXTURE_FILTER_NEAREST              = $2600;
  RL_TEXTURE_FILTER_LINEAR               = $2601;
  RL_TEXTURE_FILTER_MIP_NEAREST          = $2700;
  RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR   = $2702;
  RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST   = $2701;
  RL_TEXTURE_FILTER_MIP_LINEAR           = $2703;
  { Anisotropic filter (custom identifier) }
  RL_TEXTURE_FILTER_ANISOTROPIC          = $3000;
  RL_TEXTURE_WRAP_REPEAT                 = $2901;
  RL_TEXTURE_WRAP_CLAMP                  = $812F;
  RL_TEXTURE_WRAP_MIRROR_REPEAT          = $8370;
  RL_TEXTURE_WRAP_MIRROR_CLAMP           = $8742;
  { Matrix modes (equivalent to OpenGL) }
  RL_MODELVIEW                           = $1700;
  RL_PROJECTION                          = $1701;
  RL_TEXTURE                             = $1702;
  { Primitive assembly draw modes }
  RL_LINES                               = $0001;
  RL_TRIANGLES                           = $0004;
  RL_QUADS                               = $0007;
  { GL equivalent data types }
  RL_UNSIGNED_BYTE                       = $1401;
  RL_FLOAT                               = $1406;
  RL_STREAM_DRAW                         = $88E0;
  RL_STREAM_READ                         = $88E1;
  RL_STREAM_COPY                         = $88E2;
  RL_STATIC_DRAW                         = $88E4;
  RL_STATIC_READ                         = $88E5;
  RL_STATIC_COPY                         = $88E6;
  RL_DYNAMIC_DRAW                        = $88E8;
  RL_DYNAMIC_READ                        = $88E9;
  RL_DYNAMIC_COPY                        = $88EA;
  { GL Shader type }
  RL_FRAGMENT_SHADER                     = $8B30;
  RL_VERTEX_SHADER                       = $8B31;
  RL_COMPUTE_SHADER                      = $91B9;

type
  TFramebufferAttachType = Integer;

const
  RL_ATTACHMENT_COLOR_CHANNEL0 = 0;
  RL_ATTACHMENT_COLOR_CHANNEL1 = RL_ATTACHMENT_COLOR_CHANNEL0 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL2 = RL_ATTACHMENT_COLOR_CHANNEL1 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL3 = RL_ATTACHMENT_COLOR_CHANNEL2 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL4 = RL_ATTACHMENT_COLOR_CHANNEL3 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL5 = RL_ATTACHMENT_COLOR_CHANNEL4 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL6 = RL_ATTACHMENT_COLOR_CHANNEL5 + 1;
  RL_ATTACHMENT_COLOR_CHANNEL7 = RL_ATTACHMENT_COLOR_CHANNEL6 + 1;
  RL_ATTACHMENT_DEPTH = 100;
  RL_ATTACHMENT_STENCIL = 200;


type
  TFramebufferAttachTextureType = Integer;

const
  RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0;
  RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = RL_ATTACHMENT_CUBEMAP_POSITIVE_X + 1;
  RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = RL_ATTACHMENT_CUBEMAP_NEGATIVE_X + 1;
  RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = RL_ATTACHMENT_CUBEMAP_POSITIVE_Y + 1;
  RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y + 1;
  RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = RL_ATTACHMENT_CUBEMAP_POSITIVE_Z + 1;
  RL_ATTACHMENT_TEXTURE2D = 100;
  RL_ATTACHMENT_RENDERBUFFER = 200;


{ TVertexBuffer
  Dynamic vertex buffers (position + texcoords + colors + indices arrays) }

type
  TVertexBuffer = record
    { Vertex position (XYZ - 3 components per vertex) (shader-location = 0) }
    vertices: PSingle;
    { Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1) }
    texcoords: PSingle;
    { Vertex colors (RGBA - 4 components per vertex) (shader-location = 3) }
    colors: PByte;
    { Vertex indices (in case vertex data comes indexed) (6 indices per quad) }
    indices: PLongWord;
    { OpenGL Vertex Array Object id }
    vaoId: LongWord;
    { OpenGL Vertex Buffer Objects id (4 types of vertex data) }
    vboId: array[0..3] of LongWord;
  end;
  PVertexBuffer = TVertexBuffer;

{ TDrawCall
  NOTE: Only texture changes register a new draw, other state-change-related elements are not
  used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
  of those state-change happens (this is done in core module) }

  TDrawCall = record
    { Drawing mode: LINES, TRIANGLES, QUADS }
    mode: Integer;
    { Number of vertex of the draw }
    vertexCount: Integer;
    { Number of vertex required for index alignment (LINES, TRIANGLES) }
    vertexAlignment: Integer;
    { Texture id to be used on the draw -> Use to create new draw call if changes }
    textureId: LongWord;
  end;
  PDrawCall = ^TDrawCall;

{ TRenderBatch }

  TRenderBatch = record
    { Number of vertex buffers (multi-buffering support) }
    bufferCount: Integer;
    { Current buffer tracking in case of multi-buffering }
    currentBuffer: Integer;
    { Dynamic buffer(s) for vertex data }
    vertexBuffer: PVertexBuffer;
    { Draw calls array, depends on textureId }
    drawCall: PDrawCall;
    { Draw calls counter }
    drawCounter: Integer;
    { Current depth value for next draw }
    currentDepth: Single;
  end;
  PRenderBatch = ^TRenderBatch;

{ Choose the current matrix to be transformed }
procedure rlMatrixMode(mode: Integer); cdecl; external;
{ Push the current matrix to stack }
procedure rlPushMatrix; cdecl; external;
{ Pop lattest inserted matrix from stack }
procedure rlPopMatrix; cdecl; external;
{ Reset current matrix to identity matrix }
procedure rlLoadIdentity; cdecl; external;
{ Multiply the current matrix by a translation matrix }
procedure rlTranslatef(x, y, z: Single); cdecl; external;
{ Multiply the current matrix by a rotation matrix }
procedure rlRotatef(angle, x, y, z: Single); cdecl; external;
{ Multiply the current matrix by a scaling matrix }
procedure rlScalef(x, y, z: Single); cdecl; external;
{ Multiply the current matrix by another matrix }
procedure rlMultMatrixf(matf: PSingle); cdecl; external;
procedure rlFrustum(left, right, bottom, top, znear, zfar: Double); cdecl; external;
procedure rlOrtho(left, right, bottom, top, znear, zfar: Double); cdecl; external;
{ Set the viewport area }
procedure rlViewport(x, y, width, height: Integer); cdecl; external;

{ Initialize drawing mode (how to organize vertex) }
procedure rlBegin(mode: Integer); cdecl; external;
{ Finish vertex providing }
procedure rlEnd; cdecl; external;
{ Define one vertex (position) - 2 Integer }
procedure rlVertex2i(x, y: Integer); cdecl; external;
{ Define one vertex (position) - 2 Single }
procedure rlVertex2f(x, y: Single); cdecl; external;
{ Define one vertex (position) - 3 Single }
procedure rlVertex3f(x, y, z: Single); cdecl; external;
{ Define one vertex (texture coordinate) - 2 Single }
procedure rlTexCoord2f(x, y: Single); cdecl; external;
{ Define one vertex (normal) - 3 Single }
procedure rlNormal3f(x, y, z: Single); cdecl; external;
{ Define one vertex (color) - 4 byte }
procedure rlColor4ub(r, g, b, a: Byte); cdecl; external;
{ Define one vertex (color) - 3 Single }
procedure rlColor3f(x, y, z: Single); cdecl; external;
{ Define one vertex (color) - 4 Single }
procedure rlColor4f(x, y, z, w: Single); cdecl; external;

{ Functions Declaration - OpenGL style functions (common to 1: 1; 3+: 3; ES2)
  NOTE: This functions are used to completely abstract raylib code from layer: OpenGL;
  some of them are direct wrappers over calls: OpenGL; some others are custom }

{ Vertex buffers state }

{ Enable vertex VAO: array ; if supported) }
procedure rlEnableVertexArray(vaoId: LongWord); cdecl; external;
{ Disable vertex VAO: array ; if supported) }
procedure rlDisableVertexArray; cdecl; external;
{ Enable vertex buffer (VBO) }
procedure rlEnableVertexBuffer(id: LongWord); cdecl; external;
{ Disable vertex buffer (VBO) }
procedure rlDisableVertexBuffer; cdecl; external;
{ Enable vertex buffer element (VBO element) }
procedure rlEnableVertexBufferElement(id: LongWord); cdecl; external;
{ Disable vertex buffer element (VBO element) }
procedure rlDisableVertexBufferElement; cdecl; external;
{ Enable vertex attribute index }
procedure rlEnableVertexAttribute(index: LongWord); cdecl; external;
{ Disable vertex attribute index }
procedure rlDisableVertexAttribute(index: LongWord); cdecl; external;
{ Enable attribute state pointer }
procedure rlEnableStatePointer(vertexAttribType: Integer; buffer: Pointer); cdecl; external;
{ Disable attribute state pointer }
procedure rlDisableStatePointer(vertexAttribType: Integer); cdecl; external;

{ Select and active a texture slot }
procedure rlActiveTextureSlot(slot: Integer); cdecl; external;
{ Enable texture }
procedure rlEnableTexture(id: LongWord); cdecl; external;
{ Disable texture }
procedure rlDisableTexture; cdecl; external;
{ Enable texture cubemap }
procedure rlEnableTextureCubemap(id: LongWord); cdecl; external;
{ Disable texture cubemap }
procedure rlDisableTextureCubemap; cdecl; external;
{ Set texture filter: parameters, wrap) }
procedure rlTextureParameters(id, param, value: Integer); cdecl; external;
{Enable shader program }
procedure rlEnableShader(id: LongWord); cdecl; external;
{ Disable shader program }
procedure rlDisableShader; cdecl; external;

{ Enable render texture (fbo) }
procedure rlEnableFramebuffer(id: LongWord); cdecl; external;
{ Disable render fbo): texture ; return to default framebuffer }
procedure rlDisableFramebuffer; cdecl; external;
{ Activate multiple draw color buffers }
procedure rlActiveDrawBuffers(count: Integer); cdecl; external;

{ General render state }

{ Enable color blending }
procedure rlEnableColorBlend; cdecl; external;
{ Disable color blending }
procedure rlDisableColorBlend; cdecl; external;
{ Enable depth test }
procedure rlEnableDepthTest; cdecl; external;
{ Disable depth test }
procedure rlDisableDepthTest; cdecl; external;
{ Enable depth write }
procedure rlEnableDepthMask; cdecl; external;
{ Disable depth write }
procedure rlDisableDepthMask; cdecl; external;
{ Enable backface culling }
procedure rlEnableBackfaceCulling; cdecl; external;
{ Disable backface culling }
procedure rlDisableBackfaceCulling; cdecl; external;
{ Enable scissor test }
procedure rlEnableScissorTest; cdecl; external;
{ Disable scissor test }
procedure rlDisableScissorTest; cdecl; external;
{ Scissor test }
procedure rlScissor(x, y, width, height: Integer); cdecl; external;
{ Enable wire mode }
procedure rlEnableWireMode; cdecl; external;
{ Disable wire mode }
procedure rlDisableWireMode; cdecl; external;
{ Set the line drawing width }
procedure rlSetLineWidth(width: Single); cdecl; external;
{ Get the line drawing width }
function rlGetLineWidth: Single; cdecl; external;
{ Enable line aliasing }
procedure rlEnableSmoothLines; cdecl; external;
{ Disable line aliasing }
procedure rlDisableSmoothLines; cdecl; external;
{ Enable stereo rendering }
procedure rlEnableStereoRender; cdecl; external;
{ Disable stereo rendering }
procedure rlDisableStereoRender; cdecl; external;
{ Check if stereo render is enabled }
function rlIsStereoRenderEnabled: Boolean; cdecl; external;

{ Clear color buffer with color }
procedure rlClearColor(r, g, b, a: Byte); cdecl; external;
{ Clear used screen buffers (color and depth) }
procedure rlClearScreenBuffers; cdecl; external;
{ Check and log OpenGL error codes }
procedure rlCheckErrors; cdecl; external;
{ Set blending mode }
procedure rlSetBlendMode(mode: Integer); cdecl; external;
{ Set blending mode factor and equation (using OpenGL factors) }
procedure rlSetBlendFactors(glSrcFactor, glDstFactor, glEquation: Integer); cdecl; external;

{ rlgl initialization functions }

{ Initialize buffers, shaders, textures, rlgl states) }
procedure rlglInit(width, height: Integer); cdecl; external;
{ De-inititialize buffers, shaders, textures, rlgl states) }
procedure rlglClose; cdecl; external;
{ Load OpenGL extensions (loader function required) }
procedure rlLoadExtensions(loader: Pointer); cdecl; external;
{ Get current OpenGL version }
function rlGetVersion: Integer; cdecl; external;
{ Get default framebuffer width }
function rlGetFramebufferWidth: Integer; cdecl; external;
{ Get default framebuffer height }
function rlGetFramebufferHeight: Integer; cdecl; external;

{ Get default texture id }
function rlGetTextureIdDefault: LongWord; cdecl; external;
{ Get default shader id }
function rlGetShaderIdDefault: LongWord; cdecl; external;
{ Get default shader locations }
function rlGetShaderLocsDefault: PInteger; cdecl; external;

{ Render batch management
  NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
  but this render batch API is exposed in case of custom batches are required }

{ Load a render batch system }
function rlLoadRenderBatch(numBuffers: Integer; bufferElements: Integer): TRenderBatch; cdecl; external;
{ Unload render batch system }
procedure rlUnloadRenderBatch(batch: TRenderBatch); cdecl; external;
{ Draw render batch data (Update->Draw->Reset) }
procedure rlDrawRenderBatch(var batch: TRenderBatch); cdecl; external;
{ Set the active render batch for rlgl (NULL for default internal) }
procedure rlSetRenderBatchActive(var batch: TRenderBatch); cdecl; external;
{ Update and draw internal render batch }
procedure rlDrawRenderBatchActive; cdecl; external;
{ Check internal buffer overflow for a given number of vertex }
function rlCheckRenderBatchLimit(vCount: Integer): Boolean; cdecl; external;
{ Set current texture for render batch and check buffers limits }
procedure rlSetTexture(id: LongWord); cdecl; external;

{ Vertex buffers management }

{ Load vertex array (vao) if supported }
function rlLoadVertexArray: LongWord; cdecl; external;
{ Load a vertex buffer attribute }
function rlLoadVertexBuffer(buffer: Pointer; size: Integer; _dynamic: Boolean): LongWord; cdecl; external;
{ Load a new attributes element buffer }
function rlLoadVertexBufferElement(buffer: Pointer; size: Integer; _dynamic: Boolean): LongWord; cdecl; external;
{ Update GPU buffer with new data }
procedure rlUpdateVertexBuffer(bufferId: LongWord; data: Pointer; dataSize, offset: Integer); cdecl; external;
procedure rlUnloadVertexArray(vaoId: LongWord); cdecl; external;
procedure rlUnloadVertexBuffer(vboId: LongWord); cdecl; external;
procedure rlSetVertexAttribute(index: LongWord; compSize, _type: Integer; normalized: Boolean; stride: Integer; data: Pointer); cdecl; external;
procedure rlSetVertexAttributeDivisor(index, divisor: Integer); cdecl; external;
{ Set vertex attribute default value }
procedure rlSetVertexAttributeDefault(locIndex: Integer; value: Pointer; attribType: Integer; count: Integer); cdecl; external;
procedure rlDrawVertexArray(offset: Integer; count: Integer); cdecl; external;
procedure rlDrawVertexArrayElements(offset, count: Integer; buffer: Pointer); cdecl; external;
procedure rlDrawVertexArrayInstanced(offset, count: Integer; instances: Integer); cdecl; external;
procedure rlDrawVertexArrayElementsInstanced(offset, count: Integer; buffer: Pointer; instances: Integer); cdecl; external;

{ Textures management }

{ Load texture in GPU }
function rlLoadTexture(data: Pointer; width, height, format, mipmapCount: Integer): LongWord; cdecl; external;
{ Load depth texture/renderbuffer (to be attached to fbo) }
function rlLoadTextureDepth(width, height: Integer; useRenderBuffer: Boolean): LongWord; cdecl; external;
{ Load texture cubemap }
function rlLoadTextureCubemap(data: Pointer; size, format: Integer): LongWord; cdecl; external;
{ Update GPU texture with new data }
procedure rlUpdateTexture(id: LongWord; offsetX, offsetY, width, height, format: Integer; data: Pointer); cdecl; external;
{ Get OpenGL internal formats }
procedure rlGetGlTextureFormats(format: Integer; out glInternalFormat, glFormat, glType: PInteger); cdecl; external;
{ Get name string for pixel format }
function rlGetPixelFormatName(format: LongWord): PChar; cdecl; external;
{ Unload texture from GPU memory }
procedure rlUnloadTexture(id: LongWord); cdecl; external;
{ Generate mipmap data for selected texture }
procedure rlGenTextureMipmaps(id: LongWord; width, height, format: Integer; mipmaps: PInteger); cdecl; external;
{ Read texture pixel data }
function rlReadTexturePixels(id: LongWord; width, height, format: Integer): Pointer; cdecl; external;
{ Read screen pixel data (color buffer) }
function rlReadScreenPixels(width, height: Integer): PByte; cdecl; external;

{ Framebuffer management (fbo) }

{ Load an empty framebuffer }
function rlLoadFramebuffer(width: Integer; height: Integer): LongWord; cdecl; external;
{ Attach texture/renderbuffer to a framebuffer }
procedure rlFramebufferAttach(fboId, texId: LongWord; attachType, texType, mipLevel: Integer); cdecl; external;
{ Verify framebuffer is complete }
function rlFramebufferComplete(id: LongWord): Boolean; cdecl; external;
{ Delete framebuffer from GPU }
procedure rlUnloadFramebuffer(id: LongWord); cdecl; external;

{ Shaders management }

{ Load shader from code strings }
function rlLoadShaderCode(vsCode: PChar; fsCode: PChar): LongWord; cdecl; external;
{ Compile custom shader and return shader id (RL_VERTEX_SHADER: RL_FRAGMENT_SHADER: type:;; RL_COMPUTE_SHADER) }
function rlCompileShader(shaderCode: PChar; _type: Integer): LongWord; cdecl; external;
{ Load custom shader program }
function rlLoadShaderProgram(vShaderId: LongWord; fShaderId: LongWord): LongWord; cdecl; external;
{ Unload shader program }
procedure rlUnloadShaderProgram(id: LongWord); cdecl; external;
{ Get shader location uniform }
function rlGetLocationUniform(shaderId: LongWord; uniformName: PChar): Integer; cdecl; external;
{ Get shader location attribute }
function rlGetLocationAttrib(shaderId: LongWord; attribName: PChar): Integer; cdecl; external;
{ Set shader value uniform }
procedure rlSetUniform(locIndex: Integer; value: Pointer; uniformType: Integer; count: Integer); cdecl; external;
{ Set shader value matrix }
procedure rlSetUniformMatrix(locIndex: Integer; mat: TMat4); cdecl; external;
{ Set shader value sampler }
procedure rlSetUniformSampler(locIndex: Integer; textureId: LongWord); cdecl; external;
{ Set shader currently active (id and locations) }
procedure rlSetShader(id: LongWord; locs: PInteger); cdecl; external;

{ Compute shader management }

{ Load compute shader program }
function rlLoadComputeShaderProgram(shaderId: LongWord): LongWord; cdecl; external;
{ Dispatch compute shader (equivalent to *draw* for graphics pilepine) }
procedure rlComputeShaderDispatch(groupX, groupY, groupZ: LongWord); cdecl; external;

{ Shader buffer storage object management (ssbo) }

{ Load shader storage buffer object (SSBO) }
function rlLoadShaderBuffer(size: QWord; data: Pointer; usageHint: Integer): LongWord; cdecl; external;
{ Unload shader storage buffer object (SSBO) }
procedure rlUnloadShaderBuffer(ssboId: LongWord); cdecl; external;
{ Update SSBO buffer data }
procedure rlUpdateShaderBufferElements(id: LongWord; data: Pointer; dataSize, offset: QWord); cdecl; external;
{ Get SSBO buffer size }
function rlGetShaderBufferSize(id: LongWord): QWord; cdecl; external;
{ Bind SSBO buffer }
procedure rlReadShaderBufferElements(id: LongWord; dest: Pointer; count, offset: QWord); cdecl; external;
{ Copy SSBO buffer data }
procedure rlBindShaderBuffer(id, index: LongWord); cdecl; external;

{ Buffer management }

{ Copy SSBO buffer data }
procedure rlCopyBuffersElements(destId, srcId: LongWord; destOffset, srcOffset, count: QWord); cdecl; external;
{ Bind image texture }
procedure rlBindImageTexture(id, index, format, readonly: Integer); cdecl; external;

{ Matrix state management }

{ Get internal modelview matrix }
function rlGetMatrixModelview: TMat4; cdecl; external;
{ Get internal projection matrix }
function rlGetMatrixProjection: TMat4; cdecl; external;
{ Get internal accumulated transform matrix }
function rlGetMatrixTransform: TMat4; cdecl; external;
{ Get internal projection matrix for stereo render (selected eye) }
function rlGetMatrixProjectionStereo(eye: Integer): TMat4; cdecl; external;
{ Get internal view offset matrix for stereo render (selected eye) }
function rlGetMatrixViewOffsetStereo(eye: Integer): TMat4; cdecl; external;
{ Set a custom projection matrix (replaces internal projection matrix) }
procedure rlSetMatrixProjection(proj: TMat4); cdecl; external;
{ Set a custom modelview matrix (replaces internal modelview matrix) }
procedure rlSetMatrixModelview(view: TMat4); cdecl; external;
{ Set eyes projection matrices for stereo rendering }
procedure rlSetMatrixProjectionStereo(right, left: TMat4); cdecl; external;
{ Set eyes view offsets matrices for stereo rendering }
procedure rlSetMatrixViewOffsetStereo(right, left: TMat4); cdecl; external;

{ Quick and dirty cube/quad buffers load->draw->unload }

{ Load and draw a cube }
procedure rlLoadDrawCube; cdecl; external;
{ Load and draw a quad }
procedure rlLoadDrawQuad; cdecl; external;

implementation

end.
