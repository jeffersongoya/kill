unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CheckLst, ExtCtrls;

type
  TPrincipal = class(TForm)
    lbl1: TLabel;
    edt1: TEdit;
    pnl1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure edt1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    function TerminarProcesso(sFile: String): Boolean;
    procedure ApagarArqLogs;
    procedure ApagarArqTemps;
    procedure Homologadores;
    procedure ApagarCertificados;
    procedure ApagarCfgCache;
    function ExtractSystemDir: String;
    function ExtractTempDir: String;
    function ExtractWindowsDir: String;
    procedure ApagarTemporarios;
    function GetTemporaryDir: String;
    function IfThen(AValue: Boolean; const ATrue: string;
      AFalse: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Principal: TPrincipal;

implementation

{$R *.DFM}

uses TLHelp32, PsAPI;

function TPrincipal.TerminarProcesso(sFile: String): Boolean;
var
  verSystem: TOSVersionInfo;
  hdlSnap,hdlProcess: THandle;
  bPath,bLoop: Bool;
  peEntry: TProcessEntry32;
  arrPid: Array [0..1023] of DWORD;
  iC: DWord;
  k,iCount: Integer;
  arrModul: Array [0..299] of Char;
  hdlModul: HMODULE;
begin
   Result := False;
   if ExtractFileName(sFile)=sFile then
      bPath:=false
   else
      bPath:=true;
   verSystem.dwOSVersionInfoSize:=SizeOf(TOSVersionInfo);
   GetVersionEx(verSystem);
   if verSystem.dwPlatformId=VER_PLATFORM_WIN32_WINDOWS then
   begin
      hdlSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      peEntry.dwSize:=Sizeof(peEntry);
      bLoop:=Process32First(hdlSnap,peEntry);
      while integer(bLoop)<>0 do
      begin
         if bPath then
         begin
            if CompareText(peEntry.szExeFile,sFile) = 0 then
            begin
               TerminateProcess(OpenProcess(PROCESS_TERMINATE,false,peEntry.th32ProcessID), 0);
               Result := True;
            end;
         end
         else
         begin
            if CompareText(ExtractFileName(peEntry.szExeFile),sFile) = 0 then
            begin
               TerminateProcess(OpenProcess(PROCESS_TERMINATE,false,peEntry.th32ProcessID), 0);
               Result := True;
            end;
         end;
         bLoop := Process32Next(hdlSnap,peEntry);
      end;
      CloseHandle(hdlSnap);
   end
   else
      if verSystem.dwPlatformId=VER_PLATFORM_WIN32_NT then
      begin
         EnumProcesses(@arrPid,SizeOf(arrPid),iC);
         iCount := iC div SizeOf(DWORD);
         for k := 0 to Pred(iCount) do
         begin
            hdlProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,false,arrPid [k]);
            if (hdlProcess<>0) then
            begin
               EnumProcessModules(hdlProcess,@hdlModul,SizeOf(hdlModul),iC);
               GetModuleFilenameEx(hdlProcess,hdlModul,arrModul,SizeOf(arrModul));
               if bPath then
               begin
                  if CompareText(arrModul,sFile) = 0 then
                  begin
                     TerminateProcess(OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION,False,arrPid [k]), 0);
                     Result := True;
                  end;
               end
               else
               begin
                  if CompareText(ExtractFileName(arrModul),sFile) = 0 then
                  begin
                     TerminateProcess(OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION,False,arrPid [k]), 0);
                     Result := True;
                  end;
               end;
               CloseHandle(hdlProcess);
            end;
         end;
      end;
end;

