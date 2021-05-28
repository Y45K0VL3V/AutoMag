unit AutoMag;

{
  ==============[SOFTWARE IMPLEMENTATION TOOL]=======
  ===================[AUTO MAGAZINE]=================
  Author: Yakovlev Vadim gr.051004
}


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Help, CarCreate, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, sSkinManager, Vcl.Mask, sMaskEdit,
  sCustomComboEdit, sComboBox, sComboBoxes, sSkinProvider, Vcl.Grids, Data.DB,
  Vcl.DBGrids, acDBGrid, CarPanel, sLabel, System.ImageList, Vcl.ImgList,
  acAlphaImageList, sButton, sBitBtn, sScrollBox, sPanel, sGroupBox;

type
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    trlHelp: TMenuItem;
    PanelControl: TPanel;
    btnCarCreate: TButton;
    btnCartEnter: TButton;
    btnFavEnter: TButton;
    SkinChange: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    lstImgCartnFav: TsAlphaImageList;
    slblNoCars: TsLabel;
    scrlboxCars: TsScrollBox;
    spnlSortFilt: TsPanel;
    srgrSort: TsRadioGroup;
    slblSortFilt: TsLabel;
    sbtnShow: TsButton;
    scmbBrand: TsComboBox;
    scmbYear: TsComboBox;
    scmbPower: TsComboBox;
    scmbDriveUnit: TsComboBox;
    scmbTransm: TsComboBox;
    scmbFuelType: TsComboBox;
    sbtnClearFilt: TsButton;
    scmbPrice: TsComboBox;
    procedure trlHelpClick(Sender: TObject);
    procedure btnCarCreateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFavEnterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCartEnterClick(Sender: TObject);
    procedure spnlSortFiltMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbtnShowClick(Sender: TObject);
    procedure sbtnClearFiltClick(Sender: TObject);

  private
    { Private declarations }
  public
  end;

  TPCar = ^TCarListElem;

  TCarListElem = record
    CarInfo: TCar;
    PNextCar: TPCar;
  end;

  TCarList = record
    PFirstCar, PLastCar: TPCar;
  end;

  TCarArray = array of TCar;

  Function IsCarEqual(Car1, Car2: TCar): Boolean;
  procedure OneAddListOnShow(Car: TCar);
  procedure SetCarOnPanel(var CarPanel: TCarPanel; var CurrPanel: Integer; Car: TPCar; PanelOwner: TComponent; Skip: Integer);
  procedure ShowCars(const CarLst: TCarList; var CurrPanel: Integer; var CarPanels: array of TCarPanel; PanelOwner: TComponent; Skip: Integer);
  procedure AddCarToList(var CarLst: TCarList; const CurrCar: TCar);
  procedure DeleteCarFromList(var CarLst: TCarList; const CurrCar: TCar);
  procedure ClearPanels(var Panels: array of TCarPanel; var CurrPnl, AmountPnl: Integer);

var
  FormMain: TFormMain;
  CarInfoPanel: array of TCarPanel;
  CurrPanel: Integer = 0;
  CurrPanelFilt: Integer = 0;
  FileCar, FileFav, FileCart: TCarFile;
  ListCar, ListCarFav, ListCarCart, ListFilter: TCarList;
  CarsAmount: Integer;
  FiltCarsAmount: Integer;
  FavsAmount: Integer = 0;
  CartAmount: Integer = 0;

implementation

{$R *.dfm}

uses Favorites, Cart;

procedure SetcmbBrands();
var
  PCar: TPCar;
begin
  FormMain.scmbBrand.Items.Clear;
  PCar := ListCar.PFirstCar;
  while PCar <> nil do
  begin
    if FormMain.scmbBrand.Items.IndexOf(PCar^.CarInfo.Brand) = -1 then
      FormMain.scmbBrand.Items.Add(PCar^.CarInfo.Brand);
    PCar := PCar^.PNextCar;
  end;
end;

procedure ClearPanels(var Panels: array of TCarPanel; var CurrPnl, AmountPnl: Integer);
var
  i: Integer;
