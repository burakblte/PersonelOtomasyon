program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ElAES in 'ElAES.pas',
  LicenceEntities in 'LicenceEntities.pas',
  LicenceHelper in 'LicenceHelper.pas',
  JOSE.Encoding.Base64 in 'JWTLib\Common\JOSE.Encoding.Base64.pas',
  JOSE.Hashing.HMAC in 'JWTLib\Common\JOSE.Hashing.HMAC.pas',
  JOSE.OpenSSL.Headers in 'JWTLib\Common\JOSE.OpenSSL.Headers.pas',
  JOSE.Signing.Base in 'JWTLib\Common\JOSE.Signing.Base.pas',
  JOSE.Signing.ECDSA in 'JWTLib\Common\JOSE.Signing.ECDSA.pas',
  JOSE.Signing.RSA in 'JWTLib\Common\JOSE.Signing.RSA.pas',
  JOSE.Types.Arrays in 'JWTLib\Common\JOSE.Types.Arrays.pas',
  JOSE.Types.Bytes in 'JWTLib\Common\JOSE.Types.Bytes.pas',
  JOSE.Types.JSON in 'JWTLib\Common\JOSE.Types.JSON.pas',
  JOSE.Types.Utils in 'JWTLib\Common\JOSE.Types.Utils.pas',
  JOSE.Builder in 'JWTLib\JOSE\JOSE.Builder.pas',
  JOSE.Consumer in 'JWTLib\JOSE\JOSE.Consumer.pas',
  JOSE.Consumer.Validators in 'JWTLib\JOSE\JOSE.Consumer.Validators.pas',
  JOSE.Context in 'JWTLib\JOSE\JOSE.Context.pas',
  JOSE.Core.Base in 'JWTLib\JOSE\JOSE.Core.Base.pas',
  JOSE.Core.Builder in 'JWTLib\JOSE\JOSE.Core.Builder.pas',
  JOSE.Core.JWA.Compression in 'JWTLib\JOSE\JOSE.Core.JWA.Compression.pas',
  JOSE.Core.JWA.Encryption in 'JWTLib\JOSE\JOSE.Core.JWA.Encryption.pas',
  JOSE.Core.JWA.Factory in 'JWTLib\JOSE\JOSE.Core.JWA.Factory.pas',
  JOSE.Core.JWA in 'JWTLib\JOSE\JOSE.Core.JWA.pas',
  JOSE.Core.JWA.Signing in 'JWTLib\JOSE\JOSE.Core.JWA.Signing.pas',
  JOSE.Core.JWE in 'JWTLib\JOSE\JOSE.Core.JWE.pas',
  JOSE.Core.JWK in 'JWTLib\JOSE\JOSE.Core.JWK.pas',
  JOSE.Core.JWS in 'JWTLib\JOSE\JOSE.Core.JWS.pas',
  JOSE.Core.JWT in 'JWTLib\JOSE\JOSE.Core.JWT.pas',
  JOSE.Core.Parts in 'JWTLib\JOSE\JOSE.Core.Parts.pas',
  JOSE.Producer in 'JWTLib\JOSE\JOSE.Producer.pas',
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
