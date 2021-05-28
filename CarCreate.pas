unit CarCreate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.Grids, Vcl.ValEdit, Vcl.ExtDlgs, JPEG, Magazine, sPanel,
  acSlider, sButton, acAlphaImageList, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList, Vcl.ImgList,
  Vcl.Buttons, sSpeedButton, acImage, acPNG, sGroupBox, Vcl.ComCtrls,
  sRadioButton, Vcl.Mask, sMaskEdit, sCustomComboEdit, sComboBox, sComboBoxes,
  sScrollBar, sBitBtn, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl,
  IWControl, IWCompText, sSkinProvider, sLabel;

type

  TCarSizeParms = packed Record
      Length: Integer;
      Width: Integer;
      Height: Integer;
  End;
  TCar = packed Record
    Brand: string[20];
    Model: string[20];
    Year: Integer;
    Color: string[20];
    Mileage: Integer;
    Power: Integer;
    EngineVol: extended;
    Acceler100: extended;
    AverFuelRate: extended;
    Fuel: string[10];
    Transm: string[10];
    DriveUnit: string[20];
    Weight: Integer;
    Dimensions: TCarSizeParms;
    Price: Integer;
    HolderName: string[40];
    Contacts: string[17];
    Email: string[50];
    Images: TImageArr;
  End;

  TFormCarCreate = class(TForm)
    btnPhotoInp: TButton;
    edtBrand: TEdit;
    edtModel: TEdit;
    edtYear: TEdit;
    edtCarColor: TEdit;
    edtMileage: TEdit;
    edtPower: TEdit;
    edtEngineVol: TEdit;
    edtAverFuel: TEdit;
    edtAcceler100: TEdit;
    edtLength: TEdit;
    edtWeight: TEdit;
    edtPrice: TEdit;
    edtWidth: TEdit;
    edtHeight: TEdit;
    edtHolderName: TEdit;
    edtContacts: TEdit;
    edtEmail: TEdit;
    btnPhotoSave: TButton;
    dlgLoadPic: TOpenPictureDialog;
    cmbFuelType: TsComboBox;
    cmbTransm: TsComboBox;
    cmbDriveUnit: TsComboBox;
    btnCancelCreate: TButton;
    pnlControlCreate: TPanel;
    btnConfirmCreate: TButton;
    pnlImageLoad: TPanel;
    imgCarPhoto: TsImage;
    imgDeletePhoto: TImage;
    stxtPersInf: TStaticText;
    pnlPersInfo: TPanel;
    pnlPrice: TPanel;
    pnlDescription: TPanel;
    stxtAboutCar: TStaticText;
    stxtTechChars: TStaticText;
    stxtDimensions: TStaticText;
    stxtLoadPic: TStaticText;
    imglstButtons: TsAlphaImageList;
    bbtnSlideRight: TsBitBtn;
    bbtnSlideLeft: TsBitBtn;
    slblContacts: TsLabel;
    slblEmail: TsLabel;
    slblHolderName: TsLabel;
    slblPrice: TsLabel;
    slblModel: TsLabel;
    slblYear: TsLabel;
    slblMileage: TsLabel;
    slblLength: TsLabel;
    slblBrand: TsLabel;
    slblWidth: TsLabel;
    slblHeight: TsLabel;
    slblWeight: TsLabel;
    slblCarColor: TsLabel;
    slblPower: TsLabel;
    slblAverFuel: TsLabel;
    slblAcceler100: TsLabel;
    slblEngineVol: TsLabel;
    slblTransm: TsLabel;
    slblDriveUnit: TsLabel;
    slblFuelType: TsLabel;
    sbtnSaveChange: TsButton;
    sbtnCancelChange: TsButton;
    sbtnEditAd: TsButton;
    sbtnDeleteCar: TsButton;

    procedure btnPhotoInpClick(Sender: TObject);
    procedure btnPhotoSaveClick(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure btnConfirmCreateClick(Sender: TObject);
    procedure btnCancelCreateClick(Sender: TObject);
    procedure bbtnSlideRightClick(Sender: TObject);
    procedure bbtnSlideLeftClick(Sender: TObject);
    procedure imgDeletePhotoMouseEnter(Sender: TObject);
    procedure imgDeletePhotoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnEditAdClick(Sender: TObject);
    procedure sbtnCancelChangeClick(Sender: TObject);
    procedure sbtnSaveChangeClick(Sender: TObject);
    procedure sbtnDeleteCarClick(Sender: TObject);

  private
    { Private declarations }
  public
    function IsAllCorrect(): Boolean;
    function IsCarCreated(): Boolean;
    procedure SetInfo(Car: TCar);
  end;

  TCarFile = file of TCar;

var
  FormCarCreate: TFormCarCreate;
  CarExpl: TCar;
  CarOnPanel: TCar;
  FileCarList: TCarFile;
  ImagesAm: Integer = 0;
  CurrImg: Integer;

implementation

{$R *.dfm}

uses AutoMag, Favorites;

procedure ToClearCar();
begin
  ImagesAm := 0;
  CurrImg := 0;
  ZeroMemory(@CarExpl, SizeOf(CarExpl));
end;

function TFormCarCreate.IsCarCreated(): Boolean;
var
  PCar: TPCar;
begin
  Result := false;
  PCar := ListCar.PFirstCar;
  while (PCar <> nil) and (not Result) do
  begin
    if IsCarEqual(PCar^.CarInfo, CarExpl) then
    Begin
      Result := true;
      MessageBox(handle, PChar('Ad already created. Create other.'), PChar('Ad info'), MB_OK + MB_ICONINFORMATION);
    End;
    PCar := PCar^.PNextCar;
  end;
end;

function TFormCarCreate.IsAllCorrect(): Boolean;

  procedure GetBrandCorrect();
  Begin
    if string(edtBrand.Text).IsEmpty then
      slblBrand.UseSkinColor := false
    Else
    Begin
      slblBrand.UseSkinColor := true;
      CarExpl.Brand := edtBrand.Text;
    End;
  End;

  procedure GetModelCorrect();
  Begin
    if string(edtModel.Text).IsEmpty then
      slblModel.UseSkinColor := false
    Else
    Begin
      slblModel.UseSkinColor := true;
      CarExpl.Model := edtModel.Text;
    End;
  End;

  procedure GetYearCorrect();
  Var
    EnteredNum: Integer;
  begin
    if String(edtYear.Text).IsEmpty then
    Begin
      slblYear.UseSkinColor := false;
      exit;
    End;
    ValidInp(edtYear.Text, EnteredNum);
    if (EnteredNum < 1800) or (EnteredNum > 2021) then
      slblYear.UseSkinColor := false
    Else
    Begin
      slblYear.UseSkinColor := true;
      CarExpl.Year := EnteredNum;
    End;
  end;

  procedure GetMileageCorrect();
  begin
    if string(edtMileage.Text).IsEmpty then
    Begin
      slblMileage.UseSkinColor := false;
      exit;
    End;
      slblMileage.UseSkinColor := true;
      CarExpl.Mileage := StrToInt(edtMileage.Text);
  end;

  procedure GetLengthCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtLength.Text).IsEmpty then
    Begin
      slblLength.UseSkinColor := false;
      exit;
    End;
    ValidInp(String(edtLength.Text), EnteredNum);
    if (EnteredNum < 1000) then
      slblLength.UseSkinColor := false
    Else
    Begin
      slblLength.UseSkinColor := true;
      CarExpl.Dimensions.Length := EnteredNum;
    End;
  end;

  procedure GetWidthCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtWidth.Text).IsEmpty then
    Begin
      slblWidth.UseSkinColor := false;
      exit;
    End;
    ValidInp(String(edtWidth.Text), EnteredNum);
    if (EnteredNum < 1000) or (EnteredNum > 5000) then
      slblWidth.UseSkinColor := false
    Else
    Begin
      slblWidth.UseSkinColor := true;
      CarExpl.Dimensions.Width := EnteredNum;
    End;
  end;

  procedure GetHeightCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtHeight.Text).IsEmpty then
    Begin
      slblHeight.UseSkinColor := false;
      exit;
    End;
    ValidInp(String(edtHeight.Text), EnteredNum);
    if (EnteredNum < 1100) or (EnteredNum > 4000) then
      slblHeight.UseSkinColor := false
    Else
    Begin
      slblHeight.UseSkinColor := true;
      CarExpl.Dimensions.Height := EnteredNum;
    End;
  end;

  procedure GetWeightCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtWeight.Text).IsEmpty then
    Begin
      slblWeight.UseSkinColor := false;
      exit;
    End;
    ValidInp(String(edtWeight.Text), EnteredNum);
    if (EnteredNum < 300) or (EnteredNum > 15000) then
      slblWeight.UseSkinColor := false
    Else
    Begin
      slblWeight.UseSkinColor := true;
      CarExpl.Weight := EnteredNum;
    End;
  end;

  procedure GetCarColorCorrect();
  var
    ColorChars: set of char;
    Each: char;
  begin
    ColorChars := ['A'..'z', '-'];
    if string(edtCarColor.Text).IsEmpty then
    Begin
      slblCarColor.UseSkinColor := false;
      exit;
    End;

    for Each in edtCarColor.Text do
      if not (Each in ColorChars)then
      Begin
        slblCarColor.UseSkinColor := false;
        exit;
      End;
    slblCarColor.UseSkinColor := true;
    CarExpl.Color := edtCarColor.Text;
  end;

  procedure GetPowerCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtPower.Text).IsEmpty then
    Begin
      slblPower.UseSkinColor := false;
      exit;
    End;
    if ValidInp(String(edtPower.Text), EnteredNum) then
    Begin
      if (EnteredNum < 1) or (EnteredNum > 2000) then
        slblPower.UseSkinColor := false
      Else
      Begin
        slblPower.UseSkinColor := true;
        CarExpl.Power := EnteredNum;
      End;
    End
    Else
      slblPower.UseSkinColor := false;
  end;

  procedure GetAverFuelCorrect();
  Var
    EnteredNum: Real;
  begin
    if string(edtAverFuel.Text).IsEmpty then
    Begin
      slblAverFuel.UseSkinColor := false;
      exit;
    End;
    if ValidInp(String(edtAverFuel.Text), EnteredNum) then
    Begin
      if (EnteredNum <= 0) or (EnteredNum > 200) then
        slblAverFuel.UseSkinColor := false
      Else
      Begin
        slblAverFuel.UseSkinColor := true;
        CarExpl.AverFuelRate := EnteredNum;
      End;
    End
    Else
      slblAverFuel.UseSkinColor := false;
  end;

  procedure GetAcceler100Correct();
  Var
    EnteredNum: Real;
  begin
    if string(edtAcceler100.Text).IsEmpty then
    Begin
      slblAcceler100.UseSkinColor := false;
      exit;
    End;
    if ValidInp(String(edtAcceler100.Text), EnteredNum) then
    Begin
      if (EnteredNum < 0.1) or (EnteredNum >= 200) then
        slblAcceler100.UseSkinColor := false
      Else
      Begin
        slblAcceler100.UseSkinColor := true;
        CarExpl.Acceler100 := EnteredNum;
      End;
    End
    Else
      slblAcceler100.UseSkinColor := false;
  end;

  procedure GetEngineVolCorrect();
  Var
    EnteredNum: Real;
  begin
    if string(edtEngineVol.Text).IsEmpty then
    Begin
      slblEngineVol.UseSkinColor := false;
      exit;
    End;
    if ValidInp(String(edtEngineVol.Text), EnteredNum) then
    Begin
      if (EnteredNum < 0) or (EnteredNum >= 10) then
        slblEngineVol.UseSkinColor := false
      Else
      Begin
        slblEngineVol.UseSkinColor := true;
        CarExpl.EngineVol := EnteredNum;
      End;
    End
    Else
      slblEngineVol.UseSkinColor := false;
  end;

  procedure GetTransmCorrect();
  begin
    if cmbTransm.ItemIndex = -1 then
      slblTransm.UseSkinColor := false
    Else
    Begin
      slblTransm.UseSkinColor := true;
      CarExpl.Transm := cmbTransm.Text;
    End;
  end;

  procedure GetDriveUnitCorrect();
  begin
    if cmbDriveUnit.ItemIndex = -1 then
      slblDriveUnit.UseSkinColor := false
    Else
    Begin
      slblDriveUnit.UseSkinColor := true;
      CarExpl.DriveUnit := cmbDriveUnit.Text;
    End;
  end;

  procedure GetFuelTypeCorrect();
  begin
    if cmbFuelType.ItemIndex = -1 then
      slblFuelType.UseSkinColor := false
    Else
    Begin
      slblFuelType.UseSkinColor := true;
      CarExpl.Fuel := cmbFuelType.Text;
    End;
  end;

  procedure GetHolderNameCorrect();
  var
    Alphabet: set of char;
    Each: char;
  begin
    Alphabet := ['A'..'z', ' '];
    if string.IsNullOrWhiteSpace(edtHolderName.Text) then
    Begin
      slblHolderName.UseSkinColor := false;
      exit;
    End;

    for Each in edtHolderName.Text do
      if not (Each in Alphabet)then
      Begin
        slblHolderName.UseSkinColor := false;
        exit;
      End;
    slblHolderName.UseSkinColor := true;
    CarExpl.HolderName := edtHolderName.Text;
  end;

  procedure GetContactsCorrect();
  var
    NumberChars: set of char;
    Each: Integer;
  begin
    NumberChars := ['0' .. '9'];
    if string.IsNullOrWhiteSpace(edtContacts.Text) then
    Begin
      slblContacts.UseSkinColor := false;
      exit;
    End;

    for Each := 2 to edtContacts.GetTextLen do
      if (not (edtContacts.Text[Each] in NumberChars)) or (edtContacts.Text[1] <> '+') or (edtContacts.GetTextLen < 10) then
      Begin
        slblContacts.UseSkinColor := false;
        exit;
      End;
    slblContacts.UseSkinColor := true;
    CarExpl.Contacts := edtContacts.Text;
  end;

  procedure GetEmailCorrect();
  var
    NumberChars: set of char;
    Each: Integer;
    DogCount: Integer;
  begin
    NumberChars := ['A' .. 'z', '0' .. '9', '_', '-', '.', '@'];
    if string.IsNullOrWhiteSpace(edtEmail.Text)then
    Begin
      slblEmail.UseSkinColor := false;
      exit;
    End;

    DogCount := 0;
    for Each := 1 to edtEmail.GetTextLen do
      if edtEmail.Text[Each] = '@' then
        Inc(DogCount);

    for Each := 1 to edtEmail.GetTextLen do
    Begin
      if (not (edtEmail.Text[Each] in NumberChars)) or (edtEmail.Text[1] = '.') or (edtEmail.Text[edtEmail.GetTextLen] = '.')
          or (DogCount <> 1) then
      Begin
        slblEmail.UseSkinColor := false;
        exit;
      End;
    End;
    slblEmail.UseSkinColor := true;
    CarExpl.Email := edtEmail.Text;
  end;

  procedure GetPriceCorrect();
  Var
    EnteredNum: Integer;
  begin
    if string(edtPrice.Text).IsEmpty then
    Begin
      slblPrice.UseSkinColor := false;
      exit;
    End;
    ValidInp(String(edtPrice.Text), EnteredNum);
    slblPrice.UseSkinColor := true;
    CarExpl.Price := EnteredNum;
  end;

