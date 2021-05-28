unit Favorites;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sGroupBox, Vcl.ExtCtrls,
  sSplitter, Vcl.ComCtrls, sTrackBar, Vcl.Mask, sMaskEdit, sCustomComboEdit,
  sCurrEdit, Vcl.OleCtrls, SHDocVw, acWebBrowser, sScrollBox, CarPanel, sButton;

type
  TFormFavs = class(TForm)
    scrlboxFavs: TsScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFavs: TFormFavs;
  FavsInfoPanel: array of TCarPanel;
  FavCurrPanel: integer;
implementation

{$R *.dfm}

uses AutoMag;

procedure SetStartCarts(CartLst: TCarList; var Panels: array of TCarPanel);
var
  PCarCart: TPCar;
  i: Integer;
begin
  PCarCart := CartLst.PFirstCar;
  while PCarCart <> nil do
  begin
    for i := 0 to FavsAmount - 1 do
      if IsCarEqual(PCarCart^.CarInfo, Panels[i].LinkedCar) then
      begin
        Panels[i].sbtnBuyCar.Down := true;
        Panels[i].sbtnBuyCar.Caption := 'IN CART'
      end;
    PCarCart := PCarCart^.PNextCar;
  end;
end;

procedure TFormFavs.FormClose(Sender: TObject; var Action: TCloseAction);
var
  pnlFavsCount, pnlMainCount: Integer;
begin
  for pnlFavsCount := 0 to High(FavsInfoPanel) do
  begin
    if FavsInfoPanel[pnlFavsCount].imgFav.ImageIndex = 1 then
      for pnlMainCount := 0 to CarsAmount - 1 do
        if IsCarEqual(FavsInfoPanel[pnlFavsCount].LinkedCar, CarInfoPanel[pnlMainCount].LinkedCar) then
          CarInfoPanel[pnlMainCount].imgFav.ImageIndex := 1;
  end;
end;

procedure TFormFavs.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FavCurrPanel := 0;
  scrlboxFavs.VertScrollBar.Range := FavsAmount * 315;
  SetLength(FavsInfoPanel, FavsAmount);
  ShowCars(ListCarFav, FavCurrPanel, FavsInfoPanel, FormFavs.scrlboxFavs, 0);
  for i := 0 to FavsAmount - 1 do
    FavsInfoPanel[i].imgFav.ImageIndex := 2;
  SetStartCarts(ListCarCart, FavsInfoPanel);
end;

end.
