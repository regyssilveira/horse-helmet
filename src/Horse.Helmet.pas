unit Horse.Helmet;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
    SysUtils, Generics.Collections,
  {$ELSE}
    System.SysUtils, System.Generics.Collections,
  {$ENDIF}
  Horse;

type
  IHelmetConfig = interface
    ['{88CEB4E8-7DE4-4C2E-B68C-7DE667A5D19A}']
    function DisableCSP: IHelmetConfig;
    function DisableFrameOptions: IHelmetConfig;
    function DisableContentTypeOptions: IHelmetConfig;
    function DisableXSSProtection: IHelmetConfig;
    function DisableHSTS: IHelmetConfig;
    function DisableReferrerPolicy: IHelmetConfig;

    function CSP(const AValue: string): IHelmetConfig;
    function FrameOptions(const AValue: string): IHelmetConfig;
    function ContentTypeOptions(const AValue: string): IHelmetConfig;
    function XSSProtection(const AValue: string): IHelmetConfig;
    function HSTS(const AValue: string): IHelmetConfig;
    function ReferrerPolicy(const AValue: string): IHelmetConfig;

    function GetDisableCSP: Boolean;
    function GetDisableFrameOptions: Boolean;
    function GetDisableContentTypeOptions: Boolean;
    function GetDisableXSSProtection: Boolean;
    function GetDisableHSTS: Boolean;
    function GetDisableReferrerPolicy: Boolean;

    function GetCSPValue: string;
    function GetFrameOptionsValue: string;
    function GetContentTypeOptionsValue: string;
    function GetXSSProtectionValue: string;
    function GetHSTSValue: string;
    function GetReferrerPolicyValue: string;
    function CustomHeader(const AName, AValue: string): IHelmetConfig;
    function GetCustomHeaders: TDictionary<string, string>;
  end;

  THelmetConfig = class(TInterfacedObject, IHelmetConfig)
  private
    FDisableCSP: Boolean;
    FDisableFrameOptions: Boolean;
    FDisableContentTypeOptions: Boolean;
    FDisableXSSProtection: Boolean;
    FDisableHSTS: Boolean;
    FDisableReferrerPolicy: Boolean;

    FCSPValue: string;
    FFrameOptionsValue: string;
    FContentTypeOptionsValue: string;
    FXSSProtectionValue: string;
    FHSTSValue: string;
    FReferrerPolicyValue: string;
    FCustomHeaders: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IHelmetConfig;

    function DisableCSP: IHelmetConfig;
    function DisableFrameOptions: IHelmetConfig;
    function DisableContentTypeOptions: IHelmetConfig;
    function DisableXSSProtection: IHelmetConfig;
    function DisableHSTS: IHelmetConfig;
    function DisableReferrerPolicy: IHelmetConfig;

    function CSP(const AValue: string): IHelmetConfig;
    function FrameOptions(const AValue: string): IHelmetConfig;
    function ContentTypeOptions(const AValue: string): IHelmetConfig;
    function XSSProtection(const AValue: string): IHelmetConfig;
    function HSTS(const AValue: string): IHelmetConfig;
    function ReferrerPolicy(const AValue: string): IHelmetConfig;

    function GetDisableCSP: Boolean;
    function GetDisableFrameOptions: Boolean;
    function GetDisableContentTypeOptions: Boolean;
    function GetDisableXSSProtection: Boolean;
    function GetDisableHSTS: Boolean;
    function GetDisableReferrerPolicy: Boolean;

    function GetCSPValue: string;
    function GetFrameOptionsValue: string;
    function GetContentTypeOptionsValue: string;
    function GetXSSProtectionValue: string;
    function GetHSTSValue: string;
    function GetReferrerPolicyValue: string;
    function CustomHeader(const AName, AValue: string): IHelmetConfig;
    function GetCustomHeaders: TDictionary<string, string>;
  end;

function Helmet: THorseCallback; overload;
function Helmet(const AConfig: IHelmetConfig): THorseCallback; overload;

implementation

{ THelmetConfig }

constructor THelmetConfig.Create;
begin
  inherited Create;
  FCustomHeaders := TDictionary<string, string>.Create;
  FDisableCSP := False;
  FDisableFrameOptions := False;
  FDisableContentTypeOptions := False;
  FDisableXSSProtection := False;
  FDisableHSTS := False;
  FDisableReferrerPolicy := False;

  FCSPValue := 'default-src ''self'';';
  FFrameOptionsValue := 'SAMEORIGIN';
  FContentTypeOptionsValue := 'nosniff';
  FXSSProtectionValue := '1; mode=block';
  FHSTSValue := 'max-age=15552000; includeSubDomains';
  FReferrerPolicyValue := 'no-referrer';
end;

class function THelmetConfig.New: IHelmetConfig;
begin
  Result := THelmetConfig.Create;
end;

function THelmetConfig.DisableCSP: IHelmetConfig;
begin
  FDisableCSP := True;
  Result := Self;
end;

function THelmetConfig.DisableFrameOptions: IHelmetConfig;
begin
  FDisableFrameOptions := True;
  Result := Self;