var
  CompIndslbl: Integer;
begin
  Result := true;
  GetBrandCorrect();
  GetModelCorrect();
  GetYearCorrect();
  GetMileageCorrect();
  GetLengthCorrect();
  GetWidthCorrect();
  GetHeightCorrect();
  GetWeightCorrect();
  GetCarColorCorrect();
  GetPowerCorrect();
  GetAverFuelCorrect();
  GetAcceler100Correct();
  GetEngineVolCorrect();
  GetTransmCorrect();
  GetDriveUnitCorrect();
  GetFuelTypeCorrect();
  GetHolderNameCorrect();
  GetContactsCorrect();
  GetEmailCorrect();
  GetPriceCorrect();
  for CompIndslbl := 0 to FormCarCreate.ComponentCount - 1 do
    if FormCarCreate.Components[CompIndslbl] is TsLabel then
      if (FormCarCreate.Components[CompIndslbl] as TsLabel).UseSkinColor = false then
      Begin
        Result := false;
        exit;
      End;
end;

procedure TFormCarCreate.sbtnCancelChangeClick(Sender: TObject);
var
  i: Integer;
begin
  SetInfo(CarExpl);
  for i := 0 to FormCarCreate.ComponentCount - 1 do
  Begin
    if FormCarCreate.Components[i] is TEdit then
      (FormCarCreate.Components[i] as TEdit).Enabled := false;
    if FormCarCreate.Components[i] is TsComboBox then
      (FormCarCreate.Components[i] as TsComboBox).Enabled := false;
  End;
  btnPhotoInp.Visible := false;
  btnPhotoSave.Visible := false;
  imgDeletePhoto.Visible := false;
  sbtnCancelChange.Enabled := false;
  sbtnEditAd.Enabled := true;
  sbtnSaveChange.Enabled := false;
  sbtnDeleteCar.Enabled := true;
