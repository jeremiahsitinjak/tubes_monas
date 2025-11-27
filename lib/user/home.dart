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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // HILANGKAN TOMBOL BACK
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: buildListContent(),

      floatingActionButton: SizedBox(
        width: 180,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          label: const Text(
            " +  Tambah Celengan",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // CONTENT VIEW
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
            Icon(Icons.list, color: Colors.black, size: 60),
            const SizedBox(height: 10),
            const Text(
              "Tidak ada data untuk ditampilkan.",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  // DROPDOWN WIDGETS
  Widget buildDropdownNominal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:  Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterNominal,
          dropdownColor: Colors.blue,
          borderRadius: BorderRadius.circular(8),
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
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterUrutan,
          dropdownColor: Colors.blue,
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
