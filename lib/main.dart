import 'package:flutter/material.dart';

void main() {
  runApp(const SanadApp());
}

/// حالة التطبيق المحلية (In-Memory App State)
class AppState {
  static String? userName = 'عز الدين';
  static String? userPhone = '+213600000000';
  
  static final List<Med> meds = [
    Med(
      id: '1', 
      name: 'أوميبرازول', 
      dose: 'حبة واحدة', 
      time: '08:00 صباحاً',
      notes: 'قبل الأكل',
    ),
    Med(
      id: '2', 
      name: 'باراسيتامول', 
      dose: 'حبتان', 
      time: '02:00 ظهراً', 
      notes: 'عند اللزوم',
    ),
  ];
  
  static final List<Visit> visits = [];
}

/// نماذج البيانات
class Med {
  final String id;
  final String name;
  final String dose;
  final String time;
  final String? notes;
  String? voiceNotePath;
  bool enabled;

  Med({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    this.notes,
    this.voiceNotePath,
    this.enabled = true,
  });
}

class Visit {
  final String id;
  final String elderName;
  final String caregiverName;
  final DateTime startAt;
  DateTime? endAt;
  final String type;
  String status;
  String? notes;

  Visit({
    required this.id,
    required this.elderName,
    required this.caregiverName,
    required this.startAt,
    this.endAt,
    required this.type,
    this.status = 'scheduled',
    this.notes,
  });
}

/// التطبيق الرئيسي
class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سَنَد - SANAD',
      debugShowCheckedModeBanner: false,
      // دعم الاتجاه من اليمين إلى اليسار تلقائياً
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthLocalScreen(),
        '/preview': (_) => const PreviewScreen(),
        '/home': (_) => const ElderHomeScreen(),
        '/sos': (_) => const SosScreen(),
        '/dashboard': (_) => const CaregiverDashboard(),
        '/meds': (_) => const MedsScreen(),
        '/voice': (_) => const VoiceAssistantScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

/* ---------------------------
   1. شاشة الدخول المحلي
   --------------------------- */
class AuthLocalScreen extends StatefulWidget {
  const AuthLocalScreen({super.key});
  @override
  State<AuthLocalScreen> createState() => _AuthLocalScreenState();
}

