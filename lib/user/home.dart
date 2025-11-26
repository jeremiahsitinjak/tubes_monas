import 'package:flutter/material.dart';
import 'history.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A17),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A17),
        elevation: 0,
        automaticallyImplyLeading: false, // HILANGKAN TOMBOL BACK
        title: const Text(
          "Celenganku",
          style: TextStyle(color: Colors.white),
        ),
      ),


      body: buildListContent(),

      floatingActionButton: SizedBox(
        width: 180,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFFC3B54A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          label: const Text(
            " +  Tambah Celengan",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ==============================
  // CONTENT VIEW
  // ==============================
  Widget buildListContent() {
    return Column(
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(child: buildDropdownNominal()),
              const SizedBox(width: 10),
              Expanded(child: buildDropdownUrutan()),
            ],
          ),
        ),

        const SizedBox(height: 60),

        Column(
          children: [
            Icon(Icons.list, color: const Color(0xFFC3B54A), size: 45),
            const SizedBox(height: 10),
            const Text(
              "Tidak ada data untuk ditampilkan.",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  // ==============================
  // DROPDOWN WIDGETS
  // ==============================
  Widget buildDropdownNominal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterNominal,
          dropdownColor: const Color(0xFF2E2E28),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: nominalList.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filterNominal = value!;
            });
          },
        ),
      ),
    );
  }

  Widget buildDropdownUrutan() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterUrutan,
          dropdownColor: const Color(0xFF2E2E28),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: urutanList.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filterUrutan = value!;
            });
          },
        ),
      ),
    );
  }
}