procedure TPrincipal.FormCreate(Sender: TObject);
const Max = 11;
var i: integer;
begin  
   Self.Hide;

   for I := 1 to Max do
   begin
      if (ParamStr(I) = '-j') then
      begin
         Self.Show;
         edt1.Text;
         Exit;
      end;
   end;

   ApagarTemporarios;
   ApagarArqTemps;
   ApagarCfgCache;

   for I := 1 to Max do
   begin
      if (LowerCase(ParamStr(I)) = '-k') then
      begin
         TerminarProcesso(Copy(ParamStr(I+1), 2, Length(ParamStr(I+1))));
         TerminarProcesso(ParamStr(I+1)+'.exe');
      end;
      if (LowerCase(ParamStr(I)) = '-f') then
         TerminarProcesso('firefox.exe');
      if (LowerCase(ParamStr(I)) = '-b') then
         TerminarProcesso('binbrowser.exe');
      if (LowerCase(ParamStr(I)) = '-u') then
         TerminarProcesso('ueditor.exe');
      if (LowerCase(ParamStr(I)) = '-d') then
         TerminarProcesso('delphi32.exe');
      if (LowerCase(ParamStr(I)) = '-i') then
         TerminarProcesso('ibexpert.exe');
      if (LowerCase(ParamStr(I)) = '-ie') then
         TerminarProcesso('iexplore.exe');
      if (LowerCase(ParamStr(I)) = '-o') then
         TerminarProcesso('OUTLOOK.exe');
      if (LowerCase(ParamStr(I)) = '-e') then
         TerminarProcesso('ieditor.exe');
      if (LowerCase(ParamStr(I)) = '-w') then
         TerminarProcesso('wtsBroker.exe');
      if (LowerCase(ParamStr(I)) = '-w') then
         TerminarProcesso('wtsBrokerIBX.exe');
      if (LowerCase(ParamStr(I)) = '-import') then
         TerminarProcesso('ImportMethod.exe');
      if (LowerCase(ParamStr(I)) = '-l') then
         ApagarArqLogs;
      if (LowerCase(ParamStr(I)) = '-h') then
         Homologadores;
      if (LowerCase(ParamStr(I)) = '-c') then
         ApagarCertificados;
      if (LowerCase(ParamStr(I)) = '-cache') then
         ApagarCfgCache;                      
      if (LowerCase(ParamStr(I)) = '-m') then
         TerminarProcesso('wtsMessenger.exe');
      if (LowerCase(ParamStr(I)) = '-md') then
      begin
         TerminarProcesso('wtsMessenger.exe');
         if FileExists('C:\wts\wtsMessenger.exe') then
            DeleteFile('C:\wts\wtsMessenger.exe');
      end;

      if (LowerCase(ParamStr(I)) = '-s') then
      begin
         if FileExists('C:\wts\scheduler.ini') then
            DeleteFile('C:\wts\scheduler.ini');
      end;

      if (LowerCase(ParamStr(I)) = '-all') then
      begin
//         TerminarProcesso('firefox.exe');
         TerminarProcesso('binbrowser.exe');
         TerminarProcesso('ueditor.exe');
         TerminarProcesso('delphi32.exe');
         TerminarProcesso('ibexpert.exe');
         TerminarProcesso('iexplore.exe');
//         TerminarProcesso('OUTLOOK.exe');
         TerminarProcesso('ieditor.exe');
         TerminarProcesso('wtsBroker.exe');
         TerminarProcesso('wtsBrokerIBX.exe');
         TerminarProcesso('ImportMethod.exe');
         ApagarArqLogs;
         Homologadores;
         ApagarCfgCache;
         TerminarProcesso('wtsMessenger.exe');
         if FileExists('C:\wts\wtsMessenger.exe') then
            DeleteFile('C:\wts\wtsMessenger.exe');
         if FileExists('C:\wts\scheduler.ini') then
            DeleteFile('C:\wts\scheduler.ini');
         WinExec(PChar('cmd.exe'),SW_SHOWNORMAL);
      end;
   end;

   Application.Terminate;
end;

procedure TPrincipal.edt1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = 13 then
   begin
      TerminarProcesso(edt1.Text);
      Application.Terminate;
   end;
end;

procedure TPrincipal.ApagarArqLogs;
var Rec: TSearchRec; i: integer; lista: TStringList;
const Folder = 'C:\wts\';
begin
   Lista := TStringList.Create;
   if FindFirst(Folder + '*.txt', faDirectory, Rec) = 0 then
      try
         repeat
            if (LowerCase(Copy(rec.Name,1,16)) = 'wtsbrokeribxlog_') or (LowerCase(Copy(rec.Name,1,13)) = 'wtsbrokerlog_') or
               (LowerCase(Copy(rec.Name,1,25)) = 'wtsbrokeribxschedulerlog_') or (LowerCase(Copy(rec.Name,1,12)) = 'wtsmessenger') then
               lista.Add(Folder+rec.Name);
         until
            FindNext(Rec) <> 0;
      finally
         if lista.count <> 0 then
            for i := 0 to lista.count - 1 do
               DeleteFile(lista.Strings[i]);
      end;
   Lista.Free;
end;

Function TPrincipal.GetTemporaryDir: String;
var pNetpath: array[0..MAX_path - 1] of Char;
    nlength: Cardinal;
