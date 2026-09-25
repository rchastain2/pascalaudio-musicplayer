
unit main;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  sysutils,
  classes,
  
  msetypes,
  mseglob,
  mseguiglob,
  mseguiintf,
  mseapplication,
  msestat,
  msemenus,
  msegui,
  msegraphics,
  msegraphutils,
  mseevent,
  mseclasses,
  msewidgets,
  mseforms,
  msesimplewidgets,
  mseact,
  msebitmap,
  msedataedits,
  msedatanodes,
  msedragglob,
  msedropdownlist,
  mseedit,
  msefiledialog,
  msegrids,
  msegridsglob,
  mseificomp,
  mseificompglob,
  mseifiglob,
  mselistbrowser,
  msestatfile,
  msestream,
  msetimer,
  msegraphedits,
  msescrollbar,
  msedispwidgets,
  mserichstring,
  msesys,
  msefileutils,
  mseformatstr,
  msekeyboard,
  msestrings,
  msearrayutils,
  msesysintf,
  mseformatpngread,
  
  pa_base,
  pa_stream,
  
  decoders,
  fadedest,
  utils;

type
  tmainfo = class(tmainform)
    bt_quit: tbutton;
    mm_menu: tmainmenu;
    tm_timer: ttimer;
    pb_progress: tprogressbar;
    lb_appname: tlabel;
    sd_filename: tstringdisp;
    bt_pause: tbutton;
    bt_next: tbutton;
    bt_previous: tbutton;
    bt_stop: tbutton;
    bt_play: tbutton;
    procedure mainfo_oncreate(const sender: TObject);
    procedure bt_quit_onexecute(const sender: TObject);
    procedure mainfo_onkeyup(const sender: twidget; var ainfo: keyeventinfoty);
    procedure tm_timer_ontimer(const sender: TObject);
    procedure item_about_onexecute(const sender: TObject);
    procedure mainfo_onterminated(const sender: TObject);
    procedure bt_pause_onexecute(const sender: TObject);
    procedure bt_next_onexecute(const sender: TObject);
    procedure bt_play_onexecute(const sender: TObject);
  private
    fsource: TPAStreamSource;
    fdest: TPAFadeDestination;
    ffilelist: filenamearty;
    ffileindex: integer;
    procedure addfiletolist(const afilename: filenamety);
    procedure fadeout;
    procedure freeplayer;
    procedure playfile(const afilename: filenamety);
  end;

var
  mainfo: tmainfo;

implementation

uses
  main_mfm;

procedure tmainfo.mainfo_oncreate(const sender: TObject);
{
const
  cextensions: msestringarty = (
    'flac',
    'm4a',
    'ogg',
    'wav'
  );
}
var
  lextensions, larguments: msestringarty;
  lfilelist: filenamearty;
  lfilename: filenamety;
  i: integer;
begin
  icon.loadfromfile(tosysfilepath(filedir(sys_getapplicationpath) + 'icon/pamp-32.png'));
  pb_progress.frame.createfont;
  
  setlength(ffilelist, 0);
  ffileindex := -1;
  fsource := nil;
  fdest := nil;

  lextensions := supportedextensions;
  logln('[DEBUG] Supported extensions ' + concatstrings(lextensions));

  larguments := getcommandlinearguments;
  for i := 1 to high(larguments) do
    if directoryexists(larguments[i]) then
    begin
      logln('[DEBUG] Directory exists "' + larguments[i] + '"');

      lfilelist := searchfiles('*', larguments[i]);
      for lfilename in lfilelist do
        if checkfileext(lfilename, lextensions) then
          addfiletolist(lfilename);
    end else if fileexists(larguments[i]) then
    begin
      logln('[DEBUG] File exists "' + larguments[i] + '"');

      if checkfileext(larguments[i], lextensions) then
        addfiletolist(larguments[i]);
    end else
      logln('[DEBUG] Ignore parameter "' + larguments[i] + '"');

  logln('[DEBUG] Found ' + inttostrmse(length(ffilelist)) + ' files');

  if length(ffilelist) = 0 then
  begin
    logln('[DEBUG] No music to play');
    pb_progress.frame.font.style := [fs_italic];
    pb_progress.frame.caption := 'No music to play';
  end else
  begin
    sortarray(ffilelist);
    tm_timer.enabled := TRUE;
  end;

  pb_progress.format := '';
end;

procedure tmainfo.bt_quit_onexecute(const sender: TObject);
begin
  application.terminated := TRUE;
end;

procedure tmainfo.mainfo_onkeyup(const sender: twidget; var ainfo: keyeventinfoty);
begin
  logln(unicodeformat('[DEBUG] mainfo_onkeyup(%d)', [ainfo.key]));

  case ainfo.key of
    KEY_ESCAPE, KEY_Q:
      application.terminated := TRUE;
    KEY_P:
      bt_pause_onexecute(nil);
    KEY_RIGHT, KEY_N:
      bt_next_onexecute(nil);
    KEY_LEFT:
      bt_next_onexecute(bt_previous);
  end;
end;