end;

procedure TFormCarCreate.sbtnDeleteCarClick(Sender: TObject);
var
  btnSelected: Integer;
  PCar: TPCar;
begin
  btnSelected := MessageDlg('Do you want to delete ad?', mtWarning, mbOKCancel, 0);
  if btnSelected = mrOk then
  begin
    DeleteCarFromList(ListCar, CarOnPanel);

    PCar := ListCarFav.PFirstCar;
    while PCar <> nil do
    begin
      if IsCarEqual(PCar^.CarInfo, CarOnPanel) then
      begin
        DeleteCarFromList(ListCarFav, CarOnPanel);
        Dec(FavsAmount);
      end;
      PCar := PCar^.PNextCar;
    end;

    ClearPanels(CarInfoPanel, CurrPanel, CarsAmount);
    Dec(CarsAmount);
    FormMain.scrlboxCars.VertScrollBar.Range := FormMain.scrlboxCars.VertScrollBar.Range - 315;
    ShowCars(ListCar, CurrPanel, CarInfoPanel, FormMain.scrlboxCars, 100);
    FormCarCreate.Close;
  end;
end;

procedure TFormCarCreate.sbtnEditAdClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FormCarCreate.ComponentCount - 1 do
  begin
    if FormCarCreate.Components[i] is TEdit then
      (FormCarCreate.Components[i] as TEdit).Enabled := true;
    if FormCarCreate.Components[i] is TsComboBox then
      (FormCarCreate.Components[i] as TsComboBox).Enabled := true;
    imgDeletePhoto.Enabled := true;
    imgDeletePhoto.Visible := true;
    btnPhotoInp.Visible := true;
    btnPhotoSave.Visible := true;
    sbtnEditAd.Enabled := false;
    sbtnCancelChange.Enabled := true;
    sbtnSaveChange.Enabled := true;
    cmbTransm.ItemIndex := TransmConvert(cmbTransm.Text);
    cmbFuelType.ItemIndex := FuelTypeConvert(cmbFuelType.Text);
    cmbDriveUnit.ItemIndex := DriveUnitConvert(cmbDriveUnit.Text);
    cmbFuelType.Style := csDropDownList;
    cmbTransm.Style := csDropDownList;
    cmbDriveUnit.Style := csDropDownList;
    sbtnDeleteCar.Enabled := false;
  end;
