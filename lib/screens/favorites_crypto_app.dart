import 'package:crypto_app/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coin_detail_screen.dart';

class FavoritesCryptoApp extends StatelessWidget {
  const FavoritesCryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favorites, child) {
          final favCoins = favorites.favoriteCoins;

          if (favCoins.isEmpty) {
            return const Center(
              child: Text(
                'No favorite coins yet. \nGo to Home and Click the star!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey, fontSize: 16.0,
                ),

              ),
            );
          }
          return ListView.separated(
            itemCount: favCoins.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            separatorBuilder: (context, index) => const Divider(color: Colors.white10,),
            itemBuilder: (context, index) {
              final coin = favCoins[index];
              final quote = coin['quote']?['USD'];

              if (quote == null) {
                return const SizedBox.shrink();
              }

              final double price = (quote['price'] as num?)?.toDouble() ?? 0.0;
              final double percentChange =
                  (quote['percent_change_24h'] as num?)?.toDouble() ?? 0.0;
              final String symbol = (coin['symbol'] ?? '--').toString();
              final String imageUrl = (coin['image'] ?? '').toString();

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => CoinDetailScreen(coin: coin),
                    )
                  );
                },
                leading: _buildCoinAvatar(symbol: symbol, imageUrl: imageUrl),
                title:  Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4.0),

                    GestureDetector(
                      onTap: () => favorites.toggleFavorite(coin),
                      child: const Icon(Icons.star, color: Colors.orange, size: 18),
                    )
                  ],
                ),
                subtitle: Text(
                  (coin['name'] ?? 'Unknown').toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${percentChange >= 0 ? "+" : ""}${percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: percentChange >= 0 ? Colors.green : Colors.red,
                        fontSize: 12.0,
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },),
    );
  }

  Widget _buildCoinAvatar({
    required String symbol,
    required String imageUrl,
    double radius = 20,
  }) {
    final avatarLabel = symbol.isNotEmpty ? symbol[0] : '?';
    final hasLogo = imageUrl.isNotEmpty;

    if (!hasLogo) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade800,
        child: Text(
          avatarLabel,
          style: const TextStyle(color: Colors.orange),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                avatarLabel,
                style: const TextStyle(color: Colors.orange),
              ),
            );
          },
        ),
      ),
    );
  }
}
