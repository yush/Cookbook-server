unit U_CookView;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  VirtualTrees,
  Controls,
  U_Client,
  mORMotSQLite3,
  mORMot,
  U_Model,
  contnrs,
  SynCommons,
  u_import,
  FileUtil;

type

  { Liste de toutes les categories }
  TListCategorie = class(TObjectList)
    procedure loadCategories(Client: TSQLRest);
    function getCat(aID: integer): TSQLCategorie;
  end;

  { TListNodes }
  TListNodes = class(TObjectList)
  public
    procedure addNode(aVst: TVirtualStringTree; aCat: TSQLCategorie);
    function getNodeForCat(vst: TVirtualStringTree; idCat: integer): PVirtualNode;
  end;

  { Gestion de l'affichage des categories }

  { TCategorieView }

  TCategorieView = class(TObject)
  private
    FListCat: TListCategorie;
    FCategorieVst: TVirtualStringTree;
    FListNodes: TListNodes;
  public
    constructor Create;
    destructor Destroy; override;
    procedure setCategorieVst(aVst: TVirtualStringTree);
    procedure showCategoriesVst(listCat: TListCategorie);
    procedure showCategoriesList(listCat: TListCategorie; list: TStrings);
    function getNodeForCat(aID: integer): PVirtualNode;
    function getDefaultNodeCat: PVirtualNode;
    procedure refresh(Client: TSQLRest);
    property listCat: TListCategorie read FListCat;
    property listNodes: TListNodes read FListNodes;
  end;

  { TRecetteView }
  TRecetteView = class(TObject)
  private
    FdragObject: TDragObject;
    FVst: TVirtualStringTree;
    FListNodes: TListNodes;
    FDraggedNodes: TList;
    procedure SetdragObject(AValue: TDragObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure setRecetteVst(aVst: TVirtualStringTree);
    procedure voirRecetteForCat(Client: TSQLRest; catId: integer);
    property dragObject: TDragObject read FdragObject write SetdragObject;
    property listNodes: TListNodes read FListNodes;
    property draggedNodes: TList read FDraggedNodes;
  end;


implementation

uses
  LazFileUtils,
  LazUTF8;

{ TCategorieView }

constructor TCategorieView.Create;
begin
  FListCat := TListCategorie.Create(true);
  FListNodes := TListNodes.Create(true);

end;

destructor TCategorieView.Destroy;
begin
  FListNodes.Free;
  FListCat.Free;
  inherited Destroy;
end;

procedure TCategorieView.setCategorieVst(aVst: TVirtualStringTree);
begin
  FCategorieVst := aVst;
end;

procedure TCategorieView.showCategoriesVst(listCat: TListCategorie);
var
  aCat: TSQLCategorie;
  i: integer;
begin
  FCategorieVst.Clear;
  try
    FCategorieVst.BeginUpdate;
    // affectation des sous categories
    for i := 0 to listCat.count-1 do
    begin
      aCat := TSQLCategorie(listCat.Items[i]);
      if aCat.parentCat.id > 0 then
      begin
        aCat.parentCat := listCat.getCat(aCat.parentCat.id);
      end;
    end;

    // création de l'arbre
    for i := 0 to listCat.count-1 do
    begin
      aCat := TSQLCategorie(listCat.Items[i]);
      listNodes.addNode(FCategorieVst, aCat);
    end;
  finally
    FCategorieVst.EndUpdate;
  end;
end;

procedure TCategorieView.showCategoriesList(listCat: TListCategorie;
  list: TStrings);
var
  aCat: TSQLCategorie;
  i: integer;
begin
  list.Clear;
  for i := 0 to listCat.count-1 do
  begin
    aCat := TSQLCategorie(listCat.Items[i]);
    if aCat.parentCat.id = 0 then
    begin
      list.AddObject(aCat.nom, aCat);
    end;
  end;
end;

function TCategorieView.getNodeForCat(aID: integer): PVirtualNode;
var
  n: PVirtualNode;
  dto: TDtoRecette;
begin
  n := FCategorieVst.getFirst;
  while n <> nil do
  begin
    dto := TDtoRecette(FCategorieVst.GetNodeData(n)^);
    if (dto.typeNode = dnCategorie) and (dto.id = aID) then
    begin
      result := n;
      break;
    end;
    n := FCategorieVst.GetNext(n, true);
  end;
end;

function TCategorieView.getDefaultNodeCat: PVirtualNode;
var
  n: PVirtualNode;
  dto: TDtoRecette;
begin
  n := FCategorieVst.getFirst;
  while n <> nil do
  begin
    dto := TDtoRecette(FCategorieVst.GetNodeData(n)^);
    if (dto.typeNode = dnCategorie) and (dto.nom = 'Aucune') then
    begin
      result := n;
      break;
    end;
    n := FCategorieVst.GetNext(n, true);
  end;
end;

procedure TCategorieView.refresh(Client: TSQLRest);
begin
  listCat.loadCategories(Client);
  showCategoriesVst(listCat);
end;

{ TListNodes }

procedure TListNodes.addNode(aVst: TVirtualStringTree; aCat: TSQLCategorie);
var
  dto: TDtoRecette;
  parentNode: PVirtualNode;
begin
  dto := TDtoRecette.Create;
  dto.nom := aCat.Nom;
  dto.id := aCat.ID;
  dto.typeNode := dnCategorie;
  self.add(dto);
  parentNode := getNodeForCat(aVst, aCat.parentCat.ID);
  aVst.AddChild(parentNode, dto);
end;

function TListNodes.getNodeForCat(vst: TVirtualStringTree; idCat: integer): PVirtualNode;
var
  dto: TDtoRecette;
  n: PVirtualNode;
begin
  result := nil;
  n := vst.GetFirst(true);
  while n <> nil do
  begin
    dto := TDtoRecette(vst.GetNodeData(n)^);
    if (dto.typeNode = dnCategorie) and (dto.id = idCat) then
    begin
      result := n;
      break;
    end;
    n := vst.GetNext(n, true);
  end;
end;

{ TRecetteView }

procedure TRecetteView.SetdragObject(AValue: TDragObject);
begin
  if FdragObject = AValue then Exit;
  FdragObject := AValue;
end;

constructor TRecetteView.Create;
begin
  FListNodes := TListNodes.Create(true);
  FDraggedNodes := TList.create;
end;

destructor TRecetteView.Destroy;
begin
  FDraggedNodes.Free;
  FListNodes.Free;
  inherited Destroy;
end;

procedure TRecetteView.setRecetteVst(aVst: TVirtualStringTree);
begin
  FVst := aVst;
end;

procedure TRecetteView.voirRecetteForCat(Client: TSQLRest; catId: integer);
var
  Rec: TSQLRecette;
  dto: TDtoRecette;
  n: PVirtualNode;
begin

  FVst.Clear;
  listNodes.Clear;
  FVst.BeginUpdate;
  Rec := TSQLRecette.CreateAndFillPrepare(Client,'categorie = ?', [catId], [], '');
  while Rec.FillOne do
  begin
    dto := TDtoRecette.Create;
    dto.nom := Rec.Name;
    dto.id := Rec.ID;
    dto.typeNode := dnRecette;
    FVst.AddChild(nil, dto);
    listNodes.Add(dto);
  end;
  FVst.EndUpdate;
end;

procedure TListCategorie.loadCategories(Client: TSQLRest);
var
  aCat: TSQLCategorie;
  newCat: TSQLCategorie;
begin
  clear;
  aCat := TSQLCategorie.CreateAndFillPrepare(Client,'');
  while aCat.FillOne do
  begin
    newCat := TSQLCategorie.Create(Client, aCat.ID);
    Add(newCat);
  end;
end;

function TListCategorie.getCat(aID: integer): TSQLCategorie;
var
  aCat: TSQLCategorie;
  i: integer;
begin
  for i := 0 to Count-1 do
  begin
    aCat := TSQLCategorie(items[i]);
    if aCat.ID = aID then
    begin
      result := aCat;
      break;
    end;
  end;
end;


end.

