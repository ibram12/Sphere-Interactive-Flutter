import 'dart:math';
import 'package:flutter/material.dart';
import 'ImageDetailPage.dart';

class SphereInteractivePage extends StatefulWidget {
  @override
  _SphereInteractivePageState createState() => _SphereInteractivePageState();
}

class _SphereInteractivePageState extends State<SphereInteractivePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double thetaOffset = 0; // التحكم بالدوران الأفقي
  double phiOffset = 0; // التحكم بالدوران العمودي
  double rotationSpeed = 0.02; // سرعة الدوران عند السحب
  int numPoints = 40; // عدد العناصر
  double radius = 150; // نصف قطر الكرة - تقليل الحجم

  @override
  void initState() {
    super.initState();

    // إعداد AnimationController لتحريك الكرة تلقائيًا
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..repeat(); // يجعل الحركة تستمر بدون توقف

    _controller.addListener(() {
      setState(() {
        thetaOffset += 0.005; // حركة تلقائية بطيئة
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حساب حجم الشاشة للتمركز
    double centerX = MediaQuery.of(context).size.width / 2;
    double centerY = MediaQuery.of(context).size.height / 4; // وضع الشكل في النصف العلوي

    // بناء العناصر على شكل كرة
    List<Widget> buttons = [];
    for (int i = 0; i < numPoints; i++) {
      double z = 1 - (2.0 * i) / (numPoints - 1); // z بين -1 و 1
      double theta = sqrt(numPoints * pi) * i; // الزاوية
      double x = radius * sqrt(1 - z * z) * cos(theta); // موقع x
      double y = radius * sqrt(1 - z * z) * sin(theta); // موقع y
      double depthZ = radius * z; // العمق z

      // تطبيق الإزاحات بناءً على حركات المستخدم
      double rotatedX = x * cos(thetaOffset) - depthZ * sin(thetaOffset);
      double rotatedZ = x * sin(thetaOffset) + depthZ * cos(thetaOffset);
      double rotatedY = y * cos(phiOffset) - rotatedZ * sin(phiOffset);
      double finalZ = y * sin(phiOffset) + rotatedZ * cos(phiOffset);

      // حساب الحجم والشفافية بناءً على العمق
      double scale = (finalZ + radius) / (2 * radius); // الحجم بين 0.5 و 1.0
      double opacity = max(scale, 0.3); // الشفافية لا تقل عن 0.3

      buttons.add(Positioned(
        left: centerX + rotatedX - 30, // وضع العنصر في موضعه
        top: centerY - rotatedY - 30,
        child: Transform.scale(
          scale: scale, // التحكم بالحجم
          child: Opacity(
            opacity: opacity, // التحكم بالشفافية
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageDetailPage(
                      imagePath: 'images/${i % 19}.jpg', // تمرير مسار الصورة
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // يجعل الإطار دائريًا
                  border: Border.all(
                    color: Colors.purple, // لون الإطار
                    width: 3.0, // سمك الإطار
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('images/${i % 19}.jpg'),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 80,0,0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) {
            // إيقاف الحركة التلقائية عند التفاعل
            _controller.stop();

            // تحديث الزوايا بناءً على السحب مع عكس الاتجاه
            setState(() {
              thetaOffset += details.delta.dx * rotationSpeed; // الحركة أفقية
              phiOffset += details.delta.dy * rotationSpeed; // الحركة عمودية
            });
          },

          onPanEnd: (details) {
            // إعادة تشغيل الحركة التلقائية بعد التفاعل
            _controller.repeat();
          },
          child: Stack(
            children: buttons,
          ),
        ),
      ),
    );
  }
}
