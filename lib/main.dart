import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:snapfolio/data/datasources/auth_remote_data_source.dart';
import 'package:snapfolio/data/repositories/auth_repository_impl.dart';
import 'package:snapfolio/domain/entities/user_entity.dart';
import 'package:snapfolio/domain/repositories/auth_repository.dart';
import 'package:snapfolio/presentation/pages/auth_wrapper.dart';
import 'package:snapfolio/domain/repositories/contact_repository.dart';
import 'package:snapfolio/data/repositories/contact_repository_impl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SnapFolioApp());
}

class SnapFolioApp extends StatelessWidget {
  const SnapFolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRemoteDataSource>(
          create: (_) => AuthRemoteDataSourceImpl(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),
        Provider<ContactRepository>(
          create: (_) => ContactRepositoryImpl(),
        ),
      ],
      child: Consumer<AuthRepository>(
        builder: (context, authRepository, _) => StreamProvider<UserEntity?>.value(
          value: authRepository.user,
          initialData: null,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SnapFolio!',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const AuthWrapper(),
          ),
        ),
      ),
    );
  }
}