end;

procedure TFormCarCreate.sbtnSaveChangeClick(Sender: TObject);
var
  btnSelected, i, j: Integer;
  PCar: TPCar;
begin
  if not IsAllCorrect then
  Begin
    if ImagesAm <> 0 then
      MessageBox(handle, PChar('Enter all fields correctly!'), PChar('Ad creating'), MB_OK + MB_ICONERROR)
    else
      MessageBox(handle, PChar('Enter all fields correctly and load photo!'), PChar('Ad creating'), MB_OK + MB_ICONERROR);
  End
  Else
    if ImagesAm <> 0 then
    Begin
      btnSelected := MessageDlg('Do you want to edit ad?', mtWarning, mbOKCancel, 0);
      if (btnSelected = mrOk) and (not IsCarCreated()) then
      begin
        PCar := ListCar.PFirstCar;
        while PCar <> nil do
        begin
          if IsCarEqual(PCar^.CarInfo, CarOnPanel) then
            PCar^.CarInfo := CarExpl;
          PCar := PCar^.PNextCar;
        end;

        PCar := ListCarFav.PFirstCar;
        while PCar <> nil do
        begin
          if IsCarEqual(PCar^.CarInfo, CarOnPanel) then
            PCar^.CarInfo := CarExpl;
          PCar := PCar^.PNextCar;
        end;
        for i := 0 to CarsAmount - 1 do
          if IsCarEqual(CarInfoPanel[i].LinkedCar, CarOnPanel) then
          Begin
            CarInfoPanel[i].SetInfo(CarExpl);
            CarInfoPanel[i].LinkedCar := CarExpl;
          End;

        with Screen do
          for i := 0 to FormCount - 1 do
          begin
            if Forms[i] = FormFavs then
              for j := 0 to FavsAmount - 1 do
                if IsCarEqual(FavsInfoPanel[j].LinkedCar, CarOnPanel) then
                Begin
                  FavsInfoPanel[j].SetInfo(CarExpl);
                  FavsInfoPanel[j].LinkedCar := CarExpl;
                End;
          end;
        sbtnCancelChange.Click;
      end;
    End
    Else
      MessageBox(handle, PChar('Load photo!'), PChar('Ad creating'), MB_OK + MB_ICONERROR);
