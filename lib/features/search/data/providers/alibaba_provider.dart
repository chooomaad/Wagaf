import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import 'abstract_product_provider.dart';

class AlibabaProvider implements AbstractProductProvider {
  @override
  String get platform => 'alibaba';

  @override
  bool canHandle(String url) => url.toLowerCase().contains('alibaba.com');

  @override
  Future<ProductEntity> getProduct(String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return ProductEntity(
      id: const Uuid().v4(),
      url: url,
      platform: platform,
      title: 'Produit Alibaba (analyse requise)',
      description: 'Produit importé depuis Alibaba.',
      price: 49.99,
      currency: 'USD',
      images: ['https://picsum.photos/seed/alibaba/400/400'],
      category: 'Général',
      rating: 4.2,
      reviewsCount: 567,
      isAvailable: true,
      metadata: {'source_url': url, 'provider': 'alibaba'},
    );
  }
}
