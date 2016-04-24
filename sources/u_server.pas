unit U_Server;

//{$mode objfpc}{$H+}
{$mode delphi}

interface

uses
  Classes,
  SysUtils,
  SynCommons,
  mORMot,
  mORMotSQLite3,
  SynSQLite3Static,
  mORMotHttpServer,
  SynMustache,
  mORMotHttpClient,
  SynCrtSock,
  U_Model,
  U_CookBookServices;

var
   ServerDatabase: TSQLRestServerDB;
   ServerHttp: TSQLHttpServer;
type
{ TCookBookServer }

  { TCookBookHTTPServer }

  TCookBookHTTPServer = class(TSQLHttpServer)
    procedure indexNew(Ctxt: TSQLRestServerURIContext);
  //  function Request(Ctxt: THttpServerRequest): cardinal; override;
  end;

  TCookBookServer = class(TSQLRestServerDB)
  published
//    procedure index(Ctxt: TSQLRestServerURIContext);
    procedure allRecette(Ctxt: TSQLRestServerURIContext);
    procedure allCategories(Ctxt: TSQLRestServerURIContext);
    procedure allCategoriesTest(Ctxt: TSQLRestServerURIContext);
    procedure CategoriesDetails(Ctxt: TSQLRestServerURIContext);
    procedure newRecette(Ctxt: TSQLRestServerURIContext);
  end;

  /// an easy way to create a database model for client and server
  function CreateCookbookModel: TSQLModel;
  function createServer(port: RawUTF8): boolean;
  function initClient(server, port: string; aModel: TSQLModel): TSQLRestClientURI;
  procedure createDirIfNotExists(dirName: string);

implementation

uses
  SynLog;

procedure createDirIfNotExists(dirName: string);
begin
  if not DirectoryExists(dirName) then
    CreateDir(dirName);
end;

function createServer(port: RawUTF8): boolean;
var
  Model: TSQLModel;
  aCat: TSQLCategorie;
begin
  with TSQLLog.Family do begin
    createDirIfNotExists('log');
    DestinationPath := 'log/';
    Level := LOG_VERBOSE;
    ArchiveAfterDays := 1; // archive after one day
  end;
  Model := CreateCookbookModel;
  ForceDirectories('db');
  ServerDatabase := TCookBookServer.Create(Model,'db/'+ChangeFileExt(ExtractFileName(ExeVersion.ProgramFileName),'.db3') , true);
  ServerDatabase.CreateMissingTables;
  ServerHttp := TCookBookHttpServer.Create(port,[ServerDatabase],'+', useHttpSocket,  8);
  //ServerHttp := TSQLHttpServer.Create(port,[ServerDatabase],'+', useHttpSocket,  8);
  //ServerHttp.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries

  aCat := TSQLCategorie.Create();
  try
    if not ServerDatabase.Retrieve('nom = ?',[], ['Aucune'], aCat) then
    begin
      aCat.nom := 'Aucune';
      ServerDatabase.Add (aCat, true);
    end;
  finally
    aCat.Free;
  end;
end;

function initClient(server, port: string; aModel: TSQLModel): TSQLRestClientURI;
begin
  {$IFDEF UNIX}
    result := TSQLHttpClientCurl.Create(server, port, aModel, false);
  {$ELSE}
    result := TSQLHttpClientWinINet.Create(server, port, aModel, false);
  {$ENDIF}
  result.SetUser('Admin', 'synopse');
end;

function CreateCookbookModel: TSQLModel;
begin
  result := TSQLModel.Create([TSQLRecette, TSQLCategorie]);
end;

{ TCookBookHTTPServer }

procedure TCookBookHTTPServer.indexNew(Ctxt: TSQLRestServerURIContext);
var
   mustache: TSynMustache;
   html: RawUTF8;
   p: TSynMustachePartials;
   js: RawJSON;
   partialHeader: RawByteString;
   partialFooter: RawByteString;
   default: RawByteString;
begin
  try
    Ctxt.Returns('test', HTML_SUCCESS, HTML_CONTENT_TYPE_HEADER);
  finally
    p.Free;
  end;
end;

(*
function TCookBookHTTPServer.Request(Ctxt: THttpServerRequest): cardinal;
begin

	if PosEx('root', Ctxt.URL) = -1 then
	  Result := inherited Request(Ctxt)
  else begin
  	Ctxt.outContent := 'test';
    Ctxt.outContentType := HTML_CONTENT_TYPE_HEADER;
    result := HTML_SUCCESS;
  end;
end;
*)


{ TCookBookServer }

(*
procedure TCookBookServer.index(Ctxt: TSQLRestServerURIContext);
var
   mustache: TSynMustache;
   html: RawUTF8;
   p: TSynMustachePartials;
   js: RawJSON;
   partialHeader: RawByteString;
   partialFooter: RawByteString;
   default: RawByteString;
begin
  try
    js := RetrieveListJSON(TSQLrecette, '');
    p := TSynMustachePartials.Create;
    partialHeader := StringFromFile('Views/header.partial');
    partialFooter := StringFromFile('Views/footer.partial');
    default := StringFromFile('Views/Default.html');

    if (partialHeader = '') or (partialFooter = '') or (default = '') then
      raise Exception.Create('Erreur chargement template');

    p.Add('header', partialHeader);
    p.Add('footer', partialFooter);

    mustache := TSynMustache.Parse(default);
    html := mustache.RenderJSON('{listeRecette:'+js+'}',[],[], p);
    Ctxt.Returns(html, HTML_SUCCESS, HTML_CONTENT_TYPE_HEADER);

  finally
    p.Free;
  end;
end;
*)

