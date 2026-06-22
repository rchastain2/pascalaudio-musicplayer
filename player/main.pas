
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
  
  pa_base,
  pa_stream,
  pa_dec_oggvorbis,
  pa_flac,
  pa_wav,
  pa_m4a,
  pa_register,
  pa_pulse_simple,
  
  log;

type
  tmainfo = class(tmainform)
    bt_quit: tbutton;
    mm_menu: tmainmenu;
    tm_timer: ttimer;
    pb_progress: tprogressbar;
    lb_appname: tlabel;
    sd_filename: tstringdisp;
    bt_pause: tbutton;
    bt_stop: tbutton;
    procedure mainfo_oncreate(const sender: TObject);
    procedure bt_quit_onexecute(const sender: TObject);
    procedure mainfo_onkeyup(const sender: twidget; var ainfo: keyeventinfoty);
    procedure tm_timer_ontimer(const sender: TObject);
    procedure item_about_onexecute(const sender: TObject);
    procedure mainfo_onterminated(const sender: TObject);
    procedure bt_pause_onexecute(const sender: TObject);
    procedure bt_stop_onexecute(const sender: TObject);
  private
    fsource: TPAStreamSource;
    fdest: TPAAudioDestination;
    ffilelist: filenamearty;
    ffileindex: integer;
    procedure addfiletolist(const afilename: filenamety);
    procedure playfile(const afilename: filenamety);
  end;

var
  mainfo: tmainfo;

implementation

uses
  main_mfm;

procedure tmainfo.mainfo_oncreate(const sender: TObject);
const
  cextensions: msestringarty = (
    'flac',
    'mp4a',
    'ogg'{,
    'opus',
    'wav'}
    );
var
  larguments: msestringarty;
  lfilelist: filenamearty;
  lfilename: filenamety;
  i: integer;
begin
  setlength(ffilelist, 0);
  ffileindex := 0;

  larguments := getcommandlinearguments;
  for i := 1 to high(larguments) do
    if directoryexists(larguments[i]) then
    begin
      logln('[DEBUG] Directory exists ' + larguments[i]);

      lfilelist := searchfiles('*', larguments[i]);
      for lfilename in lfilelist do
        if checkfileext(lfilename, cextensions) then
          addfiletolist(lfilename);
    end
    else if fileexists(larguments[i]) then
    begin
      logln('[DEBUG] File exists ' + larguments[i]);

      if checkfileext(lfilename, cextensions) then
        addfiletolist(larguments[i]);
    end
    else
      logln('[DEBUG] Ignore parameter ' + larguments[i]);

  logln('[DEBUG] Found ' + inttostrmse(length(ffilelist)) + ' files');

  if length(ffilelist) = 0 then
  begin
    logln('[DEBUG] No music to play');
    pb_progress.frame.caption := 'No music to play';
  end
  else
  begin
    sortarray(ffilelist);
    playfile(ffilelist[0]);
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
    KEY_ESCAPE:
      application.terminated := TRUE;
  end;
end;

procedure tmainfo.addfiletolist(const afilename: filenamety);
begin
  logln('[DEBUG] Add file ' + afilename);
  setlength(ffilelist, length(ffilelist) + 1);
  ffilelist[high(ffilelist)] := afilename;
end;

procedure tmainfo.playfile(const afilename: filenamety);
var
  lfilename: string;
begin
  logln('[DEBUG] Play ' + afilename);
  pb_progress.frame.caption := unicodeformat('Track %d / %d', [ffileindex + 1, length(ffilelist)]);
  sd_filename.value := filename(afilename);
  if assigned(fsource) then
    fsource.Free;
  lfilename := stringtoutf8(afilename);
  fsource := PARegisteredGetDecoderClass(lfilename, FALSE).Create(TFileStream.Create(lfilename, fmOpenRead));
  if not assigned(fdest) then
    fdest := PARegisteredGetDeviceOut('').Create;
  fdest.DataSource := fsource;
  fsource.StartData;
end;

procedure tmainfo.tm_timer_ontimer(const sender: TObject);
var
  lplayable: IPAPlayable;
  lpos, lposmax: Double;
begin
  if assigned(fdest) then
    if not fdest.Working then
      if ffileindex = high(ffilelist) then
      begin
        logln('[DEBUG] No more music to play');
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
  if assigned(fsource) then
    freeandnil(fsource);
  if assigned(fdest) then
    freeandnil(fdest);
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
        lplayable.Pause;
        bt_pause.caption := 'Resume';
      end else
      begin
        lplayable.Play;
        bt_pause.caption := 'Pause';
      end;
    end;
end;

procedure tmainfo.bt_stop_onexecute(const sender: TObject);
var
  lplayable: IPAPlayable;
begin
  if assigned(fsource) then
    if fsource.GetInterface('IPAPlayable', lplayable) then
    begin
      lplayable.Stop;
    end;
end;

end.
