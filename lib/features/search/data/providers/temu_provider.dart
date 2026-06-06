import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import 'abstract_product_provider.dart';

class TemuProvider implements AbstractProductProvider {
  @override
  String get platform => 'temu';

  @override
  bool canHandle(String url) => url.toLowerCase().contains('temu.com');

  @override
  Future<ProductEntity> getProduct(String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return ProductEntity(
      id: const Uuid().v4(),
      url: url,
      platform: platform,
      title: 'Produit Temu (analyse requise)',
      description: 'Produit importé depuis Temu.',
      price: 12.99,
      currency: 'USD',
      images: ['https://picsum.photos/seed/temu/400/400'],
      category: 'Général',
      rating: 4.3,
      reviewsCount: 3456,
      isAvailable: true,
      metadata: {'source_url': url, 'provider': 'temu'},
    );
  }
}