begin
  for i := 0 to AmountPnl - 1 do
    Panels[i].Destroy;
  CurrPnl := 0;
end;

procedure SetStartFavs(FavsLst: TCarList; var Panels: array of TCarPanel);
var
  PCarFav: TPCar;
  i: Integer;
begin
  PCarFav := FavsLst.PFirstCar;
  while PCarFav <> nil do
  begin
    for i := 0 to CarsAmount - 1 do
      if IsCarEqual(PCarFav^.CarInfo, Panels[i].LinkedCar) then
        Panels[i].imgFav.ImageIndex := 2;
    PCarFav := PCarFav^.PNextCar;
  end;
end;

procedure SetStartCarts(CartLst: TCarList; var Panels: array of TCarPanel);
var
  PCarCart: TPCar;
  i: Integer;
begin
  PCarCart := CartLst.PFirstCar;
  while PCarCart <> nil do
  begin
    for i := 0 to CarsAmount - 1 do
      if IsCarEqual(PCarCart^.CarInfo, Panels[i].LinkedCar) then
      begin
        Panels[i].sbtnBuyCar.Down := true;
        Panels[i].sbtnBuyCar.Caption := 'IN CART'
      end;
    PCarCart := PCarCart^.PNextCar;
  end;
end;

procedure WriteListToFile(var Lst: TCarList; var TypeFile: TCarFile);
var
  PCar: TPCar;
begin
  Rewrite(TypeFile);
  Seek(TypeFile, 0);
  PCar := Lst.PFirstCar;
  while PCar <> nil do
  Begin
    Write(TypeFile, PCar.CarInfo);
    PCar := PCar^.PNextCar;
  End;
end;

Function IsCarEqual(Car1, Car2: TCar): Boolean;
Begin
  if (Car1.Brand = Car2.Brand)
     and (Car1.Model = Car2.Model)
     and (Car1.Year = Car2.Year)
     and (Car1.Color = Car2.Color)
     and (Car1.Mileage = Car2.Mileage)
     and (Car1.Power = Car2.Power)
     and (Car1.EngineVol = Car2.EngineVol)
     and (Car1.AverFuelRate = Car2.AverFuelRate)
     and (Car1.Acceler100 = Car2.Acceler100)
     and (Car1.Dimensions.Length = Car2.Dimensions.Length)
     and (Car1.Weight = Car2.Weight)
     and (Car1.Price = Car2.Price)
     and (Car1.Dimensions.Width = Car2.Dimensions.Width)
     and (Car1.Dimensions.Height = Car2.Dimensions.Height)
     and (Car1.HolderName = Car2.HolderName)
     and (Car1.Contacts = Car2.Contacts)
     and (Car1.Email = Car2.Email)
     and (Car1.Fuel = Car2.Fuel)
     and (Car1.Transm = Car2.Transm)
     and (Car1.DriveUnit = Car2.DriveUnit) then
    Result := true
  else
    Result := false;
End;

procedure InitList(var CarLst: TCarList);
begin
  CarLst.PFirstCar := nil;
  CarLst.PLastCar := nil;
end;

procedure AddCarToList(var CarLst: TCarList; const CurrCar: TCar);
var
  PCurrCar: TPCar;
begin
  New(PCurrCar);
  PCurrCar^.CarInfo := CurrCar;
  PCurrCar^.PNextCar := nil;
  if CarLst.PFirstCar = nil then
    CarLst.PFirstCar := PCurrCar
  else
    CarLst.PLastCar^.PNextCar := PCurrCar;
  CarLst.PLastCar := PCurrCar;
end;

procedure DeleteCarFromList(var CarLst: TCarList; const CurrCar: TCar);
var
  PCar: TPCar;
begin
  PCar := CarLst.PFirstCar;
  if IsCarEqual(PCar^.CarInfo, CurrCar) then
  Begin
    CarLst.PFirstCar := CarLst.PFirstCar.PNextCar;
    Dispose(PCar);
  End
  Else
  Begin
    while not IsCarEqual(PCar^.PNextCar^.CarInfo, CurrCar) do
    Begin
      PCar := PCar^.PNextCar;
    End;
    if PCar^.PNextCar = CarLst.PLastCar then
      CarLst.PLastCar := PCar;
    Dispose(PCar^.PNextCar);
    PCar^.PNextCar := PCar^.PNextCar^.PNextCar;
  End;
