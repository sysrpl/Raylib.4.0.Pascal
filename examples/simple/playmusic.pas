program PlayMusic;

{$mode delphi}
{$ifdef windows}{$apptype gui}{$endif}

uses
  Raylib;

const
  W = 800;
  H = 450;
  StateMessage: array[Boolean] of PChar = ('Music is playing', 'Music is paused');
var
  Music: TMusic;
  Paused: Boolean;
  C: TColor;
begin
  SetTargetFPS(60);
  InitWindow(W, H, 'Raylib Music Test');
  InitAudioDevice;
  Music := LoadMusicStream('../assets/song.mp3');
  Music.looping := True;
  PlayMusicStream(Music);
  Paused := False;
  while not WindowShouldClose do
  begin
    if IsKeyPressed(KEY_ENTER) then
      SeekMusicStream(Music, 0);
    if IsKeyPressed(KEY_SPACE) then
    begin
      Paused := not Paused;
      if Paused then
        PauseMusicStream(Music)
      else
        PlayMusicStream(Music);
    end;
    UpdateMusicStream(Music);
    C := GREEN.Mix(YELLOW, (Sin(GetTime * 20) + 1) / 2);
    C := C.Mix(WHITE, 0.5);
    ClearBackground(C);
    BeginDrawing;
      DrawText('Press [space] to toggle music, [enter] to restart', 10, 10, 20, MAROON);
      DrawText(StateMessage[Paused], 10, 40, 20, MAROON);
      DrawText(TextFormat('Song time is %.2f', GetMusicTimePlayed(Music)), 10, 70, 20, MAROON);
    EndDrawing;
  end;
  StopMusicStream(Music);
  CloseWindow;
end.

