import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_maya_exam/view/app_router.dart';
import 'package:new_maya_exam/services/service_locator.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_event.dart';
import 'package:new_maya_exam/bloc/balance/balance_bloc.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_bloc.dart';
import 'package:new_maya_exam/utils/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<BalanceBloc>(
          create: (context) => getIt<BalanceBloc>(),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => getIt<TransactionBloc>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: AppStrings.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
        ),
      ),
    );
  }
}