end;

procedure ReadFileToList(const FileOfCars: TCarFile; var CarLst: TCarList);
var
  Car: TCar;
Begin
  while not EOF(FileOfCars) do
  Begin
    Read(FileOfCars, Car);
    AddCarToList(CarLst, Car);
  End;
End;

procedure SetCarOnPanel(var CarPanel: TCarPanel; var CurrPanel: Integer; Car: TPCar; PanelOwner: TComponent; Skip: Integer);
begin
  CarPanel := TCarPanel.Create(PanelOwner);
  CarPanel.BevelOuter := bvLowered;
  CarPanel.SetAllComps(Car^.CarInfo);

  with CarPanel do
  Begin
    Parent := (PanelOwner as TWinControl);
    Left := -1;
    Top := Skip + CurrPanel * 315;
    Height := 276;
    Width := 1124;
  End;
  Inc(CurrPanel);
end;

procedure ShowCars(const CarLst: TCarList; var CurrPanel: Integer; var CarPanels: array of TCarPanel; PanelOwner: TComponent; Skip: Integer);
var
  PCar: TPCar;
begin
  PCar := CarLst.PFirstCar;
  while PCar <> nil do
  begin
    SetCarOnPanel(CarPanels[CurrPanel], CurrPanel, PCar, PanelOwner, Skip);
    PCar := PCar^.PNextCar;
  end;
  SetStartFavs(ListCarFav, CarInfoPanel);
  SetStartCarts(ListCarCart, CarInfoPanel);
end;

procedure OneAddListOnShow(Car: TCar);
begin
  FormMain.scrlboxCars.VertScrollBar.Range := FormMain.scrlboxCars.VertScrollBar.Range + 315;
  Inc(CarsAmount);
  SetLength(CarInfoPanel, CarsAmount);

  AddCarToList(ListCar, Car);
  SetCarOnPanel(CarInfoPanel[CurrPanel], CurrPanel, ListCar.PLastCar, FormMain.scrlboxCars, 100);
end;

procedure TFormMain.btnCarCreateClick(Sender: TObject);
begin
  Application.CreateForm(TFormCarCreate, FormCarCreate);
  FormCarCreate.Position := poScreenCenter;
  FormCarCreate.ActiveControl := nil;
  FormCarCreate.ShowModal;
end;

procedure TFormMain.btnCartEnterClick(Sender: TObject);
begin
  if CartAmount <> 0 then
  Begin
    Application.CreateForm(TFormCart, FormCart);
    FormCart.Position := poScreenCenter;
    FormCart.DoubleBuffered := true;
    FormCart.ShowModal;
  End
  Else
    MessageBox(handle, PChar('Cart is clear :('), PChar('Favorites'), MB_OK + MB_ICONINFORMATION);
end;

