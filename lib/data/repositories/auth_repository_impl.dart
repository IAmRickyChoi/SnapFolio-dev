import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapfolio/data/datasources/auth_remote_data_source.dart';
import 'package:snapfolio/domain/entities/user_entity.dart';
import 'package:snapfolio/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get user {
    return remoteDataSource.user.map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserEntity(id: firebaseUser.uid, email: firebaseUser.email);
    });
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) {
    return remoteDataSource.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }
}
