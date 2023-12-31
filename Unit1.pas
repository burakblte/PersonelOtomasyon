unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, LicenceEntities, LicenceHelper,
  FMX.Objects, FMX.Layouts, System.ImageList, FMX.ImgList, Unit2;

type
  User = class
  private
    fUsername: string;
    fPassword: string;
  published
    property Username: string read fUsername write fUsername;
    property Password: string read fPassword write fPassword;
  end;

  TForm1 = class( TForm)
    rctsignup: TRectangle;
    rctlogin: TRectangle;
    Label1: TLabel;
    Label2: TLabel;
    edtusername: TEdit;
    edtpassword: TEdit;
    GridPanelLayout1: TGridPanelLayout;
    rctusername: TRectangle;
    rctpassword: TRectangle;
    Label3: TLabel;
    Label4: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure rctloginClick(Sender: TObject);

  private
    { Private declarations }
  public
   HttpHelper: THttpHelper;
    { Public declarations }
  const
    HelperBaseUrl = 'http://88.250.253.31:1690/api';
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}

procedure TForm1.rctloginClick(Sender: TObject);

var
  tokenDto: TResponseDto<TTokenDto>;
begin
  if (edtusername.Text = '') or (edtpassword.Text = '') then
  begin
    ShowMessage('Kullan�c� Ad� ve �ifre Zorunludur !');
  end;

  try
    tokenDto := TLicenceHelper.AuthorizeLicenceServer(HttpHelper,(edtusername.Text), (edtpassword.Text));
  except on E: Exception do
    begin
      TAndroidHelper.Toast(Self, E.Message, 3);
      exit;
    end;
  end;

  Form2.Show;
  Form1.Hide;


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  HttpHelper := THttpHelper.Create(Self, HelperBaseUrl);
end;

end.
