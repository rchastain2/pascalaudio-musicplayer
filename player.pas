
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

const
  CFont = 'Oxanium';

var
  LSuccess: boolean;
  
begin
  logln('PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  LSuccess := registerfontalias('stf_fancy', CFont, fam_overwrite, 26);
  if not LSuccess then logln('[WARNING] Failed to register font alias');
  LSuccess := registerfontalias('stf_default', CFont, fam_overwrite, 14);
  if not LSuccess then logln('[WARNING] Failed to register font alias');
  application.createform(tmainfo, mainfo);
  application.run;
end.
