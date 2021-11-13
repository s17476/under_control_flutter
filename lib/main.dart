import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/screens/auth_screen.dart';
import 'package:under_control_flutter/screens/initialize_went_wrong_screen.dart';
import 'package:under_control_flutter/widgets/loading_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    ThemeData mainTheme = Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          color: Colors.white,
        ),
      ),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            secondary: Colors.indigo,
          ),
      scaffoldBackgroundColor: Colors.white24,
      primaryColor: Colors.green,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mainTheme,
      home: FutureBuilder(
          future: _initialization,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              // print(snapshot.error);
              return const InitializeWentWrong();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return const AuthScree();
            }
            return const LoadingWidget();
          }),
    );
  }
}
