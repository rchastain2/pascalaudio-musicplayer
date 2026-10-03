unit pampdarkskin;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  mseclasses,
  msedatamodules,
  msegui,
  mseskin;

type
  tpampdarkskinmo = class(tmsedatamodule)
    windowface: tfacecomp;
    buttonface: tfacecomp;
    vbuttonface: tfacecomp;
    menuface: tfacecomp;
    menuactiveface: tfacecomp;
    skin: tskincontroller;
  end;

var
  pampdarkskinmo: tpampdarkskinmo;

implementation

uses
  pampdarkskin_mfm;

end.
