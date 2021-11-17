import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/screens/auth_screen.dart';
import 'package:under_control_flutter/screens/initialize_went_wrong_screen.dart';
import 'package:under_control_flutter/screens/main_screen.dart';
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.green,
        ),
      ),
      scaffoldBackgroundColor: Colors.white12,
      primaryColor: Colors.green,
      cardColor: Colors.black87,
      splashColor: Colors.white12,
      shadowColor: Colors.white24,
      hintColor: Colors.white54,
      // iconTheme:
      //     const IconThemeData(color: Colors.green, size: 50, opacity: 0.9),
    );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   theme: mainTheme,
    //   home: StreamBuilder(
    //     stream: FirebaseAuth.instance.authStateChanges(),
    //     builder: (ctx, userSnapshot) {
    //       if (userSnapshot.hasData) {
    //         return const MainScreen();
    //       }
    //       return const AuthScreen();
    //     },
    //   ),
    // );

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const InitializeWentWrong();
        }

        // Once complete, show app
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'UnderControl',
            theme: mainTheme,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  return const MainScreen();
                }
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                return const AuthScreen();
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
