unit daemonCookbook;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  DaemonApp,
  mORMotHttpServer,
  DaemonMapperUnit1,
  U_Server;

{ TDaemon2 }

type
  TDaemon2 = class(TDaemon)
    procedure DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
    procedure DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Daemon2: TDaemon2;

implementation

procedure RegisterDaemon;
begin
  RegisterDaemonClass(TDaemon2)
end;

{$R *.lfm}

{ TDaemon2 }

procedure TDaemon2.DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
begin
  ok := true;
  createServer('8080');
end;

procedure TDaemon2.DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
begin
  ok := true;
  ServerHttp.Free;
  ServerDatabase.Free;
end;


initialization
  RegisterDaemon;
end.

