import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const CharacterStudioApp());
}

class CharacterStudioApp extends StatelessWidget {
  const CharacterStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'استوديو شخصيتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const StudioHomePage(),
    );
  }
}

class StudioHomePage extends StatefulWidget {
  const StudioHomePage({super.key});

  @override
  State<StudioHomePage> createState() => _StudioHomePageState();
}

class _StudioHomePageState extends State<StudioHomePage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String currentHair = 'قصير';
  String currentMouth = 'ابتسامة';
  String currentPose = 'وقوف';
  Color jacketColor = Colors.red;

  final List<String> hairOptions = ['قصير', 'طويل', 'سبايكي', 'صلع'];
  final List<String> mouthOptions = ['ابتسامة', 'حزن', 'غضب', 'دهشة', 'خط مستقيم'];
  final List<String> poseOptions = ['وقوف', 'جلوس', 'تلويح', 'استعداد'];
  final List<Color> colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.black,
  ];

  bool _isExporting = false;

  Future<void> _exportPng(BuildContext context) async {
    setState(() {
      _isExporting = true;
    });

    try {
      Uint8Image? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/character_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم الحفظ بنجاح في: $imagePath')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استوديو شخصيتي - لصانعي المحتوى'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'تصدير PNG شفاف',
            onPressed: _isExporting ? null : () => _exportPng(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Center(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    color: Colors.transparent,
                    width: 250,
                    height: 350,
                    child: CustomPaint(
                      painter: CharacterPainter(
                        hairStyle: currentHair,
                        mouthStyle: currentMouth,
                        poseStyle: currentPose,
                        jacketColor: jacketColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF181818),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                children: [
                  const Text('تخصيص الأجزاء والوضعيات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildDropdownRow('الشعر:', currentHair, hairOptions, (val) {
                    setState(() => currentHair = val!);
                  }),
                  _buildDropdownRow('الفم / التعبير:', currentMouth, mouthOptions, (val) {
                    setState(() => currentMouth = val!);
                  }),
                  _buildDropdownRow('الوضعية:', currentPose, poseOptions, (val) {
                    setState(() => currentPose = val!);
                  }),
                  const SizedBox(height: 8),
                  const Text('لون الجاكيت:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorOptions.length,
                      itemBuilder: (context, index) {
                        final color = colorOptions[index];
                        return GestureDetector(
                          onTap: () => setState(() => jacketColor = color),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: jacketColor == color ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String currentVal, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          DropdownButton<String>(
            value: currentVal,
            dropdownColor: const Color(0xFF2C2C2C),
            items: options.map((String opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(opt),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class CharacterPainter extends CustomPainter {
  final String hairStyle;
  final String mouthStyle;
  final String poseStyle;
  final Color jacketColor;

  CharacterPainter({
    required this.hairStyle,
    required this.mouthStyle,
    required this.poseStyle,
    required this.jacketColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // الأرجل
    paint.color = Colors.black;
    if (poseStyle == 'جلوس') {
      canvas.drawRect(Rect.fromLTWH(cx - 35, cy + 50, 25, 40), paint);
      canvas.drawRect(Rect.fromLTWH(cx + 10, cy + 50, 25, 40), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(cx - 25, cy + 40, 20, 80), paint);
      canvas.drawRect(Rect.fromLTWH(cx + 5, cy + 40, 20, 80), paint);
    }

    // القميص الأسود والجذع
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(cx - 35, cy - 20, 70, 70), paint);

    // الجاكيت
    paint.color = jacketColor;
    canvas.drawRect(Rect.fromLTWH(cx - 40, cy - 25, 80, 75), paint);

    // الذراعان
    paint.color = jacketColor;
    if (poseStyle == 'تلويح') {
      canvas.drawRect(Rect.fromLTWH(cx + 35, cy - 45, 45, 18), paint);
      canvas.drawRect(Rect.fromLTWH(cx - 75, cy - 20, 40, 18), paint);
    } else if (poseStyle == 'استعداد') {
      canvas.drawRect(Rect.fromLTWH(cx - 65, cy - 10, 30, 18), paint);
      canvas.drawRect(Rect.fromLTWH(cx + 35, cy - 10, 30, 18), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(cx - 55, cy - 20, 18, 60), paint);
      canvas.drawRect(Rect.fromLTWH(cx + 37, cy - 20, 18, 60), paint);
    }

    // الرأس
    paint.color = const Color(0xFFFFD1A9);
    canvas.drawCircle(Offset(cx, cy - 65), 32, paint);

    // الشعر
    paint.color = Colors.brown;
    if (hairStyle == 'قصير') {
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy - 75), radius: 32), 3.14, 3.14, true, paint);
    } else if (hairStyle == 'طويل') {
      canvas.drawRect(Rect.fromLTWH(cx - 34, cy - 85, 68, 50), paint);
    } else if (hairStyle == 'سبايكي') {
      Path spikePath = Path();
      spikePath.moveTo(cx - 30, cy - 65);
      spikePath.lineTo(cx, cy - 105);
      spikePath.lineTo(cx + 30, cy - 65);
      spikePath.close();
      canvas.drawPath(spikePath, paint);
    }

    // الفم
    Paint mouthPaint = Paint()
      ..color = Colors.black89
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (mouthStyle == 'ابتسامة') {
      Path smilePath = Path();
      smilePath.moveTo(cx - 10, cy - 53);
      smilePath.quadraticBezierTo(cx, cy - 40, cx + 10, cy - 53);
      canvas.drawPath(smilePath, mouthPaint);
    } else if (mouthStyle == 'حزن') {
      Path sadPath = Path();
      sadPath.moveTo(cx - 10, cy - 45);
      sadPath.quadraticBezierTo(cx, cy - 55, cx + 10, cy - 45);
      canvas.drawPath(sadPath, mouthPaint);
    } else if (mouthStyle == 'غضب') {
      canvas.drawLine(Offset(cx - 8, cy - 50), Offset(cx + 8, cy - 50), mouthPaint);
    } else if (mouthStyle == 'دهشة') {
      paint.color = Colors.black89;
      canvas.drawCircle(Offset(cx, cy - 48), 6, paint);
    } else {
      canvas.drawLine(Offset(cx - 8, cy - 48), Offset(cx + 8, cy - 48), mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CharacterPainter oldDelegate) {
    return oldDelegate.hairStyle != hairStyle ||
        oldDelegate.mouthStyle != mouthStyle ||
        oldDelegate.poseStyle != poseStyle ||
        oldDelegate.jacketColor != jacketColor;
  }
}