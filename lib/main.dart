import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
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
    );

    //injecting data providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
      ],
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const InitializeWentWrong();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'UnderControl',
              theme: mainTheme,
              home: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, AsyncSnapshot<User?> userSnapshot) {
                  //user logged in
                  if (userSnapshot.hasData) {
                    return const MainScreen();
                  }
                  //waiting for data
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }
                  //user not logged in
                  return const AuthScreen();
                },
              ),
            );
          }
          //waiting for Firebase initialization
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
