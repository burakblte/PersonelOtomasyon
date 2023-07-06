unit LicenceEntities;

interface

uses
  System.Generics.Collections, SysUtils, System.JSON, System.Rtti;

type
  TUserDto = class
    private
      fUsername: string;
      fPassword: string;
    public
      property Username: string read fUsername write fUsername;
      property Password: string read fPassword write fPassword;
  end;

  TKeyValueDto = class
    private
      fKey, fValue : string;
    public
      property Key: string read fKey write fKey;
      property Value: string read fValue write fValue;
  end;

  TRefreshTokenDto = class
    private
      fToken: string;
    public
      property Token: string read fToken write fToken;
  end;

  TTokenDto = class
    private
      fAccessToken, fRefreshToken: string;
      fAccessTokenExpiration, fRefreshTokenExpiration: TDateTime;
    public
      property AccessToken: string read fAccessToken write fAccessToken;
      property RefreshToken: string read fRefreshToken write fRefreshToken;
      property AccessTokenExpiration: TDateTime read fAccessTokenExpiration write fAccessTokenExpiration;
      property RefreshTokenExpiration: TDateTime read fRefreshTokenExpiration write fRefreshTokenExpiration;
  end;

  TCurrentDateDto = class
    private
      fDate: TDateTime;
    public
      property Date: TDateTime read fDate write fDate;
  end;
  TJWTPayloadDto = class
  private
    fuser, frole, fjti, fiss: string;
    fcompanyID: Integer;
    fnbf, fexp: Double;
  public
    property User: string read fuser write fuser;
    property Role: string read frole write frole;
    property CompanyID: Integer read fcompanyID write fcompanyID;
    property JTI: string read fjti write fjti;
    property NBF: Double read fnbf write fnbf;
    property EXP: Double read fexp write fexp;
    property ISS: string read fiss write fiss;
  end;

  TUserCompanyUpdateDto = class
  private
    fUsername, fPassword, fRole: string;
    fCompanyID: Integer;
    fFullName: string;
    fEmail: string;
    fPhone: string;
  public
    property Username: string read fUsername write fUsername;
    property Password: string read fPassword write fPassword;
    property Role: string read fRole write fRole;
    property CompanyId: Integer read fCompanyID write fCompanyID;
    property FullName: string read fFullName write fFullName;
    property Email: string read fEmail write fEmail;
    property Phone: string read fPhone write fPhone;
  end;

  TProductDto = class
  private
    fid: Integer;
    fProductName: string;
  public
    property Id: Integer read fid write fid;
    property ProductName: string read fProductName write fProductName;
  end;

  TProductCreateDto = class
  private
    fProductName: string;
  published
    property ProductName: string read fProductName write fProductName;
  end;

  TCompanyDto = class
  private
    fid: Integer;
    fCompanyName: string;
  public
    property Id: Integer read fid write fid;
    property CompanyName: string read fCompanyName write fCompanyName;
  end;

  TCompanyCreateDto = class
  private
    fCompanyName: string;
  published
    property CompanyName: string read fCompanyName write fCompanyName;
  end;

  TUserCompanyDto = class
  private
    fUsername: string;
    fRole: string;
    fFullName: string;
    fEmail: string;
    fPhone: string;
    fCompany: TCompanyDto;
  published
    property Username: string read fUsername write fUsername;
    property Role: string read fRole write fRole;
    property FullName: string read fFullName write fFullName;
    property Email: string read fEmail write fEmail;
    property Phone: string read fPhone write fPhone;
    property Company: TCompanyDto read fCompany write fCompany;
  end;

  TCompanyLicenceBaseDto = class
  private
    fLicenceText: string;
    fLicenceCheckInterval: Integer;
    fLicenceCheckReminder: Integer;
  published
    property LicenceText: string read fLicenceText write fLicenceText;
    property LicenceCheckInterval: Integer read fLicenceCheckInterval write fLicenceCheckInterval;
    property LicenceCheckReminder: Integer read fLicenceCheckReminder write fLicenceCheckReminder;
  end;

  TCompanyLicenceDto = class(TCompanyLicenceBaseDto)
  private
    fid: Integer;
    fCompany: TCompanyDto;
  published
    property Id: Integer read fid write fid;
    property Company: TCompanyDto read fCompany write fCompany;
  end;

  TCompanyLicenceUpdateDto = class(TCompanyLicenceBaseDto)
  private
    fid: Integer;
    fCompanyId: Integer;
  published
    property Id: Integer read fid write fid;
    property CompanyId: Integer read fCompanyId write fCompanyId;
  end;

  TCompanyLicenceCreateDto = class(TCompanyLicenceBaseDto)
  private
    fCompanyId: Integer;
  published
    property CompanyId: Integer read fCompanyId write fCompanyId;
  end;

  TModuleProgramBaseDto = class
  private
    fModuleNumber: Integer;
    fModuleName: string;
    fParentModuleNumber: Integer;
    fFormId: Integer;
    fFormName: string;
    fFormFactor: Integer;
    fisActive: boolean;
  published
    property ModuleNumber: Integer read fModuleNumber write fModuleNumber;
    property ModuleName: string read fModuleName write fModuleName;
    property ParentModuleNumber: Integer read fParentModuleNumber write fParentModuleNumber;
    property FormId: Integer read fFormId write fFormId;
    property FormName: string read fFormName write fFormName;
    property FormFactor: Integer read fFormFactor write fFormFactor;
    property IsActive: boolean read fisActive write fisActive;
  end;

  TModuleProgramDto = class(TModuleProgramBaseDto)
  private
    fid: Integer;
    fProduct: TProductDto;
  published
    property Id: Integer read fid write fid;
    property Product: TProductDto read fProduct write fProduct;
  end;

  TModuleProgramWithChildsDto = class(TModuleProgramBaseDto)
  private
    fid: Integer;
    fModuleProgramChilds: TArray<TModuleProgramWithChildsDto>;
  published
    property Id: Integer read fid write fid;
    property ModuleProgramChilds: TArray<TModuleProgramWithChildsDto> read fModuleProgramChilds write fModuleProgramChilds;
  end;

  TModuleProgramCreateDto = class
  private
    fModuleNumber: Integer;
    fModuleName: string;
    fParentModuleNumber: Integer;
    fFormId: Integer;
    fFormName: string;
    fFormFactor: Integer;
    fisActive: boolean;
    fProductId: Integer;
  published
    property ModuleNumber: Integer read fModuleNumber write fModuleNumber;
    property ModuleName: string read fModuleName write fModuleName;
    property ParentModuleNumber: Integer read fParentModuleNumber write fParentModuleNumber;
    property FormId: Integer read fFormId write fFormId;
    property FormName: string read fFormName write fFormName;
    property FormFactor: Integer read fFormFactor write fFormFactor;
    property IsActive: boolean read fisActive write fisActive;
    property ProductId: Integer read fProductId write fProductId;
  end;

  TModuleProgramUpdateDto = class
    private
      fModuleNumber: Integer;
      fModuleName: string;
      fParentModuleNumber: Integer;
      fFormId: Integer;
      fFormName: string;
      fFormFactor: Integer;
      fisActive: boolean;
      fid: Integer;
      fProductId: Integer;
    published
      property ModuleNumber: Integer read fModuleNumber write fModuleNumber;
      property ModuleName: string read fModuleName write fModuleName;
      property ParentModuleNumber: Integer read fParentModuleNumber write fParentModuleNumber;
      property FormId: Integer read fFormId write fFormId;
      property FormName: string read fFormName write fFormName;
      property FormFactor: Integer read fFormFactor write fFormFactor;
      property IsActive: boolean read fisActive write fisActive;
      property Id: Integer read fid write fid;
      property ProductId: Integer read fProductId write fProductId;
  end;

  TExtensionModuleDto = class
  private
    fid: Integer;
    fModuleName: string;
    fProduct: TProductDto;
  published
    property Id: Integer read fid write fid;
    property ModuleName: string read fModuleName write fModuleName;
    property Product: TProductDto read fProduct write fProduct;
  end;

  TExtensionModuleUpdateDto = class
  private
    fid: Integer;
    fModuleName: string;
    fProductId: Integer;
  published
    property Id: Integer read fid write fid;
    property ModuleName: string read fModuleName write fModuleName;
    property ProductId: Integer read fProductId write fProductId;
  end;

  TExtensionModuleCreateDto = class
  private
    fModuleName: string;
    fProductId: Integer;
  published
    property ModuleName: string read fModuleName write fModuleName;
    property ProductId: Integer read fProductId write fProductId;
  end;

  TCompanyExtensionModuleBaseDto = class
  private
    fExpiration: TDateTime;
    fLicenceCount: Integer;
    fDefaultLicenceCount: Integer;
  published
    property Expiration: TDateTime read fExpiration write fExpiration;
    property LicenceCount: Integer read fLicenceCount write fLicenceCount;
    property DefaultLicenceCount: Integer read fDefaultLicenceCount write fDefaultLicenceCount;
  end;

  TCompanyExtensionModuleDto = class(TCompanyExtensionModuleBaseDto)
  private
    fid: Integer;
    fCompany: TCompanyDto;
    fExtensionModule: TExtensionModuleDto;
  published
    property Id: Integer read fid write fid;
    property Company: TCompanyDto read fCompany write fCompany;
    property ExtensionModule: TExtensionModuleDto read fExtensionModule write fExtensionModule;
  end;

  TCompanyExtensionModuleCreateDto = class(TCompanyExtensionModuleBaseDto)
  private
    fCompanyId: Integer;
    fExtensionModuleId: Integer;
  published
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ExtensionModuleId: Integer read fExtensionModuleId write fExtensionModuleId;
  end;

  TCompanyExtensionModuleUpdateDto = class(TCompanyExtensionModuleCreateDto)
  private
    fid: Integer;
  published
    property Id: Integer read fid write fid;
  end;


  TCompanyModuleProgramDto = class
  private
    fid: Integer;
    fCompany : TCompanyDto;
    fModuleProgram  : TModuleProgramDto;
    fisSold  : boolean;
  published
    property Id: Integer read fid write fid;
    property Company: TCompanyDto read fCompany write fCompany;
    property ModuleProgram: TModuleProgramDto read fModuleProgram write fModuleProgram;
    property IsSold: boolean read fisSold write fisSold;
  end;

  TCompanyModuleProgramCreateDto = class
  private
    fCompanyId: Integer;
    fModuleProgramId: Integer;
    fisSold: boolean;
  published
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ModuleProgramId: Integer read fModuleProgramId write fModuleProgramId;
    property IsSold: boolean read fisSold write fisSold;
  end;

  TCompanyModuleProgramUpdateDto = class
  private
    fid : Integer;
    fCompanyId : Integer;
    fModuleProgramId : Integer;
    fisSold : Boolean;
  public
    property Id: Integer read fid write fid;
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ModuleProgramId: Integer read fModuleProgramId write fModuleProgramId;
    property IsSold: Boolean read fisSold write fisSold;
  end;

  TCompanyProductDto = class
  private
    fid: Integer;
    fProduct: TProductDto;
    fCompany: TCompanyDto;
    fLicenceCount: Integer;
    fUserCount: Integer;
    fExpiration: TDateTime;
  public
    property Id: Integer read fid write fid;
    property Product: TProductDto read fProduct write fProduct;
    property Company: TCompanyDto read fCompany write fCompany;
    property LicenceCount: Integer read fLicenceCount write fLicenceCount;
    property UserCount: Integer read fUserCount write fUserCount;
    property Expiration: TDateTime read fExpiration write fExpiration;

  end;

  TCompanyProductCreateDto = class
  private
    fCompanyId: Integer;
    fProductId: Integer;
    fLicenceCount: Integer;
    fUserCount: Integer;
    fExpiration: TDateTime;
  published
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ProductId: Integer read fProductId write fProductId;
    property LicenceCount: Integer read fLicenceCount write fLicenceCount;
    property UserCount: Integer read fUserCount write fUserCount;
    property Expiration: TDateTime read fExpiration write fExpiration;
  end;

  TCompanyProductUpdateDto = class
  private
    fid : Integer;
    fCompanyId : Integer;
    fProductId : Integer;
    fLicenceCount : Integer;
    fUserCount : Integer;
    fExpiration : TDateTime;
  public
    property Id: Integer read fid write fid;
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ProductId: Integer read fProductId write fProductId;
    property LicenceCount: Integer read fLicenceCount write fLicenceCount;
    property UserCount: Integer read fUserCount write fUserCount;
    property Expiration: TDateTime read fExpiration write fExpiration;
  end;

  TCompanyDeviceDto = class
    private
      fid: Integer;
      fProduct: TProductDto;
      fCompany: TCompanyDto;
      fDeviceUniqueID: string;
      fCreatedDate : TDateTime;
    public
      property Id: Integer read fid write fid;
      property Product: TProductDto read fProduct write fProduct;
      property Company: TCompanyDto read fCompany write fCompany;
      property DeviceUniqueID: string read fDeviceUniqueID write fDeviceUniqueID;
      property CreatedDate: TDateTime read fCreatedDate write fCreatedDate;
  end;

  TCompanyDeviceCreateDto = class
    private
      fDeviceUniqueId: string;
      fProductId: Integer;
      fCompanyId: Integer;
    public
      property DeviceUniqueId: string read fDeviceUniqueId write fDeviceUniqueId;
      property CompanyId: Integer read fCompanyId write fCompanyId;
      property ProductId: Integer read fProductId write fProductId;
  end;

  TCompanyEmployeeDto = class
    private
      fid: Integer;
      fCompany: TCompanyDto;
      fEmployeeFullName:String;
    public
      property Id: Integer read fid write fid;
      property Company: TCompanyDto read fCompany write fCompany;
      property EmployeeFullName: String read fEmployeeFullName write fEmployeeFullName;
  end;

  TCompanyEmployeeCreateDto = class
    private
      fEmployeeFullName: String;
      fCompanyId: Integer;
    public
      property EmployeeFullName: String read fEmployeeFullName write fEmployeeFullName;
      property CompanyId: Integer read fCompanyId write fCompanyId;
  end;

  TCompanyEmployeeUpdateDto = class
    private
      fid:Integer;
      fEmployeeFullName: String;
      fCompanyId: Integer;
    public
      property Id: Integer read fid write fid;
      property EmployeeFullName: String read fEmployeeFullName write fEmployeeFullName;
      property CompanyId: Integer read fCompanyId write fCompanyId;
  end;

  TNoContentDto = class

  end;

  TResponseDto <T: class, constructor> = class
  private
    fData: T;
    fErrors : TList<string>;
  published
    property Data: T read fData write fData;
    property Errors: TList<string> read fErrors write fErrors;
  public
    destructor Destroy; override;
  end;

