import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borc Kitabçası'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Borc Aldıqlarım'),
            Tab(text: 'Borc Verdiklərim'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Ümumi Borcum',
                    provider.totalBorrowed,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Mənə Borclular',
                    provider.totalLent,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(provider.borrowedTransactions, true),
                _buildTransactionList(provider.lentTransactions, false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} ₼',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<DebtTransaction> transactions, bool isBorrowing) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBorrowing ? Icons.money_off : Icons.attach_money,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isBorrowing ? 'Borc aldığınız heç kim yoxdur' : 'Borc verdiyiniz heç kim yoxdur',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Dismissible(
          key: Key(tx.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(tx.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Əməliyyat silindi')),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isBorrowing ? Colors.red[100] : Colors.green[100],
                child: Icon(
                  isBorrowing ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isBorrowing ? Colors.red : Colors.green,
                ),
              ),
              title: Text(
                tx.personName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: tx.isPaid ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd MMM yyyy').format(tx.date)),
                  if (tx.description != null && tx.description!.isNotEmpty)
                    Text(
                      tx.description!,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.amount.toStringAsFixed(2)} ₼',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: tx.isPaid ? Colors.grey : (isBorrowing ? Colors.red : Colors.green),
                      decoration: tx.isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Provider.of<TransactionProvider>(context, listen: false).togglePaymentStatus(tx.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tx.isPaid ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tx.isPaid ? 'Ödənildi' : 'Aktiv',
                        style: TextStyle(
                          fontSize: 10,
                          color: tx.isPaid ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
