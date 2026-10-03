
program pamp; { PascalAudio Music Player }

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
  utils,
  loadskin;
  
begin
  logln('PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  application.createform(tmainfo, mainfo);
  application.run;
end.
