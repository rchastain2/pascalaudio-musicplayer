
program Player;

{$IFDEF fpc}{$MODE objfpc}{$H+}{$ENDIF}
{$IFDEF mswindows}{$APPTYPE console}{$ENDIF}

uses
{$IFDEF fpc}{$IFDEF unix}
  cthreads,
  cwstring,
{$ENDIF}{$ENDIF}
  sysutils,
  classes,
  
  msetypes,
  msesys, {getcommandlinearguments}
  msefileutils, {searchfiles}
  mseformatstr, {inttostrmse}
  msekeyboard, {KEY_*}
  msestrings, {stringtoutf8}
  msearrayutils, {sortarray}
  mseprocutils, {execwaitmse}
  msesysintf, {sys_getapplicationpath}
  
  log;

var
  ffilelist: filenamearty;
  ffileindex: integer;

procedure addfiletolist(const afilename: filenamety);
begin
  logln('[DEBUG] Add file "' + afilename + '"');
  setlength(ffilelist, length(ffilelist) + 1);
  ffilelist[high(ffilelist)] := afilename;
end;

procedure playfile(const afilename: filenamety);
var
  lplayerdir, llastdirname: filenamety;
  lplayer, lcmd: msestring;
  lerror: integer;
begin
  logln('[DEBUG] Try to play "' + afilename + '"');
  
  WriteLn(unicodeformat('Track %d / %d', [ffileindex + 1, length(ffilelist)]));
  
  if checkfileext(afilename, ['flac']) then
    lplayer := 'smartplay'
  else
  if checkfileext(afilename, ['ogg']) then
    lplayer := 'playogg'
  else
  if checkfileext(afilename, ['opus']) then
    lplayer := 'playopus'
  else
  begin
    WriteLn('No player available for this format');
    Exit;
  end;
  
  lplayerdir := filedir(sys_getapplicationpath);
  llastdirname := removelastdir(lplayerdir, lplayerdir);
  lplayerdir := lplayerdir + 'examples/';
  lplayer := lplayerdir + lplayer;
  lcmd := unicodeformat('%s ''%s''', [lplayer, afilename]);
  logln('[DEBUG] Command "' + lcmd + '"');
  
  lerror := execwaitmse(lcmd);
  
  logln('[DEBUG] Error ' + inttostrmse(lerror));
end;

const
  cappinfo = 'PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')';
  cextensions: msestringarty = (
    'flac',
    'ogg',
    'opus',
    'wav'
  );

var
  larguments: msestringarty;
  lfilelist: filenamearty;
  lfilename: filenamety;
  i: integer;
  lloop: boolean;
  
begin
  logln(cappinfo, TRUE);
  
  WriteLn(cappinfo);
  
  setlength(ffilelist, 0);
  ffileindex := 0;
  lloop := FALSE;
  
  larguments := getcommandlinearguments;
  for i := 1 to high(larguments) do
    if directoryexists(larguments[i]) then
    begin
      logln('[DEBUG] Directory exists "' + larguments[i] + '"');

      lfilelist := searchfiles('*', larguments[i]);
      for lfilename in lfilelist do
        if checkfileext(lfilename, cextensions) then
          addfiletolist(lfilename);
    end else
      if fileexists(larguments[i]) then
      begin
        logln('[DEBUG] File exists "' + larguments[i] + '"');
  
        if checkfileext(lfilename, cextensions) then
          addfiletolist(larguments[i]);
      end else
        logln('[WARNING] Invalid parameter "' + larguments[i] + '"');

  logln('[DEBUG] Found ' + inttostrmse(length(ffilelist)) + ' files');

  if length(ffilelist) = 0 then
  begin
    logln('[DEBUG] No music to play');
    
    WriteLn('No music to play');
  end else
  begin
    sortarray(ffilelist);
    lloop := TRUE;
  end;

  while lloop do
  begin
    if ffileindex = high(ffilelist) then
    begin
      logln('[DEBUG] No more music to play');
      
      WriteLn('No more music to play');
      lloop := FALSE;
    end else
    begin
      playfile(ffilelist[ffileindex]);
      inc(ffileindex);
    end;
    
    sleep(500);
  end;
end.
