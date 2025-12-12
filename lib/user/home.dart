import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/user/add_celengan.dart';
import 'package:tubes_monas/user/celengan_detail.dart';
import 'package:tubes_monas/models/celengan.dart';
import 'package:intl/intl.dart';
import 'package:tubes_monas/models/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _filterNominal = "Nominal Terkumpul";
  String _filterUrutan = "Meningkat";

  final List<String> nominalList = ["Nominal Terkumpul", "Nominal Target"];
  final List<String> urutanList = ["Meningkat", "Menurun"];

  List<Celengan> _celenganList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCelengan();
  }

  Future<void> _loadCelengan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse("$apiBase/celengan?status=active");

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

  double get _totalAllSavings {
    return _celenganList.fold(0, (sum, item) => sum + item.nominalTerkumpul);
  }

  Future<void> _openCelenganDetail(Celengan celengan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CelenganDetailPage(celengan: celengan),
      ),
    );
    if (result == true) {
      await _loadCelengan();
    }
  }

  Future<void> _openCelenganForm({Celengan? celengan}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCelenganPage(celengan: celengan),
      ),
    );
    if (result == true) {
      await _loadCelengan();
    }
  }

  Future<void> _confirmDelete(Celengan celengan) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Celengan'),
        content: Text('Apakah Anda yakin ingin menghapus "${celengan.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteCelengan(celengan);
    }
  }

  Future<void> _deleteCelengan(Celengan celengan) async {
    if (celengan.id == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final url = Uri.parse("$apiBase/celengan/${celengan.id}");
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Celengan berhasil dihapus'),
                backgroundColor: Colors.green),
          );
        }
        await _loadCelengan();
      } else {
        throw Exception('Gagal menghapus');
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

  String? _resolveImageUrl(String? path) {
    if (path == null) return null;
    if (path.startsWith('http')) return path;
    return "$apiBase/image-proxy/$path";
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
          "Home",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: buildBodyContent(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openCelenganForm(),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          label: const Text(
            "Tambah Celengan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Celengan> sortedList = List.from(_celenganList);
    sortedList.sort((a, b) {
      int comp = (_filterNominal == "Nominal Terkumpul")
          ? a.nominalTerkumpul.compareTo(b.nominalTerkumpul)
          : a.target.compareTo(b.target);
      return _filterUrutan == "Meningkat" ? comp : -comp;
    });

    return RefreshIndicator(
      onRefresh: _loadCelengan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _buildSummaryHeader(),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Celengan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
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
            ...sortedList.map((item) => _buildCelenganCard(item)),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Tabungan Anda",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp ${NumberFormat('#,###').format(_totalAllSavings)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_celenganList.length} Goals Aktif",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Belum ada celengan",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Mulai wujudkan mimpimu sekarang!",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelenganCard(Celengan celengan) {
    final currencySymbol = celengan.currency.contains('Rp')
        ? 'Rp'
        : celengan.currency == 'USD'
        ? '\$'
        : celengan.currency;

    final imageUrl = _resolveImageUrl(celengan.imagePath);
    final progress = celengan.progress;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => _openCelenganDetail(celengan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'celengan-${celengan.id}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[100],
                        image: imageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: imageUrl == null
                          ? const Icon(Icons.savings,
                          color: Colors.blueAccent, size: 30)
                          : null,
                    ),
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
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.more_horiz, color: Colors.grey),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openCelenganForm(celengan: celengan);
                                } else if (value == 'delete') {
                                  _confirmDelete(celengan);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus',
                                        style: TextStyle(color: Colors.red))),
                              ],
                            )
                          ],
                        ),
                        Text(
                          'Target: $currencySymbol ${NumberFormat('#,###').format(celengan.target)}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$currencySymbol ${NumberFormat('#,###').format(celengan.nominalTerkumpul)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(
                                '$progressPercent%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2193b0)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}