unit DaemonUnit1;

{$mode delphi}

interface

uses
  cthreads,
  Classes,
  SysUtils,
  FileUtil,
  DaemonApp,
  mORMotHttpServer,
  U_Server;

{ TDaemon1 }

type
  TDaemon1 = class(TDaemon)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleExecute(Sender: TCustomDaemon);
    procedure DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
    procedure DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
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

procedure TDaemon1.DataModuleCreate(Sender: TObject);
begin

end;

procedure TDaemon1.DataModuleExecute(Sender: TCustomDaemon);
begin

end;

procedure TDaemon1.DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
begin
  ok := true;
  createServer('8080');
end;

procedure TDaemon1.DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
begin
  ok := true;
  ServerHttp.Free;
  ServerDatabase.Free;
end;


initialization
  RegisterDaemon;
end.

