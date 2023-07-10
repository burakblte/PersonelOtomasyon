unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, Data.DB, Data.Win.ADODB, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, FMX.Ani, FMX.Objects,
  System.ImageList, FMX.ImgList, FMX.Layouts, System.Generics.Collections,fMx.MultiResBitmap,
  FMX.Effects;

type

  TPersonel = class
  private
    FPersonel_id: integer;
    FPersonel_adi: string;
    FPersonel_soyadi: string;
    FPersonel_yas: integer;
    FPersonel_cinsiyet: string;
  published
    property Personel_id: integer read FPersonel_id write FPersonel_id;
    property Personel_adi: string read FPersonel_adi write FPersonel_adi;
    property Personel_soyadi: string read FPersonel_soyadi write FPersonel_soyadi;
    property Personel_yas: integer read FPersonel_yas write FPersonel_yas;
    property Personel_cinsiyet: string read FPersonel_cinsiyet write FPersonel_cinsiyet;

  end;

  TPersonelList = class(TList<TPersonel>)
  public
    function GetById(AId: Integer): TPersonel;
  end;

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    RectAnimation1: TRectAnimation;
    grppersonad: TGroupBox;
    grppersonid: TGroupBox;
    grppersonsoyad: TGroupBox;
    grppersonyas: TGroupBox;
    grppersoncins: TGroupBox;
    RectAnimation2: TRectAnimation;
    adi: TEdit;
    soyadi: TEdit;
    id: TEdit;
    yas: TEdit;
    cinsiyet: TEdit;
    rctsil: TRectangle;
    rctkaydet: TRectangle;
    rctgüncelle: TRectangle;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    grdPersonel: TGridPanelLayout;
    Image1: TImage;
    imgIconList: TImageList;
    lytDetail: TLayout;
    rctDetailScrim: TRectangle;
    rctDetail: TRectangle;
    sheDialog: TShadowEffect;
    AnimDetailWidth: TFloatAnimation;
    AnimDetailHeight: TFloatAnimation;
    rctDialogContext: TRectangle;
    lytDialogButtons: TLayout;
    lytDialogCopy: TLayout;
    lblDialogCopy: TLabel;
    lytDialogClose: TLayout;
    lblDialogClose: TLabel;
    Rectangle1: TRectangle;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    procedure rctkaydetClick(Sender: TObject);
    procedure rctsilClick(Sender: TObject);
    procedure rctgüncelleClick(Sender: TObject);
    function AddPersonelToList(APersonelID,APersonelYas:integer;APersonelAdi,APersonelSoyadi,APersonelCinsiyet:string): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure LoadData;
    procedure DesignPersonelPage(APersonels: TList<TPersonel>; AColumnName :string);
    procedure PersonelUpdate(Sender: TObject);
    procedure ShowDetailModal;
    procedure HideDetailModal(Sender: TObject);
    procedure SaveDetailModal(Sender: TObject);
    procedure lytDialogCopyClick(Sender: TObject);
    procedure ClearGrid(AGrid : TGridPanelLayout);



  private
    PersonelList: TPersonelList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.rctsilClick(Sender: TObject);
begin
with adoquery1 do
  begin
     Sql.Text := 'delete from personel where personel_id= :id';
     parameters.ParamByName('id').Value := id.Text;
     execsql;
     close;
     sql.Text :='select * from personel';
     ShowMessage('Silme iþlemi baþarýlý!');
     open;
  end;
end;

procedure TForm2.SaveDetailModal(Sender: TObject); //Modal butona týklandýðýnda bildirim penceresidir.
begin
  AnimDetailHeight.Inverse := True;
  AnimDetailHeight.StopValue := rctDetail.Height;
  AnimDetailHeight.Start;
  lytDetail.Visible := False;
end;

procedure TForm2.ShowDetailModal;
begin
  lytDetail.Visible := True;
  AnimDetailHeight.Inverse := False;
  AnimDetailHeight.StartValue := 0;
  AnimDetailHeight.Start;
