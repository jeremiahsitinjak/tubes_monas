import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/models/celengan.dart';
import 'package:tubes_monas/user/celengan_detail.dart';
import 'package:intl/intl.dart';
import 'package:tubes_monas/models/constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterNominal = "Nominal Terkumpul";
  String _filterUrutan = "Meningkat";

  final List<String> nominalList = [
    "Nominal Terkumpul",
    "Nominal Target",
    "Nama Celengan",
  ];

  final List<String> urutanList = [
    "Meningkat",
    "Menurun",
  ];

  List<Celengan> _celenganList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCelengan();
  }

  Future<void> _loadCelengan() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse("$apiBase/celengan?status=completed");

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'] ?? [];

        setState(() {
          _celenganList = data.map((json) => Celengan.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading celengan: $e');
      setState(() => _isLoading = false);
    }
  }

  double get _totalCompletedSavings {
    return _celenganList.fold(0, (sum, item) => sum + item.nominalTerkumpul);
  }

  String? _resolveImageUrl(String? path) {
    if (path == null) return null;
    if (path.startsWith('http')) return path;
    return "$apiBase/image-proxy/$path";
  }

  Future<void> _openCelenganDetail(Celengan celengan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CelenganDetailPage(celengan: celengan),
      ),
    );
    _loadCelengan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "History",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: buildListContent(),
    );
  }

  Widget buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Celengan> sortedList = List.from(_celenganList);
    sortedList.sort((a, b) {
      int comparison = 0;
      if (_filterNominal == "Nominal Terkumpul") {
        comparison = a.nominalTerkumpul.compareTo(b.nominalTerkumpul);
      } else if (_filterNominal == "Nominal Target") {
        comparison = a.target.compareTo(b.target);
      } else {
        comparison = a.nama.compareTo(b.nama);
      }
      return _filterUrutan == "Meningkat" ? comparison : -comparison;
    });

    return RefreshIndicator(
      onRefresh: _loadCelengan,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_celenganList.isNotEmpty) _buildAchievementCard(),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Daftar Pencapaian",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Icon(Icons.emoji_events_outlined, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModernDropdown(
                  value: _filterNominal,
                  items: nominalList,
                  onChanged: (val) => setState(() => _filterNominal = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernDropdown(
                  value: _filterUrutan,
                  items: urutanList,
                  onChanged: (val) => setState(() => _filterUrutan = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (sortedList.isEmpty)
            _buildEmptyState()
          else
            ...sortedList.map((item) => _buildHistoryCard(item)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                "Total Target Tercapai",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Rp ${NumberFormat('#,###').format(_totalCompletedSavings)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Dari ${_celenganList.length} impian yang terwujud",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Belum ada riwayat selesai",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Selesaikan target pertamamu!",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.sort, size: 20, color: Colors.grey),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Celengan celengan) {
    final currencySymbol = celengan.currency.contains('Rp')
        ? 'Rp'
        : celengan.currency == 'USD' ? '\$' : celengan.currency;

    final imageUrl = _resolveImageUrl(celengan.imagePath);

    String dateLabel = "Selesai: -";
    if (celengan.completedAt != null) {
      dateLabel = "Selesai: ${DateFormat('dd MMM yyyy').format(celengan.completedAt!)}";
    } else if (celengan.updatedAt != null) {
      dateLabel = "Selesai: ${DateFormat('dd MMM yyyy').format(celengan.updatedAt!)}";
    }

    return GestureDetector(
      onTap: () => _openCelenganDetail(celengan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.green.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green[50],
                  image: imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: imageUrl == null
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            celengan.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LUNAS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currencySymbol ${NumberFormat('#,###').format(celengan.target)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 8, top: 12),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}