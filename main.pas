
unit main;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  SysUtils,
  Classes,
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
  msesys, {getcommandlinearguments}
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
  msefileutils, {searchfiles}
  mseformatstr, {inttostrmse}
  msekeyboard, {KEY_*}
  msestrings; {stringtoutf8}

type
  tmainfo = class(tmainform)
    bt_quit: tbutton;
    mm_menu: tmainmenu;
    tm_timer: ttimer;
    pb_progress: tprogressbar;
    lb_appname: tlabel;
    procedure mainfo_oncreate(const sender: TObject);
    procedure bt_quit_onexecute(const sender: TObject);
    procedure mainfo_onkeyup(const sender: twidget; var ainfo: keyeventinfoty);
   procedure tm_timer_ontimer(const sender: TObject);
  private
    lfiles: filenamearty;
    procedure addfiletolist(const afilename: filenamety);
    procedure playfile(const afilename: filenamety);
  end;

var
  mainfo: tmainfo;
  
implementation

uses
  main_mfm,
  Log,
  pa_base,
  pa_stream,
  pa_dec_oggvorbis,
  pa_flac,
  pa_wav,
  pa_m4a,
  pa_register,
  pa_pulse_simple;

var
  FSource: TPAStreamSource;
  FDest: TPAAudioDestination;

procedure tmainfo.mainfo_oncreate(const sender: TObject);
const
  cextensions: msestringarty = ('flac', 'ogg', 'opus', 'wav');
var
  larguments: msestringarty;
  i: integer;
  lfilename: filenamety;
  lfiles1: filenamearty;
begin
  setlength(lfiles, 0);
  larguments := getcommandlinearguments;
  for i := 1 to high(larguments) do
    if directoryexists(larguments[i]) then
    begin
      LogLn('[DEBUG] Directory: ' + larguments[i]);

      lfiles1 := searchfiles('*', larguments[i]);
      for lfilename in lfiles1 do
      begin
        if checkfileext(lfilename, cextensions) then
        begin
          addfiletolist(lfilename);
        end;
      end;
      LogLn('[DEBUG] Files count: ' + inttostrmse(length(lfiles)));
    end
    else if fileexists(larguments[i]) then
    begin
      LogLn('[DEBUG] File: ' + larguments[i]);
      addfiletolist(larguments[i]);
    end
    else
      LogLn('[DEBUG] Unexpected parameter: ' + larguments[i]);
  
  // quick test
  if length(lfiles) > 0 then
  begin
    playfile(lfiles[0]);
    tm_timer.enabled := true;
  end;
end;

procedure tmainfo.bt_quit_onexecute(const sender: TObject);
begin
  application.terminated := true;
end;

procedure tmainfo.mainfo_onkeyup(const sender: twidget; var ainfo: keyeventinfoty);
begin
  LogLn(unicodeformat('[DEBUG] mainfo_onkeyup(%d)', [ainfo.key]));

  case ainfo.key of
    KEY_ESCAPE:
      ;
  end;
end;

procedure tmainfo.addfiletolist(const afilename: filenamety);
begin
  LogLn('[DEBUG] Add file ' + afilename);
  setlength(lfiles, length(lfiles) + 1);
  lfiles[high(lfiles)] := afilename;
end;

procedure tmainfo.playfile(const afilename: filenamety);
var
  lfilename: string;
begin
  LogLn('[DEBUG] play file ' + afilename);
  if Assigned(FSource) then
  begin
    FSource.Free;
  end;
  lfilename := stringtoutf8(afilename);
  FSource := PARegisteredGetDecoderClass(lfilename, False).Create(TFileStream.Create(lfilename, fmOpenRead));
  if not Assigned(FDest) then
    FDest := PARegisteredGetDeviceOut('').Create;
  FDest.DataSource := FSource;
  FSource.StartData;
end;

procedure tmainfo.tm_timer_ontimer(const sender: TObject);
var
  Playable: IPAPlayable;
  PosMax, PosCurrent: Double;
begin
  if Assigned(FSource) then
    if FSource.GetInterface('IPAPlayable', Playable) then
    begin
      PosMax := Playable.GetMaxPosition;
      PosCurrent := Playable.GetPosition;
      
     {ProgressBar1.Max := Trunc(PosMax * 100);
      ProgressBar1.Position := Trunc(PosCurrent * 100);}
      
      pb_progress.value := PosCurrent / PosMax;
      
     {lblPosition.Text := SecondsToTime(PosCurrent);
      lblTotal.Text := SecondsToTime(PosMax);}
    end;
end;

end.
