unit Help;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ToolWin,
  Vcl.ComCtrls, Vcl.ExtCtrls, acTitleBar, sButton, sMemo;

type
  TFormHelp = class(TForm)
    sMemo1: TsMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormHelp: TFormHelp;

implementation

{$R *.dfm}

procedure TFormHelp.FormCreate(Sender: TObject);
var
  HelpFile: textfile;
  StrToWrite, Tmp: string;
begin
  SetConsoleCP(1251);
  SetConsoleOutputCP(1251);
  AssignFile(HelpFile, '../../CarPh/ProgramInfo.txt');
  Reset(HelpFile);
  ReadLn(HelpFile, Tmp);
  sMemo1.Text := Tmp;
  StrToWrite := Tmp;
  while not EOF(HelpFile) do
  Begin
    ReadLn(HelpFile, Tmp);
    sMemo1.Text := sMemo1.Text + #13#10;
    sMemo1.Text := sMemo1.Text + Tmp;
  End;

  Readln(HelpFile, Tmp);
  CloseFile(HelpFile);
end;

end.
