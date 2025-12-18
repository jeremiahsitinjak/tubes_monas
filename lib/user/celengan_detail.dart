import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/models/celengan.dart';
import 'package:tubes_monas/models/celengan_transaction.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tubes_monas/models/constants.dart';

class CelenganDetailPage extends StatefulWidget {
  final Celengan celengan;

  const CelenganDetailPage({super.key, required this.celengan});

  @override
  State<CelenganDetailPage> createState() => _CelenganDetailPageState();
}

class _CelenganDetailPageState extends State<CelenganDetailPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<CelenganTransaction> _transactions = [];
  int _totalDeposit = 0;
  int _totalWithdraw = 0;
  int _currentBalance = 0;
  bool _hasChanges = false;

  bool get _isHistory => widget.celengan.status == 'completed';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<bool> _handleWillPop() async {
    Navigator.pop(context, _hasChanges);
    return false;
  }

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.celengan.nominalTerkumpul.toInt();
    _loadTransactions();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final url = Uri.parse(
          "$apiBase/celengan/${widget.celengan.id}/transactions");
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        final summary = data['summary'] ?? {};
        setState(() {
          _transactions = list
              .map((json) => CelenganTransaction.fromJson(json))
              .toList();
          _totalDeposit = summary['total_deposit'] ?? 0;
          _totalWithdraw = summary['total_withdraw'] ?? 0;
          _currentBalance = summary['current_balance'] ?? _currentBalance;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil transaksi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openTransactionDialog(String type) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(type == 'deposit' ? '💰 Tambah Tabungan' : '💸 Tarik Uang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: widget.celengan.currency == 'IDR' ? 'Rp ' : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                type == 'deposit' ? Colors.blueAccent : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final amountText = amountController.text.trim();
      final description = descriptionController.text.trim();
      if (amountText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nominal wajib diisi')),
        );
        return;
      }

      // Validasi maksimum setoran 1 milyar di sisi Flutter
      try {
        final parsedAmount = double.parse(
            amountText.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsedAmount > 1000000000) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Melebihi batas maksimal'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal setoran tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _submitTransaction(
        type: type,
        amount: amountText,
        description: description,
      );
    }
  }

  Future<void> _submitTransaction({
    required String type,
    required String amount,
    String? description,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');
      final createdAt = DateTime.now().toIso8601String();

      final url = Uri.parse(
        "$apiBase/celengan/${widget.celengan.id}/transactions");
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'type': type,
          'amount': amount,
          'created_at': createdAt,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(type == 'deposit'
                  ? 'Berhasil menambah uang'
                  : 'Berhasil menarik uang'),
              backgroundColor: Colors.green,
            ),
          );
        }
        setState(() {
          _hasChanges = true;
        });

        await _loadTransactions();

        if (type == 'deposit' && _currentBalance >= widget.celengan.target) {
          try {
            // Batalkan semua notifikasi pengingat terjadwal untuk celengan ini
            // agar setelah target tercapai tidak ada pengingat lagi.
            if (widget.celengan.id != null) {
              await flutterLocalNotificationsPlugin
                  .cancel(widget.celengan.id!);
            }
          } catch (e) {
            debugPrint('Gagal membatalkan notifikasi terjadwal: $e');
          }

          try {
            const AndroidNotificationDetails androidPlatformChannelSpecifics =
                AndroidNotificationDetails(
              'target_channel',
              'Target Channel',
              importance: Importance.max,
              priority: Priority.high,
            );
            const NotificationDetails platformChannelSpecifics =
                NotificationDetails(
                    android: androidPlatformChannelSpecifics);

            await flutterLocalNotificationsPlugin.show(
              0,
              'Yeay! Target Tercapai 🎉',
              'Selamat! Celengan ${widget.celengan.nama} sudah penuh.',
              platformChannelSpecifics,
            );
          } catch (e) {
            debugPrint('Gagal menampilkan notifikasi: $e');
          }

          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menyimpan transaksi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Celengan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${widget.celengan.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteCelengan();
    }
  }

  String _getImageUrl() {
    final String? rawPath = widget.celengan.imagePath;
    if (rawPath == null || rawPath.isEmpty) return '';
    if (rawPath.startsWith('http')) return rawPath;
    String cleanPath = rawPath;
    if (rawPath.contains('celengan/')) {
      cleanPath = rawPath.substring(rawPath.indexOf('celengan/'));
    }
    return "$apiBase/image-proxy/$cleanPath";
  }

  Future<void> _deleteCelengan() async {
    if (widget.celengan.id == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final url = Uri.parse(
          "$apiBase/celengan/${widget.celengan.id}");
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Berhasil menghapus di server, sekarang batalkan juga pengingat lokal
        try {
          await flutterLocalNotificationsPlugin.cancel(widget.celengan.id!);
        } catch (e) {
          debugPrint('Gagal membatalkan notifikasi saat hapus celengan: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Celengan berhasil dihapus'),
                backgroundColor: Colors.green),
          );
        }
        setState(() => _hasChanges = true);
        if (mounted) Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus celengan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menghapus celengan: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = widget.celengan.currency.contains('Rp')
        ? 'Rp'
        : widget.celengan.currency.contains('\$')
        ? '\$'
        : widget.celengan.currency.contains('RM')
        ? 'RM'
        : 'Rp';

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadTransactions,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildHeroCard(currencySymbol),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        _buildTransactionHeader(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildTransactionList(currencySymbol),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSliverAppBar() {
    final imageUrl = _getImageUrl();
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blueAccent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: _handleWillPop,
            tooltip: 'Kembali',
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.celengan.nama,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
        background: imageUrl.isNotEmpty
            ? Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        )
            : Container(
          color: Colors.blueAccent,
          child:
          const Icon(Icons.savings, size: 80, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildHeroCard(String currencySymbol) {
    double progress =
    (_currentBalance / widget.celengan.target).clamp(0.0, 1.0);
    String percentage = (progress * 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Saat Ini',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currencySymbol ${NumberFormat('#,###').format(_currentBalance)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: $currencySymbol ${NumberFormat('#,###').format(widget.celengan.target)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isHistory) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _confirmDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Hapus Celengan Selesai'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Setor',
            color: Colors.green,
            onPressed: () => _openTransactionDialog('deposit'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.remove_circle_outline,
            label: 'Tarik',
            color: Colors.orange,
            onPressed: () => _openTransactionDialog('withdraw'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.2))),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Row(
      children: const [
        Text(
          'Riwayat Transaksi',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Spacer(),
        Icon(Icons.history, color: Colors.grey),
      ],
    );
  }

  Widget _buildTransactionList(String currencySymbol) {
    if (_transactions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded,
                    size: 50, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final tx = _transactions[index];
            final isDeposit = tx.type == 'deposit';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDeposit
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDeposit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isDeposit ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${isDeposit ? '+' : '-'} $currencySymbol ${NumberFormat('#,###').format(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDeposit ? Colors.black87 : Colors.redAccent,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tx.description?.isNotEmpty == true
                        ? tx.description!
                        : (isDeposit ? 'Setoran Tabungan' : 'Penarikan Dana'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM').format(tx.createdAt),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 12),
                    ),
                    Text(
                      DateFormat('HH:mm').format(tx.createdAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _transactions.length,
        ),
      ),
    );
  }
}