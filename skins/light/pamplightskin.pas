unit pamplightskin;

{$IFDEF FPC}{$MODE objfpc}{$H+}{$ENDIF}

interface

uses
  mseclasses,
  msedatamodules,
  msegui,
  mseskin;

type
  tpamplightskinmo = class(tmsedatamodule)
    windowface: tfacecomp;
    buttonface: tfacecomp;
    vbuttonface: tfacecomp;
    menuface: tfacecomp;
    menuactiveface: tfacecomp;
    skin: tskincontroller;
  end;

var
  pamplightskinmo: tpamplightskinmo;

implementation

uses
  pamplightskin_mfm;

end.
