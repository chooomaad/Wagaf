import '../../domain/entities/product_entity.dart';

/// Abstract interface for all shopping platform providers.
/// Add a new provider by implementing this class.
abstract class AbstractProductProvider {
  /// Platform identifier (e.g., 'aliexpress', 'amazon')
  String get platform;

  /// Returns true if this provider handles the given URL
  bool canHandle(String url);

  /// Fetch product details from the given URL
  Future<ProductEntity> getProduct(String url);
}
