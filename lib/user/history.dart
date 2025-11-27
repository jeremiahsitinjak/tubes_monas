import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // HILANGKAN TOMBOL BACK
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: buildListContent(),
    );
  }

  Widget buildListContent() {
    return Column(
      children: [
        // const SizedBox(height: 20),

        // Dropdown filter
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   child: Row(
        //     children: [
        //       Expanded(child: buildDropdownNominal()),
        //       const SizedBox(width: 10),
        //       Expanded(child: buildDropdownUrutan()),
        //     ],
        //   ),
        // ),

        // Empty state
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.list, color: Colors.black, size: 60),
                const SizedBox(height: 10),
                const Text(
                  "Tidak ada data untuk ditampilkan.",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget buildDropdownNominal() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.blue,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: _filterNominal,
  //         dropdownColor: Colors.blue,
  //         borderRadius: BorderRadius.circular(8),
  //         icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
  //         style: const TextStyle(color: Colors.white),
  //         items: nominalList.map((value) {
  //           return DropdownMenuItem(
  //             value: value,
  //             child: Text(value, style: const TextStyle(color: Colors.white)),
  //           );
  //         }).toList(),
  //         onChanged: (value) {
  //           setState(() {
  //             _filterNominal = value!;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget buildDropdownUrutan() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.blue,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: _filterUrutan,
  //         dropdownColor: Colors.blue,
  //         borderRadius: BorderRadius.circular(8),
  //         icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
  //         style: const TextStyle(color: Colors.white),
  //         items: urutanList.map((value) {
  //           return DropdownMenuItem(
  //             value: value,
  //             child: Text(value, style: const TextStyle(color: Colors.white)),
  //           );
  //         }).toList(),
  //         onChanged: (value) {
  //           setState(() {
  //             _filterUrutan = value!;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }
}
