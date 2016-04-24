Program serviceCookbook;

Uses
{$IFDEF UNIX}{$IFDEF UseCThreads}
  CThreads,
{$ENDIF}{$ENDIF}
  CThreads, U_Server,
  {$IfDef DEV}
  Forms, Interfaces
  {$Else}
  DaemonApp, mapper, daemon
  {$EndIf}
  ;
  { add your units here }

begin
  Application.Title := 'Daemon application';
  Application.Initialize;
  {$IfDef DEV}
  createServer('8080');
  {$EndIf}
  Application.Run;
end.
