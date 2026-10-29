import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/setup_locator.dart';
import 'core/l10n/locale_controller.dart';
import 'core/navigation/pill_dock_scaffold.dart';
import 'core/session/session_lifecycle_orchestrator.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth_config/presentation/config_screen.dart';
import 'features/coleta/presentation/coleta_screen.dart';
import 'features/dados/presentation/dados_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/sensores/presentation/sensores_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Força estilo de barra de sistema translúcida
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  setupLocators();

  runApp(const RoadifyApp());
}

class RoadifyApp extends StatefulWidget {
  final SessionLifecycleOrchestrator? sessionOrchestrator;
  final LocaleController? localeController;

  const RoadifyApp({
    super.key,
    this.sessionOrchestrator,
    this.localeController,
  });

  @override
  State<RoadifyApp> createState() => _RoadifyAppState();
}

class _RoadifyAppState extends State<RoadifyApp> {
  final ThemeController _themeController = ThemeController();
  late final LocaleController _localeController;
  late final bool _ownsLocaleController;
  late final SessionLifecycleOrchestrator _sessionOrchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    _ownsLocaleController = widget.localeController == null;
    _localeController = widget.localeController ?? LocaleController();
    if (!isWidgetTest) {
      unawaited(_localeController.loadSavedLocale());
    }

    if (widget.sessionOrchestrator != null) {
      _sessionOrchestrator = widget.sessionOrchestrator!;
      _ownsOrchestrator = false;
    } else if (getIt.isRegistered<SessionLifecycleOrchestrator>()) {
      _sessionOrchestrator = getIt<SessionLifecycleOrchestrator>();
      _ownsOrchestrator = false;
    } else {
      _sessionOrchestrator = SessionLifecycleOrchestrator();
      _ownsOrchestrator = true;
    }

    unawaited(
      _sessionOrchestrator.initialize(
        requestPermissionsOnFirstUse:
            !isWidgetTest || widget.sessionOrchestrator != null,
      ),
    );
  }

  @override
  void dispose() {
    _themeController.dispose();
    if (_ownsLocaleController) {
      _localeController.dispose();
    }
    if (_ownsOrchestrator) {
      _sessionOrchestrator.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeController, _localeController]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Roadify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          locale: _localeController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleController.supportedLocales,
          home: RoadifyMainShell(
            themeController: _themeController,
            localeController: _localeController,
            sessionOrchestrator: _sessionOrchestrator,
          ),
        );
      },
    );
  }
}

class RoadifyMainShell extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController? localeController;
  final SessionLifecycleOrchestrator? sessionOrchestrator;

  const RoadifyMainShell({
    super.key,
    required this.themeController,
    this.localeController,
    this.sessionOrchestrator,
  });

  @override
  State<RoadifyMainShell> createState() => _RoadifyMainShellState();
}

class _RoadifyMainShellState extends State<RoadifyMainShell> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  void _onIndexChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
      _visitedTabs.add(newIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        themeController: widget.themeController,
        onStartCollection: () => _onIndexChanged(1), // Direciona para Coleta
      ),
      _visitedTabs.contains(1) ? const ColetaScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(2)
          ? const SensoresScreen()
          : const SizedBox.shrink(),
      _visitedTabs.contains(3) ? const DadosScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(4)
          ? ConfigScreen(
              themeController: widget.themeController,
              localeController: widget.localeController,
            )
          : const SizedBox.shrink(),
    ];

    final scaffold = PillDockScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: _onIndexChanged,
      pages: pages,
    );

    final orchestrator = widget.sessionOrchestrator;
    if (orchestrator == null) {
      return scaffold;
    }

    return ListenableBuilder(
      listenable: orchestrator,
      builder: (context, _) {
        final sessionState = orchestrator.state;
        if (!sessionState.hasPendingInterruptionRecovery) {
          return scaffold;
        }

        final durationSeconds =
            sessionState.lastInterruption?.duration.inSeconds ?? 0;

        return Column(
          children: [
            Material(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restore_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sessão retomada após interrupção (${durationSeconds}s). Wakelock ativo.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: orchestrator.acknowledgeInterruptionRecovery,
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: scaffold),
          ],
        );
      },
    );
  }
}