procedure TFormMain.btnFavEnterClick(Sender: TObject);
begin
  if FavsAmount <> 0 then
  Begin
    Application.CreateForm(TFormFavs, FormFavs);
    FormFavs.Position := poScreenCenter;
    FormFavs.DoubleBuffered := true;
    FormFavs.ShowModal;
  End
  Else
    MessageBox(handle, PChar('You have no favorites :('), PChar('Favorites'), MB_OK + MB_ICONINFORMATION);
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteListToFile(ListCarFav, FileFav);
  WriteListToFile(ListCar, FileCar);
  WriteListToFile(ListCarCart, FileCart);
  CloseFile(FileCar);
  CloseFile(FileFav);
  CloseFile(FileCart);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  PanelControl.BringToFront;
  InitList(ListCar);
  InitList(ListCarFav);
  InitList(ListCarCart);
  DoubleBuffered := true;
  AssignFile(FileCar, '../../CarPh/CarList');
  if FileExists('../../CarPh/CarList') then
    Reset(FileCar)
  else
    Rewrite(FileCar);

  AssignFile(FileFav, '../../CarPh/FavList');
  if FileExists('../../CarPh/FavList') then
    Reset(FileFav)
  else
    Rewrite(FileFav);

  AssignFile(FileCart, '../../CarPh/CartList');
  if FileExists('../../CarPh/CartList') then
    Reset(FileCart)
  else
    Rewrite(FileCart);

  ReadFileToList(FileCart,ListCarCart);
  ReadFileToList(FileCar, ListCar);
  ReadFileToList(FileFav, ListCarFav);
  CarsAmount := FileSize(FileCar);
  FavsAmount := FileSize(FileFav);
  CartAmount := FileSize(FileCart);
  SetLength(CarInfoPanel, CarsAmount);
  scrlboxCars.VertScrollBar.Range := 315 * CarsAmount + 100;

  if CarsAmount <> 0 then
    ShowCars(ListCar, CurrPanel, CarInfoPanel, FormMain.scrlboxCars, 100)
  else
  begin
    slblNoCars.BringToFront;
    slblNoCars.Visible := true;
  end;
end;

Function CheckFilters(): Boolean;
begin
  Result := true;
  with FormMain do
    if (scmbBrand.ItemIndex = -1)
       and (scmbYear.ItemIndex = -1)
       and (scmbPower.ItemIndex = -1)
       and (scmbDriveUnit.ItemIndex = -1)
       and (scmbTransm.ItemIndex = -1)
       and (scmbFuelType.ItemIndex = -1)
       and (scmbPrice.ItemIndex = -1)
       and (srgrSort.ItemIndex = -1)  then
      Result := false;

end;

