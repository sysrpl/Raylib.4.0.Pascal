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
begin
  C := colorBlack;
  C.A := 0.4;
  FFade := NewBrush(C);
  FChalkboard := Canvas.LoadBitmap('chalkboard', 'assets/chalkboard.png');
  FRect := NewRect(WindowWidth, WindowHeight);
  FFont := Canvas.LoadFont('chalk', 'assets/chalk.ttf');
  FFont.Color := colorWhite;
  FFont.Size := 30;
  FSource := FChalkboard.ClientRect;
  FDest := FSource;
  FDest.X := (FRect.Width - FSource.Width) / 2;
  FDest.Y := (FRect.Height - FSource.Height) / 2;
end;

procedure TTableHelp.Unload;
begin

end;

procedure TTableHelp.Draw(Canvas: ICanvas);
begin
  Canvas.FillRect(FFade, FRect);
  Canvas.DrawImage(FChalkboard, FSource, FDest);
  Canvas.DrawText(FFont, 'Pool Table Simulator Help', 300, 120);
  Canvas.DrawText(FFont, '(press any key to close)', 490, 520);
end;

end.

