# Roadify Mobile — Arquitetura de Temas & Design System

Aplicação móvel do **Roadify**, desenvolvida em Flutter para Android e iOS, focada em triagem e avaliação da qualidade de pavimentos asfálticos.

---

## 🎨 Sistema de Temas e Design System (Guia para o Time)

Este projeto utiliza a biblioteca **`flex_color_scheme`** combinada com **Material 3** e extensões personalizadas de tema (`ThemeExtension`), garantindo:
- **Modo Claro de Alto Contraste (Padrão):** Otimizado para visualização nítida sob incidência solar direta no para-brisa.
- **Modo Escuro (Dark Mode):** Otimizado para condução noturna.
- **Adaptação Multiplataforma:** Transições e comportamentos com sensação nativa no Android e iOS.
- **Escala de Qualidade do Pavimento:** 5 cores semânticas padronizadas (Excelente, Boa, Média, Ruim, Muito Ruim).
- **Pill-Shaped Dock:** Barra flutuante translúcida no estilo Samsung Galaxy OneUI / iOS.

---

### 🚀 Como Usar o Tema nas Features (Para todos os Devs e Vibecoder)

Qualquer membro do time pode acessar as cores e tipografias diretamente do `BuildContext` sem decorar códigos hexadecimais:

#### 1. Acessando as Cores Principais
```dart
import 'package:roadify_app/core/theme/theme_extensions.dart';

// No método build de qualquer Widget:
final colors = context.colors;

Container(
  color: colors.primary, // Verde Floresta (#134E3F)
  child: Text('Exemplo', style: TextStyle(color: colors.onPrimary)),
);
```

#### 2. Acessando as Cores da Escala de Pavimento (5 Níveis)
```dart
final quality = context.roadQualityColors;

// quality.excelente  -> #10B981 (Verde Esmeralda)
// quality.boa        -> #34D399 (Verde Claro)
// quality.media      -> #F59E0B (Amarelo Âmbar)
// quality.ruim       -> #F97316 (Laranja)
// quality.muitoRuim  -> #EF4444 (Vermelho - Requer Perfilômetro)
```

#### 3. Acessando a Tipografia Padronizada (Google Fonts Inter)
```dart
final typography = context.typography;

Text('Título', style: typography.titleLarge);
Text('Subtítulo', style: typography.bodyMedium);
Text('Legenda', style: typography.labelSmall);
```

#### 4. Verificando Modo Escuro
```dart
if (context.isDarkMode) {
  // Ajuste condicional caso necessário
}
```

---

## 📁 Estrutura de Pastas (MVVM por Features)

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Paleta institucional e tokens de cores
│   │   ├── app_dimensions.dart     # Grid de espaçamentos, raios e pill dock specs
│   │   ├── app_typography.dart     # Hierarquia tipográfica com GoogleFonts.inter
│   │   ├── app_theme.dart          # Configuração mestre com FlexColorScheme e M3
│   │   ├── theme_extensions.dart   # Extensions no BuildContext e classes de extensão
│   │   └── theme_controller.dart   # Gerenciador reativo de ThemeMode (light/dark/system)
│   └── navigation/
│       └── pill_dock_scaffold.dart # Componente da barra flutuante Pill Dock OneUI/iOS
│
├── features/
│   ├── home/                       # [Valber: Tech Lead & Integrador]
│   │   └── presentation/home_screen.dart
│   ├── coleta/                     # [Lucas: Fullstack]
│   │   └── presentation/coleta_screen.dart
│   ├── sensores/                   # [Allan: Fullstack]
│   │   └── presentation/sensores_screen.dart
│   ├── dados/                      # [Humberto: Fullstack]
│   │   └── presentation/dados_screen.dart
│   └── auth_config/                # [Tiago: Feature Owner via Antigravity]
│       ├── presentation/config_screen.dart
│       ├── presentation/login_screen.dart
│       └── presentation/register_screen.dart
│
└── main.dart                       # Ponto de entrada com MaterialApp e PillDockScaffold
```

---

## 🧪 Testes e Validação

Para validar a integridade do código e dos temas:

```bash
flutter analyze
flutter test
```