procedure FilteringList(ListToFilter: TCarList);

  procedure FiltModel(Brand: string);
  var
    PCar: TPCar;
  begin
    PCar := ListCar.PFirstCar;
    if not Brand.IsEmpty then
    begin
      while PCar <> nil do
      begin
        if PCar^.CarInfo.Brand = Brand then
        begin
          AddCarToList(ListFilter, PCar^.CarInfo);
          Inc(FiltCarsAmount);
        end;
        PCar := PCar^.PNextCar;
      end;
    end
    else
      while PCar <> nil do
      begin
        AddCarToList(ListFilter, PCar^.CarInfo);
        Inc(FiltCarsAmount);
        PCar := PCar^.PNextCar;
      end;
  end;

  procedure FiltYear(LeftYear, RightYear: Integer);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if (PCar^.CarInfo.Year > RightYear) or (PCar^.CarInfo.Year < LeftYear) then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

  procedure FiltPower(LeftPower, RightPower: Integer);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if (PCar^.CarInfo.Power > RightPower) or (PCar^.CarInfo.Power < LeftPower) then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

  procedure FiltDriveUnit(DriveUnit: string);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if PCar^.CarInfo.DriveUnit <> DriveUnit then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

  procedure FiltTransm(Transm: string);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if PCar^.CarInfo.Transm <> Transm then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

  procedure FiltFuelType(Fuel: string);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if PCar^.CarInfo.Fuel <> Fuel then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

  procedure FiltPrice(LeftPrice, RightPrice: Integer);
  var
    PCar: TPCar;
  begin
    PCar := ListFilter.PFirstCar;
    while PCar <> nil do
    begin
      if (PCar^.CarInfo.Price > RightPrice) or (PCar^.CarInfo.Price < LeftPrice) then
      begin
        DeleteCarFromList(ListFilter, PCar^.CarInfo);
        Dec(FiltCarsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;
  end;

var
  PCar: TPCar;
  i: Integer;
begin
  with FormMain do
  begin
    if scmbBrand.ItemIndex <> -1 then
    begin
      FiltModel(scmbBrand.Text);
    end
    else
      FiltModel('');

    if scmbYear.ItemIndex <> -1 then
    begin
      case scmbYear.ItemIndex of
        0: FiltYear(2019, 2021);
        1: FiltYear(2015, 2018);
        2: FiltYear(2010, 2014);
        3: FiltYear(2005, 2009);
        4: FiltYear(2000, 2004);
        5: FiltYear(1995, 1999);
        6: FiltYear(1980, 1994);
        7: FiltYear(1800, 1979);
      end;
    end;

    if scmbPower.ItemIndex <> -1 then
    begin
      case scmbPower.ItemIndex of
        0: FiltPower(1001, 10000);
        1: FiltPower(750, 1000);
        2: FiltPower(500, 749);
        3: FiltPower(350, 499);
        4: FiltPower(250, 349);
        5: FiltPower(150, 249);
        6: FiltPower(0, 150);
      end;
    end;

    if scmbDriveUnit.ItemIndex <> -1 then
    begin
      FiltDriveUnit(scmbDriveUnit.Text);
    end;
    if scmbTransm.ItemIndex <> -1 then
    begin
      FiltTransm(scmbTransm.Text);
    end;
    if scmbFuelType.ItemIndex <> -1 then
    begin
      FiltFuelType(scmbFuelType.Text);
    end;

    if scmbPrice.ItemIndex <> -1 then
    begin
      case scmbPrice.ItemIndex of
        0: FiltPrice(1000001, 99999999);
        1: FiltPrice(750000, 1000000);
        2: FiltPrice(500000, 749999);
        3: FiltPrice(250000, 499999);
        4: FiltPrice(150000, 249999);
        5: FiltPrice(90000, 149999);
        6: FiltPrice(60000, 89999);
        7: FiltPrice(30000, 59999);
        8: FiltPrice(10000, 29999);
        9: FiltPrice(0, 9999);
      end;
    end;
  end;
end;

procedure SortingList(var ListToSort: TCarList; SortInd: Integer);
var
  PCar, PCar2: TPCar;
  Arr: TCarArray;
  TempList: TCarList;
  i, j: Integer;
begin
  PCar := ListToSort.PFirstCar;

  SetLength(Arr, FiltCarsAmount + 1);
  i := 1;
  while PCar <> nil do
  begin
    case SortInd of
      0: Arr[i] := PCar^.CarInfo;
      1: Arr[i] := PCar^.CarInfo;
      2: Arr[i] := PCar^.CarInfo;
      3: Arr[i] := PCar^.CarInfo;
      4: Arr[i] := PCar^.CarInfo;
      5: Arr[i] := PCar^.CarInfo;
    end;
    Inc(i);
    PCar := PCar^.PNextCar
  end;

  For i := 2 to Length(Arr) - 1 do
    Begin
      Arr[0] := Arr[i];
      j := i - 1;

      case SortInd of
        0:
        begin
          While (Arr[j].Price < Arr[0].Price) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;
        1:
        begin
          While (Arr[j].Price < Arr[0].Price) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;
        2:
        begin
          While (Arr[j].Power < Arr[0].Power) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;
        3:
        begin
          While (Arr[j].Power < Arr[0].Power) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;
        4:
        begin
          While (Arr[j].Year < Arr[0].Year) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;
        5:
        begin
          While (Arr[j].Year < Arr[0].Year) and (j >= 0) do
          Begin
            Arr[j + 1] := Arr[j];
            j := j - 1;
          End;
        end;

      end;
      Arr[j + 1] := Arr[0];
    End;

  if SortInd mod 2 = 0 then
    for i := 1 to Length(Arr) - 1 do
      AddCarToList(TempList, Arr[i])
  else
    for i := Length(Arr) - 1 downto 1 do
      AddCarToList(TempList, Arr[i]);

  ListToSort.PFirstCar := TempList.PFirstCar;
end;

procedure TFormMain.sbtnShowClick(Sender: TObject);
begin
  if CheckFilters() then
  begin
    if CurrPanel <> 0 then
      ClearPanels(CarInfoPanel, CurrPanel, CarsAmount)
    else
      ClearPanels(CarInfoPanel, CurrPanelFilt, FiltCarsAmount);
    FiltCarsAmount := 0;
    InitList(ListFilter);
    FilteringList(ListFilter);
    if srgrSort.ItemIndex <> -1 then
      SortingList(ListFilter, srgrSort.ItemIndex);
    ShowCars(ListFilter, CurrPanelFilt, CarInfoPanel, FormMain.scrlboxCars, 100);
    if FiltCarsAmount = 0 then
      slblNoCars.Visible := true
    else
      slblNoCars.Visible := false;
    scrlboxCars.VertScrollBar.Range := 100 + 315 * FiltCarsAmount;

    if FiltCarsAmount <> 0 then
    begin
      slblSortFilt.Visible := true;
      scmbBrand.Visible := false;
      scmbYear.Visible := false;
      scmbPower.Visible := false;
      scmbTransm.Visible := false;
      scmbDriveUnit.Visible := false;
      scmbFuelType.Visible := false;
      scmbPrice.Visible := false;
      srgrSort.Visible := false;
    end
    else
    begin
      slblSortFilt.Visible := false;
      scmbBrand.Visible := true;
      scmbYear.Visible := true;
      scmbPower.Visible := true;
      scmbTransm.Visible := true;
      scmbDriveUnit.Visible := true;
      scmbFuelType.Visible := true;
      scmbPrice.Visible := true;
      srgrSort.Visible := true;
    end;

  end;

end;

procedure TFormMain.sbtnClearFiltClick(Sender: TObject);
var
  i: Integer;
begin
  scmbBrand.ItemIndex := -1;
  scmbYear.ItemIndex := -1;
  scmbPower.ItemIndex := -1;
  scmbDriveUnit.ItemIndex := -1;
  scmbTransm.ItemIndex := -1;
  scmbFuelType.ItemIndex := -1;
  scmbPrice.ItemIndex := -1;
  srgrSort.ItemIndex := -1;

  if (FiltCarsAmount <> 0) or ((FiltCarsAmount = 0) and (CurrPanel = 0)) then
  begin
    ClearPanels(CarInfoPanel, CurrPanelFilt, FiltCarsAmount);
    FiltCarsAmount := 0;
    ShowCars(ListCar, CurrPanel, CarInfoPanel, FormMain.scrlboxCars, 100);
    if FiltCarsAmount = 0 then
      slblNoCars.Visible := true
    else
      slblNoCars.Visible := false;
    scrlboxCars.VertScrollBar.Range := 100 + 315 * CarsAmount;

    slblSortFilt.Visible := true;
    scmbBrand.Visible := false;
    scmbYear.Visible := false;
    scmbPower.Visible := false;
    scmbTransm.Visible := false;
    scmbDriveUnit.Visible := false;
    scmbFuelType.Visible := false;
    scmbPrice.Visible := false;
    srgrSort.Visible := false;
  end;
end;

procedure TFormMain.spnlSortFiltMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (X >= 0) and (Y >= 0) and (X < spnlSortFilt.Width) and (Y < spnlSortFilt.Height) then
  begin
    SetcmbBrands();
    spnlSortFilt.BringToFront;
    slblSortFilt.Visible := false;
    scmbBrand.Visible := true;
    scmbYear.Visible := true;
    scmbPower.Visible := true;
    scmbTransm.Visible := true;
    scmbDriveUnit.Visible := true;
    scmbFuelType.Visible := true;
    scmbPrice.Visible := true;
    srgrSort.Visible := true;
    if GetCapture <> spnlSortFilt.Handle then
    begin
      SetCapture(spnlSortFilt.Handle);
    end;
  end
  else
  begin
    slblSortFilt.Visible := true;
    srgrSort.Visible := false;
    scmbBrand.Visible := false;
    scmbYear.Visible := false;
    scmbPower.Visible := false;
    scmbTransm.Visible := false;
    scmbDriveUnit.Visible := false;
    scmbFuelType.Visible := false;
    scmbPrice.Visible := false;
    spnlSortFilt.SendToBack;
    ReleaseCapture;
  end;
end;

procedure TFormMain.trlHelpClick(Sender: TObject);
begin
  FormHelp.Position := poScreenCenter;
  FormHelp.ShowModal;
end;

end.
