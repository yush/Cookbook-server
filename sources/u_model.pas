/// it's a good practice to put all data definition into a stand-alone unit
// - this unit will be shared between client and server
unit U_Model;

interface

uses
  SynCommons,
  mORMot;

type
  /// here we declare the class containing the data
  // - it just has to inherits from TSQLRecord, and the published
  // properties will be used for the ORM (and all SQL creation)
  // - the beginning of the class name must be 'TSQL' for proper table naming
  // in client/server environnment

  TSQLCategorie = class;

  { TSQLRecette }

  TSQLRecette = class(TSQLRecord)
  private
    FCategorie: TSQLCategorie;
    fImage: TSQLRawBlob;
    fDescription: RawUTF8;
    fName: RawUTF8;
    fTime: TModTime;
  published
    property Time: TModTime read FTime write FTime;
    property Name: RawUTF8 read FName write FName;
    property Description: RawUTF8 read FDescription write FDescription;
    property Categorie: TSQLCategorie read FCategorie write FCategorie;
    property Image: TSQLRawBlob read fImage write fImage;

  end;

  { TSQLCategorie }

  TSQLCategorie = class(TSQLRecord)
  private
    FNom: RawUTF8;
    FParentCat: TSQLCategorie;
  published
    property nom: RawUTF8 read FNom write FNom;
    property parentCat: TSQLCategorie read FParentCat write FParentCat;
  end;

implementation


end.
