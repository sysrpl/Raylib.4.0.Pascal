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

(*******************************************************************************************
*
*   raygui v3.0 - A simple and easy-to-use immediate-mode gui library
*
*   DESCRIPTION:
*
*   raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
*   available as a standalone library, as long as input and drawing functions are provided.
*
*   Controls provided:
*
*   # Container/separators Controls
*       - WindowBox
*       - GroupBox
*       - Line
*       - Panel
*
*   # Basic Controls
*       - Label
*       - Button
*       - LabelButton   --> Label
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - TextBoxMulti
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - ScrollBar
*       - ScrollPanel
*       - DummyRec
*       - Grid
*
*   # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*
*   It also provides a set of functions for styling the controls based on its properties (size, color).
*
*
*   GUI STYLE (guiStyle):
*
*   raygui uses a global data array for all gui style properties (allocated on data segment by default),
*   when a new style is loaded, it is loaded over the global style... but a default gui style could always be
*   recovered with GuiLoadStyleDefault() function, that overwrites the current style to the default one
*
*   The global style array size is fixed and depends on the number of controls and properties:
*
*       static unsigned int guiStyle[RAYGUI_MAX_CONTROLS*(RAYGUI_MAX_PROPS_BASE + RAYGUI_MAX_PROPS_EXTENDED)];
*
*   guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
*
*   Note that the first set of BASE properties (by default guiStyle[0..15]) belong to the generic style
*   used for all controls, when any of those base values is set, it is automatically populated to all
*   controls, so, specific control values overwriting generic style should be set after base values.
*
*   After the first BASE set we have the EXTENDED properties (by default guiStyle[16..23]), those
*   properties are actually common to all controls and can not be overwritten individually (like BASE ones)
*   Some of those properties are: TEXT_SIZE, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR
*
*   Custom control properties can be defined using the EXTENDED properties for each independent control.
*
*   TOOL: rGuiStyler is a visual tool to customize raygui style.
*
*
*   GUI ICONS (guiIcons):
*
*   raygui could use a global array containing icons data (allocated on data segment by default),
*   a custom icons set could be loaded over this array using GuiLoadIcons(), but loaded icons set
*   must be same RICON_SIZE and no more than RICON_MAX_ICONS will be loaded
*
*   Every icon is codified in binary form, using 1 bit per pixel, so, every 16x16 icon
*   requires 8 integers (16*16/32) to be stored in memory.
*
*   When the icon is draw, actually one quad per pixel is drawn if the bit for that pixel is set.
*
*   The global icons array size is fixed and depends on the number of icons and size:
*
*       static unsigned int guiIcons[RICON_MAX_ICONS*RICON_DATA_ELEMENTS];
*
*   guiIcons size is by default: 256*(16*16/32) = 2048*4 = 8192 bytes = 8 KB
*
*   TOOL: rGuiIcons is a visual tool to customize raygui icons.
*
*
*   CONFIGURATION:
*
*   #define RAYGUI_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RAYGUI_STANDALONE
*       Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
*       internally in the library and input management and drawing functions must be provided by
*       the user (check library implementation for further details).
*
*   #define RAYGUI_NO_RICONS
*       Avoid including embedded ricons data (256 icons, 16x16 pixels, 1-bit per pixel, 2KB)
*
*   #define RAYGUI_CUSTOM_RICONS
*       Includes custom ricons.h header defining a set of custom icons,
*       this file can be generated using rGuiIcons tool
*
*
*   VERSIONS HISTORY:
*
*       3.0 (xx-Sep-2021) Integrated ricons data to avoid external file
*                         REDESIGNED: GuiTextBoxMulti()
*                         REMOVED: GuiImageButton*()
*                         Multiple minor tweaks and bugs corrected
*       2.9 (17-Mar-2021) REMOVED: Tooltip API
*       2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
*       2.7 (20-Feb-2020) ADDED: Possible tooltips API
*       2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
*                         REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
*                         REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
*                         Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
*                         ADDED: 8 new custom styles ready to use
*                         Multiple minor tweaks and bugs corrected
*       2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
*       2.3 (29-Apr-2019) ADDED: rIcons auxiliar library and support for it, multiple controls reviewed
*                         Refactor all controls drawing mechanism to use control state
*       2.2 (05-Feb-2019) ADDED: GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
*       2.1 (26-Dec-2018) REDESIGNED: GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
*                         REDESIGNED: Style system (breaking change)
*       2.0 (08-Nov-2018) ADDED: Support controls guiLock and custom fonts
*                         REVIEWED: GuiComboBox(), GuiListView()...
*       1.9 (09-Oct-2018) REVIEWED: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
*       1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
*       1.5 (21-Jun-2017) Working in an improved styles system
*       1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
*       1.3 (12-Jun-2017) Complete redesign of style system
*       1.1 (01-Jun-2017) Complete review of the library
*       1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
*       0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
*       0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
*
*
*   CONTRIBUTORS:
*
*       Ramon Santamaria:   Supervision, review, redesign, update and maintenance
*       Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
*       Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
*       Adria Arranz:       Testing and Implementation of additional controls (2018)
*       Jordi Jorba:        Testing and Implementation of additional controls (2018)
*       Albert Martos:      Review and testing of the library (2015)
*       Ian Eito:           Review and testing of the library (2015)
*       Kevin Gato:         Initial implementation of basic components (2014)
*       Daniel Nicolas:     Initial implementation of basic components (2014)
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

unit Raylib.Gui;

{$mode delphi}
{$a8}

interface

uses
  Raylib;

const
  RAYGUI_VERSION = '3.0';

{ Style property }

type
  TGuiStyleProp = record
    controlId: Word;
    propertyId: Word;
    propertyValue: Integer;
  end;
  PGuiStyleProp = ^TGuiStyleProp;

{ Gui control state }

type
  TGuiControlState = Integer;

const
  GUI_STATE_NORMAL = 0;
  GUI_STATE_FOCUSED = GUI_STATE_NORMAL + 1;
  GUI_STATE_PRESSED = GUI_STATE_FOCUSED + 1;
  GUI_STATE_DISABLED = GUI_STATE_PRESSED + 1;

{ Gui control text alignment }

type
  TGuiTextAlignment = Integer;

const
  GUI_TEXT_ALIGN_LEFT = 0;
  GUI_TEXT_ALIGN_CENTER = GUI_TEXT_ALIGN_LEFT + 1;
  GUI_TEXT_ALIGN_RIGHT = GUI_TEXT_ALIGN_CENTER + 1;

{ Gui controls }

type
  TGuiControl = Integer;

const
  { Generic control -> populates to all controls when set }
  DEFAULT_CONTROL = 0;
  { Used also for: LABEL }
  LABELBUTTON = DEFAULT_CONTROL + 1;
  BUTTON = LABELBUTTON + 1;
  { Used also for: TOGGLEGROUP }
  TOGGLE = BUTTON + 1;
  { Used also for: SLIDERBAR }
  SLIDER = TOGGLE + 1;
  PROGRESSBAR = SLIDER + 1;
  CHECKBOX = PROGRESSBAR + 1;
  COMBOBOX = CHECKBOX + 1;
  DROPDOWNBOX = COMBOBOX + 1;
  { Used also for: TEXTBOXMULTI }
  TEXTBOX = DROPDOWNBOX + 1;
  VALUEBOX = TEXTBOX + 1;
  SPINNER = VALUEBOX + 1;
  LISTVIEW = SPINNER + 1;
  COLORPICKER = LISTVIEW + 1;
  SCROLLBAR = COLORPICKER + 1;
  STATUSBAR = SCROLLBAR + 1;

{ Gui base properties for every control
  NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties) }

