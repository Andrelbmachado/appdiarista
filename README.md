# Diarista Fácil 🧽

**O "iFood das diaristas": conecta quem precisa de uma faxina a diaristas de confiança — do pedido ao pagamento, tudo no app.**

- **Cliente:** escolhe o tipo de limpeza, a data, o horário e o endereço, anexa fotos do ambiente e paga com Apple Pay.
- **Diarista:** vê serviços disponíveis no mapa, filtra por região de atendimento, acompanha a agenda e registra a conclusão com fotos.
- **Marketplace:** produtos de limpeza com favoritos, filtros por categoria e carrinho.

> ⚠️ **Estado atual: protótipo navegável (iPhone, SwiftUI).** As telas e fluxos existem, mas **não há backend**: login usa contas de demonstração, os dados são de exemplo e ficam só em memória (somem ao fechar o app) e nenhum pagamento é processado de verdade. Tudo marcado como **🔜 planejado** abaixo ainda não existe no código.

## O que já funciona

| Área | O que existe hoje | Arquivos principais |
|---|---|---|
| Login | Alternância Cliente/Diarista com credenciais fixas de demonstração | `LoginView.swift`, `AuthViewModel.swift` |
| Cadastro | Formulário de novo cliente/diarista (visual — **não cria conta**) | `RegistrationView.swift` |
| Home | Próximos serviços, serviços disponíveis, filtros por status, tipo e região | `HomeView.swift`, `ServiceBoard.swift` |
| Pedido de serviço | Tipo de limpeza, data, horário, endereço, observações e fotos (PhotosPicker) | `MainClientView.swift`, `ServiceSelectionView.swift`, `TimeSelectionView.swift`, `CalendarView.swift` |
| Diaristas | Lista com mapa (MapKit) e indicador de compatibilidade | `DiaristasListView.swift` |
| Serviços | Detalhe do próximo serviço, histórico e detalhe do histórico | `UpcomingServiceDetailView.swift`, `HistoryView.swift`, `HistoryDetailView.swift` |
| Conclusão | Fotos do serviço (câmera) e pagamento via Apple Pay (PassKit) | `ServiceCompletionView.swift`, `PaymentController.swift` |
| Marketplace | Catálogo, detalhe, favoritos, filtros e carrinho (em memória) | `MarketplaceView.swift` |
| Conta | Preferências, endereços / áreas de atendimento, troca de senha (em memória), tema e tamanho de texto | `SettingsView.swift`, `AppearanceSettings.swift` |

### Limitações conhecidas

- **Apple Pay:** usa o merchant ID de exemplo `merchant.com.example.diaristafacil` e aprova a autorização localmente — não há processamento real nem repasse.
- **Pix no carrinho:** o botão só mostra uma mensagem; não gera QR Code.
- **Persistência:** `Item.swift` é o modelo SwiftData do template do Xcode e não está ligado ao app (não há `modelContainer`).
- **Testes:** o projeto declara alvos de teste, mas ainda não há testes no repositório.

## 🔜 Planejado

- Backend com contas reais e dados compartilhados entre cliente e diarista.
- Fluxo ponta a ponta: pedido → aceite → conclusão → pagamento real → avaliação.
- Notificações push, Pix real e repasse para a diarista.
- Verificação de identidade, avaliações e denúncias.
- Versão **Android**.

Detalhes, ordem e critérios de pronto em **[PLANO.md](PLANO.md)**.

## Como rodar

**Requisitos:** macOS com Xcode compatível com **iOS 26.2** (deployment target do projeto). App só para iPhone.

1. Abra `Diarista facil.xcodeproj` no Xcode.
2. Selecione o esquema **Diarista facil** e um simulador de iPhone.
3. Rode com `⌘R`.

**Contas de demonstração** (definidas em `AuthViewModel.swift`):

| Perfil | E-mail | Senha |
|---|---|---|
| Cliente | `cliente@diarista.com` | `cliente123` |
| Diarista | `diarista@diarista.com` | `diarista123` |

> Apple Pay no simulador abre a folha de pagamento de teste; nenhum valor é cobrado.

## Stack

Swift 5 · SwiftUI · Combine · MapKit · PhotosUI · PassKit (Apple Pay).

## Estrutura

Todos os arquivos `.swift` ficam na raiz do repositório (ainda sem pastas por módulo). Estado global via `@EnvironmentObject`: `AuthViewModel` (sessão e perfil), `ServiceBoard` (serviços publicados) e `AppearanceSettings` (tema), criados em `Diarista_facilApp.swift`.
