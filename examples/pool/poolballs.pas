unit PoolBalls;

{$mode delphi}

interface

uses
  RayLib,
  Raylib.System,
  Raylib.Graphics,
  Raylib.App;

(*const
  BallMax = 15;

type

  { TBallImages }

  TBallImages = class
  private
    FCanvas: ICanvas;
    FSize: Integer;
    FBalls: array[0..BallMax] of IRenderBitmap;
    function GetBall(Index: Integer): IRenderBitmap;
    procedure SetSize(const Value: Integer);
  public
    constructor Create(Canvas: ICanvas; Size: Integer);
    destructor Destroy; override;
    property Ball[Index: Integer]: IRenderBitmap read GetBall;
    property Size: Integer read FSize write SetSize;
  end;*)

implementation

{ TBallImages }

(*constructor TBallImages.Create(Canvas: ICanvas; Size: Integer);
begin
  FCanvas := ICanvas.Create;
  FSize := Size;
  if FSize < 8 FSize := 8;
end;

destructor TBallImages.Destroy;
var
  I: Integer;
begin
  FCanvas := nil;
  for I := 0 to BallMax do
    FBalls[I] := nil;
  inherited Destroy;
end;

function TBallImages.GetBall(Index: Integer): IRenderBitmap;
begin
  while Index < 0 then
    Index := -Index;
  Index := Index mod (BallMax + 1);
  Result := FBalls[Index];
  if Result = nil then
  begin
    for I := 0 to BallMax do
      FBalls[I] := FCanvas.NewBitmap('ball' + IntToStr(I), FSize, FSize);

  end;
end;

procedure TBallImages.SetSize(Value: Integer);
var
  I: Integer;
begin
  if Value < 8 then
    Value := 8;
  if Value > 128 then
    Value := 128;
  if Value = FSize then Exit;
  FSize := Value;
  for I := 0 to BallMax do
    FBalls[I] := nil;
end;*)

end.