end;

function THelmetConfig.DisableContentTypeOptions: IHelmetConfig;
begin
  FDisableContentTypeOptions := True;
  Result := Self;
end;

function THelmetConfig.DisableXSSProtection: IHelmetConfig;
begin
  FDisableXSSProtection := True;
  Result := Self;
end;

function THelmetConfig.DisableHSTS: IHelmetConfig;
begin
  FDisableHSTS := True;
  Result := Self;
end;

function THelmetConfig.DisableReferrerPolicy: IHelmetConfig;
begin
  FDisableReferrerPolicy := True;
  Result := Self;
end;

function THelmetConfig.CSP(const AValue: string): IHelmetConfig;
begin
  FCSPValue := AValue;
  Result := Self;
end;

function THelmetConfig.FrameOptions(const AValue: string): IHelmetConfig;
begin
  FFrameOptionsValue := AValue;
  Result := Self;
end;

function THelmetConfig.ContentTypeOptions(const AValue: string): IHelmetConfig;
begin
  FContentTypeOptionsValue := AValue;
  Result := Self;
end;

function THelmetConfig.XSSProtection(const AValue: string): IHelmetConfig;
begin
  FXSSProtectionValue := AValue;
  Result := Self;
end;

function THelmetConfig.HSTS(const AValue: string): IHelmetConfig;
begin
  FHSTSValue := AValue;
  Result := Self;
end;

function THelmetConfig.ReferrerPolicy(const AValue: string): IHelmetConfig;
begin
  FReferrerPolicyValue := AValue;
  Result := Self;
end;

function THelmetConfig.GetDisableCSP: Boolean;
begin
  Result := FDisableCSP;
end;

function THelmetConfig.GetDisableFrameOptions: Boolean;
begin
  Result := FDisableFrameOptions;
end;

function THelmetConfig.GetDisableContentTypeOptions: Boolean;
begin
  Result := FDisableContentTypeOptions;
end;

function THelmetConfig.GetDisableXSSProtection: Boolean;
begin
  Result := FDisableXSSProtection;
end;

function THelmetConfig.GetDisableHSTS: Boolean;
begin
  Result := FDisableHSTS;
end;

function THelmetConfig.GetDisableReferrerPolicy: Boolean;
begin
  Result := FDisableReferrerPolicy;
end;

function THelmetConfig.GetCSPValue: string;
begin
  Result := FCSPValue;
end;

function THelmetConfig.GetFrameOptionsValue: string;
begin
  Result := FFrameOptionsValue;
end;

function THelmetConfig.GetContentTypeOptionsValue: string;
begin
  Result := FContentTypeOptionsValue;
end;

function THelmetConfig.GetXSSProtectionValue: string;
begin
  Result := FXSSProtectionValue;
end;

function THelmetConfig.GetHSTSValue: string;
begin
  Result := FHSTSValue;
end;

function THelmetConfig.GetReferrerPolicyValue: string;
begin
  Result := FReferrerPolicyValue;
end;

destructor THelmetConfig.Destroy;
begin
  FCustomHeaders.Free;
  inherited;
end;

function THelmetConfig.CustomHeader(const AName, AValue: string): IHelmetConfig;
begin
  FCustomHeaders.AddOrSetValue(AName, AValue);
  Result := Self;
end;

function THelmetConfig.GetCustomHeaders: TDictionary<string, string>;
begin
  Result := FCustomHeaders;
end;

{ Helmet }

function Helmet: THorseCallback;
begin
  Result := Helmet(THelmetConfig.New);
end;

function Helmet(const AConfig: IHelmetConfig): THorseCallback;
begin
  Result :=
    procedure(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF})
    var
      LPair: TPair<string, string>;
    begin
      if not AConfig.GetDisableCSP then
        Res.RawWebResponse.SetCustomHeader('Content-Security-Policy', AConfig.GetCSPValue);

      if not AConfig.GetDisableFrameOptions then
        Res.RawWebResponse.SetCustomHeader('X-Frame-Options', AConfig.GetFrameOptionsValue);

      if not AConfig.GetDisableContentTypeOptions then
        Res.RawWebResponse.SetCustomHeader('X-Content-Type-Options', AConfig.GetContentTypeOptionsValue);

      if not AConfig.GetDisableXSSProtection then
        Res.RawWebResponse.SetCustomHeader('X-XSS-Protection', AConfig.GetXSSProtectionValue);

      if not AConfig.GetDisableHSTS then
        Res.RawWebResponse.SetCustomHeader('Strict-Transport-Security', AConfig.GetHSTSValue);

      if not AConfig.GetDisableReferrerPolicy then
        Res.RawWebResponse.SetCustomHeader('Referrer-Policy', AConfig.GetReferrerPolicyValue);

      if Assigned(AConfig.GetCustomHeaders) then
      begin
        for LPair in AConfig.GetCustomHeaders do
          Res.RawWebResponse.SetCustomHeader(LPair.Key, LPair.Value);
      end;

      Next();
    end;
end;

end.
