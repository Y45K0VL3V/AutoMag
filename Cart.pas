unit Cart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.DBCGrids, acDBCtrlGrid, Vcl.Grids,
  Vcl.StdCtrls, sLabel;

type
  TFormCart = class(TForm)
    strgridCart: TStringGrid;
    slblTotalPrice: TsLabel;
    stxtTotal: TStaticText;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCart: TFormCart;

implementation

{$R *.dfm}

uses AutoMag;



procedure SetCars();
var
  PCar: TPCar;
  CurrCol: Integer;
  Total: Integer;
  img: TPicture;
begin
  Total := 0;
  PCar := ListCarCart.PFirstCar;
  For CurrCol := 1 to CartAmount do
  begin
    with FormCart.strgridCart do
    begin
      Cells[CurrCol,1] := PCar^.CarInfo.Brand;
      Cells[CurrCol,2] := PCar^.CarInfo.Model;
      Cells[CurrCol,3] := IntToStr(PCar^.CarInfo.Year);
      Cells[CurrCol,4] := IntToStr(PCar^.CarInfo.Mileage);
      Cells[CurrCol,5] := IntToStr(PCar^.CarInfo.Power);
      Cells[CurrCol,6] := FloatToStr(PCar^.CarInfo.AverFuelRate);
      Cells[CurrCol,7] := FloatToStr(PCar^.CarInfo.EngineVol);
      Cells[CurrCol,8] := FloatToStr(PCar^.CarInfo.Acceler100);
      Cells[CurrCol,9] := PCar^.CarInfo.Transm;
      Cells[CurrCol,10] := PCar^.CarInfo.Fuel;
      Cells[CurrCol,11] := PCar^.CarInfo.DriveUnit;
      Cells[CurrCol,12] := IntToStr(PCar^.CarInfo.Price);
      Cells[CurrCol,13] := IntToStr(PCar^.CarInfo.Dimensions.Length);
      Cells[CurrCol,14] := IntToStr(PCar^.CarInfo.Dimensions.Width);
      Cells[CurrCol,15] := IntToStr(PCar^.CarInfo.Dimensions.Height);
      Cells[CurrCol,16] := IntToStr(PCar^.CarInfo.Weight);
      Cells[CurrCol,17] := PCar^.CarInfo.Color;
    end;
    Inc(Total, PCar^.CarInfo.Price);
    PCar := PCar^.PNextCar;
  end;
  FormCart.slblTotalPrice.Caption := IntToStr(Total) + '$';
end;

procedure TFormCart.FormCreate(Sender: TObject);
begin
  strGridCart.ColCount := CartAmount + 1;
  with strgridCart do
  begin
    Cells[0,1] := 'Brand';
    Cells[0,2] := 'Model';
    Cells[0,3] := 'Year';
    Cells[0,4] := 'Mileage';
    Cells[0,5] := 'Power';
    Cells[0,6] := 'Average fuel';
    Cells[0,7] := 'Engine volume';
    Cells[0,8] := '0 - 100 km/h';
    Cells[0,9] := 'Transmission';
    Cells[0,10] := 'Fuel type';
    Cells[0,11] := 'Drive unit';
    Cells[0,12] := 'Price';
    Cells[0,13] := 'Length';
    Cells[0,14] := 'Width';
    Cells[0,15] := 'Height';
    Cells[0,16] := 'Weight';
    Cells[0,17] := 'Color';
  end;
  SetCars();
end;


end.
