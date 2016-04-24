unit U_CookBookServices;

{$mode delphi}

interface

uses
  Classes,
  SysUtils,
  SynCommons,
  U_Model,
  mORMot;

type

  { TCookBookServices }

  TCookBookServices = class(TObject)
  public
    constructor create;
    destructor Destroy; override;
    function newRecette(nom: RawUTF8; description: RawUTF8; image: TStream; aCat: TSQLCategorie): TSQLRecette;
    function addNewRecette(client: TSQLRest; aRecette: TSQLRecette; photoFile: string): boolean;
    function addNewCategorie(client: TSQLRest; aCategorie: TSQLCategorie; aParentCat: TSQLCategorie): boolean;
    function resizeStream(stream: TStream; streamOut: TStream): boolean;
    class function changeCat(client: TSQLRest; aRec: TSQLRecette; aCat: TSQLCategorie): boolean;
    class function changeParentCat(client: TSQLRest; aCat: integer; aParentCat: integer): boolean;
    class function deleteCat(client: TSQLRestClient; aCatId: TID): boolean;
  end;

implementation

uses
  mORMotHttpClient;
  //ImagingClasses,
  //ImagingTypes;

{ TCookBookServices }

constructor TCookBookServices.create;
begin

end;

destructor TCookBookServices.Destroy;
begin
  inherited Destroy;
end;

function TCookBookServices.newRecette(nom: RawUTF8; description: RawUTF8; image: TStream; aCat: TSQLCategorie): TSQLRecette;
var
  rec: TSQLRecette;
begin
  result := nil;
  rec := TSQLRecette.Create;
  rec.Name :=  nom;
  rec.Description := description;
  rec.Categorie := aCat.AsTSQLRecord;
  result := rec;
end;

function TCookBookServices.addNewRecette(client: TSQLRest; aRecette: TSQLRecette; photoFile: string): boolean;
var
  newStream: TRawByteStringStream;
begin
  result := false;
  if client.Add(aRecette, true) <> 0 then
  begin
    try
      newStream := TRawByteStringStream.Create(StringFromFile(photoFile));
      result := client.UpdateBlob(TSQLRecette, aRecette.ID, 'Image', newStream);
    finally
      newStream.Free;
    end;
  end;
end;

function TCookBookServices.addNewCategorie(client: TSQLRest;
  aCategorie: TSQLCategorie; aParentCat: TSQLCategorie): boolean;
begin
  result := false;
  if aParentCat <> nil then
    aCategorie.parentCat := aParentCat.AsTSQLRecord;
  result := client.Add(aCategorie, true) <> 0;
end;

function TCookBookServices.resizeStream(stream: TStream; streamOut: TStream): boolean;
begin

end;

(*
function TCookBookServices.resizeStream(stream: TStream; streamOut: TStream): boolean;
var
  Image: TMultiImage;
  t: Integer;
begin
  Image := TMultiImage.CreateFromStream(stream);
  Image.Resize(80, 60, rfNearest);
  Image.SaveMultiToStream('png', stream);
  t := Image.Width;
  result := true;
end;
*)

class function TCookBookServices.changeCat(client: TSQLRest; aRec: TSQLRecette; aCat: TSQLCategorie): boolean;
begin
  result := false;
  if aRec.Name = '' then
    raise Exception.Create('Nom recette vide');
  aRec.Categorie := aCat.AsTSQLRecord;
  result := client.Update(aRec);
end;

class function TCookBookServices.changeParentCat(client: TSQLRest; aCat: integer; aParentCat: integer): boolean;
var
  cat, parentCat: TSQLCategorie;
begin
  result := false;
  cat := TSQLCategorie.Create();
  if client.Retrieve(aCat, cat) then
  begin
    parentCat := TSQLCategorie.Create(client, aParentCat) ;
    cat.parentCat := ParentCat.AsTSQLRecord;
    result := client.Update(cat);
  end;
end;

class function TCookBookServices.deleteCat(client: TSQLRestClient; aCatId: TID): boolean;
begin
  result := client.Delete(TSQLCategorie, aCatId);
end;

end.

