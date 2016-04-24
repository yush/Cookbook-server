unit daemon;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, DaemonApp, U_Server;

{ TDaemon1 }

type
  TDaemon1 = class(TDaemon)
    procedure DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Daemon1: TDaemon1;

implementation

procedure RegisterDaemon;
begin
  RegisterDaemonClass(TDaemon1)
end;

{$R *.lfm}

{ TDaemon1 }

procedure TDaemon1.DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
begin
  createServer('8080');
end;


initialization
  {$IfNDef DEV}
  RegisterDaemon;
  {$EndIf}
end.

