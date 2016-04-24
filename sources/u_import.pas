unit u_import;

{$mode objfpc}{$H+}

interface

uses
  mORMotSQLite3,
  mORMot,
  U_Model,
  contnrs,
  SynCommons,
  Classes,
  FileUtil;


type

{ TRecetteImport }

TRecetteImport = class(TObject)
private
  FListFiles: TRawUTF8List;
public
  DirPath: string;
  strList: TStringList;
  constructor Create;
  destructor Destroy; override;
  procedure loadDirectory;
  procedure importFiles(fn: string; aCatID: TID);
  procedure testUtf8;
  property listFiles: TRawUTF8List read FListFiles;
end;

{ TListUTF8FileSearcher }

TListUTF8FileSearcher = class(TFileSearcher)
private
  FList: TRawUTF8List;
  function GetFileName: string;
protected
  procedure DoFileFound; override;
public
  constructor Create(AList: TRawUTF8List);
  property FileName: String read GetFileName;
end;


implementation

uses
  SysUtils;

{ TListUTF8FileSearcher }

function TListUTF8FileSearcher.GetFileName: string;
var
  r: RawByteString;
  c: TSynAnsiConvert;
begin
  r := FileInfo.Name;
  //c := TSynAnsiConvert.Engine(CP_RAWBYTESTRING);
  result := Path + UTF8ToSys(FileInfo.Name);
end;

procedure TListUTF8FileSearcher.DoFileFound;
begin
  FList.add(FileName);
end;

constructor TListUTF8FileSearcher.Create(AList: TRawUTF8List);
begin
  Inherited Create;
  FList := AList;
end;

{ TecetteImport }

constructor TRecetteImport.Create;
begin
  FListFiles := TRawUTF8List.Create;
end;

destructor TRecetteImport.Destroy;
begin
  FListFiles.Free;
  strList.Free;
  inherited Destroy;
end;

procedure TRecetteImport.loadDirectory;
var
  Searcher: TFileSearcher;
begin
  FListFiles.clear;
  //FindAllFiles (FListFiles, , , );
  strList := FindAllFiles(dirPath, '*.jpg;*.png;*.gif');
  Searcher := TListUTF8FileSearcher.Create(FListFiles);
  //Searcher := TFileSearcher.Create(FListFiles);
  Searcher.DirectoryAttribute := faDirectory;
  try
    Searcher.Search(dirPath, '*.jpg;*.png;*.gif');
  finally
    Searcher.Free;
  end;
end;

procedure TRecetteImport.importFiles(fn: string; aCatID: TID);
begin


end;

procedure TRecetteImport.testUtf8;
var
  s: TSearchRec;
  fn: System.RawByteString;
  sfn: String;
begin
  if FindFirstUTF8('./test/',faAnyFile, s) = 0 then
  begin
    repeat
      fn := s.Name;
      sfn := UTF8ToSys(fn);
    until (FindNextUTF8(s) <> 0);

  end;
end;



end.

