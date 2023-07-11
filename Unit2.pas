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
  FMX.Effects, FMX.Memo.Types, FMX.Memo;

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
    RectAnimation2: TRectAnimation;
    grdPersonel: TGridPanelLayout;
    Image1: TImage;
    imgIconList: TImageList;
    lytDetail: TLayout;
    rctDetailScrim: TRectangle;
    rctDetail: TRectangle;
    sheDialog: TShadowEffect;
    AnimDetailWidth: TFloatAnimation;
    AnimDetailHeight: TFloatAnimation;
    rctDialogContent: TRectangle;
    lytDialogButtons: TLayout;
    lytDialogCopy: TLayout;
    lblDialogCopy: TLabel;
    lytDialogClose: TLayout;
    lblDialogClose: TLabel;
    Label1: TLabel;
    rctPagination: TRectangle;
    btnLast: TLayout;
    imgLast: TImage;
    btnNext: TLayout;
    imgNext: TImage;
    btnPrevious: TLayout;
    imgPrevious: TImage;
    btnFirst: TLayout;
    imgFirst: TImage;
    lytPage: TLayout;
    lblPage: TLabel;
    grpAge: TGroupBox;
    grpName: TGroupBox;
    edtName: TEdit;
    grpSurname: TGroupBox;
    edtSurname: TEdit;
    lytTopBox: TLayout;
    lytBack: TLayout;
    lytAdding: TLayout;
    imgBack: TImage;
    rctSearch: TRectangle;
    imgNewCompany: TImage;
    Layout4: TLayout;
    imgSearch: TImage;
    edtSearch: TEdit;
    Label2: TLabel;
    edtAge: TEdit;
    Layout1: TLayout;
    Layout2: TLayout;
    function AddPersonelToList(APersonelID,APersonelYas:integer;APersonelAdi,APersonelSoyadi,APersonelCinsiyet:string): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure LoadData;
    procedure DesignPersonelPage(APersonels: TList<TPersonel>; AColumnName :string);
    procedure PersonelUpdate(Sender: TObject);
    procedure ShowDetailModal;
    procedure HideDetailModal(Sender: TObject);
//    procedure SaveDetailModal(Sender: TObject);
    procedure lytDialogCopyClick(Sender: TObject);
    procedure ClearGrid(AGrid : TGridPanelLayout);
    procedure Rectangle1Click(Sender: TObject);
    procedure FillPersonelInformation(APersonel :TPersonel);
    procedure lytAddingClick(Sender: TObject);
    procedure rctDetailScrimClick(Sender: TObject);
    procedure DeletePersonel(Sender: TObject);



  private
    PersonelList: TPersonelList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
const
  btnCaptionUpdate = 'Güncelle';
  btnCaptionInsert = 'Ekle';

implementation

{$R *.fmx}

//procedure TForm2.SaveDetailModal(Sender: TObject); //Modal butona týklandýðýnda bildirim penceresidir.
//begin
//  AnimDetailHeight.Inverse := True;
//  AnimDetailHeight.StopValue := rctDetail.Height;
//  AnimDetailHeight.Start;
//  lytDetail.Visible := False;
//end;

procedure TForm2.ShowDetailModal;
begin
  lytDetail.Visible := True;
  AnimDetailHeight.Inverse := False;
  AnimDetailHeight.StartValue := 0;
  AnimDetailHeight.Start;
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

procedure TForm2.DeletePersonel(Sender: TObject);
var
  LPersonelId: Integer;
  LPersonel: TPersonel;
  Response: Integer;
begin
  LPersonelId := TLayout(Sender).Tag;
  LPersonel := PersonelList.GetById(LPersonelId);

  ShowMessage('Silmek istediðinizden emin misiniz?');

  AdoQuery1.SQL.Text := 'delete from personel where personel_id= :pPersonelId';
  AdoQuery1.Parameters.ParamByName('pPersonelId').Value := LPersonel.Personel_id;
  AdoQuery1.ExecSQL;

  ClearGrid(grdPersonel);
  LoadData();
  DesignPersonelPage(PersonelList,'Personel Adý');
end;

procedure TForm2.DesignPersonelPage(APersonels:TList<TPersonel>;AColumnName:string);
var
  rctAlan, rctButton: TRectangle;
  lblAlan: TLabel;
  imgButton: TImage;
  grdAlanlar: TGridPanelLayout;
  lytUpdate, lytDelete: TLayout;
  rowcount: integer; //SATIR SAYISI
  LColumn: TGridPanelLayout.TColumnItem; //SÜTUN
  i: Integer;
  LRow: TGridPanelLayout.TRowItem; //SATIR
  item: TCustomBitmapItem;
  size: TSize;
  rctbutton2 : TRectangle;

