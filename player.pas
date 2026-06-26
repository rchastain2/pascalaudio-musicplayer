
program player;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}
{$IFDEF FPC}
{$IFDEF mswindows}{$APPTYPE gui}{$ENDIF}
{$ENDIF}

uses
{$IFDEF FPC}{$IFDEF unix}
  cthreads,
  cwstring,
{$ENDIF}{$ENDIF}
  msegui,
  msefont,
  msegraphics,
  main,
  log;

const
  CFont = 'Oxanium';
  
begin
  logln('PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  registerfontalias('stf_fancy', CFont, fam_overwrite, 26);
  registerfontalias('stf_default', CFont, fam_overwrite, 14);
  application.createform(tmainfo, mainfo);
  application.run;
end.