type
  TGuiControlProperty = Integer;

const
  BORDER_COLOR_NORMAL = 0;
  BASE_COLOR_NORMAL = BORDER_COLOR_NORMAL + 1;
  TEXT_COLOR_NORMAL = BASE_COLOR_NORMAL + 1;
  BORDER_COLOR_FOCUSED = TEXT_COLOR_NORMAL + 1;
  BASE_COLOR_FOCUSED = BORDER_COLOR_FOCUSED + 1;
  TEXT_COLOR_FOCUSED = BASE_COLOR_FOCUSED + 1;
  BORDER_COLOR_PRESSED = TEXT_COLOR_FOCUSED + 1;
  BASE_COLOR_PRESSED = BORDER_COLOR_PRESSED + 1;
  TEXT_COLOR_PRESSED = BASE_COLOR_PRESSED + 1;
  BORDER_COLOR_DISABLED = TEXT_COLOR_PRESSED + 1;
  BASE_COLOR_DISABLED = BORDER_COLOR_DISABLED + 1;
  TEXT_COLOR_DISABLED = BASE_COLOR_DISABLED + 1;
  BORDER_WIDTH = TEXT_COLOR_DISABLED + 1;
  TEXT_PADDING = BORDER_WIDTH + 1;
  TEXT_ALIGNMENT = TEXT_PADDING + 1;

