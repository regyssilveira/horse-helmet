unit Tests.Settings.Helmet;

interface

uses
  DUnitX.TestFramework, Horse.Helmet;

type
  [TestFixture]
  TTestHelmetConfig = class
  public
    [Test]
    procedure TestDefaultConfigValues;
    [Test]
    procedure TestDisableMethods;
    [Test]
    procedure TestCustomValueAssignment;
    [Test]
    procedure TestFluentInterfaceChaining;
  end;

implementation

{ TTestHelmetConfig }

procedure TTestHelmetConfig.TestDefaultConfigValues;
var
  LConfig: IHelmetConfig;
begin
  LConfig := THelmetConfig.New;

  Assert.IsFalse(LConfig.GetDisableCSP);
  Assert.IsFalse(LConfig.GetDisableFrameOptions);
  Assert.IsFalse(LConfig.GetDisableContentTypeOptions);
  Assert.IsFalse(LConfig.GetDisableXSSProtection);
  Assert.IsFalse(LConfig.GetDisableHSTS);
  Assert.IsFalse(LConfig.GetDisableReferrerPolicy);

  Assert.AreEqual('default-src ''self'';', LConfig.GetCSPValue);
  Assert.AreEqual('SAMEORIGIN', LConfig.GetFrameOptionsValue);
  Assert.AreEqual('nosniff', LConfig.GetContentTypeOptionsValue);
  Assert.AreEqual('1; mode=block', LConfig.GetXSSProtectionValue);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LConfig.GetHSTSValue);
  Assert.AreEqual('no-referrer', LConfig.GetReferrerPolicyValue);
end;

procedure TTestHelmetConfig.TestDisableMethods;
var
  LConfig: IHelmetConfig;
begin
  LConfig := THelmetConfig.New;

  LConfig.DisableCSP;
  LConfig.DisableFrameOptions;
  LConfig.DisableContentTypeOptions;
  LConfig.DisableXSSProtection;
  LConfig.DisableHSTS;
  LConfig.DisableReferrerPolicy;

  Assert.IsTrue(LConfig.GetDisableCSP);
  Assert.IsTrue(LConfig.GetDisableFrameOptions);
  Assert.IsTrue(LConfig.GetDisableContentTypeOptions);
  Assert.IsTrue(LConfig.GetDisableXSSProtection);
  Assert.IsTrue(LConfig.GetDisableHSTS);
  Assert.IsTrue(LConfig.GetDisableReferrerPolicy);
end;

procedure TTestHelmetConfig.TestCustomValueAssignment;
var
  LConfig: IHelmetConfig;
begin
  LConfig := THelmetConfig.New;

  LConfig.CSP('default-src ''none''');
  LConfig.FrameOptions('DENY');
  LConfig.ContentTypeOptions('sniff');
  LConfig.XSSProtection('0');
  LConfig.HSTS('max-age=3600');
  LConfig.ReferrerPolicy('origin');
  LConfig.CustomHeader('X-Custom-Secure', 'my-value');

  Assert.AreEqual('default-src ''none''', LConfig.GetCSPValue);
  Assert.AreEqual('DENY', LConfig.GetFrameOptionsValue);
  Assert.AreEqual('sniff', LConfig.GetContentTypeOptionsValue);
  Assert.AreEqual('0', LConfig.GetXSSProtectionValue);
  Assert.AreEqual('max-age=3600', LConfig.GetHSTSValue);
  Assert.AreEqual('origin', LConfig.GetReferrerPolicyValue);
  Assert.AreEqual('my-value', LConfig.GetCustomHeaders.Items['X-Custom-Secure']);
end;

procedure TTestHelmetConfig.TestFluentInterfaceChaining;
var
  LConfig: IHelmetConfig;
begin
  LConfig := THelmetConfig.New
    .DisableCSP
    .CSP('default-src ''self''; script-src ''unsafe-inline''')
    .DisableHSTS
    .HSTS('max-age=0')
    .FrameOptions('SAMEORIGIN');

  Assert.IsTrue(LConfig.GetDisableCSP);
  Assert.AreEqual('default-src ''self''; script-src ''unsafe-inline''', LConfig.GetCSPValue);
  Assert.IsTrue(LConfig.GetDisableHSTS);
  Assert.AreEqual('max-age=0', LConfig.GetHSTSValue);
  Assert.AreEqual('SAMEORIGIN', LConfig.GetFrameOptionsValue);
  Assert.IsFalse(LConfig.GetDisableFrameOptions);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestHelmetConfig);

end.