end;

procedure TForm2.rctkaydetClick(Sender: TObject);
begin
with AdoQuery1 do
  begin
    Sql.Text:= 'insert into personel (personel_id,personel_adi,personel_soyadi,personel_yas,personel_cinsiyet) values (:id,:adi,:soyadi,:yas,:cinsiyet)';
    parameters.ParamByName('id').Value:= id.Text;
    parameters.ParamByName('adi').Value := adi.text;
    parameters.ParamByName('soyadi').Value := soyadi.Text;
    parameters.ParamByName('yas').Value := yas.Text;
    parameters.ParamByName('cinsiyet').Value:= cinsiyet.Text;
    execsql;
    close;
    sql.Text := 'select * from personel';
    ShowMessage('Kayýt iþlemi baþarýlý!');
    open;
  end;
end;

function TForm2.AddPersonelToList(APersonelID, APersonelYas: integer;
  APersonelAdi, APersonelSoyadi, APersonelCinsiyet: string): Boolean; //A harfi ile baþlayanlar
                                                                      //Fonksiyonun propertyleri.
var                                                                   //Class içindeki fieldlerden
  LPersonel : TPersonel;                                              //olmalý.
begin
  LPersonel := TPersonel.Create; //TPersonelin özellikleri LPersonele geçti.
  LPersonel.Personel_id := APersonelID; //LPersonelin.Field'ini APersonelID'ye attý.
  LPersonel.Personel_adi := APersonelAdi;
  LPersonel.Personel_soyadi := APersonelSoyadi;
  LPersonel.Personel_yas := APersonelYas;
  LPersonel.Personel_cinsiyet := APersonelCinsiyet;
  PersonelList.Add(LPersonel); //PersonelListesine LPersonel Fieldlarýný doldurduðumuz bilgileri ekle.
  Result := True; //bool oluþturduk diye true.
end;
//
procedure TForm2.ClearGrid(AGrid: TGridPanelLayout);  //Bu kodlar refreshte kullanýlmaktadýr.
var
  i: Integer;
  control: TControl;
begin
  for i := AGrid.ControlsCount - 1 downto 0 do
  begin
    control := AGrid.ControlCollection.Items[i].Control;
    control.Destroy;
  end;

end;

procedure TForm2.DesignPersonelPage(APersonels:TList<TPersonel>;AColumnName:string);
var
  rctAlan, rctButton: TRectangle;
  lblAlan: TLabel;
  imgButton: TImage;
  grdAlanlar: TGridPanelLayout;
  lytButton: TLayout;
  rowcount: integer; //SATIR SAYISI
  LColumn: TGridPanelLayout.TColumnItem; //SÜTUN
  i: Integer;
  LRow: TGridPanelLayout.TRowItem; //SATIR
  item: TCustomBitmapItem;
  size: TSize;

