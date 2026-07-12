unit Tests.Integration.Helmet;

interface

uses
  DUnitX.TestFramework, Horse, Horse.Commons, Horse.Helmet,
  Horse.Core.RouterTree, Horse.Core,
  RESTRequest4D, System.SysUtils, System.Classes, System.Rtti, System.Generics.Collections;

type
  [TestFixture]
  TTestIntegrationHelmet = class
  private
    const TEST_PORT = 9097;
    procedure ClearGlobalState;
  public
    [SetupFixture]
    procedure SetupFixture;
    [TearDownFixture]
    procedure TearDownFixture;

    [Test]
    procedure TestDefaultHeaders;
    [Test]
    procedure TestDisableCSP;
    [Test]
    procedure TestCustomFrameOptions;
    [Test]
    procedure TestCustomHSTS;
    [Test]
    procedure TestDisableAll;
    [Test]
    procedure TestRealLifeJson;
    [Test]
    procedure TestRealLifeException;
    [Test]
    procedure TestCustomHeaders;
  end;

implementation

{ TTestIntegrationHelmet }

procedure TTestIntegrationHelmet.ClearGlobalState;
var
  LContext: TRttiContext;
  LType: TRttiInstanceType;
  LField: TRttiField;
  LList: TList<THorseCallback>;
begin
  try
    THorse.StopListen;
  except
  end;
  THorse.Routes := nil;
  THorse.Routes := THorseRouterTree.Create;
  THorse.Port := 9000;
  THorse.Host := '0.0.0.0';

  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(THorseCore) as TRttiInstanceType;
    if Assigned(LType) then
    begin
      LField := LType.GetField('FCallbacks');
      if Assigned(LField) then
      begin
        LList := TList<THorseCallback>(LField.GetValue(nil).AsObject);
        if Assigned(LList) then
          LList.Clear;
      end;
    end;

    LType := LContext.FindType('Horse.THorse') as TRttiInstanceType;
    if Assigned(LType) then
    begin
      LField := LType.GetField('FCallbacks');
      if Assigned(LField) then
      begin
        LList := TList<THorseCallback>(LField.GetValue(nil).AsObject);
        if Assigned(LList) then
          LList.Clear;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

procedure TTestIntegrationHelmet.SetupFixture;
begin
  ClearGlobalState;

  // Rota /default que utiliza o middleware padrão restrito a este path
  THorse.Use('/default', Helmet());
  THorse.Get('/default',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('default');
    end);

  // Rota /nocsp que desabilita CSP localmente
  THorse.Use('/nocsp', Helmet(THelmetConfig.New.DisableCSP));
  THorse.Get('/nocsp',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('nocsp');
    end);

  // Rota /custom-frame que customiza o FrameOptions para 'DENY'
  THorse.Use('/custom-frame', Helmet(THelmetConfig.New.FrameOptions('DENY')));
  THorse.Get('/custom-frame',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('custom-frame');
    end);

  // Rota /custom-hsts que customiza o HSTS
  THorse.Use('/custom-hsts', Helmet(THelmetConfig.New.HSTS('max-age=3600')));
  THorse.Get('/custom-hsts',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('custom-hsts');
    end);

  // Rota /no-headers que desabilita todos os cabeçalhos de segurança
  THorse.Use('/no-headers', Helmet(
    THelmetConfig.New
      .DisableCSP
      .DisableFrameOptions
      .DisableContentTypeOptions
      .DisableXSSProtection
      .DisableHSTS
      .DisableReferrerPolicy
    ));
  THorse.Get('/no-headers',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('no-headers');
    end);

  // Rota /api/json que simula um retorno JSON de API da vida real
  THorse.Use('/api/json', Helmet());
  THorse.Get('/api/json',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('{"status":"success","data":{"id":123,"name":"Test User"}}').ContentType('application/json');
    end);

  // Rota /api/error que lança exceção simulando um erro na vida real
  THorse.Use('/api/error', Helmet());
  THorse.Get('/api/error',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      raise EHorseException.Create.Status(THTTPStatus.InternalServerError).Error('Real Life Internal Error');
    end);

  // Rota /custom-headers que adiciona cabeçalhos customizados
  THorse.Use('/custom-headers', Helmet(
    THelmetConfig.New
      .DisableCSP
      .CustomHeader('X-Custom-Secure', 'test-value')
      .CustomHeader('X-Another-Secure', 'another-value')
  ));
  THorse.Get('/custom-headers',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('custom-headers');
    end);

  TThread.CreateAnonymousThread(
    procedure
    begin
      THorse.Listen(TEST_PORT);
    end).Start;

  Sleep(1500); // Aguarda inicialização do socket listener
