import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/requests/data/datasources/requests_remote_datasource.dart';
import '../../features/requests/data/repositories/requests_repository_impl.dart';
import '../../features/requests/domain/repositories/requests_repository.dart';
import '../../features/search/data/datasources/product_remote_datasource.dart';
import '../../features/search/data/providers/aliexpress_provider.dart';
import '../../features/search/data/providers/alibaba_provider.dart';
import '../../features/search/data/providers/amazon_provider.dart';
import '../../features/search/data/providers/temu_provider.dart';
import '../../features/search/data/repositories/product_repository_impl.dart';
import '../../features/search/domain/repositories/product_repository.dart';
import '../../shared/services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Services
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<RequestsRemoteDataSource>(
    () => RequestsRemoteDataSourceImpl(db: sl()),
  );

  // Product Providers (abstract factory pattern)
  sl.registerLazySingleton<AliExpressProvider>(() => AliExpressProvider());
  sl.registerLazySingleton<AlibabaProvider>(() => AlibabaProvider());
  sl.registerLazySingleton<AmazonProvider>(() => AmazonProvider());
  sl.registerLazySingleton<TemuProvider>(() => TemuProvider());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      dataSource: sl(),
      aliExpressProvider: sl(),
      alibabaProvider: sl(),
      amazonProvider: sl(),
      temuProvider: sl(),
    ),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<RequestsRepository>(
    () => RequestsRepositoryImpl(dataSource: sl()),
  );
}
