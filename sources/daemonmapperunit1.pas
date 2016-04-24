unit DaemonMapperUnit1;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, DaemonApp;

{ TDaemonMapper1 }

type
  TDaemonMapper1= class(TDaemonMapper)
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DaemonMapper1: TDaemonMapper1;

implementation

procedure RegisterMapper;
begin
  RegisterDaemonMapper(TDaemonMapper1)
end;

{$R *.lfm}


initialization
  RegisterMapper;
end.

