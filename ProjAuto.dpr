program ProjAuto;

uses
  Vcl.Forms,
  AutoMag in 'AutoMag.pas' {FormMain},
  Help in 'Help.pas' {FormHelp},
  Magazine in 'Win32\Debug\Magazine.pas',
  CarCreate in 'CarCreate.pas' {FormCarCreate},
  CarPanel in 'Win32\Debug\CarPanel.pas',
  Favorites in 'Favorites.pas' {FormFavs},
  Cart in 'Cart.pas' {FormCart};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormHelp, FormHelp);
  Application.Run;
end.
