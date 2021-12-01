import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/providers/company_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/providers/user_provider.dart';
import 'package:under_control_flutter/screens/add_company_screen.dart';
import 'package:under_control_flutter/screens/equipment/add_equipment_screen.dart';
import 'package:under_control_flutter/screens/auth_screen.dart';
import 'package:under_control_flutter/screens/choose_company_screen.dart';
import 'package:under_control_flutter/screens/equipment/equipment_details_screen.dart';
import 'package:under_control_flutter/screens/initialize_went_wrong_screen.dart';
import 'package:under_control_flutter/screens/main_screen.dart';
import 'package:under_control_flutter/widgets/loading_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          color: Colors.white70,
        ),
        headline6: TextStyle(
          color: Colors.white70,
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
      backgroundColor: Colors.grey,
      cardColor: Colors.white24,
      splashColor: Colors.white12,
      shadowColor: Colors.white24,
      hintColor: Colors.white54,
      bottomNavigationBarTheme:
          Theme.of(context).bottomNavigationBarTheme.copyWith(
                backgroundColor: Colors.black,
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.white24,
                type: BottomNavigationBarType.shifting,
              ),
      popupMenuTheme: Theme.of(context).popupMenuTheme.copyWith(
            color: Colors.black54,
          ),
      dialogTheme: Theme.of(context).dialogTheme.copyWith(
            backgroundColor: Colors.black,
            elevation: 7,
          ),
    );

    //injecting data providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        ChangeNotifierProvider(create: (ctx) => CompanyProvider()),
        ChangeNotifierProxyProvider<UserProvider, ItemProvider>(
          create: (ctx) => ItemProvider(),
          update: (ctx, user, item) => ItemProvider.user(user: user.user),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UnderControl',
        theme: mainTheme,
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // print(snapshot.error);
              return const InitializeWentWrong();
            }
            //Firebase initialized
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext ctx, AsyncSnapshot<User?> userSnapshot) {
                  //set status bar and bottom navigation colors
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    systemNavigationBarColor: Colors.black,
                    statusBarColor: Colors.black,
                  ));
                  //user logged in
                  if (userSnapshot.hasData) {
                    UserProvider userProvider =
                        Provider.of<UserProvider>(context);
                    // user data initialized and has company
                    if (userProvider.user != null &&
                        userProvider.user!.companyId != null) {
                      return const MainScreen();
                    } else {
                      // user data initialized and has no company
                      if (userProvider.user != null &&
                          userProvider.user!.companyId == null) {
                        return const ChooseCompanyScreen();
                      } else {
                        // initialize user provider
                        userProvider
                            .initializeUser(context, userSnapshot.data!.uid)
                            .then((user) {
                          if (user != null && user.companyId != null) {
                            // print(user.companyId);
                            // initialize company provider
                            Provider.of<CompanyProvider>(context, listen: false)
                                .initializeCompany(context, user.companyId!);
                            // .then((company) {
                            // if (company != null) {
                            // print(company.name);
                            // }
                            // });
                          }
                        });
                      }
                    }
                  } else if (!userSnapshot.hasData) {
                    return const AuthScreen();
                  }
                  return const LoadingWidget();
                },
              );
            }
            //waiting for Firebase initialization
            return const LoadingWidget();
          },
        ),
        routes: {
          ChooseCompanyScreen.routeName: (ctx) => const ChooseCompanyScreen(),
          AddCompanyScreen.routeName: (ctx) => const AddCompanyScreen(),
          AddEquipmentScreen.routeName: (ctx) => const AddEquipmentScreen(),
          EquipmentDetailsScreen.routeName: (ctx) =>
              const EquipmentDetailsScreen(),
        },
      ),
    );
  }
}