begin
  grdPersonel.RowCollection.Clear; //gridpanel satýrlarýný siler.
  grdpersonel.ColumnCollection.Clear; //gridpanel sütunlarýný siler.
  rowcount := APersonels.Count+1; //satýr sayýsý bilinmediðinden deðiþken oluþturduk.
  grdPersonel.ColumnCollection.Add;
  grdPersonel.ColumnCollection.Add;

  grdPersonel.ColumnCollection.BeginUpdate;
  grdPersonel.ColumnCollection.Items[0].SizeStyle := TGridPanelLayout.TSizeStyle.Percent;
  grdPersonel.ColumnCollection.Items[1].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdPersonel.ColumnCollection.Items[0].Value := 100;
  grdPersonel.ColumnCollection.Items[1].Value := 50;
  grdPersonel.ColumnCollection.EndUpdate;

  grdPersonel.RowCollection.BeginUpdate; //her satýrda güncelleme yapar.
  for i := 0 to APersonels.Count  do
  begin
    LRow := grdPersonel.RowCollection.Add; //satýr ekledik.
    LRow.SizeStyle := TGridPanelLayout.TSizeStyle.Absolute; //size style.
    LRow.Value := 50; //size style deðeri verdik.

    rctAlan := TRectangle.Create(Self);
    rctalan.Align := TAlignLayout.Client;
    rctAlan.Parent := grdPersonel;
    rctalan.Width := 150;
    rctalan.XRadius := 0;
    rctalan.YRadius := 0;
    rctalan.Stroke.Thickness := 0;

    lblAlan := TLabel.Create(Self); //label create ettik.
    lblalan.Parent := rctalan; //label'i gride attýk.
    lblAlan.Align := TAlignLayout.Client; //labeli
    lblAlan.Margins.Rect := TRectF.Create(16,5,16,5); //4 yandan margins deðeri.
    lblAlan.StyledSettings := [TStyledSetting.Style];
    lblAlan.Font.Size := 14;
    lblAlan.Font.Family := 'Roboto';

    rctbutton := TRectangle.Create(self);
    rctbutton.Align := TAlignlayout.Client;
    rctbutton.Parent := grdPersonel;
    rctbutton.Width := 100;
    rctbutton.XRadius := 0;
    rctbutton.YRadius := 0;
    rctbutton.Stroke.Thickness := 0;

    lytButton := TLayout.Create(Self);
    lytButton.Parent := rctbutton;
    lytButton.Align := TAlignLayout.Client;
    lytButton.Margins.Rect := TRectF.Create(2,4,2,4);
    lytButton.HitTest := True;
    lytButton.OnClick := PersonelUpdate;

    if i=0 then
    begin
      lblAlan.Text := 'Personel Adý';
      grdPersonel.ControlCollection[0].ColumnSpan := 2;
      lytButton.HitTest := False;
    end
    else
    begin
      lytButton.Tag := APersonels.Items[i-1].Personel_id;
      lblAlan.Text := APersonels.Items[i-1].Personel_adi;
      lytButton.Hint :=  APersonels.Items[i-1].Personel_adi;
      lytButton.Tag := APersonels.Items[i-1].Personel_id;

      imgButton := TImage.Create(self);
      imgButton.Parent := lytbutton;
      imgButton.Align := TAlignLayout.Client;
      imgButton.Margins.Rect := TRectF.Create(12, 12, 12, 12);
      imgIconList.BitmapItemByName('updateBlack', item, size);
      imgButton.Bitmap := item.MultiResBitmap.Bitmaps[1.0];
      imgbutton.HitTest := False;
    end;

  end;

  grdPersonel.RowCollection.EndUpdate; //her satýrda güncellemeyi sonlandýrýr.

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  PersonelList := TPersonelList.Create;
  LoadData;
  DesignPersonelPage(PersonelList,'personel_adi');
end;

procedure TForm2.HideDetailModal(Sender: TObject);
begin
  AnimDetailHeight.Inverse := True;
  AnimDetailHeight.StopValue := rctDetail.Height;
  AnimDetailHeight.Start;
  lytDetail.Visible := False;
end;

procedure TForm2.LoadData; // Sql'den verilerimizi çekme iþlemini fonksiyona ekledik.
begin
 Adoquery1.SQL.Text:='select * from personel';
 Adoquery1.Open;

  PersonelList.Clear;

 while not Adoquery1.Eof do // eof = end of file. data bitene kadar devam et.
 begin
  AddPersonelToList(
  Adoquery1.FieldByName('personel_id').AsInteger,
  Adoquery1.FieldByName('personel_yas').AsInteger,
  Adoquery1.FieldByName('personel_adi').AsString,
  Adoquery1.FieldByName('personel_soyadi').AsString,
  Adoquery1.FieldByName('personel_cinsiyet').AsString
  );
  Adoquery1.Next;
 end;
end;

