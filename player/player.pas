
program player;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}
{$IFDEF FPC}
{$IFDEF mswindows}{$APPTYPE gui}{$ENDIF}
{$ENDIF}

uses
{$IFDEF FPC}{$IFDEF unix}
  cthreads,
{$ENDIF}{$ENDIF}
  msegui,
  msefont,
  msegraphics,
  main,
  log;

begin
  logln('PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  registerfontalias('stf_fancy', 'Oxanium', fam_overwrite, 26);
  registerfontalias('stf_default', 'Oxanium', fam_overwrite, 14);
  application.createform(tmainfo, mainfo);
  application.run;
end.