class _AuthLocalScreenState extends State<AuthLocalScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: AppState.userName ?? '');
    _phone = TextEditingController(text: AppState.userPhone ?? '+213');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _localSignIn() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رجاءً أدخل الاسم ورقم الهاتف')),
      );
      return;
    }
    AppState.userName = name;
    AppState.userPhone = phone;
    Navigator.pushReplacementNamed(context, '/preview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول (سَنَد)')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
              const SizedBox(height: 12),
              const Text(
                'تطبيق سَنَد',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const Text('عَوْن وسَنَد لكبار السن والعائلة', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _localSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('دخول تجريبي', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/preview'),
                child: const Text('تخطي ومعاينة النماذج'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   2. شاشة المعاينة Preview
   --------------------------- */
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String title = 'الرئيسية للمسن';
  String description = 'واجهة بسيطة تحتوي على زر استغاثة أحمر بارز، أزرار اتصال سريع، تذكير الأدوية والمساعد الصوتي.';

  void update(String t, String d) => setState(() {
        title = t;
        description = d;
      });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(title: const Text('العرض التفاعلي — سَنَد')),
      body: wide
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal)),
                        const SizedBox(height: 12),
                        Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.phone_in_talk),
                          label: const Text('تجربة شاشة الطوارئ'),
                          onPressed: () => update('شاشة الطوارئ', 'تظهر عند تفعيل الاستغاثة، وتضم مراحل إشعار العائلة ومشاركة الموقع والاتصال بالمكلفين.'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.dashboard),
                          label: const Text('لوحة العائلة / المرافق'),
                          onPressed: () => update('لوحة العائلة', 'تتيح لمفوض العائلة متابعة حالة المسن ومراجعة تنبيهات الطوارئ.'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: PhonePreview(onScreenSelect: (s) {
                    if (s == 'home') update('الرئيسية للمسن', 'زر استغاثة أحمر للضغط المطوّل مع إمكانية الوصول السريع.');
                    if (s == 'sos') update('شاشة الطوارئ', 'عد تنازلي وتحديد موقع محاكى.');
                    if (s == 'dashboard') update('لوحة العائلة', 'سجل الاستغاثات والزيارات.');
                    if (s == 'meds') update('جدول الأدوية', 'قائمة الأدوية والمواعيد.');
                    if (s == 'voice') update('المساعد الصوتي', 'مساعد صوتي محلي (مريم) للتفاعل والرد على الأوامر.');
                  }),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(description, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/home'),
                      child: const Text('الانتقال للواجهة الرئيسية'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/* ---------------------------
   3. إطار محاكاة الهاتف PhonePreview
   --------------------------- */
class PhonePreview extends StatefulWidget {
  final void Function(String) onScreenSelect;
  const PhonePreview({super.key, required this.onScreenSelect});

  @override
  State<PhonePreview> createState() => _PhonePreviewState();
}

class _PhonePreviewState extends State<PhonePreview> {
  String current = 'home';

  @override
  Widget build(BuildContext context) {
    Widget screen;
    switch (current) {
      case 'sos':
        screen = const SosScreen();
        break;
      case 'dashboard':
        screen = const CaregiverDashboard();
        break;
      case 'meds':
        screen = const MedsScreen();
        break;
      case 'voice':
        screen = const VoiceAssistantScreen();
        break;
      case 'home':
      default:
        screen = const ElderHomeScreen();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: screen),
                  Container(
                    color: Colors.white,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() => current = 'home');
                            widget.onScreenSelect('home');
                          },
                          icon: Icon(Icons.home, color: current == 'home' ? Colors.teal : Colors.grey),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => current = 'sos');
                            widget.onScreenSelect('sos');
                          },
                          icon: Icon(Icons.warning_amber_rounded, color: current == 'sos' ? Colors.red : Colors.grey),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => current = 'dashboard');
                            widget.onScreenSelect('dashboard');
                          },
                          icon: Icon(Icons.people, color: current == 'dashboard' ? Colors.teal : Colors.grey),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => current = 'meds');
                            widget.onScreenSelect('meds');
                          },
                          icon: Icon(Icons.medical_services, color: current == 'meds' ? Colors.teal : Colors.grey),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => current = 'voice');
                            widget.onScreenSelect('voice');
                          },
                          icon: Icon(Icons.mic, color: current == 'voice' ? Colors.teal : Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   4. الرئيسية للمسن ElderHomeScreen
   --------------------------- */
class ElderHomeScreen extends StatefulWidget {
  const ElderHomeScreen({super.key});
  @override
  State<ElderHomeScreen> createState() => _ElderHomeScreenState();
}

class _ElderHomeScreenState extends State<ElderHomeScreen> {
  bool _isCounting = false;
  int _count = 5;
  double _fontScale = 1.0;

  void _toggleFontScale() {
    setState(() {
      _fontScale = _fontScale >= 1.5 ? 1.0 : _fontScale + 0.25;
    });
  }

  void _startCountdown() {
    _isCounting = true;
    _count = 5;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (!_isCounting) return false;

      setState(() => _count -= 1);
      if (_count <= 0) {
        setState(() => _isCounting = false);
        Navigator.pushNamed(context, '/sos');
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontSize: 20 * _fontScale, fontWeight: FontWeight.bold);
    final bodyStyle = TextStyle(fontSize: 15 * _fontScale);

    return Scaffold(
      appBar: AppBar(
        title: Text('سَنَد', style: TextStyle(fontSize: 22 * _fontScale, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.text_fields), onPressed: _toggleFontScale, tooltip: 'تغيير حجم الخط'),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('مرحباً بك،\n${AppState.userName ?? 'المستخدم'}', style: titleStyle),
                ),
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('اضغط مطوّلاً على زر الاستغاثة لإرسال طلب طوارئ', style: bodyStyle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    _startCountdown();
                  },
                  onLongPressEnd: (_) {
                    if (_isCounting) {
                      setState(() {
                        _isCounting = false;
                        _count = 5;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إلغاء الاستغاثة')),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 95,
                    backgroundColor: Colors.red.shade600,
                    child: _isCounting
                        ? Text('$_count', style: const TextStyle(fontSize: 54, color: Colors.white, fontWeight: FontWeight.bold))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.white),
                              SizedBox(height: 4),
                              Text('نداء استغاثة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.call,
                    label: 'اتصال بالعائلة',
                    color: Colors.teal.shade700,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('اتصال سريع'),
                          content: Text('محاكاة الاتصال بـ: ${AppState.userPhone}'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.medical_services,
                    label: 'الأدوية',
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.pushNamed(context, '/meds'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.mic,
                    label: 'المساعد الصوتي',
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.pushNamed(context, '/voice'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.handshake,
                    label: 'طلب مرافق',
                    color: Colors.teal.shade700,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('طلب مرافق'),
                          content: const Text('تم إرسال طلب مرافق يومي لمساعدة المسن.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required