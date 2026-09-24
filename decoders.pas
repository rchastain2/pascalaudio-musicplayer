
unit decoders;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  sysutils,
  classes,

  msetypes,
  msestrings,
  msearrayutils,

  pa_base,
  pa_stream,
  pa_register,
  pa_dec_oggvorbis,
  pa_flac,
  pa_wav,
  pa_m4a,
  pa_ogg_opus;

function supportedextensions: msestringarty;
function createsource(const afilename: filenamety): TPAStreamSource;

implementation

function supportedextensions: msestringarty;
var
  litems, lextensions: TStrings;
  i: integer;
begin
  result := nil;
  lextensions := TStringList.Create;
  try
    litems := PARegisteredGetList(partDecoder, lextensions);
    if assigned(litems) then
    begin
      setlength(result, lextensions.Count);
      for i := 0 to lextensions.Count - 1 do
        result[i] := utf8tostring(copy(lextensions[i], 2));
      litems.Free;
    end;
  finally
    lextensions.Free;
  end;
  sortarray(result);
end;

function decoderfromextension(const aextension: string): TPAStreamSourceClass;
var
  litems, lextensions: TStrings;
  i: integer;
begin
  result := nil;
  lextensions := TStringList.Create;
  try
    litems := PARegisteredGetList(partDecoder, lextensions);
    if assigned(litems) then
    begin
      for i := 0 to lextensions.Count - 1 do
        if SameText(lextensions[i], aextension) then
        begin
          result := TPAStreamSourceClass(litems.Objects[i]);
          break;
        end;
      litems.Free;
    end;
  finally
    lextensions.Free;
  end;
end;

function createsource(const afilename: filenamety): TPAStreamSource;
var
  lfilename: string;
  ldecoder: TPAStreamSourceClass;
begin
  lfilename := stringtoutf8(afilename);
  ldecoder := decoderfromextension(ExtractFileExt(lfilename));
  if not assigned(ldecoder) then
    ldecoder := PARegisteredGetDecoderClass(lfilename, FALSE);
  if not assigned(ldecoder) then
    exit(nil);
  result := ldecoder.Create(TFileStream.Create(lfilename, fmOpenRead));
end;

initialization
  PARegister(partDecoder, TPAOggOpusDecoderSource, 'OGG/Opus', '.opus', 'OggS', 4);

end.
