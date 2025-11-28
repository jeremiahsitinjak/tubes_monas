import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddCelenganPage extends StatefulWidget {
  const AddCelenganPage({super.key});

  @override
  State<AddCelenganPage> createState() => _AddCelenganPageState();
}

class _AddCelenganPageState extends State<AddCelenganPage> {
  String? selectedCurrency = "Indonesia Rupiah (Rp)";
  String plan = "Harian";
  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 00);
  bool notifOn = false;

  DateTime? targetDate;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<String> days = [
    "Minggu",
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
  ];
  List<bool> activeDays = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Tambah Celengan",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: namaController,
              decoration: inputDeco("Nama Tabungan"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: inputDeco("Target Tabungan"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: inputDeco(
                "Tanggal Target Menabung",
              ).copyWith(suffixIcon: const Icon(Icons.calendar_month)),
              onTap: pickDate,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: boxDeco(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  items:
                      [
                            "Indonesia Rupiah (Rp)",
                            "US Dollar (\$)",
                            "Ringgit (RM)",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => selectedCurrency = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Rencana Pengisian",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                planButton("Harian"),
                const SizedBox(width: 8),
                planButton("Mingguan"),
                const SizedBox(width: 8),
                planButton("Bulanan"),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: inputDeco("Nominal Pengisian"),
            ),

            const SizedBox(height: 25),

            const Text(
              "Notifikasi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Text(
                  selectedTime.format(context),
                  style: const TextStyle(fontSize: 26),
                ),
                IconButton(
                  onPressed: pickTime,
                  icon: const Icon(Icons.access_time),
                ),
                const Spacer(),
                Switch(
                  value: notifOn,
                  onChanged: (value) => setState(() => notifOn = value),
                ),
              ],
            ),

            if (notifOn) ...[
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: List.generate(days.length, (index) {
                  bool active = activeDays[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Reset semua hari menjadi false
                        for (int i = 0; i < activeDays.length; i++) {
                          activeDays[i] = false;
                        }
                        // Set hanya hari yang dipilih menjadi true
                        activeDays[index] = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: active ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: active ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration inputDeco(String text) {
    return InputDecoration(
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  BoxDecoration boxDeco() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.blue),
    );
  }

  Widget planButton(String title) {
    bool active = plan == title;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => plan = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.blue,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        targetDate = picked;
        dateController.text = DateFormat("dd MMMM yyyy").format(picked);
      });
    }
  }

  void pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }
}
