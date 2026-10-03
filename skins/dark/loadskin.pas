unit loadskin;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

implementation

uses
  msegui,
  pampdarkskin;

initialization
  application.createdatamodule(tpampdarkskinmo, pampdarkskinmo);
end.
