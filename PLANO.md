# PLANO — Diarista Fácil

Ponto de partida (out/2026): protótipo SwiftUI navegável, sem backend. Login com credenciais fixas, dados de exemplo em memória, Apple Pay sem processamento real, sem testes. Ver [README.md](README.md#limitações-conhecidas).

Cada fase só começa quando o **critério de pronto** da anterior estiver cumprido. Itens dentro de uma fase estão em ordem de execução.

---

## Fase 0 — Base técnica (antes de qualquer feature)

Objetivo: deixar o projeto fácil de evoluir e de verificar automaticamente.

- [ ] Organizar arquivos em pastas no Xcode: `App/`, `Features/<Área>/`, `Models/`, `Services/`, `Resources/`.
- [ ] Remover `Item.swift` (template SwiftData não usado).
- [ ] Mover `Videos/Limpando-pano.mov` para Git LFS ou removê-lo se não for usado.
- [ ] Extrair os dados de exemplo (`ServiceBoard.sampleData`, produtos do marketplace, contas demo) para um `MockDataService` atrás de protocolos (`AuthService`, `ServiceRepository`, `ProductRepository`) — o backend da Fase 1 só troca a implementação.
- [ ] Criar testes unitários para `AuthViewModel`, `ServicePosting.matches(query:)` e `CurrencyFormatter`.
- [ ] Criar 1 teste de UI: login como cliente → aba Home visível.
- [ ] CI no GitHub Actions rodando `xcodebuild test -scheme "Diarista facil" -destination 'platform=iOS Simulator,name=iPhone 17'` em cada PR.

**Pronto quando:** CI verde no `main`, app roda igual ao atual, nenhuma tela lê dados de exemplo diretamente.

## Fase 1 — Funcional no iPhone (MVP)

Objetivo: cliente e diarista reais completam um serviço de ponta a ponta.

- [ ] **Decidir backend** (Supabase recomendado: Auth + Postgres + Storage + Edge Functions). Registrar a decisão em `docs/decisoes.md`.
- [ ] Modelar tabelas: `profiles` (tipo cliente/diarista), `addresses`, `coverage_areas`, `services` (status: aberto → aceito → em andamento → concluído → pago), `service_photos`, `reviews`. Políticas RLS por usuário.
- [ ] Auth real: cadastro (`RegistrationView`), login, logout, recuperação e troca de senha.
- [ ] Cliente publica serviço com fotos (upload no Storage) → aparece para diaristas da região.
- [ ] Diarista aceita serviço → some da lista dos demais e entra em "Próximos serviços" dos dois lados.
- [ ] Diarista conclui com fotos → cliente confirma.
- [ ] Pagamento: merchant ID real da Apple + provedor (ex.: Stripe/Pagar.me) processando o token do Apple Pay numa Edge Function. Remover o merchant de exemplo.
- [ ] Avaliação mútua (1–5 estrelas + comentário) após o pagamento.
- [ ] Notificações push (APNs): novo serviço na região, serviço aceito, serviço concluído.
- [ ] Testes de UI do fluxo completo usando um projeto Supabase de teste.

**Pronto quando:** duas contas reais em dois iPhones completam pedido → aceite → conclusão → pagamento (sandbox) → avaliação, com push em cada etapa, e o teste de UI passa no CI.

## Fase 2 — Confiança e pagamentos no Brasil

- [ ] Pix real (QR Code dinâmico via provedor) no serviço e no carrinho do marketplace.
- [ ] Repasse automático para a diarista (split de pagamento) e tela de extrato.
- [ ] Verificação de identidade da diarista (documento + selfie) antes de aceitar serviços.
- [ ] Denúncias e bloqueio de usuário; painel simples de moderação.
- [ ] Termos de uso e política de privacidade (LGPD), com aceite no cadastro e exclusão de conta no app.

**Pronto quando:** pagamento via Pix chega na conta da diarista em sandbox, e nenhuma diarista não verificada consegue aceitar serviço.

## Fase 3 — Android

- [ ] Decidir com base no estado da Fase 2: **Kotlin + Jetpack Compose nativo** (recomendado — reaproveita o backend, mantém o iOS) vs. reescrever as duas plataformas em Flutter/React Native.
- [ ] Paridade com o iOS, na ordem: auth → publicar/aceitar serviço → conclusão → pagamento (Google Pay + Pix) → avaliações → marketplace.
- [ ] Push via FCM.

**Pronto quando:** fluxo completo da Fase 1 funciona entre um iPhone e um Android.

## Fase 4 — Lançamento

- [ ] TestFlight (iOS) e teste interno na Play Store com 10–20 usuários reais (clientes e diaristas).
- [ ] Analytics de funil: cadastro → primeiro pedido → serviço concluído.
- [ ] Teste de preço / taxa da plataforma com público simulado (opcional).
- [ ] Ficha das lojas: ícone, screenshots, descrição, política de privacidade publicada.

**Pronto quando:** app aprovado nas duas lojas e pelo menos 10 serviços reais concluídos no teste interno.
