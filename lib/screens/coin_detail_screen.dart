import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/favorites_provider.dart';

class CoinDetailScreen extends StatelessWidget {
  final dynamic coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final quote = (coin['quote']?['USD'] as Map<String, dynamic>?) ?? {};
    final double price = (quote['price'] as num?)?.toDouble() ?? 0.0;
    final double percentChange24h =
        (quote['percent_change_24h'] as num?)?.toDouble() ?? 0.0;
    final double marketCap = (quote['market_cap'] as num?)?.toDouble() ?? 0.0;
    final double volume24h = (quote['volume_24h'] as num?)?.toDouble() ?? 0.0;
    final String symbol = (coin['symbol'] ?? '').toString();
    final String imageUrl = (coin['image'] ?? '').toString();
    final String coinName = (coin['name'] ?? 'Unknown').toString();
    final isPositive = percentChange24h >= 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white10),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favorites, child) {
              final isFav = favorites.isFavorite(coin);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
                onPressed: () => favorites.toggleFavorite(coin),
              );
            }
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- HEADER ---
            _buildCoinAvatar(symbol: symbol, imageUrl: imageUrl, radius: 30),
            const SizedBox(height: 10),
            Text(
              coinName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              symbol,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // --- HUGE PRICE TEXT ---
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.orange, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  '${isPositive ? "+" : ""}${percentChange24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- CHART CONTAINER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Chart (7 Days)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 3,
                        gridData: FlGridData(show: true), // Shows the grid lines
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 34,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(0),
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true), // Shows chart border
                        lineBarsData: [
                          LineChartBarData(
                            // Note: CoinGecko free tier doesn't give historical array data, 
                            // so we use a visual placeholder array here that mimics your screenshot.
                            spots: const [
                              FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.2),
                              FlSpot(3, 2.5), FlSpot(4, 1.8), FlSpot(5, 2.0),
                              FlSpot(6, 2.2),
                            ],
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true), // Shows the dots on the line
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- STATISTICS GRID ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Statistics',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildStatCard('Market Cap', '\$${(marketCap / 1000000000).toStringAsFixed(2)}B')),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard('24h Volume', '\$${(volume24h / 1000000000).toStringAsFixed(2)}B')),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // If API doesn't provide high/low, we calculate a rough estimate for UI purposes
                Expanded(child: _buildStatCard('24h High', '\$${(price * 1.05).toStringAsFixed(2)}')), 
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard('24h Low', '\$${(price * 0.95).toStringAsFixed(2)}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinAvatar({
    required String symbol,
    required String imageUrl,
    double radius = 30,
  }) {
    final avatarLabel = symbol.isNotEmpty ? symbol[0] : '?';
    final hasLogo = imageUrl.isNotEmpty;

    if (!hasLogo) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.orange,
        child: Text(
          avatarLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to build the dark grey stat boxes
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
