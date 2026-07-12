program Sample;

{$APPTYPE CONSOLE}

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

uses
  {$IF DEFINED(FPC)}
  SysUtils,
  {$ELSE}
  System.SysUtils,
  {$ENDIF}
  Horse,
  Horse.Helmet;

begin
  // Ativa as configurações do Helmet de forma customizada:
  // - Desabilita o CSP padrão (caso vá usar outra política ou não seja necessário)
  // - Altera o X-Frame-Options padrão para 'DENY'
  // - Injeta um cabeçalho de segurança personalizado ('X-Custom-Secure-Header')
  THorse.Use(Helmet(
    THelmetConfig.New
      .DisableCSP
      .FrameOptions('DENY')
      .CustomHeader('X-Custom-Secure-Header', 'custom-value')
  ));

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  Writeln('Server is running on port 9000');
  THorse.Listen(9000);
end.
