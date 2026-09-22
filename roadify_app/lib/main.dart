import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation/pill_dock_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth_config/presentation/config_screen.dart';
import 'features/coleta/presentation/coleta_screen.dart';
import 'features/dados/presentation/dados_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/sensores/presentation/sensores_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Força estilo de barra de sistema translúcida
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const RoadifyApp());
}

class RoadifyApp extends StatefulWidget {
  const RoadifyApp({super.key});

  @override
  State<RoadifyApp> createState() => _RoadifyAppState();
}

class _RoadifyAppState extends State<RoadifyApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Roadify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          home: RoadifyMainShell(themeController: _themeController),
        );
      },
    );
  }
}

class RoadifyMainShell extends StatefulWidget {
  final ThemeController themeController;

  const RoadifyMainShell({super.key, required this.themeController});

  @override
  State<RoadifyMainShell> createState() => _RoadifyMainShellState();
}

class _RoadifyMainShellState extends State<RoadifyMainShell> {
  int _currentIndex = 0;

  void _onIndexChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        themeController: widget.themeController,
        onStartCollection: () => _onIndexChanged(1), // Direciona para Coleta
      ),
      const ColetaScreen(),
      const SensoresScreen(),
      const DadosScreen(),
      ConfigScreen(themeController: widget.themeController),
    ];

    return PillDockScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: _onIndexChanged,
      pages: pages,
    );
  }
}
