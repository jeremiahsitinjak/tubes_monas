import 'package:flutter/material.dart';
import 'package:tubes_monas/user/add_celengan.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // HILANGKAN TOMBOL BACK
        title: const Text("Home", style: TextStyle(color: Colors.white)),
      ),

      body: buildListContent(),

      floatingActionButton: SizedBox(
        width: 180,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCelenganPage()),
            );
          },
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          color: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 50),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          onSelected: (value) {
            setState(() {
              _filterNominal = value;
            });
          },
          itemBuilder: (context) {
            return nominalList.map((value) {
              return PopupMenuItem<String>(
                value: value,
                height: 50,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _filterNominal,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDropdownUrutan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          color: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 50),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          onSelected: (value) {
            setState(() {
              _filterUrutan = value;
            });
          },
          itemBuilder: (context) {
            return urutanList.map((value) {
              return PopupMenuItem<String>(
                value: value,
                height: 50,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _filterUrutan,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
