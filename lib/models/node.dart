class Node {
  final int chainId;
  final String name;
  final String httpsUrl;
  final String? wssUrl;

  const Node({
    required this.chainId,
    required this.name,
    required this.httpsUrl,
    this.wssUrl,
  });
}
