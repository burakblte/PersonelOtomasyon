unit LicenceHelper;

interface

uses
  {$IFDEF ANDROID}
    FMX.Memo,
  {$ENDIF}
  System.Classes, REST.Client, REST.Authenticator.OAuth, REST.Types,
  System.Generics.Collections, System.StrUtils, System.IOUtils, System.SysUtils,
  LicenceEntities, System.Rtti, REST.Json, System.JSON, ElAES, System.Math,
  JOSE.Core.JWK, JOSE.Core.JWT, JOSE.Core.Builder, JOSE.Types.Bytes, Xml.xmldom,
  Xml.XMLIntf, Xml.XMLDoc, FMX.Forms, FMX.Objects, FMX.Types, FMX.Effects,
  FMX.StdCtrls, FMX.Ani, System.UITypes, System.Types;

type

  TModuleProgramCrypt = class
  private
    fModulProgramNo: Integer;
    fModulProgramAdi: string;
  published
    property ModulProgramNo: Integer read fModulProgramNo write fModulProgramNo;
    property ModulProgramAdi: string read fModulProgramAdi write fModulProgramAdi;
  end;

  TSortDirection = (sdAscending, sdDescending);

  TQueryParams = class(TDictionary<string, string>);
  THeaderParams = class(TDictionary<string, string>);
  TFileParams = class(TDictionary<string, string>);
  TFormParams = class(TDictionary<string, string>);

  TLicenceErrors = class
    const
      leUnexpectedErrorOccured = 'Beklenmedik bir hata oluþtu.';
      leLicenceFileNotFound = 'Lisans dosyasýna eriþilemedi.';
      leMaxLicenceCount = 'Maksimum lisans sayýsýna ulaþtýnýz. Yeni cihaz ile giriþ yapamazsýnýz.';
  end;

  THttpHelper = class
  private
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRestResponse: TRESTResponse;
    FAuthenticator: TOAuth2Authenticator;
    FOwner: TComponent;
    procedure ClearRestRequest;
    function GetAccessToken: string;
    procedure SetAccessToken(const Value: string);
    function CheckResponse: TRESTResponse;
    function GetRefreshToken: string;
    procedure SetRefreshToken(const Value: string);
  published
    property AccessToken: string read GetAccessToken write SetAccessToken;
    property RefreshToken: string read GetRefreshToken write SetRefreshToken;
    property Owner: TComponent read FOwner;
  public
    constructor Create(AOwner: TComponent); overload;
    constructor Create(AOwner: TComponent; ABaseURL: string); overload;
    destructor Destroy; override;

    function Get(RequestUri: string): TRESTResponse; overload;
    function Get(RequestUri: string; AQueryParams: TQueryParams): TRESTResponse; overload;
    function Get(RequestUri: string; AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Get(RequestUri: string; AFormParams: TFormParams): TRESTResponse; overload;
    function Get(RequestUri: string; AQueryParams: TQueryParams;
      AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Get(RequestUri: string; AQueryParams: TQueryParams;
      AFormParams: TFormParams): TRESTResponse; overload;
    function Post(RequestUri, AJsonBody: string): TRESTResponse; overload;
    function Post(RequestUri, AJsonBody: string; AQueryParams: TQueryParams): TRESTResponse; overload;
    function Post(RequestUri, AJsonBody: string; AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Post(RequestUri, AJSonBody: string; AQueryParams: TQueryParams;
      AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Post(RequestUri: string; AFileParams: TFileParams): TRESTResponse; overload;
    function Put(RequestUri, AJsonBody: string): TRESTResponse; overload;
    function Put(RequestUri, AJsonBody: string; AQueryParams: TQueryParams): TRESTResponse; overload;
    function Put(RequestUri, AJsonBody: string; AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Put(RequestUri, AJSonBody: string; AQueryParams: TQueryParams;
      AHeaderParams: THeaderParams): TRESTResponse; overload;
    function Put(RequestUri: string; AFileParams: TFileParams): TRESTResponse; overload;
    function Delete(RequestUri: string): TRESTResponse; overload;
    function Delete(RequestUri: string; AQueryParams: TQueryParams): TRESTResponse; overload;
    procedure DisconnectAuth;
    procedure ConnectAuth;
  end;

  TAndroidHelper = class
  private
    class procedure OnToastFinish(Sender: TObject);
  public
    class function Toast(AParentForm: TForm; AMessage: string; ATime: Cardinal): boolean;
  end;

  TCryptingHelper = class
  private
    class function HexToString(S: AnsiString): AnsiString; static;
    class function StringToHex(S: AnsiString): AnsiString; static;

    const
      AESKey = 'YalinIBSAESKey16';
  public
    class function DecryptText(pKey: string; pEncryptedText: string): string; overload; static;
    class function DecryptText(pEncryptedText: string): string; overload; static;
    class function EncryptText(pKey: string; AText: string): string; overload;
    class function EncryptText(AText: string): string; overload;
    class function DecryptXML(AEncryptedText: string): IXMLDocument; static;
    class function EncryptXML(AXmlDocument: IXMLDocument): string; static;
  end;

  TXMLHelper = class
  public
    class function FindXmlNode(AXmlDocument: IXMLDocument;
      ANodeName: string): IXMLNode; overload; static;
    class function FindXmlNode(ANode: IXMLNode;
      ANodeName: string): IXMLNode; overload; static;
    class function FindSiblingByAttributeName(AParentNode: IXMLNode;
      ASiblingNodeName, AAttributeName, AAttributeValue: string): IXMLNode; static;
    class function GetUserInfoFromConfig(AConfigPath: string): TUserDto; static;
    class function LicenceDownloadDateCheck(AXmlFile: IXMLDocument): Integer; static;
  end;

  TLicenceHelper = class
  private
    class function CreateInstance(AInstanceType: TRttiInstanceType;
      AConstructorMethod: TRttiMethod; const Args: array of TValue): TObject;
    class function ErrorsJsonToObject(AJsonValue: TJSONValue): TList<string>; static;

  const
    JWTSecurityKey = 'YalinSoftwareAuthenticationSecurityKey*!';

  public
    class function Map<T: class, constructor>(AEntity: TObject): T; static;
    class function ParseToCustomResponse<T: class, constructor>(AContent: string): TResponseDto<T>; overload;
    class function ErrorListToString(ErrorList: TList<string>): string; static;
    class function AuthorizeLicenceServer(AHttpHelper: THttpHelper; AUsername,
      APassword: string): TResponseDto<TTokenDto>; overload; static;
    class function AuthorizeLicenceServer(AHttpHelper: THttpHelper;
      ARefreshToken: string): TResponseDto<TTokenDto>; overload; static;
    class function GetJWTPayload(AJWTToken: string; const AJWTSecurityKey: string = ''): TJWTPayloadDto; static;
    class function GetServerDate(AHttpHelper: THttpHelper): string; static;
    class function SaveLicenceToFile(AFilePath: string; AXmlFile: IXMLDocument): Boolean; static;
    class function CheckDevice(AHttpHelper: THttpHelper; ALicenceFile: IXMLDocument; AApplicationName,
      ADeviceUniqueId: string; ProductId: Integer): string; static;
    class function AddDeviceToCompany(AHttpHelper: THttpHelper; CompanyId,
      ProductId: Integer; DeviceId: string): string; static;
    class function UpdateLicence(AHttpHelper: THttpHelper;
      ALicenceFile: IXMLDocument; CompanyId: Integer): string; static;
  end;



const
  sLineBreak =  {$IFDEF ANDROID}
                  AnsiChar(#10);
                {$ENDIF}
                {$IFDEF Win32}
                  AnsiString(#13#10);
                {$ENDIF}


implementation

{ THttpHelper }

constructor THttpHelper.Create(AOwner: TComponent);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure THttpHelper.ConnectAuth;
begin
  FRestClient.Authenticator := FAuthenticator;
end;

constructor THttpHelper.Create(AOwner: TComponent; ABaseURL: string);
begin
  inherited Create;
  FOwner := AOwner;

  FAuthenticator := TOAuth2Authenticator.Create(Owner);
  FAuthenticator.TokenType := TOAuth2TokenType.ttBEARER;

  FRestClient := TRESTClient.Create(Owner);
  FRestClient.BaseURL := ABaseURL;
  FRestClient.Authenticator := FAuthenticator;
  FRestClient.AcceptCharset := 'utf-8';
  FRestClient.Accept := 'application/json';
  FRestClient.ConnectTimeout := 1200000;
  FRestClient.ReadTimeout := 1200000;

  FRESTResponse := TRESTResponse.Create(Owner);

  FRESTRequest := TRESTRequest.Create(Owner);
  FRESTRequest.Response := FRESTResponse;
  FRESTRequest.Client := FRESTClient;
  FRESTRequest.ConnectTimeout := 1200000;
  FRESTRequest.ReadTimeout := 1200000;

end;

destructor THttpHelper.Destroy;
begin
  FRestResponse.Free;
  FRestRequest.Free;
  FRestClient.Free;
  FAuthenticator.Free;

  inherited;
end;

procedure THttpHelper.DisconnectAuth;
begin
  FRestClient.Authenticator := nil;
end;

procedure THttpHelper.ClearRestRequest;
begin
  FRestRequest.Params.Clear;
  FRestRequest.Method := rmGet;
  FRestRequest.Resource := '';
  FRestRequest.ClearBody;
  FRestRequest.ResetToDefaults;
  FRestRequest.Response := FRestResponse;
end;

procedure THttpHelper.SetAccessToken(const Value: string);
begin
  if not Trim(Value).IsEmpty then
    FAuthenticator.AccessToken := Value;
end;

procedure THttpHelper.SetRefreshToken(const Value: string);
begin
  if not Trim(Value).IsEmpty then
    FAuthenticator.RefreshToken := Value;
end;

function THttpHelper.GetAccessToken: string;
begin
  Result := FAuthenticator.AccessToken;
end;

function THttpHelper.GetRefreshToken: string;
begin
  Result := FAuthenticator.RefreshToken;
end;

function THttpHelper.CheckResponse: TRESTResponse;
var
  LRestRequest: TRESTRequest;
  LRefreshTokenDto: TRefreshTokenDto;
  jsonBody: string;
  resTokenDto: TResponseDto<TTokenDto>;
begin
  Result := FRestResponse;

  if FRestResponse.StatusCode <> 401 then
    exit;

  LRestRequest := TRESTRequest.Create(FRestRequest.Owner);
  try
    LRestRequest.Client := FRestClient;
    LRestRequest.Response := FRestResponse;
    LRestRequest.ConnectTimeout := 1200000;
    LRestRequest.ReadTimeout := 1200000;

    LRestRequest.Params.Clear;
    LRestRequest.Method := rmGet;
    LRestRequest.Resource := '';
    LRestRequest.ClearBody;
    LRestRequest.ResetToDefaults;

    DisconnectAuth;
    LRestRequest.Resource := 'Auth/CreateTokenByRefreshToken';
    LRestRequest.Method := rmPOST;

    LRefreshTokenDto := TRefreshTokenDto.Create;
    try
      LRefreshTokenDto.Token := FAuthenticator.RefreshToken;
      jsonBody := TJson.ObjectToJsonString(LRefreshTokenDto);
    finally
      LRefreshTokenDto.Free;
    end;

    LRestRequest.Body.Add(jsonBody, ctAPPLICATION_JSON);
    LRestRequest.Execute;

    resTokenDto := TLicenceHelper.ParseToCustomResponse<TTokenDto>(FRestResponse.Content);
    try
      if (resTokenDto.Errors <> nil) and (resTokenDto.Errors.Count > 0) then
        raise Exception.Create(TLicenceHelper.ErrorListToString(resTokenDto.Errors));
    finally
      resTokenDto.Free;
    end;

    AccessToken := resTokenDto.Data.AccessToken;
    RefreshToken := resTokenDto.Data.RefreshToken;
  finally
    LRestRequest.Free;
  end;

  ConnectAuth;
  FRestRequest.Response := FRestResponse;

  FRestRequest.Execute;

  Result := FRestResponse;
end;

{$region '<Get Request Overloads>'}

function THttpHelper.Get(RequestUri: string): TRESTResponse;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;
  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Get(RequestUri: string;
  AQueryParams: TQueryParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Get(RequestUri: string;
  AHeaderParams: THeaderParams): TRESTResponse;
var
  HeaderParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkHTTPHEADER);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Get(RequestUri: string;
  AFormParams: TFormParams): TRESTResponse;
var
  FormParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;

  if (AFormParams <> nil) and (AFormParams.ClassType = TFormParams) then
  begin
    for FormParam in AFormParams do
    begin
      FRestRequest.Params.AddItem(FormParam.Key, FormParam.Value, pkREQUESTBODY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Get(RequestUri: string; AQueryParams: TQueryParams;
  AHeaderParams: THeaderParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
  HeaderParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkHTTPHEADER);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Get(RequestUri: string; AQueryParams: TQueryParams;
  AFormParams: TFormParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
  FormParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmGET;
  FRestRequest.Resource := RequestUri;

  if (AQueryParams <> nil) and (AQueryParams.ClassType = TQueryParams) then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  if (AFormParams <> nil) and (AFormParams.ClassType = TFormParams) then
  begin
    for FormParam in AFormParams do
    begin
      FRestRequest.Params.AddItem(FormParam.Key, FormParam.Value, pkREQUESTBODY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

{$endregion}

{$region '<Post Request Overloads>'}

function THttpHelper.Post(RequestUri, AJsonBody: string): TRESTResponse;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Post(RequestUri, AJsonBody: string;
  AQueryParams: TQueryParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Post(RequestUri, AJsonBody: string;
  AHeaderParams: THeaderParams): TRESTResponse;
var
  HeaderParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Post(RequestUri, AJSonBody: string;
  AQueryParams: TQueryParams; AHeaderParams: THeaderParams): TRESTResponse;
var
  HeaderParam: TPair<string, string>;
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkHTTPHEADER);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Post(RequestUri: string;
  AFileParams: TFileParams): TRESTResponse;
var
  FileParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := RequestUri;

  if AFileParams <> nil then
  begin
    for FileParam in AFileParams do
    begin
      FRestRequest.Params.AddItem(FileParam.Key, FileParam.Value, pkFILE);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

{$endregion}

{$region '<Put Request Overloads>'}

function THttpHelper.Put(RequestUri, AJsonBody: string): TRESTResponse;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPUT;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Put(RequestUri, AJsonBody: string;
  AQueryParams: TQueryParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPUT;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Put(RequestUri, AJsonBody: string;
  AHeaderParams: THeaderParams): TRESTResponse;
var
  HeaderParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPUT;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Put(RequestUri, AJSonBody: string;
  AQueryParams: TQueryParams; AHeaderParams: THeaderParams): TRESTResponse;
var
  HeaderParam: TPair<string, string>;
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPUT;
  FRestRequest.Resource := RequestUri;

  if not Trim(AJsonBody).IsEmpty then
    FRestRequest.Body.Add(AJsonBody, ctAPPLICATION_JSON);

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  if AHeaderParams <> nil then
  begin
    for HeaderParam in AHeaderParams do
    begin
      FRestRequest.Params.AddItem(HeaderParam.Key, HeaderParam.Value, pkHTTPHEADER);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

function THttpHelper.Put(RequestUri: string;
  AFileParams: TFileParams): TRESTResponse;
var
  FileParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Method := rmPUT;
  FRestRequest.Resource := RequestUri;

  if AFileParams <> nil then
  begin
    for FileParam in AFileParams do
    begin
      FRestRequest.Params.AddItem(FileParam.Key, FileParam.Value, pkFILE);
    end;
  end;

  FRestRequest.Execute;
  Result := CheckResponse;
end;

{$endregion}

function THttpHelper.Delete(RequestUri: string): TRESTResponse;
begin
  ClearRestRequest;

  FRestRequest.Resource := RequestUri;
  FRestRequest.Method := rmDELETE;
  FRestRequest.Execute;

  Result := CheckResponse;
end;

function THttpHelper.Delete(RequestUri: string;
  AQueryParams: TQueryParams): TRESTResponse;
var
  QueryParam: TPair<string, string>;
begin
  ClearRestRequest;

  FRestRequest.Resource := RequestUri;
  FRestRequest.Method := rmDELETE;

  if AQueryParams <> nil then
  begin
    for QueryParam in AQueryParams do
    begin
      FRestRequest.Params.AddItem(QueryParam.Key, QueryParam.Value, pkQUERY);
    end;
  end;

  FRestRequest.Execute;

  Result := CheckResponse;
end;

{ TAndroidHelper }

class procedure TAndroidHelper.OnToastFinish(Sender: TObject);
var
  rctToast: TRectangle;
  I: Integer;
begin
  rctToast := TRectangle(TFloatAnimation(Sender).Parent);
  FreeAndNil(rctToast);
end;

class function TAndroidHelper.Toast(AParentForm: TForm; AMessage: string;
  ATime: Cardinal): boolean;
var
  rctToast, rctToastContent: TRectangle;
  sheEffect: TShadowEffect;
  lblToast: TLabel;
  opacityOn, opacityOff, PosX, PosY, WidthAnim: TFloatAnimation;

begin
  rctToast := TRectangle.Create(AParentForm);
  rctToast.Parent := AParentForm;
  rctToast.Height := 48;
  rctToast.Width := AParentForm.ClientWidth - 50;
  rctToast.Opacity := 0;
  rctToast.XRadius := 8;
  rctToast.YRadius := 8;
  rctToast.Stroke.Thickness := 0;
  rctToast.HitTest := False;

  rctToastContent := TRectangle.Create(rctToast);
  rctToastContent.Parent := rctToast;
  rctToastContent.Align := TAlignLayout.Client;
  rctToastContent.XRadius := 8;
  rctToastContent.YRadius := 8;
  rctToastContent.Stroke.Thickness := 0;
  rctToastContent.Padding := TBounds.Create(TRectF.Create(16,3,16,3));
  rctToastContent.HitTest := False;

  sheEffect := TShadowEffect.Create(rctToast);
  sheEffect.Parent := rctToast;
  sheEffect.Direction := 90;
  sheEffect.Distance := 2;
  sheEffect.Opacity := 0.3;
  sheEffect.Softness := 0.2;

  lblToast := TLabel.Create(rctToast);
  lblToast.Parent := rctToastContent;
  lblToast.Align := TAlignLayout.Client;
  lblToast.TextSettings.Font.Size := 14;
  lblToast.Font.Family := 'Roboto';
  lblToast.Font.Style := [];
  lblToast.TextSettings.HorzAlign := TTextAlign.Leading;
  lblToast.StyledSettings := [];
  lblToast.Text := AMessage;

  opacityOn := TFloatAnimation.Create(rctToast);
  opacityOn.Parent := rctToast;
  opacityOn.Delay := 0;
  opacityOn.Duration := 0.3;
  opacityOn.PropertyName := 'Opacity';
  opacityOn.StartValue := 0;
  opacityOn.StopValue := 1;

  opacityOff := TFloatAnimation.Create(rctToast);
  opacityOff.Parent := rctToast;
  opacityOff.Delay := ATime;
  opacityOff.Duration := 0.3;
  opacityOff.PropertyName := 'Opacity';
  opacityOff.StartValue := 1;
  opacityOff.StopValue := 1;
  opacityOff.OnFinish := OnToastFinish;

  PosX := TFloatAnimation.Create(rctToast);
  PosX.Parent := rctToast;
  PosX.Duration := 0.3;
  PosX.PropertyName := 'Position.X';
  PosX.StartValue := 100;
  PosX.StopValue := 25;

  PosY := TFloatAnimation.Create(rctToast);
  PosY.Parent := rctToast;
  PosY.Duration := 0.2;
  PosY.PropertyName := 'Position.Y';
  PosY.StartValue := AParentForm.ClientHeight - 25;
  PosY.StopValue := AParentForm.ClientHeight - 85;

  WidthAnim := TFloatAnimation.Create(rctToast);
  WidthAnim.Parent := rctToast;
  WidthAnim.Duration := 0.3;
  WidthAnim.PropertyName := 'Width';
  WidthAnim.StartValue := AParentForm.ClientWidth - 200;
  WidthAnim.StopValue := AParentForm.ClientWidth - 50;

  opacityOn.Start;
  opacityOff.Start;
  PosX.Start;
  PosY.Start;
  WidthAnim.Start;
end;

{ TCryptingHelper }

class function TCryptingHelper.HexToString(S: AnsiString): AnsiString;
var
	i: integer;
begin
  Result := '';
  for i := 1 to Length( S ) do
  begin
  	if ((i mod 2) = 1) then
	  	Result := Result + AnsiChar( StrToInt( '0x' + Copy( S, i, 2 )));
  end;
end;

class function TCryptingHelper.StringToHex(S: AnsiString): AnsiString;
var
	i: integer;
begin
  Result := '';
	for i := 1 to Length( S ) do
  	Result := Result + IntToHex( byte( S[i] ), 2 );
end;

class function TCryptingHelper.DecryptText(pKey: string; pEncryptedText: string): string;
var
  Source: TMemoryStream;
  Dest: TMemoryStream;
  Size: integer;
  Key: TAESKey128;
  str: AnsiString;
  decryptedText: string;
begin
  Result := '';
  try
    if Trim(pKey).IsEmpty then
      pKey := AESKey;

    pEncryptedText := Trim(pEncryptedText);

    Source := TMemoryStream.Create( );
    Dest   := TMemoryStream.Create( );
    try
      str := HexToString( pEncryptedText );
      Source.Write(PAnsiChar(str)^, length(str));
      Source.Position := 0;
      // Start decryption...
      Size := Source.Size;
      Source.ReadBuffer(Size, SizeOf(Size));
      // Prepare key...
      FillChar(Key, SizeOf(Key), 0);
      Move(PAnsiChar(AnsiString(pKey))^, Key, Min(SizeOf(Key), Length(pKey)));
      // Decrypt now...
      DecryptAESStreamECB(Source, Source.Size - Source.Position, Key, Dest);
      // Display unencrypted text...
      Dest.position := 0;
      SetLength(str, dest.Size);
      Dest.Read(PAnsiChar(str)^, dest.Size);
      decryptedText := str;
      Result := decryptedText;
    finally
      Source.Free;
      Dest.Free;
    end;
  except on E: Exception do
    begin
      Result := 'Decrypt Error: ' + E.ToString;
    end;
  end;
end;

class function TCryptingHelper.DecryptText(pEncryptedText: string): string;
var
  Source: TMemoryStream;
  Dest: TMemoryStream;
  Size: integer;
  Key: TAESKey128;
  str: AnsiString;
  decryptedText: string;
  pKey: string;
begin
  Result := '';
  try
    pKey := AESKey;

    pEncryptedText := Trim(pEncryptedText);

    Source := TMemoryStream.Create( );
    Dest   := TMemoryStream.Create( );
    try
      str := HexToString( pEncryptedText );
      Source.Write(PAnsiChar(str)^, length(str));
      Source.Position := 0;
      // Start decryption...
      Size := Source.Size;
      Source.ReadBuffer(Size, SizeOf(Size));
      // Prepare key...
      FillChar(Key, SizeOf(Key), 0);
      Move(PAnsiChar(AnsiString(pKey))^, Key, Min(SizeOf(Key), Length(pKey)));
      // Decrypt now...
      DecryptAESStreamECB(Source, Source.Size - Source.Position, Key, Dest);
      // Display unencrypted text...
      Dest.position := 0;
      SetLength(str, dest.Size);
      Dest.Read(PAnsiChar(str)^, dest.Size);
      decryptedText := str;
      Result := decryptedText;
    finally
      Source.Free;
      Dest.Free;
    end;
  except on E: Exception do
    begin
      Result := 'Decrypt Error: ' + E.ToString;
    end;
  end;
end;

class function TCryptingHelper.DecryptXML(AEncryptedText: string): IXMLDocument;
var
  xmlFile : IXMLDocument;
  decryptedText : string;
  strList: TStrings;

begin
  decryptedText := TCryptingHelper.DecryptText(AESKey, AEncryptedText);
  if ContainsText(decryptedText, 'Error') then
    Result := nil
  else
  begin
    xmlFile := TXMLDocument.Create(nil);

    {$IFDEF ANDROID}
      xmlFile.LoadFromXml(Trim(decryptedText));
    {$ENDIF}
    {$IFDEF Win32}
      xmlFile.LoadFromXml(decryptedText);
    {$ENDIF}

    Result := xmlFile;
  end;
end;

class function TCryptingHelper.EncryptText(pKey: string; AText: string): string;
var
  Source: TMemoryStream;
  Dest: TMemoryStream;
  Size: integer;
  Key: TAESKey128;
  str: ansistring;
  strTemp: TStringList;
begin
  try
    Result := '';

    if Trim(pKey).IsEmpty then
      pKey := AESKey;

    AText := Trim(AText);
    Source := TMemoryStream.Create();
    Dest   := TMemoryStream.Create();
    strTemp := TStringList.Create;
    try
      // Save data to memory stream...
      Source.Write(PAnsiChar(AnsiString(AText))^, length(AText));
      Source.Position := 0;
      Size := Source.Size;
      Dest.WriteBuffer( Size, SizeOf(Size) );
      // Prepare key...
      FillChar(Key, SizeOf(Key), 0);
      Move(PAnsiChar(AnsiString(pKey))^, Key, Min(SizeOf(Key), Length(pKey)));
      // Start encryption...
      EncryptAESStreamECB( Source, 0, Key, Dest );
      //Label_Time.Caption := IntToStr(Stop - Start) + ' ms';

      // Display encrypted text using hexadecimals...
      Dest.Position := 0;
      setlength(str, Dest.Size);
      Dest.Read(PAnsiChar(str)^, Dest.Size);
      strTemp.Text := StringToHex( str );
      Result := strTemp.Text;
    finally
      Source.Free;
      Dest.Free;
      strTemp.Free;
    end;
  except on E: Exception do
    begin
      Result := 'Encrypt Error: ' + E.ToString;
    end;
  end;
end;

class function TCryptingHelper.EncryptText(AText: string): string;
var
  Source: TMemoryStream;
  Dest: TMemoryStream;
  Size: integer;
  Key: TAESKey128;
  str: ansistring;
  strTemp: TStringList;
  LKey: string;
begin
  try
    Result := '';
    LKey := AESKey;

    AText := Trim(AText);
    Source := TMemoryStream.Create();
    Dest   := TMemoryStream.Create();
    strTemp := TStringList.Create;
    try
      // Save data to memory stream...
      Source.Write(PAnsiChar(AnsiString(AText))^, length(AText));
      Source.Position := 0;
      Size := Source.Size;
      Dest.WriteBuffer( Size, SizeOf(Size) );
      // Prepare key...
      FillChar(Key, SizeOf(Key), 0);
      Move(PAnsiChar(AnsiString(LKey))^, Key, Min(SizeOf(Key), Length(LKey)));
      // Start encryption...
      EncryptAESStreamECB( Source, 0, Key, Dest );
      //Label_Time.Caption := IntToStr(Stop - Start) + ' ms';

      // Display encrypted text using hexadecimals...
      Dest.Position := 0;
      setlength(str, Dest.Size);
      Dest.Read(PAnsiChar(str)^, Dest.Size);
      strTemp.Text := StringToHex( str );
      Result := strTemp.Text;
    finally
      Source.Free;
      Dest.Free;
      strTemp.Free;
    end;
  except on E: Exception do
    begin
      Result := 'Encrypt Error: ' + E.ToString;
    end;
  end;
end;

class function TCryptingHelper.EncryptXML(AXmlDocument: IXMLDocument): string;
var
  xmlText: string;
begin
  if not AXmlDocument.Active then
    AXmlDocument.Active := True;
  xmlText := FormatXMLData(AXmlDocument.XML.Text);
  //AXmlDocument.SaveToXML(xmlText);
  Result := EncryptText(AESKey, xmlText);
end;

{ TXMLHelper }

class function TXMLHelper.FindSiblingByAttributeName(AParentNode: IXMLNode;
  ASiblingNodeName, AAttributeName, AAttributeValue: string): IXMLNode;
var
  tmpNode: IXMLNode;
begin
  Result := nil;
  tmpNode := FindXmlNode(AParentNode, ASiblingNodeName);

  if tmpNode = nil then
    exit;

  repeat
    if tmpNode.HasAttribute(AAttributeName) then
    begin
      if tmpNode.Attributes[AAttributeName] = AAttributeValue then
      begin
        Result := tmpNode;
        break;
      end;
    end;
    tmpNode := tmpNode.NextSibling;
  until (tmpNode = nil);
end;

class function TXMLHelper.FindXmlNode(AXmlDocument: IXMLDocument;
  ANodeName: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to AXMLDocument.ChildNodes.Count - 1 do
  begin
    Result := FindXmlNode(AXMLDocument.ChildNodes[I], ANodeName);
    if Result <> nil then
      break;
  end;
end;

class function TXMLHelper.FindXmlNode(ANode: IXMLNode;
  ANodeName: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;

  if ANode.NodeName = ANodeName then
    Result := ANode
  else
  begin
    for I := 0 to ANode.ChildNodes.Count - 1 do
    begin
      Result := FindXmlNode(ANode.ChildNodes[I], ANodeName);
      if Result <> nil then
        break;
    end;
  end;
end;

class function TXMLHelper.GetUserInfoFromConfig(AConfigPath: string): TUserDto;
var
  XmlFile: IXMLDocument;
  yalinServerConnectionNode: IXMLNode;
begin
  Result := nil;

  XmlFile := TXMLDocument.Create(AConfigPath);

  yalinServerConnectionNode := FindXmlNode(XmlFile, 'yalinServerConnection');

  if yalinServerConnectionNode <> nil then
  begin
    Result := TUserDto.Create;
    Result.Username := yalinServerConnectionNode.Attributes['user'];
    Result.Password := yalinServerConnectionNode.Attributes['password'];
  end;
end;

class function TXMLHelper.LicenceDownloadDateCheck(
  AXmlFile: IXMLDocument): Integer;
var
  licenceNode, downloadDateNode, nextCheckDateNode: IXMLNode;
  DownloadDate: TDate;
  NextCheckDate: TDate;
begin
  //Result Meaning
  // -1: Must download
  //  0: Try download
  //  1: Don't do anyting

  licenceNode := FindXmlNode(AXmlFile, 'licence');
  if licenceNode = nil then
  begin
    Result := -1;
    exit;
  end;

  downloadDateNode := licenceNode.ChildNodes['downloadDate'];
  if downloadDateNode = nil then
  begin
    Result := -1;
    exit;
  end;

  nextCheckDateNode := licenceNode.ChildNodes['nextCheckDate'];
  if nextCheckDateNode = nil then
  begin
    Result := -1;
    exit;
  end;

  if downloadDateNode.Text.IsEmpty then
    Result := -1
  else if nextCheckDateNode.Text.IsEmpty then
    Result := -1
  else
  begin
    DownloadDate := StrToDateTime(downloadDateNode.Text);

    NextCheckDate := StrToDateTime(nextCheckDateNode.Text);

    if NextCheckDate - DownloadDate < 1 then
      Result := -1
    else if NextCheckDate - DownloadDate < 7 then
      Result := 0
    else
      Result := 1;
  end;
end;

{ TLicenceHelper }

class function TLicenceHelper.CheckDevice(AHttpHelper: THttpHelper; ALicenceFile: IXMLDocument;
  AApplicationName, ADeviceUniqueId: string; ProductId: Integer): string;
var
  ApplicationNode, ApplicationsNode, DevicesNode, DeviceNode: IXMLNode;
  I: Integer;
  JwtPayload: TJWTPayloadDto;
begin
  Result := '';

  ApplicationsNode := TXMLHelper.FindXmlNode(ALicenceFile, 'applications');
  if ApplicationsNode = nil then
  begin
    Result := TLicenceErrors.leLicenceFileNotFound;
    exit;
  end;

  ApplicationNode := TXMLHelper.FindSiblingByAttributeName(ApplicationsNode, 'application', 'name', AApplicationName);
  if ApplicationNode = nil then
  begin
    Result := TLicenceErrors.leLicenceFileNotFound;
    exit;
  end;

  DevicesNode := ApplicationNode.ChildNodes['devices'];
  if DevicesNode = nil then
    DevicesNode := ApplicationNode.AddChild('devices');

  for I := DevicesNode.ChildNodes.Count - 1 downto 0 do
  begin
    DeviceNode := DevicesNode.ChildNodes[I];
    if DeviceNode.HasAttribute('uniqueID') then
    begin
      if DeviceNode.Attributes['uniqueID'] = ADeviceUniqueID then
      begin
        exit;
      end;
    end
    else
      DevicesNode.ChildNodes.Remove(DeviceNode);
  end;

  if DevicesNode.ChildNodes.Count >= ApplicationNode.Attributes['licenceCount'] then
  begin
    Result := TLicenceErrors.leMaxLicenceCount;
    exit;
  end;

  DeviceNode := DevicesNode.AddChild('device');
  DeviceNode.Attributes['uniqueID'] := ADeviceUniqueID;

  JwtPayload := TLicenceHelper.GetJWTPayload(AHttpHelper.AccessToken);
  try
    Result := AddDeviceToCompany(AHttpHelper, JwtPayload.CompanyID, ProductID, ADeviceUniqueID);
    if Result <> '' then
      exit;

    Result := UpdateLicence(AHttpHelper, ALicenceFile, JwtPayload.CompanyID);
  finally
    JwtPayload.Free;
  end;
end;

class function TLicenceHelper.CreateInstance(AInstanceType: TRttiInstanceType;
  AConstructorMethod: TRttiMethod; const Args: array of TValue): TObject;
var
  classType: TClass;
  CreatedObject: TObject;
begin
  Result := nil;

  classType := AInstanceType.MetaclassType;
  CreatedObject := classType.NewInstance;
  try
    AConstructorMethod.Invoke(CreatedObject, Args);
  except on E: Exception do
    begin
      if CreatedObject <> nil then
        FreeAndNil(CreatedObject);
    end;
  end;

  try
    CreatedObject.AfterConstruction;
  except on E: Exception do
    begin
      if CreatedObject <> nil then
        FreeAndNil(CreatedObject);
    end;
  end;

  Result := CreatedObject;
end;

class function TLicenceHelper.ErrorsJsonToObject(
  AJsonValue: TJSONValue): TList<string>;
var
  jsonDataArray: TJSONArray;
  jsonDataObject: TJSONObject;
  jsonDataValue: TJSONValue;
begin
  Result := nil;

  if AJsonValue is TJSONNull then
    exit;

  Result := TList<string>.Create;

  if AJsonValue is TJSONArray  then
  begin
    jsonDataArray := (AJsonValue as TJSONArray);

    for jsonDataValue in jsonDataArray do
    begin
      Result.Add(ReplaceStr(jsonDataValue.ToString, '"', ''));
    end;
  end
  else if AJsonValue is TJSONObject then
  begin
    Result.Add(ReplaceStr(AJsonValue.ToString, '"', ''));
  end
  else
  begin
    FreeAndNil(Result);
    exit;
  end;

  if (Result <> nil) and (Result.Count <= 0) then
    FreeAndNil(Result);

end;

class function TLicenceHelper.Map<T>(AEntity: TObject): T;
var
  CtxDestination, CtxSource: TRttiContext;
  TypDestination, TypSource: TRttiType;
  PropDestination, PropSource: TRttiProperty;
  PropName: string;
  ChildEntity: TObject;
  PropValue: TValue;
  Instance: TObject;
  ChildTypeDest, ChildTypeSource: TRttiType;
  Method: TRttiMethod;
  ParameterDest, ParameterSource: TRttiParameter;
  ListPropFound: Boolean;
begin
  Result := T.Create;

  if AEntity = nil then
  begin
    FreeAndNil(Result);
    exit;
  end;

  TypSource := CtxSource.GetType(AEntity.ClassInfo);
  TypDestination := CtxDestination.GetType(TypeInfo(T));

  if TypDestination.GetProperty('Count') <> nil then
  begin
    if TypSource.GetProperty('Count') = nil then
    begin
      FreeAndNil(Result);
      exit;
    end;
    //List mapping
    ListPropFound := False;
    Method := TypDestination.GetMethod('Add');
    for ParameterDest in Method.GetParameters do
    begin
      if SameText(ParameterDest.Name, 'Value') then
      begin
        if ParameterDest.ParamType.IsInstance then
        begin
          ListPropFound := True;
          break;
        end;
      end;
    end;

    if not ListPropFound then
    begin
      FreeAndNil(Result);
    end;

    Method := TypSource.GetMethod('Add');
    for ParameterSource in Method.GetParameters do
    begin
      if SameText(ParameterSource.Name, 'Value') then
      begin
        if ParameterSource.ParamType.IsInstance then
        begin
          ListPropFound := True;
          break;
        end;
      end;
    end;

    if not ListPropFound then
    begin
      FreeAndNil(Result);
    end;

    for ChildEntity in TObjectList<T>(AEntity) do
    begin

      Instance := ParameterDest.ParamType.AsInstance.MetaclassType.Create;

      for PropSource in ParameterSource.ParamType.GetProperties do
      begin
        PropDestination := ParameterDest.ParamType.GetProperty(PropSource.Name);
        if PropDestination = nil then
          continue;

        if not (PropDestination.PropertyType = PropSource.PropertyType) then
          continue;

        if not PropDestination.IsWritable then
          continue;

        PropValue := PropSource.GetValue(ChildEntity);
        PropDestination.SetValue(Instance, PropValue);
      end;

      TList<T>(Result).Add(Instance);
    end;

  end
  else
  begin
    //Instance mapping
    for PropSource in TypSource.GetProperties do
    begin
      //Hedeflenen sýnýfta propery name olup olmadýðý kontrol ediliyor.
      PropDestination := TypDestination.GetProperty(PropSource.Name);
      if PropDestination = nil then
        continue;

      //Ayný isme sahip property'lerin ayný veri tipinde olup olmadýðý kontrol ediliyor.
      if not (PropDestination.PropertyType = PropSource.PropertyType) then
        continue;

      //Yazýlacak property'nin yazýlabilir olup olmadýðý kontrol ediliyor.
      if not PropDestination.IsWritable then
        continue;

      PropValue := PropSource.GetValue(AEntity);

      PropDestination.SetValue(TObject(Result), PropValue);
    end;
  end;
end;

class function TLicenceHelper.ParseToCustomResponse<T>(
  AContent: string): TResponseDto<T>;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
  Method, CreateMethod: TRttiMethod;
  Parameter: TRttiParameter;
  ListObject: TObject;
  jsonValue, jsonDataValue: TJSONValue;
  EntityObject: TObject;
  ListPropFound: boolean;
  jsonDataObject: TJSONObject;
  jsonDataArray: TJSONArray;
begin
  Result := TResponseDto<T>.Create;

  Result.Errors := nil;

  if Trim(AContent).IsEmpty then
  begin
    FreeAndNil(Result);
    exit;
  end;

  jsonValue := TJSONObject.ParseJSONValue(AContent);
  try
    try
      if (jsonValue is TJSONNull) then
      begin
        FreeAndNil(Result);
        exit;
      end;

      if (jsonValue as TJSONObject).Get('errors').JsonValue is TJSONNull then
        Result.Errors := nil
      else
      begin
        Result.Errors := ErrorsJsonToObject((jsonValue as TJSONObject).Get('errors').JsonValue);
      end;

      if (jsonValue as TJSONObject).Get('data').JsonValue is TJSONNull then
        exit;
    except on E: Exception do
      begin
        if Result.Errors = nil then
          Result.Errors := TList<string>.Create;

        Result.Errors.Add(E.Message);
        exit;
      end;
    end;

    Typ := Ctx.GetType(TypeInfo(T));
    if Typ.GetProperty('Count') <> nil then
    begin
      //Ýstenen veri liste olduðunda içinde instance create edilecek;
      Result.Data := T.Create;

      Method := Typ.GetMethod('Add');
      for Parameter in Method.GetParameters do
      begin
        if SameText(Parameter.Name, 'Value') then
        begin
          if Parameter.ParamType.IsInstance then
          begin
            CreateMethod := Parameter.ParamType.AsInstance.GetMethod('Create');
            ListPropFound := True;
            break;
          end;
        end;
      end;

      if not ListPropFound then
      begin
        if Result <> nil then
          FreeAndNil(Result);
        exit;
      end;

      if (jsonValue as TJSONObject).Get('data').JsonValue is TJSONArray then
      begin
        jsonDataArray := jsonValue.GetValue<TJSONArray>('data');

        for jsonDataValue in jsonDataArray do
        begin
          EntityObject := Parameter.ParamType.AsInstance.MetaclassType.Create;
          TJson.JsonToObject(EntityObject, (jsonDataValue as TJSONObject));
          TList<T>(Result.Data).Add(EntityObject);
        end;
      end
      else
      begin
        //Gelen verinin liste olmamasý durumunda Liste içinde tek bir kayýt gönderilecek.
        jsonDataObject := jsonValue.GetValue<TJSONObject>('data');
        EntityObject := Parameter.ParamType.AsInstance.MetaclassType.Create;
        TJson.JsonToObject(EntityObject, jsonDataObject);
        TList<T>(Result.Data).Add(EntityObject);
      end;
    end
    else
    begin
      jsonDataObject := jsonValue.GetValue<TJSONObject>('data');
      Result.Data := TJson.JsonToObject<T>(jsonDataObject);
    end;

  finally
    jsonValue.Destroy;
  end;

  if Result.Data = nil then
    exit;
end;

class function TLicenceHelper.SaveLicenceToFile(AFilePath: string;
  AXmlFile: IXMLDocument): Boolean;
var
  encryptedText: string;
  strList: TStringList;
begin
  try
    strList := TStringList.Create;
    try
      strList.Text := TCryptingHelper.EncryptXML(AXmlFile);
      strList.SaveToFile(AFilePath);
    finally
      FreeAndNil(strList);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

class function TLicenceHelper.UpdateLicence(AHttpHelper: THttpHelper;
  ALicenceFile: IXMLDocument; CompanyId: Integer): string;
var
  encryptedLicence: string;
  CompanyLicenceUpdateDto : TCompanyLicenceUpdateDto;
  respCompanyLicence: TResponseDto<TCompanyLicenceDto>;
  jsonBody: string;
  restResponse : TRESTResponse;
begin
  Result := TLicenceErrors.leUnexpectedErrorOccured;

  encryptedLicence := TCryptingHelper.EncryptXML(ALicenceFile);

  CompanyLicenceUpdateDto := TCompanyLicenceUpdateDto.Create;
  try
    CompanyLicenceUpdateDto.CompanyId := CompanyId;
    CompanyLicenceUpdateDto.LicenceText := encryptedLicence;
    CompanyLicenceUpdateDto.LicenceCheckInterval := 0;
    jsonBody := TJson.ObjectToJsonString(CompanyLicenceUpdateDto);
  finally
    CompanyLicenceUpdateDto.Free;
  end;

  restResponse := AHttpHelper.Put('CompanyLicences', jsonBody);

  if (restResponse.StatusCode <> 200) then
  begin
    respCompanyLicence := TLicenceHelper.ParseToCustomResponse<TCompanyLicenceDto>(restResponse.Content);
    if respCompanyLicence = nil then
      exit;

    if (respCompanyLicence.Errors <> nil) and (respCompanyLicence.Errors.Count > 0) then
      Result := TLicenceHelper.ErrorListToString(respCompanyLicence.Errors);
  end
  else
    Result := '';

end;

class function TLicenceHelper.ErrorListToString(ErrorList: TList<string>): string;
var
  I: Integer;
begin
  if ErrorList = nil then
    exit;

  for I := 0 to ErrorList.Count - 1 do
  begin
    Result := Result + ErrorList.Items[I];
    if I <> (ErrorList.Count - 1) then
    Result := Result + sLineBreak;
  end;
end;

class function TLicenceHelper.AuthorizeLicenceServer(AHttpHelper: THttpHelper;
  AUsername, APassword: string): TResponseDto<TTokenDto>;
var
  userDto: TUserDto;
  jsonBody: string;
  restResponse: TRESTResponse;
begin
  Result := nil;

  userDto := TUserDto.Create;
  try
    userDto.Username := AUsername;
    userDto.Password := APassword;
    jsonBody := TJson.ObjectToJsonString(userDto);
  finally
    userDto.Free;
  end;

  try
    AHttpHelper.DisconnectAuth;
    restResponse := AHttpHelper.Post('Auth/CreateToken', jsonBody);
    AHttpHelper.ConnectAuth;
    Result := TLicenceHelper.ParseToCustomResponse<TTokenDto>(restResponse.Content);
  except on E: Exception do
    begin
      if Result = nil then
        Result := TResponseDto<TTokenDto>.Create;

      if Result.Errors = nil then
      begin
        Result.Errors := TList<string>.Create;
        Result.Errors.Add(E.Message);
      end;
    end;
  end;
end;

class function TLicenceHelper.AddDeviceToCompany(AHttpHelper: THttpHelper;
  CompanyId, ProductId: Integer; DeviceId: string): string;
var
  restResponse: TRESTResponse;
  jsonBody: string;
  respCompanyDevice: TResponseDto<TCompanyDeviceDto>;
  CompanyDeviceCreateDto: TCompanyDeviceCreateDto;
begin

  Result := TLicenceErrors.leUnexpectedErrorOccured;

  CompanyDeviceCreateDto := TCompanyDeviceCreateDto.Create;
  try
    CompanyDeviceCreateDto.DeviceUniqueId := DeviceId;
    CompanyDeviceCreateDto.CompanyId := CompanyID;
    CompanyDeviceCreateDto.ProductId := ProductID;

    jsonBody := TJson.ObjectToJsonString(CompanyDeviceCreateDto);
  finally
    CompanyDeviceCreateDto.Free;
  end;

  restResponse := AHttpHelper.Post('CompanyDevices', jsonBody);
  if restResponse.StatusCode <> 201 then
  begin
    respCompanyDevice := TLicenceHelper.ParseToCustomResponse<TCompanyDeviceDto>(restResponse.Content);
    if respCompanyDevice = nil then
      exit;

    if (respCompanyDevice.Errors <> nil) and (respCompanyDevice.Errors.Count > 0) then
      Result := TLicenceHelper.ErrorListToString(respCompanyDevice.Errors);
  end
  else
    Result := '';
end;

class function TLicenceHelper.AuthorizeLicenceServer(AHttpHelper: THttpHelper;
  ARefreshToken: string): TResponseDto<TTokenDto>;
var
  refreshTokenDto: TRefreshTokenDto;
  jsonBody: string;
  restResponse: TRESTResponse;
begin
  Result := nil;

  refreshTokenDto := TRefreshTokenDto.Create;
  try
    refreshTokenDto.Token := ARefreshToken;
    jsonBody := TJson.ObjectToJsonString(refreshTokenDto);
  finally
    refreshTokenDto.Free;
  end;

  try
    AHttpHelper.DisconnectAuth;
    restResponse := AHttpHelper.Post('Auth/CreateTokenByRefreshToken', jsonBody);
    AHttpHelper.ConnectAuth;
    Result := TLicenceHelper.ParseToCustomResponse<TTokenDto>(restResponse.Content);
  except on E: Exception do
    if Result.Errors = nil then
    begin
      Result.Errors := TList<string>.Create;
      Result.Errors.Add(E.Message);
    end;
  end;
end;

class function TLicenceHelper.GetJWTPayload(AJWTToken: string; const AJWTSecurityKey: string = ''): TJWTPayloadDto;
var
  LKey: TJWK;
  LToken: TJWT;
begin
  Result := nil;

  if Trim(AJWTToken) = '' then
    exit;

  try
    if not Trim(AJWTSecurityKey).IsEmpty then
      LKey := TJWK.Create(AJWTSecurityKey)
    else
      LKey := TJWK.Create(JWTSecurityKey);

    LToken := TJOSE.Verify(LKey,AJWTToken);

    if Assigned(LToken) then
    begin
      try
        if LToken.Verified then
        begin
          //Result := TJWTPayloadDto.Create;
          //Result.Role := LToken.Claims.JSON.GetValue<string>('http://schemas.microsoft.com/ws/2008/06/identity/claims/role');
          Result := TJson.JsonToObject<TJWTPayloadDto>(LToken.Claims.JSON);
          Result.Role := LToken.Claims.JSON.GetValue('http://schemas.microsoft.com/ws/2008/06/identity/claims/role').ToString.Replace('"','');
        end
        else
          Result := nil;
      finally
        LToken.Destroy;
      end;
    end;
  finally
    LKey.Destroy;
  end;

end;

class function TLicenceHelper.GetServerDate(AHttpHelper: THttpHelper): string;
var
  restResponse: TRESTResponse;
  responseDto: TResponseDto<TCurrentDateDto>;
  jsonValue: TJSONValue;
  I: Integer;
begin
  restResponse := AHttpHelper.Get('Auth/GetCurrentDateTime');
  responseDto := TLicenceHelper.ParseToCustomResponse<TCurrentDateDto>(restResponse.Content);

  if responseDto.Data = nil then
  begin
    Result := '';
    for I := 0 to responseDto.Errors.Count - 1 do
      Result := Result + responseDto.Errors.Items[I] + sLineBreak;
  end
  else
    Result := DateTimeToStr(responseDto.Data.Date);
end;

end.