{ Gui extended properties depend on control
  NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default 8 properties) }

{ DEFAULT extended properties
  NOTE: Those properties are actually common to all controls }

type
  TGuiDefaultProperty = Integer;

const
  TEXT_SIZE = 16;
  TEXT_SPACING = TEXT_SIZE + 1;
  LINE_COLOR = TEXT_SPACING + 1;
  BACKGROUND_COLOR = LINE_COLOR + 1;

{ Toggle/ToggleGroup }

type
  TGuiToggleProperty = Integer;

const
  GROUP_PADDING = 16;

{ Slider/SliderBar }

type
  TGuiSliderProperty = Integer;

const
  SLIDER_WIDTH = 16;
  SLIDER_PADDING = SLIDER_WIDTH + 1;

{ ProgressBar }

type
  TGuiProgressBarProperty = Integer;

const
  PROGRESS_PADDING = 16;

{ CheckBox }

type
  TGuiCheckBoxProperty = Integer;

const
  CHECK_PADDING = 16;

{ ComboBox }

type
  TGuiComboBoxProperty = Integer;

const
  COMBO_BUTTON_WIDTH = 16;
  COMBO_BUTTON_PADDING = COMBO_BUTTON_WIDTH + 1;

{ DropdownBox }

type
  TGuiDropdownBoxProperty = Integer;

const
  ARROW_PADDING = 16;
  DROPDOWN_ITEMS_PADDING = ARROW_PADDING + 1;

{ TextBox/TextBoxMulti/ValueBox/Spinner }

type
  TGuiTextBoxProperty = Integer;

const
  TEXT_INNER_PADDING = 16;
  TEXT_LINES_PADDING = TEXT_INNER_PADDING + 1;
  COLOR_SELECTED_FG = TEXT_LINES_PADDING + 1;
  COLOR_SELECTED_BG = COLOR_SELECTED_FG + 1;

{ Spinner }

type
  TGuiSpinnerProperty = Integer;

const
  SPIN_BUTTON_WIDTH = 16;
  SPIN_BUTTON_PADDING = SPIN_BUTTON_WIDTH + 1;

{ ScrollBar }

type
  TGuiScrollBarProperty = Integer;

const
  ARROWS_SIZE = 16;
  ARROWS_VISIBLE = ARROWS_SIZE + 1;
  SCROLL_SLIDER_PADDING = ARROWS_VISIBLE + 1;
  SCROLL_SLIDER_SIZE = SCROLL_SLIDER_PADDING + 1;
  SCROLL_PADDING = SCROLL_SLIDER_SIZE + 1;
  SCROLL_SPEED = SCROLL_PADDING + 1;

{ ScrollBar side }

type
  TGuiScrollBarSide = Integer;

const
  SCROLLBAR_LEFT_SIDE = 0;
  SCROLLBAR_RIGHT_SIDE = SCROLLBAR_LEFT_SIDE + 1;


{ ListView }

type
  TGuiListViewProperty = Integer;

const
  LIST_ITEMS_HEIGHT = 16;
  LIST_ITEMS_PADDING = LIST_ITEMS_HEIGHT + 1;
  SCROLLBAR_WIDTH = LIST_ITEMS_PADDING + 1;
  SCROLLBAR_SIDE = SCROLLBAR_WIDTH + 1;

