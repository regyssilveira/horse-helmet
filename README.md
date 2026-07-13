# horse-helmet


Middleware para o framework **Horse** voltado à configuração rápida e simples de cabeçalhos de segurança HTTP em aplicações Delphi e Lazarus (FPC).

O `horse-helmet` ajuda a blindar sua aplicação contra diversas vulnerabilidades conhecidas da web (como *clickjacking*, *cross-site scripting* (XSS), *sniffing* de MIME types, sequestro de conexões e vazamento de informações do referenciador) através da injeção automatizada de cabeçalhos HTTP de segurança no fluxo de resposta.

---

## 🛡️ Cabeçalhos Gerenciados por Padrão

Ao ser ativado sem parâmetros, o `horse-helmet` injeta automaticamente 6 cabeçalhos recomendados pela OWASP com configurações seguras por padrão:

*   **`Content-Security-Policy`**: Previne a injeção de scripts e execução de recursos não autorizados (definido por padrão como `'default-src ''self'';'`).
*   **`X-Frame-Options`**: Protege contra Clickjacking ao impedir que a aplicação seja renderizada em `<frame>`, `<iframe>` ou `<object>` de terceiros (definido por padrão como `'SAMEORIGIN'`).
*   **`X-Content-Type-Options`**: Previne sniffing de MIME types, forçando o navegador a seguir o tipo de mídia declarado no cabeçalho Content-Type (definido como `'nosniff'`).
*   **`X-XSS-Protection`**: Ativa o filtro XSS nativo de navegadores modernos (definido como `'1; mode=block'`).
*   **`Strict-Transport-Security` (HSTS)**: Exige conexões HTTPS seguras ao navegador e impede acessos via HTTP (definido como `'max-age=15552000; includeSubDomains'`).
*   **`Referrer-Policy`**: Controla a quantidade de informações de referência (referrer) que são enviadas nas requisições (`no-referrer`).

---

## ⚙️ Instalação

A instalação deve ser feita utilizando o gerenciador de pacotes [`boss`](https://github.com/HashLoad/boss):

```sh
boss install github.com/RegysSilveira/horse-helmet
```

---

## ⚡ Ciclo de Vida da Requisição

*   **Fase recomendada:** Registrar como middleware global padrão antes das rotas (fluxo CPS) ou limitar a rotas específicas usando `THorse.Use('/caminho', Helmet())`. Ele decora a resposta inserindo cabeçalhos no `RawWebResponse` de forma transversal.
*   **Comportamento:** Transversal/Passivo. Ele não bloqueia a requisição e apenas adiciona metadados úteis e de segurança na resposta final do servidor, inclusive durante o tratamento de exceções (erros 500).

---

## 📖 Exemplos Práticos

### 1. Uso Padrão (Global)
Injeta todos os 6 cabeçalhos de segurança padrão com os valores recomendados:

```delphi
uses
  Horse,
  Horse.Helmet;

begin
  // Ativa as configurações de cabeçalho padrão globalmente
  THorse.Use(Helmet());

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

### 2. Configuração Customizada (Fluent Interface)
Você pode desabilitar cabeçalhos específicos, redefinir seus valores ou injetar novos cabeçalhos personalizados utilizando a interface fluida `IHelmetConfig`:

```delphi
uses
  Horse,
  Horse.Helmet;

begin
  THorse.Use(Helmet(
    THelmetConfig.New
      .DisableCSP // Desativa o Content-Security-Policy padrão
      .FrameOptions('DENY') // Altera o X-Frame-Options padrão de 'SAMEORIGIN' para 'DENY'
      .HSTS('max-age=31536000; includeSubDomains') // Customiza a expiração do HSTS
      .CustomHeader('X-Custom-Secure-Header', 'custom-value') // Injeta um cabeçalho customizado sob demanda
  ));

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

---

## 🛠️ Métodos de Configuração Disponíveis

A interface fluida `IHelmetConfig` fornece os seguintes métodos:

| Método | Tipo | Descrição |
| :--- | :--- | :--- |
| `DisableCSP` | Desativação | Remove o cabeçalho `Content-Security-Policy` da resposta. |
| `DisableFrameOptions` | Desativação | Remove o cabeçalho `X-Frame-Options` da resposta. |
| `DisableContentTypeOptions`| Desativação | Remove o cabeçalho `X-Content-Type-Options` da resposta. |
| `DisableXSSProtection` | Desativação | Remove o cabeçalho `X-XSS-Protection` da resposta. |
| `DisableHSTS` | Desativação | Remove o cabeçalho `Strict-Transport-Security` da resposta. |
| `DisableReferrerPolicy` | Desativação | Remove o cabeçalho `Referrer-Policy` da resposta. |
| `CSP(const AValue: string)` | Personalização| Altera o valor do cabeçalho `Content-Security-Policy`. |
| `FrameOptions(const AValue: string)`| Personalização| Altera o valor do cabeçalho `X-Frame-Options`. |
| `ContentTypeOptions(const AValue: string)`| Personalização| Altera o valor do cabeçalho `X-Content-Type-Options`. |
| `XSSProtection(const AValue: string)`| Personalização| Altera o valor do cabeçalho `X-XSS-Protection`. |
| `HSTS(const AValue: string)` | Personalização| Altera o valor do cabeçalho `Strict-Transport-Security`. |
| `ReferrerPolicy(const AValue: string)`| Personalização| Altera o valor do cabeçalho `Referrer-Policy`. |
| `CustomHeader(const AName, AValue: string)`| Extensão | Injeta cabeçalhos adicionais dinâmicos. |

---

## 📄 Licença

Este projeto está licenciado sob a [Apache License 2.0](LICENSE).
