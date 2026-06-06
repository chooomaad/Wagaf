import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final model = await dataSource.signIn(email: email, password: password);
      return Right(_toEntity(model));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? city,
    String? address,
  }) async {
    try {
      final model = await dataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        city: city,
        address: address,
      );
      return Right(_toEntity(model));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await dataSource.resetPassword(email: email);
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final model = await dataSource.getCurrentUser();
      return Right(_toEntity(model));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? avatarUrl,
  }) async {
    try {
      final model = await dataSource.updateProfile(
        fullName: fullName,
        phone: phone,
        city: city,
        address: address,
        avatarUrl: avatarUrl,
      );
      return Right(_toEntity(model));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException {
      return const Left(AuthFailure(message: 'Une erreur est survenue. Veuillez réessayer.'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return dataSource.authStateChanges.map(
      (model) => model != null ? _toEntity(model) : null,
    );
  }

  UserEntity _toEntity(UserModel m) => UserEntity(
        id: m.id,
        email: m.email,
        fullName: m.fullName,
        phone: m.phone,
        city: m.city,
        address: m.address,
        avatarUrl: m.avatarUrl,
        role: m.role,
        status: m.status,
        fcmToken: m.fcmToken,
        preferredLanguage: m.preferredLanguage,
        totalOrders: m.totalOrders,
        totalSpent: m.totalSpent,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );
}