procedure tmainfo.addfiletolist(const afilename: filenamety);
begin
  logln('[DEBUG] Add file "' + afilename + '"');
  setlength(ffilelist, length(ffilelist) + 1);
  ffilelist[high(ffilelist)] := afilename;
end;

procedure tmainfo.fadeout;
var
  lstart: qword;
begin
  if not (assigned(fdest) and tm_timer.enabled and fdest.Working) then
    exit;
  fdest.FadeOut;
  lstart := gettickcount64;
  while not fdest.Silent and (gettickcount64 - lstart < 300) do
    sleep(5);
end;

procedure tmainfo.freeplayer;
begin
  fadeout;
  if assigned(fdest) then
  begin
    fdest.DataSource := nil;
    freeandnil(fdest);
  end;
  if assigned(fsource) then
    freeandnil(fsource);
end;

procedure tmainfo.playfile(const afilename: filenamety);
begin
  logln('[DEBUG] Play "' + afilename + '"');
  freeplayer;
  
  pb_progress.frame.font.style := [];
  pb_progress.frame.caption := unicodeformat('File %d / %d', [ffileindex + 1, length(ffilelist)]);
  sd_filename.value := filename(afilename);
  pb_progress.value := 0;
  bt_pause.caption := 'Pause';
  tm_timer.enabled := TRUE;

  try
    fsource := createsource(afilename);
    if not assigned(fsource) then
    begin
      logln('[ERROR] No decoder for "' + afilename + '"');
      exit;
    end;
  except
    on e: exception do
    begin
      logln('[ERROR] Cannot open "' + afilename + '": ' + utf8tostring(e.message));
      fsource := nil;
      exit;
    end;
  end;

  fdest := TPAFadeDestination.Create;
  fdest.DataSource := fsource;
  
  fsource.StartData;
end;

procedure tmainfo.tm_timer_ontimer(const sender: TObject);
var
  lplayable: IPAPlayable;
  lpos, lposmax: Double;
begin
{$IFDEF DEBUG}
  if assigned(fdest) then
  begin
    Write(formatdatetime('hh:nn:ss:zzz', now), ' fdest is assigned. ');
    if fdest.Working then
      WriteLn('fdest is working.')
    else
      WriteLn('fdest is NOT working.')
  end else
    WriteLn(formatdatetime('hh:nn:ss:zzz', now), ' fdest is NOT assigned.');
{$ENDIF}
  if not assigned(fdest)
  or not fdest.Working then
    if ffileindex = high(ffilelist) then
    begin
      logln('[DEBUG] No more music to play');
      pb_progress.frame.font.style := [fs_italic];
      pb_progress.frame.caption := 'No more music to play';
      sd_filename.value := '';
      tm_timer.enabled := FALSE;
      exit;
    end else
    begin
      inc(ffileindex);
      playfile(ffilelist[ffileindex]);
    end;

  if assigned(fsource) then
    if fsource.GetInterface('IPAPlayable', lplayable) then
    begin
      lpos := lplayable.GetPosition;
      lposmax := lplayable.GetMaxPosition;
      if lposmax = 0 then
        pb_progress.value := 0
      else
        pb_progress.value := lpos / lposmax;
    end;
end;

procedure tmainfo.item_about_onexecute(const sender: TObject);
begin
  showmessage('PascalAudio Music Player ' + {$I version}, 'About Music Player');
end;

procedure tmainfo.mainfo_onterminated(const sender: TObject);
begin
  logln('[DEBUG] mainfo_onterminated');
  freeplayer;
end;

procedure tmainfo.bt_pause_onexecute(const sender: TObject);
var
  lplayable: IPAPlayable;
begin
  if assigned(fsource) then
    if fsource.GetInterface('IPAPlayable', lplayable) then
    begin
      if bt_pause.caption = 'Pause' then
      begin
        fadeout;
        tm_timer.enabled := FALSE;
        lplayable.Pause;
        bt_pause.caption := 'Resume';
      end else
      begin
        fdest.FadeIn;
        lplayable.Play;
        tm_timer.enabled := TRUE;
        bt_pause.caption := 'Pause';
      end;
    end;
end;

procedure tmainfo.bt_next_onexecute(const sender: TObject);
var
  lplayable: IPAPlayable;
begin
  if length(ffilelist) = 0 then
    exit;

  if sender = bt_stop then
  begin
    fadeout;
    tm_timer.enabled := FALSE;
    if assigned(fsource) then
      if fsource.GetInterface('IPAPlayable', lplayable) then
        lplayable.Stop;
    exit;
  end;

  if sender = bt_previous then
  begin
    if ffileindex > 0 then
      dec(ffileindex)
    else
      ffileindex := 0;
  end else
  begin
    if ffileindex < high(ffilelist) then
      inc(ffileindex)
    else
      exit;
  end;

  playfile(ffilelist[ffileindex]);
end;

procedure tmainfo.bt_play_onexecute(const sender: TObject);
var
  lplayable: IPAPlayable;
begin
  if assigned(fsource) then
    if fsource.GetInterface('IPAPlayable', lplayable) then
    begin
      fdest.FadeIn;
      lplayable.Play;
      tm_timer.enabled := TRUE;
    end;
end;

end.