{ ColorPicker }

type
  TGuiColorPickerProperty = Integer;

const
  COLOR_SELECTOR_SIZE = 16;
  { Right hue bar width }
  HUEBAR_WIDTH = COLOR_SELECTOR_SIZE + 1;
  { Right hue bar separation from panel }
  HUEBAR_PADDING = HUEBAR_WIDTH + 1;
  { Right hue bar selector height }
  HUEBAR_SELECTOR_HEIGHT = HUEBAR_PADDING + 1;
  { Right hue bar selector overflow }
  HUEBAR_SELECTOR_OVERFLOW = HUEBAR_SELECTOR_HEIGHT + 1;

{ Global gui state control functions }

{ Enable gui controls (global state) }
procedure GuiEnable; cdecl; external;
{ Disable gui controls (global state) }
procedure GuiDisable; cdecl; external;
{ Lock gui controls (global state) }
procedure GuiLock; cdecl; external;
{ Unlock gui controls (global state) }
procedure GuiUnlock; cdecl; external;
{ Check if gui is locked (global state) }
function GuiIsLocked: Boolean; cdecl; external;
{ Set gui controls alpha (global state) alpha goes from 0.0f to 1.0f }
procedure GuiFade(alpha: Single); cdecl; external;
{ Set gui state (global state) }
procedure GuiSetState(state: Integer); cdecl; external;
{ Get gui state (global state) }
function GuiGetState: Integer; cdecl; external;

{ Font set/get functions }

{ Set gui custom font (global state) }
procedure GuiSetFont(font: TFont); cdecl; external;
{ Get gui custom font (global state) }
function GuiGetFont: TFont; cdecl; external;

{ Style set/get functions }

{ Set one style property }
procedure GuiSetStyle(control, prop, value: Integer); cdecl; external;
{ Get one style property }
function GuiGetStyle(control, prop: Integer): Integer; cdecl; external;

{ Container/separator controls, useful for controls organization }

{ Window Box control, shows a window that can be closed }
function GuiWindowBox(bounds: TRectangle; title: PChar): Boolean; cdecl; external;
{ Group Box control with text name }
procedure GuiGroupBox(bounds: TRectangle; text: PChar); cdecl; external;
{ Line separator control, could contain text }
procedure GuiLine(bounds: TRectangle; text: PChar); cdecl; external;
{ Panel control, useful to group controls }
procedure GuiPanel(bounds: TRectangle); cdecl; external;
{ Scroll Panel control }
function GuiScrollPanel(bounds: TRectangle; content: TRectangle; scroll: PVec2): TRectangle; cdecl; external;

{ Basic controls set }