//  TDataWithRecordCount<T: class, constructor> = class
//  private
//    fRecordCount: Integer;
//    fRecords: TList<T>;
//  published
//    property RecordCount: Integer read fRecordCount write fRecordCount;
//    property Records: TList<T> read fRecords write fRecords;
//  end;

  TCustomerServiceBaseDto = class
  private
    fPlannedDate: TDateTime;
    fStartDate: TDateTime;
    fFinishDate: TDateTime;
    fServiceType: string;
    fReason: string;
    fDescription: string;
    fCustomer: string;
  published
    property PlannedDate: TDateTime read fPlannedDate write fPlannedDate;
    property StartDate: TDateTime read fStartDate write fStartDate;
    property FinishDate: TDateTime read fFinishDate write fFinishDate;
    property ServiceType: string read fServiceType write fServiceType;
    property Reason: string read fReason write fReason;
    property Description: string read fDescription write fDescription;
    property Customer: string read fCustomer write fCustomer;
  end;

  TCustomerServiceCreateDto = class(TCustomerServiceBaseDto)
  private
    fCompanyId: Integer;
    fProviderUsername: string;
  published
    property CompanyId: Integer read fCompanyId write fCompanyId;
    property ProviderUsername: string read fProviderUsername write fProviderUsername;
  public
    constructor Create;
  end;

  TCustomerServiceUpdateDto = class(TCustomerServiceCreateDto)
  private
    fid: Integer;
    fRate: Integer;
  published
    property Id: Integer read fid write fid;
    property Rate: Integer read fRate write fRate;
  end;

  TCustomerServiceDto = class(TCustomerServiceBaseDto)
  private
    fid: Integer;
    fCompany: TCompanyDto;
    fProvider: TUserCompanyDto;
    fRate: Double;
    fApprover: TUserCompanyDto;
  published
    property Id: Integer read fid write fid;
    property Company: TCompanyDto read fCompany write fCompany;
    property Provider: TUserCompanyDto read fProvider write fProvider;
    property Approver: TUserCompanyDto read fApprover write fApprover;
    property Rate: Double read fRate write fRate;
  end;

  TCustomerServiceApproveDto = class
  private
    fid: Integer;
    fApproverUsername: string;
    fApproveDate: TDateTime;
    fApproveComment: string;
    fRate: Double;
  published
    property Id: Integer read fid write fid;
    property ApproverUsername: string read fApproverUsername write fApproverUsername;
    property ApproveComment: string read fApproveComment write fApproveComment;
    property Rate: Double read fRate write fRate;
    property ApproveDate: TDateTime read fApproveDate write fApproveDate;
  end;

  TCustomerServiceWithPagination = class
  private
    fRecordCount: Integer;
    fRecords: TArray<TCustomerServiceDto>;
  published
    property RecordCount: Integer read fRecordCount write fRecordCount;
    property Records: TArray<TCustomerServiceDto> read fRecords write fRecords;
  end;

  TReportTemplateBaseDto = class
  private
    fDescription: string;
  published
    property Description: string read fDescription write fDescription;
  end;

  TReportTemplateDto = class(TReportTemplateBaseDto)
  private
    fid: Integer;
  published
    property Id: Integer read fid write fid;
  end;

  TServiceReportBaseDto = class
  end;

  TServiceReportDto = class(TServiceReportBaseDto)
  private
    fid: Integer;
    fReportTemplate: TReportTemplateDto;
    fCustomerService: TCustomerServiceDto;
    fPDFData: string;
  published
    property Id: Integer read fid write fid;
    property ReportTemplate: TReportTemplateDto read fReportTemplate write fReportTemplate;
    property CustomerService: TCustomerServiceDto read fCustomerService write fCustomerService;
    property PDFData: string read fPDFData write fPDFData;
  end;

  TServiceReportCreateDto = class(TServiceReportBaseDto)
  private
    fCustomerServiceId: Integer;
    fReportTemplateId: Integer;
  published
    property CustomerServiceId: Integer read fCustomerServiceId write fCustomerServiceId;
    property ReportTemplateId: Integer read fReportTemplateId write fReportTemplateId;
  end;

implementation

{ TCustomerServiceCreateDto }

constructor TCustomerServiceCreateDto.Create;
begin
  CompanyId := 0;
  ProviderUsername := '';
  PlannedDate := EncodeDate(0001,01,01);
  StartDate := EncodeDate(0001,01,01);
  FinishDate := EncodeDate(0001,01,01);
  ServiceType := '';
  Reason := '';
  Description := '';
  Customer := '';
end;

{ TResponseDto<T> }

destructor TResponseDto<T>.Destroy;
var
  RttiType: TRttiType;
  RttiCtx: TRttiContext;
begin
  if (Data <> nil) and (Data.ClassType = T) then
  begin
    RttiType := RttiCtx.GetType(TypeInfo(T));

    if (RttiType.GetProperty('Count') <> nil) and (RttiType.GetMethod('Add') <> nil) then
      for var item in TList<T>(Data) do
        item.Destroy;

    Data.Destroy;

  end;


  if Errors <> nil then
    Errors.Destroy;
  inherited;
end;

end.
