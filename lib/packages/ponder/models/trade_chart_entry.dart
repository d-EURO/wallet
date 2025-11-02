class TradeChartEntry {
  final String id;
  final String lastPrice;
  final String time;


  const TradeChartEntry({
    required this.id,
    required this.lastPrice,
    required this.time,
  });

  static List<TradeChartEntry> fromJson(Map<String, dynamic> query) {
    final result = <TradeChartEntry>[];
    final items = query['tradeCharts']['items'] as List<dynamic>;

    for (final itemRaw in items) {
      final item = itemRaw as Map<String, dynamic>;
      result.add(TradeChartEntry(
        id: item['id'],
        lastPrice: item['lastPrice'],
        time: item['time'],
      ));
    }

    return result;
  }
}
