program Kill;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {Principal},
  DosCommand in 'DosCommand.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TPrincipal, Principal);
  Application.Run;
end.
