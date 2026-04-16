import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'coin_detail_screen.dart';

class HomeCryptoApp extends StatefulWidget {
  const HomeCryptoApp({super.key});

  @override
  State<HomeCryptoApp> createState() => _HomeCryptoAppState();
}

class _HomeCryptoAppState extends State<HomeCryptoApp> {
  late Future<List<dynamic>> cryptoData;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    cryptoData = fetchCoins();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchCoins() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false&price_change_percentage=24h',
        ),
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        return responseData.map((coin) {
          final currentPrice = (coin['current_price'] as num?)?.toDouble() ?? 0.0;
          final percentChange =
              (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
          final marketCap = (coin['market_cap'] as num?)?.toDouble() ?? 0.0;
          final volume24h = (coin['total_volume'] as num?)?.toDouble() ?? 0.0;

          return {
            'symbol': (coin['symbol'] ?? '').toString().toUpperCase(),
            'name': coin['name'] ?? 'Unknown',
            'image': (coin['image'] ?? '').toString(),
            'quote': {
              'USD': {
                'price': currentPrice,
                'percent_change_24h': percentChange,
                'market_cap': marketCap,
                'volume_24h': volume24h,
              },
            },
          };
        }).toList();
      } else {
        debugPrint("API Error Response: ${response.body}");
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Network error: $e");
      throw Exception(
        'Unable to load cryptocurrency data. Check your internet connection and try again.',
      );
    }
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(
              height: 12.0,
              width: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 8.0),
              height: 10.0,
              width: 60.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 12.0, width: 60.0, color: Colors.white),
                const SizedBox(height: 8.0),
                Container(height: 10.0, width: 40.0, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(),
      body: searchBar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Crypto View',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.loop_rounded, color: Colors.orange),
          onPressed: () {
            setState(() {
              cryptoData = fetchCoins();
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.swap_vert, color: Colors.orange),
          onPressed: () {},
        ),
      ],
    );
  }

  Column searchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.only(left: 15.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search cryptocurrencies...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
        coinList(),
      ],
    );
  }

  Expanded coinList() {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: cryptoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No data found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final coins = snapshot.data!;
          final filteredCoins = _searchQuery.isEmpty
              ? coins
              : coins.where((coin) {
                  final symbol =
                      (coin['symbol'] ?? '').toString().toLowerCase();
                  final name = (coin['name'] ?? '').toString().toLowerCase();
                  return symbol.contains(_searchQuery) ||
                      name.contains(_searchQuery);
                }).toList();

          if (filteredCoins.isEmpty) {
            return const Center(
              child: Text(
                'No matching cryptocurrencies',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredCoins.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final coin = filteredCoins[index];
              final quote = coin['quote']['USD'];
              final double price = quote['price'];
              final double percentChange = quote['percent_change_24h'];
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
                title: Row(
                  children: [
                    Text(
                      coin['symbol'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    // The Star Icon that listens to the Provider
                    Consumer<FavoritesProvider>(
                      builder: (context, favorites, child) {
                        final isFav = favorites.isFavorite(coin);
                        return GestureDetector(
                          onTap: () => favorites.toggleFavorite(coin),
                          child: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.orange : Colors.grey,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: Text(
                  coin['name'],
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentChange >= 0 ? "+" : ""}${percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: percentChange >= 0 ? Colors.green : Colors.red,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
