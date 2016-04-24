unit mapper;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, DaemonApp;

{ TDaemonMapper1 }

type
  TDaemonMapper1 = class(TDaemonMapper)
    procedure DaemonMapper1Create(Sender: TObject);
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

{ TDaemonMapper1 }

procedure TDaemonMapper1.DaemonMapper1Create(Sender: TObject);
begin

end;


initialization
  {$IfNDef DEV}
    RegisterMapper;
  {$EndIf}
end.