end;

procedure TFormCarCreate.btnPhotoInpClick(Sender: TObject);
Var
  IsPhotoLoad: Boolean;
begin
  IsPhotoLoad := false;
  imgCarPhoto.Picture := nil;
  if dlgLoadPic.Execute then
  Begin
    stxtLoadPic.Visible := false;
    IsPhotoLoad := true;
    imgCarPhoto.Picture.LoadFromFile(dlgLoadPic.FileName);
  End
  Else
    if ImagesAm = 0 then
      stxtLoadPic.Visible := true;

  if (not IsPhotoLoad) and (ImagesAm <> 0) then
    imgCarPhoto.Picture.LoadFromFile(CarExpl.Images[CurrImg]);
  imgCarPhoto.Stretch := true;
end;

procedure TFormCarCreate.btnPhotoSaveClick(Sender: TObject);
Var
  i: Integer;
begin
  if ImagesAm + 1 > 20 then
  Begin
    MessageBox(handle, PChar('There is a limit: 20 photos. You can delete some previous.'), PChar('Car photo'), MB_OK + MB_ICONWARNING);
    exit;
  End;

  for i := 1 to ImagesAm do
    if CarExpl.Images[i] = dlgLoadPic.FileName then
    Begin
      MessageBox(handle, PChar('The picture already loaded, choose other!'), PChar('Car photo'), MB_OK + MB_ICONWARNING);
      btnPhotoInp.Click;
      exit;
    End;

  if dlgLoadPic.FileName <> '' then
  Begin
    inc(ImagesAm);
    imgDeletePhoto.Visible := true;
    imgDeletePhoto.BringToFront;

    CarExpl.Images[ImagesAm] := dlgLoadPic.FileName;
    CurrImg := ImagesAm;
  End
  Else
    MessageBox(handle, PChar('Load photo at first!'), PChar('Car photo'), MB_OK + MB_ICONWARNING);

  if ImagesAm >= 2 then
  begin
    bbtnSlideRight.Visible := true;
    bbtnSlideLeft.Visible := true;
  end;
  dlgLoadPic.FileName := '';