procedure TCookBookServer.allRecette(Ctxt: TSQLRestServerURIContext);
var
  js: RawJSON;
begin
  js := RetrieveListJSON(TSQLrecette, '');
  Ctxt.Returns(js, HTML_SUCCESS, JSON_CONTENT_TYPE_HEADER);
end;

procedure TCookBookServer.allCategories(Ctxt: TSQLRestServerURIContext);
var
  idCat, i: integer;
  tabCat, tabRecette: variant;
  listCat, listRecette: PDocVariantData;
  sl: TRawUTF8List;
  jsRecette, jsCat, rs: RawUTF8;
  aCat: PDocVariantData;
  aRec: PDocVariantData;
  count: PDocVariantData;
  numCount: Int64;
begin
  RetrieveListJSON(TSQLCategorie, '');
  idCat:= -1;
  jsRecette := '';
  if Ctxt.InputExists['idCat'] then
  begin
    idCat := Ctxt.Input['idCat'];
    tabRecette := RetrieveDocVariantArray(TSQLRecette, '', 'Categorie = ?', [idCat], '');
		if not VarIsEmptyOrNull(tabRecette) then
    begin
      listRecette := DocVariantData(tabRecette);
      sl := TRawUTF8List.create;
      try
        for i := 0 to listRecette.Count-1 do
        begin
          aRec := listRecette._[i];
      	  sl.Add(FormatUTF8('{"ID": %, "name": "%", "IDCat": "%"}', [aRec.U['ID'], aRec.U['Name'], aRec.I['Categorie']]) );
        end;
        jsRecette := FormatUTF8('%', [sl.GetText(',')]);
      finally
    	  sl.Free;
      end;
    end;
  end;

  tabCat := RetrieveDocVariantArray(TSQLCategorie, '', '', [], '');
  listCat := DocVariantData(tabCat);
  sl := TRawUTF8List.create;
  try
    for i := 0 to listCat.Count-1 do
    begin
    	aCat := listCat._[i];
      rs := EngineList(FormatUTF8('select count(*) as count from Recette where Categorie = %', [aCat.I['ID']]));
      count := DocVariantData(TDocVariant.NewJSON(rs));
      numCount := count._[0].I['count'];
      if aCat.I['ID'] = idCat then
	      sl.Add(FormatUTF8('{"ID": %, "name": "%", "count": %, "recettes": [%]}', [aCat.U['ID'], aCat.U['nom'], numCount, jsRecette]))
      else begin
	    	sl.Add(FormatUTF8('{"ID": %, "name": "%", "count": %, "recettes": []}', [aCat.U['ID'], aCat.U['nom'], numCount]) );
      end;
    end;
    jsCat := FormatUTF8('[%]', [sl.GetText(',')], [], true);
  finally
  	sl.Free;
  end;

  Ctxt.Returns(jsCat, HTML_SUCCESS, JSON_CONTENT_TYPE_HEADER);
end;

procedure TCookBookServer.allCategoriesTest(Ctxt: TSQLRestServerURIContext);
var
	j: variant;
  doc: PDocVariantData;
begin
  j := TDocVariant.NewJSON('[{ID: 1, nom: "catégorie 1", recettes: [{name:"Poulet"}, {name:"Thon"}]},'+
  												  '{ID: 2, nom: "catégorie 2", recettes: [ {name:"gateau"}]}]');
  doc := DocVariantData(j);
  Ctxt.Returns(doc.ToJSON, HTML_SUCCESS, JSON_CONTENT_TYPE_HEADER);
end;

procedure TCookBookServer.CategoriesDetails(Ctxt: TSQLRestServerURIContext);
begin
  Ctxt.Returns('liste des categories', HTML_SUCCESS);
end;

procedure TCookBookServer.newRecette(Ctxt: TSQLRestServerURIContext);
var
  sv: TCookBookServices;
  aCat: TSQLCategorie;
  Rec: TSQLRecette;
  isOk: Boolean;
  newId: TID;
  bl: RawUTF8;
  multiPart: TMultiPartDynArray;
  nom: String;
  imageStr, CatName: RawByteString;
begin
  sv := TCookBookServices.Create;
  aCat := TSQLCategorie.Create();
  Ctxt.InputAsMultiPart(multiPart);
  CatName := multiPart[0].Content;
  if self.Retrieve('nom = ?', [], [CatName], aCat) then
  begin
    try
      Rec := sv.newRecette(multiPart[1].FileName, '', nil, aCat);
      Rec.Categorie := aCat.AsTSQLRecord;
      newID := self.Add(Rec, true);

      imageStr := multiPart[1].Content;

      self.UpdateBlob(TSQLRecette, newId, 'image', imageStr);

    finally
      Rec.Free;
    end;
    Ctxt.Returns('{"status": "ok"}', HTML_SUCCESS, JSON_CONTENT_TYPE_HEADER);
  end else
    Ctxt.Returns('{"status": "ko"}', HTML_SERVERERROR, JSON_CONTENT_TYPE_HEADER);
  sv.Free;

end;

end.