{ Label control, shows text }
procedure GuiLabel(bounds: TRectangle; text: PChar); cdecl; external;
{ Button control, returns true when clicked }
function GuiButton(bounds: TRectangle; text: PChar): Boolean; cdecl; external;
{ Label button control, show true when clicked }
function GuiLabelButton(bounds: TRectangle; text: PChar): Boolean; cdecl; external;
{ Toggle Button control, returns true when active }
function GuiToggle(bounds: TRectangle; text: PChar; active: Boolean): Boolean; cdecl; external;
{ Toggle Group control, returns active toggle index }
function GuiToggleGroup(bounds: TRectangle; text: PChar; active: Integer): Integer; cdecl; external;
{ Check Box control, returns true when active }
function GuiCheckBox(bounds: TRectangle; text: PChar; checked: Boolean): Boolean; cdecl; external;
{ Combo Box control, returns selected item index }
function GuiComboBox(bounds: TRectangle; text: PChar; active: Integer): Integer; cdecl; external;
{ Dropdown Box control, returns selected item }
function GuiDropdownBox(bounds: TRectangle; text: PChar; active: PInteger; editMode: Boolean): Boolean; cdecl; external;
{ Spinner control, returns selected value }
function GuiSpinner(bounds: TRectangle; text: PChar; value: PInteger; minValue, maxValue: Integer; editMode: Boolean): Boolean; cdecl; external;
{ Value Box control, updates input text with numbers }
function GuiValueBox(bounds: TRectangle; text: PChar; value: PInteger; minValue, maxValue: Integer; editMode: Boolean): Boolean; cdecl; external;
{ Text Box control, updates input text }
function GuiTextBox(bounds: TRectangle; text: PChar; textSize: Integer; editMode: Boolean): Boolean; cdecl; external;
{ Text Box control with multiple lines }
function GuiTextBoxMulti(bounds: TRectangle; text: PChar; textSize: Integer; editMode: Boolean): Boolean; cdecl; external;
{ Slider control, returns selected value }
function GuiSlider(bounds: TRectangle; textLeft: PChar; textRight: PChar; value, minValue, maxValue: Single): Single; cdecl; external;
{ Slider Bar control, returns selected value }
function GuiSliderBar(bounds: TRectangle; textLeft: PChar; textRight: PChar; value, minValue, maxValue: Single): Single; cdecl; external;
{ Progress Bar control, shows current progress value }
function GuiProgressBar(bounds: TRectangle; textLeft: PChar; textRight: PChar; value, minValue, maxValue: Single): Single; cdecl; external;
{ Status Bar control, shows info text }
procedure GuiStatusBar(bounds: TRectangle; text: PChar); cdecl; external;
{ Dummy control for placeholders }
procedure GuiDummyRec(bounds: TRectangle; text: PChar); cdecl; external;
{ Scroll Bar control }
function GuiScrollBar(bounds: TRectangle; value, minValue, maxValue: Integer): Integer; cdecl; external;
{ Grid control }
function GuiGrid(bounds: TRectangle; spacing: Single; subdivs: Integer): TVec2; cdecl; external;
{ Advance controls set }
{ List View control, returns selected list item index }
function GuiListView(bounds: TRectangle; text: PChar; scrollIndex: PInteger; active: Integer): Integer; cdecl; external;
{ List View with extended parameters }
function GuiListViewEx(bounds: TRectangle; text: PPChar; count: Integer; focus: PInteger; scrollIndex: PInteger; active: Integer): Integer; cdecl; external;
{ Message Box control, displays a message }
function GuiMessageBox(bounds: TRectangle; title: PChar; message: PChar; buttons: PChar): Integer; cdecl; external;
{ Text Input Box control, ask for text }
function GuiTextInputBox(bounds: TRectangle; title: PChar; message: PChar; buttons: PChar; text: PChar): Integer; cdecl; external;
{ Color Picker control (multiple color controls) }
function GuiColorPicker(bounds: TRectangle; color: TColor): TColor; cdecl; external;
{ Color Panel control }
function GuiColorPanel(bounds: TRectangle; color: TColor): TColor; cdecl; external;
{ Color Bar Alpha control }
function GuiColorBarAlpha(bounds: TRectangle; alpha: Single): Single; cdecl; external;
{ Color Bar Hue control }
function GuiColorBarHue(bounds: TRectangle; value: Single): Single; cdecl; external;
{ Styles loading functions }
{ Load style file over global style variable (.rgs) }
procedure GuiLoadStyle(fileName: PChar); cdecl; external;
{ Load style default over global style }
procedure GuiLoadStyleDefault; cdecl; external;

{ Icon functions }

