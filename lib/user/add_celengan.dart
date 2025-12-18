import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/models/celengan.dart';
import 'web_camera_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tubes_monas/models/constants.dart';

class AddCelenganPage extends StatefulWidget {
  final Celengan? celengan;

  const AddCelenganPage({super.key, this.celengan});

  @override
  State<AddCelenganPage> createState() => _AddCelenganPageState();
}

class _AddCelenganPageState extends State<AddCelenganPage> {
  final List<String> currencyOptions = [
    "Indonesia Rupiah (Rp)",
    "US Dollar (\$)",
    "Ringgit (RM)",
  ];
  String? selectedCurrency = "Indonesia Rupiah (Rp)";
  String plan = "Harian";
  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 00);
  bool notifOn = false;

  DateTime? targetDate;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? existingImageUrl;
  String? imagePath;
  Uint8List? webImageBytes;
  XFile? pickedXFile;

  bool _isLoading = false;

  String? _nominalHelperText;
  Color _nominalHelperColor = Colors.grey;

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

  bool get _isEditing => widget.celengan != null;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();

    targetController.addListener(() {
      _calculateAutoNominal();
    });
    nominalController.addListener(() {
      _validateNominal();
    });

    if (widget.celengan != null) {
      _prefillForm(widget.celengan!);
    }
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      print("Error setting location: $e");
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _scheduleNotification(int id, String title, String body) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'CELENGANCHANNEL1',
      'Ingat Nabung',
      channelDescription: 'Channel notifikasi celengan high priority',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    try {
      if (plan == "Harian") {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (plan == "Mingguan") {
        int selectedDayIndex =
        activeDays.indexWhere((element) => element == true);

        int targetWeekday;
        if (selectedDayIndex == 0)
          targetWeekday = 7;
        else
          targetWeekday = selectedDayIndex;

        while (scheduledDate.weekday != targetWeekday) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      print("Notifikasi berhasil dijadwalkan untuk: $scheduledDate");
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }


  void _calculateAutoNominal() {
    if (targetDate == null || targetController.text.isEmpty) return;

    try {
      double target = double.parse(
          targetController.text.replaceAll(RegExp(r'[^0-9]'), ''));

      // Batasi target maksimal 1 miliar
      if (target > 1000000000) {
        target = 1000000000;
        targetController.text = target.toStringAsFixed(0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Melebihi batas maksimal'),
            backgroundColor: Colors.orange));
      }
      final now = DateTime.now();
      int daysRemaining = targetDate!.difference(now).inDays;

      if (daysRemaining <= 0) daysRemaining = 1;

      double calculatedNominal = 0;

      if (plan == "Harian") {
        calculatedNominal = target / daysRemaining;
      } else if (plan == "Mingguan") {
        int weeks = (daysRemaining / 7).floor();
        if (weeks < 1) weeks = 1;
        calculatedNominal = target / weeks;
      } else if (plan == "Bulanan") {
        int months = (daysRemaining / 30).floor();
        if (months < 1) months = 1;
        calculatedNominal = target / months;
      }

      double roundingMultiple = 1000;
      calculatedNominal =
          (calculatedNominal / roundingMultiple).ceil() * roundingMultiple;

      setState(() {
        nominalController.text = calculatedNominal.toStringAsFixed(0);
        _nominalHelperText = null;
      });
    } catch (e) {
      print("Error calculating nominal: $e");
    }
  }

  void _validateNominal() {
    if (targetDate == null ||
        targetController.text.isEmpty ||
        nominalController.text.isEmpty) {
      setState(() => _nominalHelperText = null);
      return;
    }

    try {
      double target = double.parse(targetController.text);
      double inputNominal = double.parse(nominalController.text);

      final now = DateTime.now();
      int daysRemaining = targetDate!.difference(now).inDays;
      if (daysRemaining <= 0) daysRemaining = 1;

      double requiredNominal = 0;
      if (plan == "Harian") {
        requiredNominal = target / daysRemaining;
      } else if (plan == "Mingguan") {
        int weeks = (daysRemaining / 7).floor();
        if (weeks < 1) weeks = 1;
        requiredNominal = target / weeks;
      } else if (plan == "Bulanan") {
        int months = (daysRemaining / 30).floor();
        if (months < 1) months = 1;
        requiredNominal = target / months;
      }

      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      String formattedRequired = formatter.format(requiredNominal);

      setState(() {
        if (inputNominal < (requiredNominal * 0.95)) {
          _nominalHelperText =
          "Nominal kurang! Disarankan minimal: $formattedRequired";
          _nominalHelperColor = Colors.red;
        } else if (inputNominal > (requiredNominal * 1.05)) {
          _nominalHelperText =
          "Nominal berlebih! Disarankan sekitar: $formattedRequired agar sesuai tanggal target.";
          _nominalHelperColor = Colors.orange;
        } else {
          _nominalHelperText = "Nominal pas. Target akan tercapai tepat waktu.";
          _nominalHelperColor = Colors.green;
        }
      });
    } catch (e) {
      setState(() => _nominalHelperText = null);
    }
  }

  bool _isPlanEnabled(String planType) {
    if (targetDate == null) return true;
    final now = DateTime.now();
    final difference = targetDate!.difference(now).inDays;
    if (planType == "Mingguan") return difference >= 7;
    if (planType == "Bulanan") return difference >= 30;
    return true;
  }

  String _getPlanWarningMessage() {
    final now = DateTime.now();
    final difference = targetDate!.difference(now).inDays;
    if (difference < 7)
      return "*Target < 1 minggu. Hanya opsi Harian tersedia.";
    if (difference < 30)
      return "*Target < 1 bulan. Opsi Bulanan tidak tersedia.";
    return "";
  }

  @override
  void dispose() {
    namaController.dispose();
    targetController.dispose();
    nominalController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = (kIsWeb && webImageBytes != null) ||
        (!kIsWeb && imagePath != null) ||
        (existingImageUrl != null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? "Edit Celengan" : "Tambah Celengan",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceOption,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: hasImage
                          ? null
                          : Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: hasImage
                        ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _buildImageWidget(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black12, Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imagePath = null;
                                webImageBytes = null;
                                pickedXFile = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo,
                              size: 32, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tambahkan Foto Impianmu',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildInputLabel("Nama Tabungan"),
              _buildModernField(
                controller: namaController,
                hint: "Contoh: Beli Laptop Baru",
                icon: Icons.title,
              ),
              const SizedBox(height: 20),

              _buildInputLabel("Target Tabungan"),
              _buildModernField(
                controller: targetController,
                hint: "0",
                icon: Icons.monetization_on_outlined,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildInputLabel("Tanggal Target"),
              _buildModernField(
                controller: dateController,
                hint: "Pilih tanggal",
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: pickDate,
              ),
              const SizedBox(height: 20),

              _buildInputLabel("Mata Uang"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCurrency,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                    items: [
                      "Indonesia Rupiah (Rp)",
                      "US Dollar (\$)",
                      "Ringgit (RM)"
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCurrency = value),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Divider(),
              const SizedBox(height: 20),

              const Text("Rencana Pengisian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Seberapa sering kamu ingin menabung?",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),

              Row(
                children: [
                  planButton("Harian"),
                  const SizedBox(width: 12),
                  planButton("Mingguan"),
                  const SizedBox(width: 12),
                  planButton("Bulanan")
                ],
              ),

              if (targetDate != null && _getPlanWarningMessage().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getPlanWarningMessage(),
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              _buildInputLabel("Nominal per $plan"),
              _buildModernField(
                controller: nominalController,
                hint: "0",
                icon: Icons.input,
                inputType: TextInputType.number,
              ),

              if (_nominalHelperText != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _nominalHelperColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _nominalHelperColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _nominalHelperColor == Colors.red
                            ? Icons.error_outline
                            : _nominalHelperColor == Colors.orange
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        size: 20,
                        color: _nominalHelperColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _nominalHelperText!,
                          style: TextStyle(
                              color: _nominalHelperColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ingatkan Saya",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(selectedTime.format(context),
                          style: const TextStyle(fontSize: 14, color: Colors.blue)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: pickTime,
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        tooltip: "Ubah Jam",
                      ),
                      Switch(
                        value: notifOn,
                        activeColor: Colors.blue,
                        onChanged: (value) async {
                          setState(() => notifOn = value);
                          if (value == true) {
                            await _requestNotificationPermissions();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              if (notifOn && plan == "Mingguan") ...[
                const SizedBox(height: 16),
                const Text("Pilih Hari:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: List.generate(days.length, (index) {
                    bool active = activeDays[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          for (int i = 0; i < activeDays.length; i++)
                            activeDays[i] = false;
                          activeDays[index] = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: active ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? Colors.blue : Colors.grey.shade300),
                          boxShadow: active
                              ? [
                            BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ]
                              : null,
                        ),
                        child: Text(days[index],
                            style: TextStyle(
                                color: active ? Colors.white : Colors.grey[700],
                                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCelengan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(_isEditing ? "Perbarui" : "Simpan",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget planButton(String title) {
    bool active = plan == title;
    bool enabled = _isPlanEnabled(title);

    return Expanded(
      child: GestureDetector(
        onTap: enabled
            ? () {
          setState(() {
            plan = title;
            if (plan != "Mingguan") {
              for (int i = 0; i < activeDays.length; i++)
                activeDays[i] = false;
            }
            _calculateAutoNominal();
          });
        }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: !enabled
                ? Colors.grey.shade100
                : (active ? Colors.blue : Colors.white),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: !enabled
                    ? Colors.grey.shade300
                    : (active ? Colors.blue : Colors.grey.shade300)),
            boxShadow: active && enabled
                ? [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: !enabled
                    ? Colors.grey
                    : (active ? Colors.white : Colors.grey[700]),
                fontSize: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pickDate() async {
    final DateTime today = DateTime.now();
    // H dan H+1 di-disable dengan cara menjadikan batas minimum pilihan = H+2.
    final DateTime minSelectableDate =
        DateTime(today.year, today.month, today.day).add(const Duration(days: 2));

    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate != null && targetDate!.isAfter(minSelectableDate)
          ? targetDate!
          : minSelectableDate,
      firstDate: minSelectableDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        targetDate = picked;
        dateController.text = DateFormat("dd MMMM yyyy").format(picked);

        final difference = targetDate!.difference(DateTime.now()).inDays;
        if (difference < 7 && (plan == "Mingguan" || plan == "Bulanan"))
          plan = "Harian";
        else if (difference < 30 && plan == "Bulanan") plan = "Mingguan";

        _calculateAutoNominal();
      });
    }
  }

  void pickTime() async {
    final time =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (time != null) setState(() => selectedTime = time);
  }

  Widget _iconButtonOption(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showImageSourceOption() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                const Text("Pilih Sumber Foto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _iconButtonOption(
                        icon: Icons.camera_alt,
                        label: "Kamera",
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        }),
                    _iconButtonOption(
                        icon: Icons.photo_library,
                        label: "Galeri",
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb && source == ImageSource.camera) {
        final XFile? result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const WebCameraPage()));
        if (result != null) {
          final bytes = await result.readAsBytes();
          setState(() {
            pickedXFile = result;
            webImageBytes = bytes;
            imagePath = result.path;
            existingImageUrl = null;
          });
        }
      } else {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          if (kIsWeb) {
            final bytes = await pickedFile.readAsBytes();
            setState(() {
              pickedXFile = pickedFile;
              webImageBytes = bytes;
              imagePath = pickedFile.path;
              existingImageUrl = null;
            });
          } else {
            setState(() {
              pickedXFile = pickedFile;
              imagePath = pickedFile.path;
              webImageBytes = null;
              existingImageUrl = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildImageWidget() {
    if (kIsWeb && webImageBytes != null) {
      return Image.memory(
        webImageBytes!,
        width: double.infinity,
        height: 170,
        fit: BoxFit.cover,
      );
    } else if (imagePath != null) {
      return Image.file(
        File(imagePath!),
        width: double.infinity,
        height: 170,
        fit: BoxFit.cover,
      );
    } else if (existingImageUrl != null) {
      final url = existingImageUrl!;
      return Image.network(
        url,
        width: double.infinity,
        height: 170,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 170,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
    return const SizedBox();
  }


  Future<void> _saveCelengan() async {
    if (namaController.text.isEmpty ||
        targetController.text.isEmpty ||
        nominalController.text.isEmpty ||
        targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.red));
      return;
    }
    // Validasi maksimum target 1 miliar di sisi Flutter
    try {
      final rawTarget =
          double.parse(targetController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (rawTarget > 1000000000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Melebihi batas maksimal'),
            backgroundColor: Colors.red));
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Target tabungan tidak valid'),
          backgroundColor: Colors.red));
      return;
    }
    if (notifOn && plan == "Mingguan" && !activeDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Silakan pilih hari pengingat'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final baseUrl = '$apiBase/celengan';
      final url = _isEditing && widget.celengan?.id != null? Uri.parse('$baseUrl/${widget.celengan!.id}') : Uri.parse(baseUrl);

      var request = http.MultipartRequest('POST', url);
      if (_isEditing) {
        request.fields['_method'] = 'PUT';
      }
      request.headers.addAll(
          {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      request.fields['nama'] = namaController.text;
      request.fields['target'] = targetController.text;
      request.fields['nominal_pengisian'] = nominalController.text;
      request.fields['target_date'] = targetDate!.toIso8601String();
      request.fields['currency'] = selectedCurrency ?? 'Rp';
      request.fields['plan'] = plan;
      request.fields['notif_on'] = notifOn ? '1' : '0';
      request.fields['status'] = 'active';

      if (notifOn) {
        request.fields['notif_time'] =
        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        final selectedDayIndex = activeDays.indexWhere((day) => day == true);
        if (selectedDayIndex != -1)
          request.fields['notif_day'] = days[selectedDayIndex];
      }

      if (kIsWeb && webImageBytes != null && pickedXFile != null) {
        var multipartFile = http.MultipartFile.fromBytes(
          'image',
          webImageBytes!,
          filename: pickedXFile!.name.isEmpty ? 'upload.jpg' : pickedXFile!.name,
        );
        request.files.add(multipartFile);
      } else if (!kIsWeb && imagePath != null) {
        var imageFile = File(imagePath!);
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      var res = await http.Response.fromStream(await request.send());

      if (res.statusCode == 200 || res.statusCode == 201) {
        var responseData = jsonDecode(res.body);

        if (notifOn) {

          int notificationId;

          if (responseData['data'] != null && responseData['data']['id'] != null) {
            notificationId = int.parse(responseData['data']['id'].toString());
          } else if (responseData['id'] != null) {
            notificationId = int.parse(responseData['id'].toString());
          } else {
            notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          }

          await _scheduleNotification(notificationId, "Waktunya Menabung! 💰",
              "Yuk isi celengan '${namaController.text}' agar target tercapai");
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_isEditing ? 'Celengan berhasil diperbarui!' : 'Celengan berhasil disimpan!'),
              backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal');
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prefillForm(Celengan celengan) {
    namaController.text = celengan.nama;
    targetController.text = celengan.target.toStringAsFixed(0);
    nominalController.text = celengan.nominalPengisian.toStringAsFixed(0);
    selectedCurrency = currencyOptions.contains(celengan.currency)
        ? celengan.currency
        : currencyOptions.first;
    const allowedPlans = ['Harian', 'Mingguan', 'Bulanan'];
    plan = allowedPlans.contains(celengan.plan) ? celengan.plan : 'Harian';
    notifOn = celengan.notifOn;
    existingImageUrl = celengan.imagePath;

    if (celengan.targetDate != null) {
      targetDate = celengan.targetDate;
      dateController.text = DateFormat("dd MMMM yyyy").format(celengan.targetDate!);
    }

    if (celengan.notifTime != null) {
      final parts = celengan.notifTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? selectedTime.hour;
        final minute = int.tryParse(parts[1]) ?? selectedTime.minute;
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    if (celengan.notifDay != null) {
      final index = days.indexOf(celengan.notifDay!);
      if (index != -1) {
        for (int i = 0; i < activeDays.length; i++) {
          activeDays[i] = i == index;
        }
      } else {
        for (int i = 0; i < activeDays.length; i++) {
          activeDays[i] = false;
        }
      }
    } else {
      for (int i = 0; i < activeDays.length; i++) {
        activeDays[i] = false;
      }
    }
  }

}