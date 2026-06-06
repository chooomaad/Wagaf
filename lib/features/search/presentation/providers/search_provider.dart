import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

enum SearchStatus { idle, loading, success, error }

class SearchState {
  final SearchStatus status;
  final ProductEntity? product;
  final List<ProductEntity> popularProducts;
  final String? error;
  final String currentUrl;

  const SearchState({
    this.status = SearchStatus.idle,
    this.product,
    this.popularProducts = const [],
    this.error,
    this.currentUrl = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    ProductEntity? product,
    List<ProductEntity>? popularProducts,
    String? error,
    String? currentUrl,
  }) =>
      SearchState(
        status: status ?? this.status,
        product: product ?? this.product,
        popularProducts: popularProducts ?? this.popularProducts,
        error: error,
        currentUrl: currentUrl ?? this.currentUrl,
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProductRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState()) {
    loadPopularProducts();
  }

  Future<bool> analyzeUrl(String url) async {
    state = state.copyWith(
      status: SearchStatus.loading,
      currentUrl: url,
      error: null,
    );
    final result = await _repository.analyzeUrl(url);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          error: failure.message,
        );
        return false;
      },
      (product) {
        state = state.copyWith(
          status: SearchStatus.success,
          product: product,
        );
        return true;
      },
    );
  }

  Future<void> loadPopularProducts() async {
    final result = await _repository.getPopularProducts();
    result.fold(
      (_) {},
      (products) => state = state.copyWith(popularProducts: products),
    );
  }

  void setCurrentUrl(String url) {
    state = state.copyWith(currentUrl: url);
  }

  void clearProduct() {
    state = state.copyWith(
      status: SearchStatus.idle,
      error: null,
      currentUrl: '',
    );
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return GetIt.instance<ProductRepository>();
});

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(productRepositoryProvider));
});
