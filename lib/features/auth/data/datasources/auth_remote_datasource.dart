import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? city,
    String? address,
  });
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? avatarUrl,
  });
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;
  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AppAuthException(message: 'Échec de la connexion');
      }
      return await _fetchOrCreateProfile(response.user!);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(message: _mapAuthError(e.message));
    } catch (e) {
      throw AppAuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? city,
    String? address,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (city != null && city.isNotEmpty) 'city': city,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      );
      if (response.user == null) {
        throw const AppAuthException(message: "Échec de l'inscription");
      }
      return await _fetchProfileWithRetry(response.user!);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(message: _mapAuthError(e.message));
    } catch (e) {
      throw AppAuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw AppAuthException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppAuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw const AppAuthException(message: 'Non connecté');
    return await _fetchOrCreateProfile(user);
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? avatarUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw const AppAuthException(message: 'Non connecté');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    await supabase.from('profiles').update(updates).eq('id', user.id);
    return await _fetchOrCreateProfile(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabase.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session?.user == null) return null;
      try {
        return await _fetchOrCreateProfile(event.session!.user);
      } catch (_) {
        return null;
      }
    });
  }

  // Fetches the profile row; if missing, creates it from auth user metadata.
  // This handles accounts created before the DB trigger existed.
  Future<UserModel> _fetchOrCreateProfile(User authUser) async {
    var data = await supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (data == null) {
      await supabase
          .from('profiles')
          .upsert(_buildProfilePayload(authUser));
      data = await supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
    }

    if (data == null) {
      throw const AppAuthException(
        message: 'Impossible de créer le profil. Réessayez.',
      );
    }
    return UserModel.fromSupabase(data);
  }

  // Retries up to 5 times to handle the async DB trigger race condition on signup.
  Future<UserModel> _fetchProfileWithRetry(User authUser) async {
    AppAuthException? last;
    for (var i = 0; i < 5; i++) {
      try {
        return await _fetchOrCreateProfile(authUser);
      } on AppAuthException catch (e) {
        last = e;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        last = AppAuthException(message: e.toString());
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw last ?? const AppAuthException(message: 'Profil introuvable');
  }

  Map<String, dynamic> _buildProfilePayload(User user) {
    final meta = user.userMetadata ?? {};
    final fullName = (meta['full_name'] as String?)?.trim();
    return {
      'id': user.id,
      'email': user.email ?? '',
      'full_name': (fullName != null && fullName.isNotEmpty)
          ? fullName
          : user.email?.split('@').first ?? '',
      if (meta['phone'] != null) 'phone': meta['phone'],
      if (meta['city'] != null) 'city': meta['city'],
      if (meta['address'] != null) 'address': meta['address'],
    };
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (message.contains('User already registered')) {
      return 'Cet email est déjà utilisé';
    }
    if (message.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email';
    }
    if (message.contains('Password should be at least')) {
      return 'Le mot de passe doit comporter au moins 6 caractères';
    }
    return message;
  }
}
