unit loadskin;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

implementation

uses
  msegui,
  pamplightskin;

initialization
  application.createdatamodule(tpamplightskinmo, pamplightskinmo);
end.
