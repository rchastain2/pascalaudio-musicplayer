
program musicplayer;

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
  
  pa_base,
  pa_stream,
  pa_dec_oggvorbis,
  pa_flac,
  pa_wav,
  pa_m4a,
  pa_register,
  pa_pulse_simple,
  
  log;

var
  fsource: TPAStreamSource;
  fdest: TPAAudioDestination;
  ffilelist: filenamearty;
  ffileindex: integer;

procedure addfiletolist(const afilename: filenamety);
begin
  logln('[DEBUG] Add file ' + afilename);
  setlength(ffilelist, length(ffilelist) + 1);
  ffilelist[high(ffilelist)] := afilename;
end;

procedure playfile(const afilename: filenamety);
var
  lfilename: string;
begin
  logln('[DEBUG] Play ' + afilename);
  WriteLn(unicodeformat('Track %d / %d', [ffileindex + 1, length(ffilelist)]));
  if assigned(fsource) then
    fsource.Free;
  lfilename := stringtoutf8(afilename);
  fsource := PARegisteredGetDecoderClass(lfilename, FALSE).Create(TFileStream.Create(lfilename, fmOpenRead));
  if not assigned(fdest) then
    fdest := PARegisteredGetDeviceOut('').Create;
  fdest.DataSource := fsource;
  fsource.StartData;
end;

const
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

var
  lplayable: IPAPlayable;
  lpos, lposmax: Double;
  lloop: boolean;
  
begin
  logln('PascalAudio Music Player ' + {$I version} + ' (' + {$I %DATE%} + ', ' + {$I %TIME%} + ', FPC ' + {$I %FPCVERSION%} + ', ' + {$I %FPCTARGETOS%} + ')', TRUE);
  
  setlength(ffilelist, 0);
  ffileindex := 0;
  lloop := FALSE;
  
  larguments := getcommandlinearguments;
  for i := 1 to high(larguments) do
    if directoryexists(larguments[i]) then
    begin
      logln('[DEBUG] Detect directory ' + larguments[i]);

      lfilelist := searchfiles('*', larguments[i]);
      for lfilename in lfilelist do
        if checkfileext(lfilename, cextensions) then
          addfiletolist(lfilename);
    end else
    if fileexists(larguments[i]) then
    begin
      logln('[DEBUG] Detect file ' + larguments[i]);

      if checkfileext(lfilename, cextensions) then
        addfiletolist(larguments[i]);
    end else
      logln('[DEBUG] Ignore parameter ' + larguments[i]);

  logln('[DEBUG] Found ' + inttostrmse(length(ffilelist)) + ' files');

  if length(ffilelist) = 0 then
  begin
    logln('[DEBUG] No music to play');
   {sd_info.value := 'No music to play';}
   {pb_progress.frame.caption := 'No music to play';}
    WriteLn('No music to play');
  end else
  begin
    sortarray(ffilelist);
    playfile(ffilelist[0]);
   {tm_timer.enabled := TRUE;}
    lloop := TRUE;
  end;

  while lloop do
  begin
    if assigned(fdest) then
      if not fdest.Working then
        if ffileindex = high(ffilelist) then
        begin
          logln('[DEBUG] No more music to play');
         {sd_info.value := 'No more music to play';}
         {pb_progress.frame.caption := 'No more music to play';
          tm_timer.enabled := FALSE;
          exit;}
          lloop := FALSE;
        end else
        begin
          inc(ffileindex);
          playfile(ffilelist[ffileindex]);
        end;
    (*
    if assigned(fsource) then
      if fsource.GetInterface('IPAPlayable', lplayable) then
      begin
        lpos := lplayable.GetPosition;
        lposmax := lplayable.GetMaxPosition;

       {if lposmax = 0 then
          pb_progress.value := 0
        else
          pb_progress.value := lpos / lposmax;}
      end;
    *)
    
    sleep(1000);
  end;
end.
