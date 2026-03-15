import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';
import 'router.dart';
import 'injection.dart';
import 'features/cards/presentation/bloc/card_bloc.dart';
import 'features/settings/data/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');
  await initDependencies();
  runApp(DevicePreview(builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  final AppRouter _router = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CardBloc>(),
      child: ValueListenableBuilder<bool>(
        valueListenable: ValueNotifier(getIt<SettingsService>().isDarkMode),
        builder: (context, isDarkMode, child) {
          return MaterialApp.router(
            title: 'Yu-Gi-Oh Duel Engine',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router.config(),
          );
        },
      ),
    );
  }
}