procedure TForm2.lytDialogCopyClick(Sender: TObject);
var
  LDialogLayout : TLayout;
  LDialogContent : TRectAngle;
  LSenderLayout : TLayout;
  LGridPanel : TGridPanelLayout;
  LGroup : TGroupBox;
  i : integer;
  j : integer;
  k : integer;
  d : integer;
  LPersonelAdi,LPersonelSoyadi : string;
  LPersonelYasi : integer;
  LEdit : TEdit;
begin
  // Child'tan - Parent'a
  //týkladýðýmýz component TLayout deðil ise çýkýþ yap.
  if not (sender.ClassType = TLayout) then
    exit;
  //Senderimizin TLayout tipinde olduðunu gördük.
  LSenderLayout := Sender as TLayout;

  //SenderLayoutumuzun parentinin classtype'i Tlayout deðil ise çýkýþ yap.
  if not (LSenderLayout.Parent.ClassType = TLayout) then
    exit;
  //Senderimizin parentinin tlayout olduðunu öðrendik.
  LDialogLayout := LSenderLayout.Parent as TLayout;

 //**
  //LDialogLayoutumuzun parentinin classtypei rectangle deðil ise çýkýþ yap.
  if not (LDialogLayout.Parent.ClassType = TRectangle) then
    exit;
  //LDialoglayotumuzun parentinin trectangle olduðunu öðrendik ve Dialogcontente atadýk.
  LDialogContent := LDialogLayout.Parent as TRectAngle;


  //Genel parentimiz dialogcontent olduðu için onun childlerini gezdik (count-1)
  for i := 0 to LDialogContent.Children.Count -1 do
  begin
  //Dialogcontentimizin childlerinin içinde gridpanellayout olaný arýyoruz. Deðilse çýk.
    if not (LDialogContent.Children[i].ClassType = TGridPanelLayout) then
      continue;

     //Gridpaneli bulduk contentin childlerini gez ve gridpanellayout ??????
     LGridPanel := LDialogContent.Children[i] as TGridPanelLayout;

    for j := 0 to LGridPanel.ControlCollection.Count -1 do
    begin
      if not (LGridPanel.Controls[j].ClassType = TGroupBox) then
        continue;

      LGroup := LGridPanel.Controls[j] as TGroupBox;

      for k := 0 to LGroup.Children.Count -1 do
      begin
        if not (LGroup.Children[k].ClassType = TEdit) then
          continue;

          LEdit := LGroup.Children[k] as TEdit;

        if LGroup.Text = 'Personel Adý' then
        begin
         LPersonelAdi := LEdit.Text;
        end;

        if LGroup.Text = 'Personel Soyad' then
        begin
         LPersonelSoyadi := LEdit.Text;
        end;

        if LGroup.Text = 'Personel Yaþ' then
        begin
         LPersonelYasi := LEdit.Text.ToInteger;
        end;

      end;

    end;

  end;
//  ShowMessage(LSenderLayout.Tag.ToString);
  Adoquery1.SQL.Text := 'update personel set personel_adi= :pPersonelAd where personel_id= :pPersonelID';
  AdoQuery1.Parameters.ParamByName('pPersonelID').Value := LSenderLayout.Tag.ToString;
  Adoquery1.Parameters.ParamByName('pPersonelAd').Value := LPersonelAdi;
  Adoquery1.ExecSQL;

  if LGridPanel = nil then
    exit;
    
  ClearGrid(grdPersonel);
  HideDetailModal(Sender);   
  LoadData();
  DesignPersonelPage(PersonelList,'Personel Adý');
end;

procedure TForm2.PersonelUpdate(Sender: TObject);
var
  edtInfo : TEdit;
  grpName : TGroupbox;
  i : integer;
  rctAlan, rctButton: TRectangle;
  lblAlan: TLabel;
  imgButton: TImage;
  grdDetail: TGridPanelLayout;
  lytButton: TLayout;
  rowcount: integer; //SATIR SAYISI
  LColumn: TGridPanelLayout.TColumnItem; //SÜTUN
  LRow: TGridPanelLayout.TRowItem; //SATIR
  item: TCustomBitmapItem;
  size: TSize;
  LPersonelId: Integer;
  LPersonel: TPersonel;
  lytDetailCopy : TLayout;
  grpSurname : TGroupbox;
  grpAge : TGroupbox;
