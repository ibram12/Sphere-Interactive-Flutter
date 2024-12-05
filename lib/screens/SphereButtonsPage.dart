import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'ImageDetailPage.dart';

class SphereButtonsPage extends StatefulWidget {
  @override
  _SphereButtonsPageState createState() => _SphereButtonsPageState();
}

class _SphereButtonsPageState extends State<SphereButtonsPage> {
  double thetaOffset = 0; // للتحكم في الدوران الأفقي
  double phiOffset = 0; // للتحكم في الدوران العمودي
  Timer? autoRotateTimer;
  double rotationSpeed = 0.02; // سرعة الدوران عند السحب
  int numPoints = 40; // عدد الصور

  @override
  void initState() {
    super.initState();
    // بدء الحركة التلقائية
    autoRotateTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        thetaOffset += 0.005; // حركة تلقائية أفقية بسيطة
      });
    });
  }

  @override
  void dispose() {
    autoRotateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double radius = 200; // نصف القطر للكرة
    List<Widget> buttons = [];

    // توزيع الصور على الكرة
    for (int i = 0; i < numPoints; i++) {
      double z = 1 - (2.0 * i) / (numPoints - 1); // z بين -1 و 1
      double theta = sqrt(numPoints * pi) * i; // زاوية ثيتا
      double x = radius * sqrt(1 - z * z) * cos(theta); // حساب x
      double y = radius * sqrt(1 - z * z) * sin(theta); // حساب y
      double depthZ = radius * z; // حساب العمق z

      // تطبيق الإزاحات بناءً على حركة المستخدم
      double rotatedX = x * cos(thetaOffset) - depthZ * sin(thetaOffset);
      double rotatedZ = x * sin(thetaOffset) + depthZ * cos(thetaOffset);
      double rotatedY = y * cos(phiOffset) - rotatedZ * sin(phiOffset);
      double finalZ = y * sin(phiOffset) + rotatedZ * cos(phiOffset);

      // حساب الحجم والشفافية بناءً على العمق
      double scale = (finalZ + radius) / (2 * radius); // قيمة بين 0.5 و 1.0
      double opacity = max(scale, 0.3); // الشفافية لا تقل عن 0.3

      buttons.add(Positioned(
        left: MediaQuery.of(context).size.width / 2 + rotatedX - 30,
        top: MediaQuery.of(context).size.height / 2 - rotatedY - 30,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purple, // لون الإطار
                    width: 3.0, // سمك الإطار
                  ),

                  image: DecorationImage(
                    image: AssetImage('images/${i%19}.jpg'), // استبدل بالصور
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black, Colors.purple], // الألوان المستخدمة في التدرج
            center: Alignment.bottomCenter, // تحديد مركز التدرج
            radius: 10.0, // نصف قطر التدرج
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) {
            // إيقاف الحركة التلقائية عند التفاعل
            autoRotateTimer?.cancel();
            autoRotateTimer = null;

            // تحديث الزوايا بناءً على حركة المستخدم
            setState(() {
              thetaOffset -= details.delta.dx * rotationSpeed; // الحركة الأفقي (يمين/يسار)
              phiOffset += details.delta.dy * rotationSpeed; // الحركة العمودي (أعلى/أسفل)

              // تقييد phi بين -pi/2 و pi/2
              phiOffset = phiOffset.clamp(-pi / 2, pi / 2);
            });
          },
          onPanEnd: (details) {
            // إعادة تشغيل الحركة التلقائية عند انتهاء التفاعل
            autoRotateTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
              setState(() {
                thetaOffset += 0.005; // استئناف الحركة الأفقية البسيطة
              });
            });
          },
          child: Stack(
            children: buttons,
          ),
        ),
      ),
    );
  }
}