const
  RICON_NONE                     = 0;
  RICON_FOLDER_FILE_OPEN         = 1;
  RICON_FILE_SAVE_CLASSIC        = 2;
  RICON_FOLDER_OPEN              = 3;
  RICON_FOLDER_SAVE              = 4;
  RICON_FILE_OPEN                = 5;
  RICON_FILE_SAVE                = 6;
  RICON_FILE_EXPORT              = 7;
  RICON_FILE_NEW                 = 8;
  RICON_FILE_DELETE              = 9;
  RICON_FILETYPE_TEXT            = 10;
  RICON_FILETYPE_AUDIO           = 11;
  RICON_FILETYPE_IMAGE           = 12;
  RICON_FILETYPE_PLAY            = 13;
  RICON_FILETYPE_VIDEO           = 14;
  RICON_FILETYPE_INFO            = 15;
  RICON_FILE_COPY                = 16;
  RICON_FILE_CUT                 = 17;
  RICON_FILE_PASTE               = 18;
  RICON_CURSOR_HAND              = 19;
  RICON_CURSOR_POINTER           = 20;
  RICON_CURSOR_CLASSIC           = 21;
  RICON_PENCIL                   = 22;
  RICON_PENCIL_BIG               = 23;
  RICON_BRUSH_CLASSIC            = 24;
  RICON_BRUSH_PAINTER            = 25;
  RICON_WATER_DROP               = 26;
  RICON_COLOR_PICKER             = 27;
  RICON_RUBBER                   = 28;
  RICON_COLOR_BUCKET             = 29;
  RICON_TEXT_T                   = 30;
  RICON_TEXT_A                   = 31;
  RICON_SCALE                    = 32;
  RICON_RESIZE                   = 33;
  RICON_FILTER_POINT             = 34;
  RICON_FILTER_BILINEAR          = 35;
  RICON_CROP                     = 36;
  RICON_CROP_ALPHA               = 37;
  RICON_SQUARE_TOGGLE            = 38;
  RICON_SYMMETRY                 = 39;
  RICON_SYMMETRY_HORIZONTAL      = 40;
  RICON_SYMMETRY_VERTICAL        = 41;
  RICON_LENS                     = 42;
  RICON_LENS_BIG                 = 43;
  RICON_EYE_ON                   = 44;
  RICON_EYE_OFF                  = 45;
  RICON_FILTER_TOP               = 46;
  RICON_FILTER                   = 47;
  RICON_TARGET_POINT             = 48;
  RICON_TARGET_SMALL             = 49;
  RICON_TARGET_BIG               = 50;
  RICON_TARGET_MOVE              = 51;
  RICON_CURSOR_MOVE              = 52;
  RICON_CURSOR_SCALE             = 53;
  RICON_CURSOR_SCALE_RIGHT       = 54;
  RICON_CURSOR_SCALE_LEFT        = 55;
  RICON_UNDO                     = 56;
  RICON_REDO                     = 57;
  RICON_REREDO                   = 58;
  RICON_MUTATE                   = 59;
  RICON_ROTATE                   = 60;
  RICON_REPEAT                   = 61;
  RICON_SHUFFLE                  = 62;
  RICON_EMPTYBOX                 = 63;
  RICON_TARGET                   = 64;
  RICON_TARGET_SMALL_FILL        = 65;
  RICON_TARGET_BIG_FILL          = 66;
  RICON_TARGET_MOVE_FILL         = 67;
  RICON_CURSOR_MOVE_FILL         = 68;
  RICON_CURSOR_SCALE_FILL        = 69;
  RICON_CURSOR_SCALE_RIGHT_FILL  = 70;
  RICON_CURSOR_SCALE_LEFT_FILL   = 71;
  RICON_UNDO_FILL                = 72;
  RICON_REDO_FILL                = 73;
  RICON_REREDO_FILL              = 74;
  RICON_MUTATE_FILL              = 75;
  RICON_ROTATE_FILL              = 76;
  RICON_REPEAT_FILL              = 77;
  RICON_SHUFFLE_FILL             = 78;
  RICON_EMPTYBOX_SMALL           = 79;
  RICON_BOX                      = 80;
  RICON_BOX_TOP                  = 81;
  RICON_BOX_TOP_RIGHT            = 82;
  RICON_BOX_RIGHT                = 83;
  RICON_BOX_BOTTOM_RIGHT         = 84;
  RICON_BOX_BOTTOM               = 85;
  RICON_BOX_BOTTOM_LEFT          = 86;
  RICON_BOX_LEFT                 = 87;
  RICON_BOX_TOP_LEFT             = 88;
  RICON_BOX_CENTER               = 89;
  RICON_BOX_CIRCLE_MASK          = 90;
  RICON_POT                      = 91;
  RICON_ALPHA_MULTIPLY           = 92;
  RICON_ALPHA_CLEAR              = 93;
  RICON_DITHERING                = 94;
  RICON_MIPMAPS                  = 95;
  RICON_BOX_GRID                 = 96;
  RICON_GRID                     = 97;
  RICON_BOX_CORNERS_SMALL        = 98;
  RICON_BOX_CORNERS_BIG          = 99;
  RICON_FOUR_BOXES               = 100;
  RICON_GRID_FILL                = 101;
  RICON_BOX_MULTISIZE            = 102;
  RICON_ZOOM_SMALL               = 103;
  RICON_ZOOM_MEDIUM              = 104;
  RICON_ZOOM_BIG                 = 105;
  RICON_ZOOM_ALL                 = 106;
  RICON_ZOOM_CENTER              = 107;
  RICON_BOX_DOTS_SMALL           = 108;
  RICON_BOX_DOTS_BIG             = 109;
  RICON_BOX_CONCENTRIC           = 110;
  RICON_BOX_GRID_BIG             = 111;
  RICON_OK_TICK                  = 112;
  RICON_CROSS                    = 113;
  RICON_ARROW_LEFT               = 114;
  RICON_ARROW_RIGHT              = 115;
  RICON_ARROW_DOWN               = 116;
  RICON_ARROW_UP                 = 117;
  RICON_ARROW_LEFT_FILL          = 118;
  RICON_ARROW_RIGHT_FILL         = 119;
  RICON_ARROW_DOWN_FILL          = 120;
  RICON_ARROW_UP_FILL            = 121;
  RICON_AUDIO                    = 122;
  RICON_FX                       = 123;
  RICON_WAVE                     = 124;
  RICON_WAVE_SINUS               = 125;
  RICON_WAVE_SQUARE              = 126;
  RICON_WAVE_TRIANGULAR          = 127;
  RICON_CROSS_SMALL              = 128;
  RICON_PLAYER_PREVIOUS          = 129;
  RICON_PLAYER_PLAY_BACK         = 130;
  RICON_PLAYER_PLAY              = 131;
  RICON_PLAYER_PAUSE             = 132;
  RICON_PLAYER_STOP              = 133;
  RICON_PLAYER_NEXT              = 134;
  RICON_PLAYER_RECORD            = 135;
  RICON_MAGNET                   = 136;
  RICON_LOCK_CLOSE               = 137;
  RICON_LOCK_OPEN                = 138;
  RICON_CLOCK                    = 139;
  RICON_TOOLS                    = 140;
  RICON_GEAR                     = 141;
  RICON_GEAR_BIG                 = 142;
  RICON_BIN                      = 143;
  RICON_HAND_POINTER             = 144;
  RICON_LASER                    = 145;
  RICON_COIN                     = 146;
  RICON_EXPLOSION                = 147;
  RICON_1UP                      = 148;
  RICON_PLAYER                   = 149;
  RICON_PLAYER_JUMP              = 150;
  RICON_KEY                      = 151;
  RICON_DEMON                    = 152;
  RICON_TEXT_POPUP               = 153;
  RICON_GEAR_EX                  = 154;
  RICON_CRACK                    = 155;
  RICON_CRACK_POINTS             = 156;
  RICON_STAR                     = 157;
  RICON_DOOR                     = 158;
  RICON_EXIT                     = 159;
  RICON_MODE_2D                  = 160;
  RICON_MODE_3D                  = 161;
  RICON_CUBE                     = 162;
  RICON_CUBE_FACE_TOP            = 163;
  RICON_CUBE_FACE_LEFT           = 164;
  RICON_CUBE_FACE_FRONT          = 165;
  RICON_CUBE_FACE_BOTTOM         = 166;
  RICON_CUBE_FACE_RIGHT          = 167;
  RICON_CUBE_FACE_BACK           = 168;
  RICON_CAMERA                   = 169;
  RICON_SPECIAL                  = 170;
  RICON_LINK_NET                 = 171;
  RICON_LINK_BOXES               = 172;
  RICON_LINK_MULTI               = 173;
  RICON_LINK                     = 174;
  RICON_LINK_BROKE               = 175;
  RICON_TEXT_NOTES               = 176;
  RICON_NOTEBOOK                 = 177;
  RICON_SUITCASE                 = 178;
  RICON_SUITCASE_ZIP             = 179;
  RICON_MAILBOX                  = 180;
  RICON_MONITOR                  = 181;
  RICON_PRINTER                  = 182;
  RICON_PHOTO_CAMERA             = 183;
  RICON_PHOTO_CAMERA_FLASH       = 184;
  RICON_HOUSE                    = 185;
  RICON_HEART                    = 186;
  RICON_CORNER                   = 187;
  RICON_VERTICAL_BARS            = 188;
  RICON_VERTICAL_BARS_FILL       = 189;
  RICON_LIFE_BARS                = 190;
  RICON_INFO                     = 191;
  RICON_CROSSLINE                = 192;
  RICON_HELP                     = 193;
  RICON_FILETYPE_ALPHA           = 194;
  RICON_FILETYPE_HOME            = 195;
  RICON_LAYERS_VISIBLE           = 196;
  RICON_LAYERS                   = 197;
  RICON_WINDOW                   = 198;
  RICON_HIDPI                    = 199;
  RICON_200                      = 200;
  RICON_201                      = 201;
  RICON_202                      = 202;
  RICON_203                      = 203;
  RICON_204                      = 204;
  RICON_205                      = 205;
  RICON_206                      = 206;
  RICON_207                      = 207;
  RICON_208                      = 208;
  RICON_209                      = 209;
  RICON_210                      = 210;
  RICON_211                      = 211;
  RICON_212                      = 212;
  RICON_213                      = 213;
  RICON_214                      = 214;
  RICON_215                      = 215;
  RICON_216                      = 216;
  RICON_217                      = 217;
  RICON_218                      = 218;
  RICON_219                      = 219;
  RICON_220                      = 220;
  RICON_221                      = 221;
  RICON_222                      = 222;
  RICON_223                      = 223;
  RICON_224                      = 224;
  RICON_225                      = 225;
  RICON_226                      = 226;
  RICON_227                      = 227;
  RICON_228                      = 228;
  RICON_229                      = 229;
  RICON_230                      = 230;
  RICON_231                      = 231;
  RICON_232                      = 232;
  RICON_233                      = 233;
  RICON_234                      = 234;
  RICON_235                      = 235;
  RICON_236                      = 236;
  RICON_237                      = 237;
  RICON_238                      = 238;
  RICON_239                      = 239;
  RICON_240                      = 240;
  RICON_241                      = 241;
  RICON_242                      = 242;
  RICON_243                      = 243;
  RICON_244                      = 244;
  RICON_245                      = 245;
  RICON_246                      = 246;
  RICON_247                      = 247;
  RICON_248                      = 248;
  RICON_249                      = 249;
  RICON_250                      = 250;
  RICON_251                      = 251;
  RICON_252                      = 252;
  RICON_253                      = 253;
  RICON_254                      = 254;
  RICON_255                      = 255;

{ Get text with icon id prepended (if supported) }
function GuiIconText(iconId: Integer; text: PChar): PChar; cdecl; external;
procedure GuiDrawIcon(iconId, posX, posY, pixelSize: Integer; color: TColor); cdecl; external;
{ Get full icons data pointer }
function GuiGetIcons: Pointer; cdecl; external;
{ Get icon bit data }
function GuiGetIconData(iconId: Integer): Pointer; cdecl; external;
{ Set icon bit data }
procedure GuiSetIconData(iconId: Integer; data: Pointer); cdecl; external;
{ Set icon pixel value }
procedure GuiSetIconPixel(iconId, x, y: Integer); cdecl; external;
{ Clear icon pixel value }
procedure GuiClearIconPixel(iconId, x, y: Integer); cdecl; external;
{ Check icon pixel value }
function GuiCheckIconPixel(iconId, x, y: Integer): Boolean; cdecl; external;

implementation

{$ifdef linux}
  {$linklib raygui-linux}
{$endif}
{$ifdef windows}
  {$linklib raygui-win64}
{$endif}

end.