begin
  grdPersonel.RowCollection.Clear; //gridpanel satýrlarýný siler.
  grdpersonel.ColumnCollection.Clear; //gridpanel sütunlarýný siler.
  rowcount := APersonels.Count+1; //satýr sayýsý bilinmediðinden deðiþken oluþturduk.
  grdPersonel.ColumnCollection.Add;
  grdPersonel.ColumnCollection.Add;
  grdPersonel.ColumnCollection.Add;

  grdPersonel.ColumnCollection.BeginUpdate;
  grdPersonel.ColumnCollection.Items[0].SizeStyle := TGridPanelLayout.TSizeStyle.Percent;
  grdPersonel.ColumnCollection.Items[1].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdPersonel.ColumnCollection.Items[2].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
  grdPersonel.ColumnCollection.Items[0].Value := 100;
  grdPersonel.ColumnCollection.Items[1].Value := 50;
  grdPersonel.ColumnCollection.Items[2].Value := 50;
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

    lytUpdate := TLayout.Create(Self);
    lytUpdate.Parent := rctbutton;
    lytUpdate.Align := TAlignLayout.Client;
    lytUpdate.Margins.Rect := TRectF.Create(2,4,2,4);
    lytUpdate.HitTest := True;
    lytUpdate.OnClick := PersonelUpdate;

    rctbutton := TRectangle.Create(self);
    rctbutton.Align := TAlignLayout.Client;
    rctbutton.Parent := grdPersonel;
    rctbutton.Width := 100;
    rctbutton.XRadius := 0;
    rctbutton.YRadius := 0;
    rctbutton.Stroke.Thickness := 0;

    lytDelete := TLayout.Create(Self);
    lytDelete.Parent := rctbutton;
    lytDelete.Align := TAlignLayout.Client;
    lytDelete.Margins.Rect := TRectF.Create(2,4,2,4);
    lytDelete.HitTest := True;
    lytDelete.OnClick := DeletePersonel;

    if i=0 then
    begin
      lblAlan.Text := 'Personel Adý';
      grdPersonel.ControlCollection[0].ColumnSpan := 2;
      lytUpdate.HitTest := False;
    end
    else
    begin
      lytUpdate.Tag := APersonels.Items[i-1].Personel_id;
      lblAlan.Text := APersonels.Items[i-1].Personel_adi;
      lytUpdate.Hint :=  APersonels.Items[i-1].Personel_adi;
      lytUpdate.Tag := APersonels.Items[i-1].Personel_id;
      lytDelete.Tag := APersonels.Items[i-1].Personel_id;

      imgButton := TImage.Create(self);
      imgButton.Parent := lytUpdate;
      imgButton.Align := TAlignLayout.Client;
      imgButton.Margins.Rect := TRectF.Create(12, 12, 12, 12);
      imgIconList.BitmapItemByName('updateBlack', item, size);
      imgButton.Bitmap := item.MultiResBitmap.Bitmaps[1.0];
      imgbutton.HitTest := False;

      imgButton := TImage.Create(self);
      imgButton.Parent := lytDelete;
      imgButton.Align := TAlignLayout.Client;
      imgButton.Margins.Rect := TRectF.Create(12, 12, 12, 12);
      imgIconList.BitmapItemByName('deleteBlack', item, size);
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

procedure TForm2.lytAddingClick(Sender: TObject);
begin
  ShowDetailModal();
  FillPersonelInformation(nil);
end;

procedure TForm2.lytDialogCopyClick(Sender: TObject);
var
  LSenderLayout: TLayout;
begin
//  // Child'tan - Parent'a
//  //týkladýðýmýz component TLayout deðil ise çýkýþ yap.
  if not (sender.ClassType = TLayout) then
    exit;
  //Senderimizin TLayout tipinde olduðunu gördük.
  LSenderLayout := Sender as TLayout;
//
//  //SenderLayoutumuzun parentinin classtype'i Tlayout deðil ise çýkýþ yap.
//  if not (LSenderLayout.Parent.ClassType = TLayout) then
//    exit;
//  //Senderimizin parentinin tlayout olduðunu öðrendik.
//  LDialogLayout := LSenderLayout.Parent as TLayout;
//
// //**
//  //LDialogLayoutumuzun parentinin classtypei rectangle deðil ise çýkýþ yap.
//  if not (LDialogLayout.Parent.ClassType = TRectangle) then
//    exit;
//  //LDialoglayotumuzun parentinin trectangle olduðunu öðrendik ve Dialogcontente atadýk.
//  LDialogContent := LDialogLayout.Parent as TRectAngle;
//
//
//  //Genel parentimiz dialogcontent olduðu için onun childlerini gezdik (count-1)
//  for i := 0 to LDialogContent.Children.Count -1 do
//  begin
//  //Dialogcontentimizin childlerinin içinde gridpanellayout olaný arýyoruz. Deðilse çýk.
//    if not (LDialogContent.Children[i].ClassType = TGridPanelLayout) then
//      continue;
//
//     //Gridpaneli bulduk contentin childlerini gez ve gridpanellayout ??????
//     LGridPanel := LDialogContent.Children[i] as TGridPanelLayout;
//
//    for j := 0 to LGridPanel.ControlCollection.Count -1 do
//    begin
//      if not (LGridPanel.Controls[j].ClassType = TGroupBox) then
//        continue;
//
//      LGroup := LGridPanel.Controls[j] as TGroupBox;
//
//      for k := 0 to LGroup.Children.Count -1 do
//      begin
//        if not (LGroup.Children[k].ClassType = TEdit) then
//          continue;
//
//          LEdit := LGroup.Children[k] as TEdit;