end;

procedure TFormCarCreate.bbtnSlideLeftClick(Sender: TObject);
begin
  if CurrImg <> 1 then
    dec(CurrImg)
  else
    CurrImg := ImagesAm;
  imgCarPhoto.Picture.LoadFromFile(CarExpl.Images[CurrImg]);
end;

procedure TFormCarCreate.bbtnSlideRightClick(Sender: TObject);
begin
  if CurrImg <> ImagesAm then
    inc(CurrImg)
  else
    CurrImg := 1;
  imgCarPhoto.Picture.LoadFromFile(CarExpl.Images[CurrImg]);
end;

procedure TFormCarCreate.btnCancelCreateClick(Sender: TObject);
begin
  FormCarCreate.Close;
end;

procedure TFormCarCreate.btnConfirmCreateClick(Sender: TObject);
begin
  Seek(FileCarList, FileSize(FileCarList));

  if not IsAllCorrect then
  Begin
    if ImagesAm <> 0 then
      MessageBox(handle, PChar('Enter all fields correctly!'), PChar('Ad creating'), MB_OK + MB_ICONERROR)
    else
      MessageBox(handle, PChar('Enter all fields correctly and load photo!'), PChar('Ad creating'), MB_OK + MB_ICONERROR);
  End
  Else
    if ImagesAm <> 0 then
    Begin
      if not IsCarCreated() then
      begin
        OneAddListOnShow(CarExpl);
        FormCarCreate.Close;
      end;
    End
    Else
      MessageBox(handle, PChar('Load photo!'), PChar('Ad creating'), MB_OK + MB_ICONERROR);
