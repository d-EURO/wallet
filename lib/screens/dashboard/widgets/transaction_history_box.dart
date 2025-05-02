import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/transaction_history_service.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/transaction_row.dart';
import 'package:flutter/material.dart';

class TransactionHistoryBox extends StatelessWidget {
  const TransactionHistoryBox({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text("Transactions"),
                ],
              ),
            ),
            ActionChip(
              label: Text("Load Txs"),
              onPressed: () {
                TransactionHistoryService(
                        getIt<AppStore>(),
                        getIt<AssetRepository>(),
                        getIt<TransactionRepository>())
                    .explorerAssistedScan();
              },
              avatar: CircleAvatar(
                child: Icon(Icons.refresh),
              ),
            ),
            ...transactions.map((e) => TransactionRow(
                  transaction: e,
                ))
          ],
        ),
      );
}
