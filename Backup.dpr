program Backup;
uses
  Vcl.Forms,
  uBackup in 'uBackup.pas' {fCompactador};

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfCompactador, fCompactador);
  Application.Run;
end.
