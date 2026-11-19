# Roadify Mobile (`roadify_app`) — v1.0.0

Aplicação móvel **standalone (offline-first)** do **Roadify**, desenvolvida em Flutter para Android e iOS, voltada à aquisição inercial, georreferenciamento, nivelamento digital e registro multimídia de pavimentos asfálticos.

---

## Ícone e Tela de Abertura (Splash)

* `assets/images/roadify_mark.png`: símbolo oficial exibido no cabeçalho da `HomeScreen` (sobre selo verde floresta `AppColors.primary` com alto contraste nos modos Claro e Escuro).
* `assets/launcher/roadify_icon.png`: ícone quadrado opaco usado no iOS e no ícone legado do Android.
* `assets/launcher/roadify_foreground.png`: logo transparente dimensionada para a área segura do ícone adaptável do Android.
* A inicialização de permissões e do ciclo de sessão (`SessionLifecycleOrchestrator`) ocorre em segundo plano, sem atrasos artificiais na abertura.

Para regenerar ícones ou splash nativos após alterar assets:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 🎨 Sistema de Temas e Design System

O app combina **`flex_color_scheme`** com **Material 3** e `ThemeExtension` customizadas:

* **Modo Claro de Alto Contraste (Padrão):** otimizado para visibilidade sob luz solar no para-brisa (`#F8FAFC` / `#134E3F`).
* **Modo Escuro:** otimizado para condução noturna (`#09120F` / `#A3E635`).
* **Pill-Shaped Floating Dock:** barra flutuante translúcida (`BackdropFilter`) usada na navegação principal (`PillDockScaffold`) e nos controles da tela de gravação (`GravacaoScreen`).

### Uso rápido nas features

```dart
import 'package:roadify_app/core/theme/theme_extensions.dart';

final colors = context.colors;
final typography = context.typography;
final quality = context.roadQualityColors;
final isDark = context.isDarkMode;
```

---

## 🌍 Internacionalização (PT / EN / ES)

O pipeline oficial do Flutter (`l10n.yaml` + `generate: true` no `pubspec.yaml`) permanece ativo, estendido pelo catálogo central em `lib/l10n/app_localizations_catalog.dart` para suportar traduções completas em Português, Inglês e Espanhol sem conflitos com o `flutter gen-l10n`:

```dart
import 'package:roadify_app/l10n/app_localizations_catalog.dart';

Text(AppLocalizations.of(context).text('latestCollections'));
```

---

## 📁 Estrutura de Pastas (`lib/`)

```text
lib/
├── core/
│   ├── database/         # Drift (SQLite): AppDatabase, RunDao, VehicleDao, Tables e Migrations
│   ├── di/               # GetIt (setup_locator.dart)
│   ├── l10n/             # LocaleController (pt / en / es)
│   ├── navigation/       # PillDockScaffold
│   ├── session/          # SessionLifecycleOrchestrator
│   ├── theme/            # AppColors, AppDimensions, AppTypography, AppTheme, ThemeController
│   ├── utils/            # SnackbarHelper
│   └── widgets/          # AppLoadingIndicator, EmptyStateWidget
├── features/
│   ├── home/             # HomeScreen, HomeHealthViewModel, DeviceHealthState
│   ├── coleta/           # ColetaScreen, CollectionOrientationSetupScreen, preferências e permissões
│   ├── gravacao/         # GravacaoScreen, SensorSamplingIsolate, SensorTraceBuffer (60s), mídias
│   ├── sensores/         # SensoresScreen, NivelBolhaViewModel (60s), Circular/Tubular T
│   ├── dados/            # DadosScreen, RunDetailsBottomSheet, DadosViewModel, RunExportService (ZIP)
│   ├── veiculos/         # VehiclesManagementScreen, VehicleUiHelper, VehicleViewModel
│   └── auth_config/      # ConfigScreen (tema, idioma, veículo padrão e taxa padrão)
├── l10n/                 # .arb, arquivos gerados e app_localizations_catalog.dart
└── main.dart
```

---

## 🧪 Comandos de Validação e Build

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release
```