begin
  LPersonelId := TLayout(Sender).Tag;
  LPersonel := PersonelList.GetById(LPersonelId);

  if LPersonel = nil then
  begin
    ShowMessage('Personel bulunamadý.');
    exit;
  end;
  //grid rowlarýný artýr.
  //bilgiler gelsin.
  ShowDetailModal();
  grdDetail := TGridPanelLayout.Create(self);
  grdDetail.Parent := rctDialogContext;
  grdDetail.Align := TAlignLayout.Client;
  grdDetail.ColumnCollection.Clear;
  grdDetail.RowCollection.Clear;
  grdDetail.ColumnCollection.Add;
  grdDetail.RowCollection.Add;
  grdDetail.RowCollection.Add;
  grdDetail.RowCollection.Add;
  grdDetail.RowCollection.BeginUpdate;
  grdDetail.RowCollection.Items[0].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdDetail.RowCollection.Items[0].Value := 50;
  grdDetail.RowCollection.Items[1].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdDetail.RowCollection.Items[1].Value := 50;
  grdDetail.RowCollection.Items[2].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdDetail.RowCollection.Items[2].Value := 50;
  grdDetail.RowCollection.EndUpdate;

  grpName := TGroupbox.Create(self);
  grpName.Parent := grdDetail;
  grpName.Align := TAlignLayout.Client;
  grpName.Text := 'Personel Adý';
  grpName.Padding.Top := 20;

  edtInfo := TEdit.Create(self);
  edtInfo.Parent := grpName;
  edtInfo.Align := TAlignLayout.Client;
  edtInfo.Text := LPersonel.Personel_adi;

  grpSurname := TGroupbox.Create(self);
  grpSurname.Parent := grdDetail;
  grpSurname.Align := TAlignLayout.Client;
  grpSurname.Text := 'Personel Soyad';
  grpSurname.Padding.Top := 20;

  edtInfo := TEdit.Create(self);
  edtInfo.Parent := grpSurname;
  edtInfo.Align := TAlignLayout.Client;
  edtInfo.Text := LPersonel.Personel_soyadi;

  grpAge := TGroupbox.Create(self);
  grpAge.Parent := grdDetail;
  grpAge.Align := TAlignLayout.Client;
  grpAge.Padding.Top := 20;
  grpAge.Text := 'Personel Yaþ';

  edtInfo := TEdit.Create(self);
  edtInfo.Parent := grpAge;
  edtInfo.Align := TAlignLayout.Client;
  edtInfo.Text := LPersonel.Personel_yas.ToString;

  lytDialogCopy.Tag := LPersonelId;

end;

procedure TForm2.rctgüncelleClick(Sender: TObject);
begin
with Adoquery1 do
  begin
    Sql.Text := 'update personel set personel_id= :a';
    parameters.ParamByName('a').Value := id.Text;
    Sql.Text := 'update personel set personel_adi= :b';
    parameters.ParamByName('b').Value := adi.Text;
    Sql.Text := 'update personel set personel_soyadi= :c';
    parameters.ParamByName('c').Value := soyadi.Text;
    Sql.Text := 'update personel set personel_yas= :d';
    parameters.ParamByName('d').Value := yas.Text;
    Sql.Text := 'update personel set personel_cinsiyet= :e';
    parameters.ParamByName('e').Value := cinsiyet.Text;

    execsql;
    close;
    sql.Text:='select * from personel';
    showmessage('Güncelleme iþlemi baþarýlý!');
    open;
  end;
end;

{ TPersonelList }

function TPersonelList.GetById(AId: Integer): TPersonel;
begin
  Result := nil;

  for var LPersonel in Self do
  begin
    if LPersonel.Personel_id = AId then
    begin
      Result := LPersonel;
      exit;
    end;
  end;
end;

end.

