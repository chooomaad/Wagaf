import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductRemoteDataSource {
  Future<ProductEntity> analyzeUrl(String url);
  Future<ProductEntity> upsertProduct(ProductEntity product);
  Future<List<ProductEntity>> getPopularProducts();
  Future<List<ProductEntity>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabase;
  ProductRemoteDataSourceImpl({required this.supabase});

  @override
  Future<ProductEntity> analyzeUrl(String url) async {
    try {
      // Check cache first
      final cached = await supabase
          .from('products')
          .select()
          .eq('external_url', url)
          .maybeSingle();
      if (cached != null) {
        return ProductEntity.fromJson(_mapProduct(cached));
      }
      throw ProductProviderException(message: 'Product not in cache: $url');
    } catch (e) {
      if (e is ProductProviderException) rethrow;
      throw ProductProviderException(message: e.toString());
    }
  }

  @override
  Future<List<ProductEntity>> getPopularProducts() async {
    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('is_available', true)
          .order('reviews_count', ascending: false)
          .limit(10);
      return (data as List)
          .map((e) => ProductEntity.fromJson(_mapProduct(e)))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .limit(20);
      return (data as List)
          .map((e) => ProductEntity.fromJson(_mapProduct(e)))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProductEntity> upsertProduct(ProductEntity product) async {
    try {
      final data = <String, dynamic>{
        'external_url': product.url,
        'platform': product.platform,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'currency': product.currency,
        'images': product.images,
        'category': product.category,
        'rating': product.rating,
        'reviews_count': product.reviewsCount,
        'is_available': product.isAvailable,
        'metadata': product.metadata,
        'updated_at': DateTime.now().toIso8601String(),
      };
      final result = await supabase
          .from('products')
          .upsert(data, onConflict: 'external_url')
          .select()
          .single();
      return ProductEntity.fromJson(_mapProduct(result));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _mapProduct(Map<String, dynamic> data) => {
        'id': data['id'],
        'url': data['external_url'],
        'platform': data['platform'],
        'title': data['title'],
        'description': data['description'],
        'price': (data['price'] as num?)?.toDouble() ?? 0.0,
        'currency': data['currency'] ?? 'USD',
        'images': List<String>.from(data['images'] ?? []),
        'category': data['category'],
        'rating': (data['rating'] as num?)?.toDouble(),
        'reviewsCount': data['reviews_count'],
        'isAvailable': data['is_available'] ?? true,
        'metadata': data['metadata'] ?? {},
      };
}
