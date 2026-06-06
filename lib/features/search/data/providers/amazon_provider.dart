import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import 'abstract_product_provider.dart';

class AmazonProvider implements AbstractProductProvider {
  @override
  String get platform => 'amazon';

  @override
  bool canHandle(String url) => url.toLowerCase().contains('amazon.');

  @override
  Future<ProductEntity> getProduct(String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return ProductEntity(
      id: const Uuid().v4(),
      url: url,
      platform: platform,
      title: 'Produit Amazon (analyse requise)',
      description: 'Produit importé depuis Amazon.',
      price: 39.99,
      currency: 'USD',
      images: ['https://picsum.photos/seed/amazon/400/400'],
      category: 'Général',
      rating: 4.7,
      reviewsCount: 8901,
      isAvailable: true,
      metadata: {'source_url': url, 'provider': 'amazon'},
    );
  }
}
