# Decisões técnicas

Registro das decisões de arquitetura do Diarista Fácil, em ordem cronológica.

## 2026-10-22 — Backend: Supabase (Fase 1)

**Decisão:** adotar **Supabase** como backend do app na Fase 1.

**Contexto:** até a Fase 0 o app é um protótipo SwiftUI sem backend — login com
credenciais fixas, dados de exemplo em memória e Apple Pay sem processamento real
(ver [README.md](../README.md#limitações-conhecidas)). A Fase 1 exige contas reais,
dados compartilhados entre cliente e diarista, upload de fotos e pagamento real.

**Por quê Supabase:**

- **Auth** pronto (e-mail/senha, recuperação de senha) — cobre cadastro, login,
  logout e troca de senha sem servidor próprio.
- **Postgres + RLS** — modelagem relacional (`profiles`, `addresses`,
  `coverage_areas`, `services`, `service_photos`, `reviews`) com políticas de acesso
  por usuário direto no banco.
- **Storage** — upload das fotos do ambiente (cliente) e da conclusão (diarista).
- **Edge Functions** — processar o token do Apple Pay junto ao provedor de pagamento
  (ex.: Stripe/Pagar.me) sem expor chaves no app.
- **Custo e velocidade** — tier gratuito suficiente para o MVP; SDK Swift oficial.

**Alternativas consideradas:** Firebase (Firestore é NoSQL, modelagem relacional e
RLS menos diretas); backend próprio (mais controle, porém muito mais esforço para o MVP).

**Consequências:**

- Os protocolos criados na Fase 0 (`AuthService`, `ServiceRepository`,
  `ProductRepository`, hoje implementados por `MockDataService`) passam a ter
  implementações Supabase na Fase 1 — as telas não mudam.
- Adicionar dependência do SDK `supabase-swift` via Swift Package Manager.
- Definir variáveis de ambiente / configuração para URL e chave anônima do projeto.
