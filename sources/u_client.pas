unit U_Client;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  contnrs,
  mORMot,
  U_Model,
  Controls;

type
  TDtoNode = (dnRecette, dnCategorie);
  TDtoRecette = class(TObject)
  public
    id: TID;
    nom: string;
    typeNode: TDtoNode;
  end;

  function byCat(Item1, Item2: Pointer): Integer;

implementation

uses
  mORMotHttpClient,
  fileUtil;

{ TListDtoRecette }

function byCat(Item1, Item2: Pointer): Integer;
var
  c1: TSQLCategorie;
  c2: TSQLCategorie;
begin
  result := -1;
end;

end.

