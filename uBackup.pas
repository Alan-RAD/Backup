unit uBackup;

{ desenvolvido por  Alan Silva dos Santos }
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
   Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Buttons, System.Zip, Vcl.ExtCtrls, REST.Backend.ServiceTypes,
  REST.Backend.MetaTypes, System.JSON, REST.Backend.Providers,
  REST.Backend.ServiceComponents, ShellAPI, Vcl.Imaging.pngimage, System.Classes;

type
    TfCompactador = class(TForm)
    EdtCaminhoZip: TEdit;
    LblProgresszip: TLabel;
    BtnBackup: TButton;
    EdtOrigem: TEdit;
    Label1: TLabel;
    Image1: TImage;
    ProgressBar1: TProgressBar;

    procedure BtnBackupClick(Sender: TObject);
    procedure robo(const PastaOrigem, PastaDestino: string);
    Procedure CompactarPasta(const CaminhoDestino: string);
    Procedure VerificaCriaArquivoouPasta(const caminhoDestino:string);
    procedure BackupPastaEArquivos(const PastaOrigem, PastaDestino: string);

end;
var
  fCompactador: TfCompactador;

implementation

{$R *.dfm}

uses System.UITypes,System.RegularExpressions,System.StrUtils, System.Types, System.IOUtils, System.ZLib;

procedure TfCompactador.BackupPastaEArquivos(const PastaOrigem,
  PastaDestino: string);
   var
  RobocopyCommando: string;
begin

begin
  RobocopyCommando := 'robocopy.exe';
  ShellExecute(0, 'open', PChar(RobocopyCommando),
  PChar(PastaOrigem + ' ' + PastaDestino + ' /MIR'), nil, SW_HIDE);


end;

end;

procedure TfCompactador.BtnBackupClick(Sender: TObject);
var
  PastaOrigem, PastaDestino: string;
  winrar: string;
  CaminhoDestino: string;


begin
  CaminhoDestino := EdtCaminhoZip.Text;
  PastaOrigem := EdtOrigem.Text;
  PastaDestino := EdtCaminhoZip.Text;


  try
    ShowMessage('Backup concluido');
    BackupPastaEArquivos(PastaOrigem, PastaDestino);
    compactarPasta(CaminhoDestino)



  except
    on E: Exception do
      ShowMessage('Erro durante o Backup: ' + E.Message);



  end;



 EdtCaminhoZip.Text:='';
 EdtOrigem.Text:='';
 exit;
end;

procedure TfCompactador.CompactarPasta(const CaminhoDestino: string);
var
  nomeArquivoCompactado: string;
  arquivos: TStringDynArray;
  arquivo: string;
  i: Integer;
begin
  // Define o nome do arquivo compactado
  nomeArquivoCompactado := ChangeFileExt(CaminhoDestino, '.zip');
  VerificaCriaArquivoouPasta(CaminhoDestino);

  // Cria um novo arquivo ZIP
  with TZipFile.Create do

  begin
    Open(nomeArquivoCompactado, zmWrite);

    try
      // Verifica se é um arquivo ou pasta
      if TFile.Exists(CaminhoDestino) then
      begin
        // Compacta um arquivo
        Add(CaminhoDestino, ExtractFileName(CaminhoDestino));
      end
      else if TDirectory.Exists(CaminhoDestino) then
      begin
        // Compacta uma pasta
        arquivos := TDirectory.GetFiles(CaminhoDestino, '*.*',
          TSearchOption.soAllDirectories);
        for i := 0 to Length(arquivos) - 1 do
        begin
          arquivo := arquivos[i];
          Add(arquivo, ExtractRelativePath(CaminhoDestino, arquivo));
        end;
      end
      else
      begin
        // Arquivo ou pasta não existe
        raise Exception.Create('Arquivo ou pasta não encontrado.');
      end;

      // Finaliza o arquivo ZIP
      Close;
    finally
      // Libera os recursos
      Free;
    end;

  end;
end;


procedure TfCompactador.robo(const PastaOrigem, PastaDestino: string);
var
  comando: string;
  startupInfo: TstartupInfo;
  processInfo: TProcessInformation;
  output: TStringList;
  progressRegex: TRegEx;
  progressMatch: TMatch;
  totalArquivos, arquivosCopiados: Integer;

begin
  comando := 'robocopy.exe "' + PastaOrigem + '" "' + PastaDestino + '" /E';
  ShellExecute(0, 'open', 'robocopy.exe "', pchar(comando), nil, SW_NORMAL);


  FillChar(startupInfo, Sizeof(startupInfo), 0);
  startupInfo.cb := Sizeof(startupInfo);

  if createprocess(nil, pchar(comando), nil, nil, false, 0, nil, nil,
    startupInfo, processInfo) then
  begin
    WaitForSingleObject(processInfo.hProcess, INFINITE);

    CloseHandle(processInfo.hThread);
    CloseHandle(processInfo.hProcess);
        {EVENTO ON PROGRESS}

  end
  else
  begin
    raise Exception.Create('erro ao iniciar o Backup');
  end;

end;

procedure TfCompactador.VerificaCriaArquivoouPasta(
  const caminhoDestino: string);
begin

  if not TDirectory.Exists(caminhoDestino) then
  begin
    // Pasta não existe, criar pasta
    TDirectory.CreateDirectory(caminhoDestino);
  end;
end;

end.
