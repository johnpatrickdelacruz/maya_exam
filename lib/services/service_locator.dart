import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';
import '../repository/balance_repository.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/balance/balance_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register Firebase services
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Register repositories
  getIt.registerSingleton<AuthRepositoryInterface>(
    AuthRepository(),
  );

  getIt.registerSingleton<BalanceRepositoryInterface>(
    BalanceRepository(),
  );

  // Register BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(authRepository: getIt<AuthRepositoryInterface>()),
  );

  getIt.registerFactory<BalanceBloc>(
    () => BalanceBloc(getIt<BalanceRepositoryInterface>()),
  );

  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      authRepository: getIt<AuthRepositoryInterface>(),
      balanceRepository: getIt<BalanceRepositoryInterface>(),
    ),
  );
}
