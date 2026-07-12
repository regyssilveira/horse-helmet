# horse-helmet

Middleware para configuração rápida e simples de cabeçalhos de segurança HTTP no framework **Horse**.

O `horse-helmet` ajuda a proteger sua aplicação Delphi/Lazarus de diversas vulnerabilidades conhecidas da web (como clickjacking, cross-site scripting (XSS), sniff de MIME types, etc.) através da injeção de cabeçalhos HTTP apropriados no fluxo de resposta da aplicação.

---

## ⚙️ Instalação

A instalação deve ser feita utilizando o gerenciador de pacotes [`boss`](https://github.com/HashLoad/boss):

```sh
boss install horse-helmet
```

---

## 🛡️ Cabeçalhos Gerenciados por Padrão

*   `Content-Security-Policy`: Previne a injeção de scripts e recursos não autorizados.
*   `X-Frame-Options`: Protege contra Clickjacking (definido por padrão como `SAMEORIGIN` ou `DENY`).
*   `X-Content-Type-Options`: Previne sniffing de MIME types (definido como `nosniff`).
*   `X-XSS-Protection`: Ativa o filtro XSS do navegador (definido como `1; mode=block`).
*   `Strict-Transport-Security` (HSTS): Exige conexões HTTPS seguras.
*   `Referrer-Policy`: Controla a quantidade de informações de referência enviadas.

---

## ⚡️ Ciclo de Vida da Requisição

*   **Fase recomendada:** Registrar como middleware global padrão antes das rotas (fluxo CPS). Ele decora a resposta antes ou durante o envio físico final (`onSend`).
*   **Comportamento:** Transversal/Passivo. Ele não bloqueia a requisição e apenas adiciona metadados úteis na resposta.

---

## 📖 Exemplo Prático (Delphi)

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

---

## 🛠️ Roadmap de Desenvolvimento (Pendências)

Para finalizar a implementação deste middleware, as seguintes etapas devem ser concluídas:
1. **Modelagem de Configurações Customizáveis:** Permitir habilitar/desabilitar cabeçalhos específicos através de um objeto de configuração (ex: `Helmet(THelmetConfig.New.DisableCSP)`).
2. **Implementação da Unit `Horse.Helmet.pas`:** 
   - Escrever a unit contendo a função `Helmet()` que retorna a callback do middleware.
   - Garantir compatibilidade multiplataforma nativa (Delphi/Lazarus FPC).
3. **Criação de testes de integração:** Implementar chamadas HTTP em `tests/` que validem a presença de todos os cabeçalhos de segurança na resposta.
4. **Construção de Sample funcional:** Criar um console application executável na pasta `samples/` para testes locais.