begin
   nlength := MAX_path;
   FillChar( pNetpath, SizeOF( pNetpath ), #0 );
   GetTemppath( nlength, pNetpath );
   Result := StrPas( pNetpath );
end;


function TPrincipal.IfThen(AValue: Boolean; const ATrue: string;
      AFalse: string): string;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

procedure TPrincipal.ApagarArqTemps;
var Rec: TSearchRec; i,p: integer; lista: TStringList; Pasta: array[0..4] of string; Ext: string;
begin
   Lista := TStringList.Create;
   Pasta[0] := 'C:\wts\';
   Pasta[1] := 'Z:\wtslib\';
   Pasta[2] := 'Z:\Build\';
   Pasta[3] := 'C:\';
   Pasta[4] := GetTemporaryDir;
   for p := 0 to 4 do
   begin
      Ext := IfThen(p = 4, '*.*', '*.tmp');
      if FindFirst(Pasta[p] + Ext, faDirectory, Rec) = 0 then
         try
            repeat
               lista.Add(Pasta[p]+rec.Name);
            until
               FindNext(Rec) <> 0;
         finally
            if lista.count <> 0 then
               for i := 0 to lista.count - 1 do
                  DeleteFile(lista.Strings[i]);
         end;
   end;
   Lista.Free;
end;

procedure TPrincipal.ApagarCfgCache;
var Rec: TSearchRec; i,p: integer; lista: TStringList;
const Pasta: array[0..1] of string = ('C:\wts\cfgcache\','Z:\Build\cache\');
begin
   Lista := TStringList.Create;
   for p := 0 to 1 do
   begin
      if FindFirst(Pasta[p] + '*.*', faDirectory, Rec) = 0 then
         try
            repeat
               lista.Add(Pasta[p]+rec.Name);
            until
               FindNext(Rec) <> 0;
         finally
            if lista.count <> 0 then
               for i := 0 to lista.count - 1 do
                  DeleteFile(lista.Strings[i]);
         end;
   end;
   Lista.Free;
end;

procedure TPrincipal.ApagarTemporarios;
var Rec: TSearchRec; i: integer; lista: TStringList; Pasta: string;
begin
   Pasta := ExtractTempDir;
   Lista := TStringList.Create;
   if FindFirst(Pasta + '*.*', faDirectory, Rec) = 0 then
      try
         repeat
            lista.Add(Pasta+rec.Name);
         until
            FindNext(Rec) <> 0;
      finally
         if lista.count <> 0 then
            for i := 0 to lista.count - 1 do
               DeleteFile(lista.Strings[i]);
      end;
   Lista.Free;
end;

procedure TPrincipal.Homologadores;
var Rec: TSearchRec; i,p: integer; lista: TStringList;
const Pasta: array[0..1] of string = ('C:\wts\','C:\millenium\');
begin
   Lista := TStringList.Create;
   for p := 0 to 1 do
   begin
      if FindFirst(Pasta[p] + '*.*', faDirectory, Rec) = 0 then
         try
            repeat
               lista.Add(Pasta[p]+rec.Name);
            until
               FindNext(Rec) <> 0;
         finally
            if lista.count <> 0 then
               for i := 0 to lista.count - 1 do
                  if (LowerCase(lista.Strings[i]) <> LowerCase(Pasta[p] + 'wtsdatasouces.ini')) and
                     (Copy(lista.Strings[i], Length(lista.Strings[i])-4, Length(lista.Strings[i])) <>  '.cert') then
                     //DeleteFile(lista.Strings[i]);
                     sleep(0);
         end;
   end;
   Lista.Free;
end;

procedure TPrincipal.ApagarCertificados;
var Rec: TSearchRec; i: integer; lista: TStringList;
begin
   Lista := TStringList.Create;
   if FindFirst('C:\wts\*.cert', faDirectory, Rec) = 0 then
      lista.Add('C:\wts\'+rec.Name);
   if FindFirst('Z:\Build\*.cert', faDirectory, Rec) = 0 then
      lista.Add('Z:\Build\'+rec.Name);
   if lista.count >= 0 then
      if Application.MessageBox(PChar('Deseja realmente apagar os certificados listados abaixo:'+#13+lista.Text),'Apagar Certificados', MB_YESNO + MB_ICONQUESTION) = mrYes then
         for i := 0 to lista.count - 1 do
            DeleteFile(lista.Strings[i]);
   Lista.Free;
end;

Function TPrincipal.ExtractWindowsDir : String;
var Buffer : Array[0..144] of Char;
begin
   GetWindowsDirectory(Buffer,144);
   Result := StrPas(Buffer);
end;

Function TPrincipal.ExtractSystemDir : String;
var Buffer : Array[0..144] of Char;
begin
   GetSystemDirectory(Buffer,144);
   Result := StrPas(Buffer);
end;

function TPrincipal.ExtractTempDir : String;
var Buffer : Array[0..144] of Char;
begin
   GetTempPath(144,Buffer);
   Result := StrPas(Buffer);
end;

end.
