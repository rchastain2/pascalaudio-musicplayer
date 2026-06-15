program musicplayer;
{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}
{$IFDEF FPC}
{$IFDEF mswindows}{$APPTYPE gui}{$ENDIF}
{$ENDIF}
uses
{$IFDEF FPC}{$IFDEF unix}cthreads,
{$ENDIF}{$ENDIF}
  msegui,
  main,
  log;
begin
  LogLn('MSEgui Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} +
    ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  application.createform(tmainfo, mainfo);
  application.run;
end.
