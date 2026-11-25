import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../data/repositories/firebase_auth_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../presentation/cubit/session_cubit.dart';

void configureAuthDependencies({
  required GetIt getIt,
  required FirebaseAuth firebaseAuth,
}) {
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(firebaseAuth),
    );
  }
  if (!getIt.isRegistered<SessionCubit>()) {
    getIt.registerFactory<SessionCubit>(
      () => SessionCubit(getIt<AuthRepository>()),
    );
  }
}
