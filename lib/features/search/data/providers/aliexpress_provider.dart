import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import 'abstract_product_provider.dart';

/// AliExpress product provider.
/// Currently returns mock data — wire real API/scraping here.
class AliExpressProvider implements AbstractProductProvider {
  @override
  String get platform => 'aliexpress';

  @override
  bool canHandle(String url) =>
      url.toLowerCase().contains('aliexpress.com');

  @override
  Future<ProductEntity> getProduct(String url) async {
    // TODO: integrate AliExpress API or Playwright scraper
    await Future.delayed(const Duration(seconds: 1));
    return ProductEntity(
      id: const Uuid().v4(),
      url: url,
      platform: platform,
      title: 'Produit AliExpress (analyse requise)',
      description: 'Collez ce lien pour récupérer les détails du produit automatiquement.',
      price: 29.99,
      currency: 'USD',
      images: [
        'https://picsum.photos/seed/aliexpress/400/400',
      ],
      category: 'Général',
      rating: 4.5,
      reviewsCount: 1234,
      isAvailable: true,
      metadata: {'source_url': url, 'provider': 'aliexpress'},
    );
  }
}