end;

procedure TFormCarCreate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ToClearCar();
end;

procedure TFormCarCreate.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with FormCarCreate.VertScrollBar do
    Position := Position + Increment;
end;

procedure TFormCarCreate.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with FormCarCreate.VertScrollBar do
    Position := Position - Increment;
end;

procedure TFormCarCreate.imgDeletePhotoClick(Sender: TObject);
begin
  ToShiftArrLeft(CarExpl.Images, ImagesAm, CurrImg);
  if ImagesAm = 1 then
  begin
    bbtnSlideRight.Visible := false;
    bbtnSlideLeft.Visible := false;
  end;
  if ImagesAm = 0 then
  begin
    imgCarPhoto.Picture := nil;
    stxtLoadPic.Visible := true;
    imgDeletePhoto.Visible := false;
  end
  else
    imgCarPhoto.Picture.LoadFromFile(CarExpl.Images[CurrImg]);
end;

procedure TFormCarCreate.imgDeletePhotoMouseEnter(Sender: TObject);
begin
  imgDeletePhoto.Enabled := true;
end;

procedure TFormCarCreate.SetInfo(Car: TCar);
begin
  CarExpl := Car;
  CarOnPanel := Car;
  edtBrand.Text := Car.Brand;
  edtModel.Text := Car.Model;
  edtYear.Text := IntToStr(Car.Year);
  edtCarColor.Text := Car.Color;
  edtMileage.Text := IntToStr(Car.Mileage);
  edtPower.Text := IntToStr(Car.Power);
  edtEngineVol.Text := RealToStr(Car.EngineVol);
  edtAverFuel.Text := RealToStr(Car.AverFuelRate);
  edtAcceler100.Text := RealToStr(Car.Acceler100);
  edtLength.Text := IntToStr(Car.Dimensions.Length);
  edtWeight.Text := IntToStr(Car.Weight);
  edtPrice.Text := IntToStr(Car.Price);
  edtWidth.Text := IntToStr(Car.Dimensions.Width);
  edtHeight.Text := IntToStr(Car.Dimensions.Height);
  edtHolderName.Text := Car.HolderName;
  edtContacts.Text := Car.Contacts;
  edtEmail.Text := Car.Email;
  cmbFuelType.Style := csDropDown;
  cmbTransm.Style := csDropDown;
  cmbDriveUnit.Style := csDropDown;
  cmbFuelType.Text := Car.Fuel;
  cmbTransm.Text := Car.Transm;
  cmbDriveUnit.Text := Car.DriveUnit;

  GetPhotosAmount(CarExpl.Images, ImagesAm);
  CurrImg := 1;
  imgCarPhoto.Picture.LoadFromFile(CarExpl.Images[CurrImg]);
end;

end.