end;

procedure TTestIntegrationHelmet.TearDownFixture;
begin
  ClearGlobalState;
  Sleep(500);
end;

procedure TTestIntegrationHelmet.TestDefaultHeaders;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/default', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('default', LRes.Content);
  Assert.AreEqual('default-src ''self'';', LRes.Headers.Values['Content-Security-Policy']);
  Assert.AreEqual('SAMEORIGIN', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('nosniff', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('1; mode=block', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('no-referrer', LRes.Headers.Values['Referrer-Policy']);
end;

procedure TTestIntegrationHelmet.TestDisableCSP;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/nocsp', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('nocsp', LRes.Content);
  Assert.AreEqual('', LRes.Headers.Values['Content-Security-Policy']);
  Assert.AreEqual('SAMEORIGIN', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('nosniff', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('1; mode=block', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('no-referrer', LRes.Headers.Values['Referrer-Policy']);
end;

procedure TTestIntegrationHelmet.TestCustomFrameOptions;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/custom-frame', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('custom-frame', LRes.Content);
  Assert.AreEqual('DENY', LRes.Headers.Values['X-Frame-Options']);
end;

procedure TTestIntegrationHelmet.TestCustomHSTS;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/custom-hsts', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('custom-hsts', LRes.Content);
  Assert.AreEqual('max-age=3600', LRes.Headers.Values['Strict-Transport-Security']);
end;

procedure TTestIntegrationHelmet.TestDisableAll;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/no-headers', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('no-headers', LRes.Content);
  Assert.AreEqual('', LRes.Headers.Values['Content-Security-Policy']);
  Assert.AreEqual('', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('', LRes.Headers.Values['Referrer-Policy']);
end;

procedure TTestIntegrationHelmet.TestRealLifeJson;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/api/json', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('application/json', LRes.ContentType);
  Assert.AreEqual('{"status":"success","data":{"id":123,"name":"Test User"}}', LRes.Content);

  // Validar se cabeçalhos de segurança foram adicionados
  Assert.AreEqual('default-src ''self'';', LRes.Headers.Values['Content-Security-Policy']);
  Assert.AreEqual('SAMEORIGIN', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('nosniff', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('1; mode=block', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('no-referrer', LRes.Headers.Values['Referrer-Policy']);
end;

procedure TTestIntegrationHelmet.TestRealLifeException;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/api/error', [TEST_PORT]))
    .Get;

  Assert.AreEqual(500, LRes.StatusCode);
  Assert.IsTrue(LRes.Content.Contains('Real Life Internal Error'));

  // Validar se os cabeçalhos de segurança continuam presentes no erro 500
  Assert.AreEqual('default-src ''self'';', LRes.Headers.Values['Content-Security-Policy']);
  Assert.AreEqual('SAMEORIGIN', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('nosniff', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('1; mode=block', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('no-referrer', LRes.Headers.Values['Referrer-Policy']);
end;

procedure TTestIntegrationHelmet.TestCustomHeaders;
var
  LRes: IResponse;
begin
  LRes := TRequest.New
    .BaseURL(Format('http://localhost:%d/custom-headers', [TEST_PORT]))
    .Get;

  Assert.AreEqual(200, LRes.StatusCode);
  Assert.AreEqual('custom-headers', LRes.Content);

  // Validar se cabeçalhos customizados estão presentes
  Assert.AreEqual('test-value', LRes.Headers.Values['X-Custom-Secure']);
  Assert.AreEqual('another-value', LRes.Headers.Values['X-Another-Secure']);

  // Validar que CSP não está presente
  Assert.AreEqual('', LRes.Headers.Values['Content-Security-Policy']);

  // Validar que os outros cabeçalhos padrão permanecem
  Assert.AreEqual('SAMEORIGIN', LRes.Headers.Values['X-Frame-Options']);
  Assert.AreEqual('nosniff', LRes.Headers.Values['X-Content-Type-Options']);
  Assert.AreEqual('1; mode=block', LRes.Headers.Values['X-XSS-Protection']);
  Assert.AreEqual('max-age=15552000; includeSubDomains', LRes.Headers.Values['Strict-Transport-Security']);
  Assert.AreEqual('no-referrer', LRes.Headers.Values['Referrer-Policy']);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestIntegrationHelmet);

end.
