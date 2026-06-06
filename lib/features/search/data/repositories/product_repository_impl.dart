import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../providers/abstract_product_provider.dart';
import '../providers/aliexpress_provider.dart';
import '../providers/alibaba_provider.dart';
import '../providers/amazon_provider.dart';
import '../providers/temu_provider.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource dataSource;
  final AliExpressProvider aliExpressProvider;
  final AlibabaProvider alibabaProvider;
  final AmazonProvider amazonProvider;
  final TemuProvider temuProvider;

  ProductRepositoryImpl({
    required this.dataSource,
    required this.aliExpressProvider,
    required this.alibabaProvider,
    required this.amazonProvider,
    required this.temuProvider,
  });

  List<AbstractProductProvider> get _providers => [
        aliExpressProvider,
        alibabaProvider,
        amazonProvider,
        temuProvider,
      ];

  @override
  Future<Either<Failure, ProductEntity>> analyzeUrl(String url) async {
    if (!Validators.isSupportedProductUrl(url)) {
      return const Left(ProductProviderFailure(
        message: 'URL non supportée. Utilisez AliExpress, Alibaba, Amazon ou Temu.',
      ));
    }
    try {
      // 1. Check Supabase cache
      try {
        final cached = await dataSource.analyzeUrl(url);
        return Right(cached);
      } catch (_) {
        // Not in cache — fall through to provider
      }

      // 2. Use platform provider (mock until real scraper wired)
      final provider = _providers.firstWhere(
        (p) => p.canHandle(url),
        orElse: () => throw const ProductProviderException(
          message: 'Aucun fournisseur disponible pour cette URL',
        ),
      );
      final product = await provider.getProduct(url);

      // 3. Persist to Supabase (best-effort — don't fail the flow if it errors)
      try {
        final saved = await dataSource.upsertProduct(product);
        return Right(saved);
      } catch (_) {
        return Right(product);
      }
    } on ProductProviderException catch (e) {
      return Left(ProductProviderFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getPopularProducts() async {
    try {
      final products = await dataSource.getPopularProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async {
    try {
      final products = await dataSource.getProductsByCategory(category);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
