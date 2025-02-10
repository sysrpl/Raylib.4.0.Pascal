unit TableHelp;

{$mode delphi}

interface

uses
  Raylib,
  Raylib.System,
  Raylib.Graphics,
  TableVars;

{ TTableHelp }

type
  TTableHelp = record
  private
    FFade: IBrush;
    FChalkboard: IBitmap;
    FRect: TRect;
    FFont: IFont;
    FSource: TRect;
    FDest: TRect;
    FWriter: ITextWriter;
  public
    procedure Load(Canvas: ICanvas);
    procedure Unload;
    procedure Draw(Canvas: ICanvas); overload;
  end;

implementation

{ TTableRender }

procedure TTableHelp.Load(Canvas: ICanvas);
var
  C: TColorF;
  R: TRect;
begin
  C := colorBlack;
  C.A := 0.4;
  FFade := NewBrush(C);
  FChalkboard := Canvas.LoadBitmap('chalkboard', 'assets/chalkboard.png');
  FRect := NewRect(WindowWidth, WindowHeight);
  FFont := Canvas.LoadFont('chalk', 'assets/chalk.ttf');
  FFont.Color := colorWhite;
  FFont.Size := 24;
  FSource := FChalkboard.ClientRect;
  FDest := FSource;
  FDest.X := (FRect.Width - FSource.Width) / 2;
  FDest.Y := (FRect.Height - FSource.Height) / 2;
  FWriter := Canvas.NewTextWriter(FFont);
  R := FDest;
  R.Inflate(-80, -60);
  FWriter.Paper(R);
end;

procedure TTableHelp.Unload;
begin

end;

procedure TTableHelp.Draw(Canvas: ICanvas);
const
  HelpText =
    'Use the left and right arrow keys to aim the cue stick. The up and ' +
    'down arrows change the strength of your shot. Hold down ' +
    'shift for finer aiming control. Use the space bar to take a shot.';
var
  S: string;
begin
  Canvas.FillRect(FFade, FRect);
  Canvas.DrawImage(FChalkboard, FSource, FDest);
  FWriter.NewPage;
  FWriter.Write('fps ' + IntToStr(State.Fps));
  FWriter.Write('Pool Table Simulator Help', textTop);
  FWriter.Newline;
  FWriter.Newline;
  FWriter.Write(HelpText, textMemo);
  FWriter.Newline;
  FWriter.Write('The following keys toggle various options', textTop);
  FWriter.Newline;
  FWriter.Newline;
  FWriter.Indent(50);
  FWriter.WriteColumn('escape: exit program', 0);
  FWriter.WriteColumn('F1: show this help', 0.5);
  FWriter.Newline;
  FWriter.WriteColumn('1-9: rack the balls', 0);
  FWriter.WriteColumn('F5: random ball rack', 0.5);
  FWriter.Newline;
  FWriter.WriteColumn('c: cycle camera modes', 0);
  if State.CameraMode = 2 then
    FWriter.WriteColumn('wasd: freely move the camera', 0.5)
  else
    FWriter.WriteColumn('wasd: only in free camera mode', 0.5);
  FWriter.Newline;
  FWriter.WriteColumn('q: toggle shadows', 0);
  FWriter.WriteColumn('e: cycle smoothing modes', 0.5);
  FWriter.Newline;
  FWriter.Newline;
  FWriter.Indent(-100);
  S := '';
  case State.CameraMode of
    0: S := 'orbit camera  |  shadows ';
    1: S := 'overhead camera  |  shadows ';
    2: S := 'free camera wasd  | shadows ';
  end;
  if RenderOptions.Shadows then
    S := S + ' on  |  '
  else
    S := S + ' off  |  ';
  case RenderOptions.Smoothing of
    0: S := S + 'smoothing off';
    1: S := S + 'distance smoothing on';
    2: S := S + 'distance and angle smoothing on';
  end;
  FWriter.Write(S, textTop);
  FWriter.Write('Click anywhere to close this window', textBottom);
end;

end.

