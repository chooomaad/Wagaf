import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductEntity>> analyzeUrl(String url);
  Future<Either<Failure, List<ProductEntity>>> getPopularProducts();
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String category);
}
