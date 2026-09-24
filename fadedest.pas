
unit fadedest;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  sysutils,
  math,

  pa_base,
  pa_pulse_simple;

type
  TPAFadeDestination = class(TPAPulseDestination)
  private
    FGain: single;
    FTarget: single;
    FBuffer: array of single;
  protected
    function InternalProcessData(const AData; ACount: Int64; AIsLastData: Boolean): Int64; override;
  public
    constructor Create; override;
    procedure FadeIn;
    procedure FadeOut;
    function Silent: boolean;
  end;

implementation

const
  CFadeDuration = 0.03;

constructor TPAFadeDestination.Create;
begin
  inherited Create;
  FGain := 1;
  FTarget := 1;
end;

procedure TPAFadeDestination.FadeIn;
begin
  FTarget := 1;
end;

procedure TPAFadeDestination.FadeOut;
begin
  FTarget := 0;
end;

function TPAFadeDestination.Silent: boolean;
begin
  result := (FTarget = 0) and (FGain = 0);
end;

function TPAFadeDestination.InternalProcessData(const AData; ACount: Int64; AIsLastData: Boolean): Int64;
var
  lchannels, lframes, i, j: integer;
  ltarget, lstep: single;
  lsample: PSingle;
begin
  ltarget := FTarget;
  lchannels := max(Channels, 1);
  lframes := ACount div (SizeOf(single) * lchannels);

  if ((FGain = 1) and (ltarget = 1)) or (lframes = 0) then
    exit(inherited InternalProcessData(AData, ACount, AIsLastData));

  if length(FBuffer) < lframes * lchannels then
    setlength(FBuffer, lframes * lchannels);

  lstep := 1 / (CFadeDuration * max(SamplesPerSecond, 1));
  lsample := PSingle(@AData);
  for i := 0 to lframes - 1 do
  begin
    if FGain < ltarget then
      FGain := math.min(FGain + lstep, ltarget)
    else if FGain > ltarget then
      FGain := math.max(FGain - lstep, ltarget);
    for j := 0 to lchannels - 1 do
    begin
      FBuffer[i * lchannels + j] := lsample^ * FGain;
      inc(lsample);
    end;
  end;

  inherited InternalProcessData(FBuffer[0], lframes * lchannels * SizeOf(single), AIsLastData);
  result := ACount;
end;

end.
