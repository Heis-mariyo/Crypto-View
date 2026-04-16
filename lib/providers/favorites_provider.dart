import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier{
  final List<dynamic> _favoritesCoins = [];

  List<dynamic> get favoriteCoins => _favoritesCoins;

  void toggleFavorite(dynamic coin) {
    final isExist = _favoritesCoins.any((c) => c['symbol'] == coin ['symbol']);

    if (isExist) {
      _favoritesCoins.removeWhere((c) => c['symbol'] == coin['symbol']);
    } else {
      _favoritesCoins.add(coin);
    }

    notifyListeners();
  }

  bool isFavorite(dynamic coin) {
    return _favoritesCoins.any((c) => c['symbol'] == coin['symbol']);
  }
}