//        if LGroup.Text = 'Personel Adý' then
//        begin
//         LPersonelAdi := LEdit.Text;
//        end;
//
//        if LGroup.Text = 'Personel Soyad' then
//        begin
//         LPersonelSoyadi := LEdit.Text;
//        end;
//
//        if LGroup.Text = 'Personel Yaþ' then
//        begin
//         LPersonelYasi := LEdit.Text.ToInteger;
//        end;

//      end;
//
//    end;

//  end;

//  ShowMessage(LSenderLayout.Tag.ToString);
    if lblDialogCopy.Text = btnCaptionUpdate then
    begin
      Adoquery1.SQL.Text := 'update personel set personel_adi= :pPersonelAd, personel_soyadi= :pPersonelSoyad, personel_yas= :pPersonelYas where personel_id= :pPersonelID';
      AdoQuery1.Parameters.ParamByName('pPersonelID').Value := LSenderLayout.Tag.ToString;
      Adoquery1.Parameters.ParamByName('pPersonelAd').Value := edtName.Text;
      AdoQuery1.Parameters.ParamByName('pPersonelSoyad').Value := edtSurname.Text;
      AdoQuery1.Parameters.ParamByName('pPersonelYas').Value := edtAge.Text;
      Adoquery1.ExecSQL;
    end
    else if lblDialogCopy.Text = btnCaptionInsert then
    begin
      AdoQuery1.SQL.Text := 'insert into personel (personel_adi, personel_soyadi, personel_yas) values (:personeladi, :personelsoyadi, :personelyas)';
      AdoQuery1.Parameters.ParamByName('personeladi').Value := edtName.Text;
      AdoQuery1.Parameters.ParamByName('personelsoyadi').Value := edtSurname.Text;
      AdoQuery1.Parameters.ParamByName('personelyas').Value := edtAge.Text;
      AdoQuery1.ExecSQL;
    end;

  ClearGrid(grdPersonel);
  HideDetailModal(Sender);
  LoadData();
  DesignPersonelPage(PersonelList,'Personel Adý');
end;

procedure TForm2.FillPersonelInformation(APersonel :TPersonel);

begin
ShowDetailModal();
//  grdDetail := TGridPanelLayout.Create(self);
//  grdDetail.Parent := rctDialogContext;
//  grdDetail.Align := TAlignLayout.Client;
//  grdDetail.ColumnCollection.Clear;
//  grdDetail.RowCollection.Clear;
//  grdDetail.ColumnCollection.Add;
//  grdDetail.RowCollection.Add;
//  grdDetail.RowCollection.Add;
//  grdDetail.RowCollection.Add;
//  grdDetail.RowCollection.BeginUpdate;
//  grdDetail.RowCollection.Items[0].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
//  grdDetail.RowCollection.Items[0].Value := 50;
//  grdDetail.RowCollection.Items[1].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
//  grdDetail.RowCollection.Items[1].Value := 50;
//  grdDetail.RowCollection.Items[2].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
//  grdDetail.RowCollection.Items[2].Value := 50;
//  grdDetail.RowCollection.EndUpdate;
//
//  grpName := TGroupbox.Create(self);
//  grpName.Parent := grdDetail;
//  grpName.Align := TAlignLayout.Client;
//  grpName.Text := 'Personel Adý';
//  grpName.Padding.Top := 20;
//
//  edtName := TEdit.Create(self);
//  edtName.Parent := grpName;
//  edtName.Align := TAlignLayout.Client;
//
//  grpSurname := TGroupbox.Create(self);
//  grpSurname.Parent := grdDetail;
//  grpSurname.Align := TAlignLayout.Client;
//  grpSurname.Padding.Top := 20;
//  grpSurname.Text := 'Personel Soyad';
//
//  edtSurname := TEdit.Create(self);
//  edtSurname.Parent := grpSurname;
//  edtSurname.Align := TAlignLayout.Client;
//
//  grpAge := TGroupbox.Create(self);
//  grpAge.Parent := grdDetail;
//  grpAge.Align := TAlignLayout.Client;
//  grpAge.Padding.Top := 20;
//  grpAge.Text := 'Personel Yaþ';
//
//  edtAge := TEdit.Create(self);
//  edtAge.Parent := grpAge;
//  edtAge.Align := TAlignLayout.Client;


  if APersonel <> nil then
  begin
    edtName.Text := APersonel.Personel_adi;
    edtSurname.Text := APersonel.FPersonel_soyadi;
    edtAge.Text := APersonel.Personel_yas.ToString;
    lblDialogCopy.Text := btnCaptionUpdate;
  end
  else
  begin
    edtName.Text := '';
    edtSurname.Text := '';
    edtAge.Text := '';
    lblDialogCopy.Text := btnCaptionInsert;
  end;

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
  FillPersonelInformation(LPersonel);
  lytDialogCopy.Tag := LPersonelId;

end;

procedure TForm2.rctDetailScrimClick(Sender: TObject);
begin

end;

//////////////////////////////////////////////////
procedure TForm2.Rectangle1Click(Sender: TObject);
begin

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

