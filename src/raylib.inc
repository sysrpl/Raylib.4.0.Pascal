{$mode delphi}
{$modeswitch typehelpers}
{$modeswitch multihelpers}
{$macro on}
{$packrecords c}
{$minenumsize 4}
{$a8}

{$WARN 5024 off : Parameter "$1" not used}
{$WARN 5023 off : Unit "$1" not used in $2}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
{$z4}

{$ifdef windows}
  {$define apicall := stdcall}
{$else}
  {$define apicall := cdecl}
{$endif}

{$ifdef linux}
  {$ifdef cpuarm}
    // Use the nodisplay mode if you want to run on a raspberry without a
    // display server.
    // Note: This options requires a special build of SDL to work.
    {.$define nodisplay}
    {$define gl2}
    {$define raspberry}
  {$endif}
{$endif}

{ Choose your OpenGL backend using the defines below }

{.$define gl2}

{$ifndef gl2}
  {$define gl3}
{$endif}

