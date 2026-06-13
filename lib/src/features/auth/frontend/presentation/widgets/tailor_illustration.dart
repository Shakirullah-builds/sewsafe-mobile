// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class TailorIllustration extends StatelessWidget {
//   final double? size;
//   const TailorIllustration({super.key, this.size});

//   @override
//   Widget build(BuildContext context) {
//     final illustrationSize = size ?? 240.r;
//     return SizedBox(
//       width: illustrationSize,
//       height: illustrationSize,
//       child: CustomPaint(
//         painter: TailorIllustrationPainter(),
//       ),
//     );
//   }
// }

// class TailorIllustrationPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = math.min(size.width, size.height) * 0.45;

//     // 1. Draw soft circular pastel pink background
//     final bgPaint = Paint()
//       ..color = const Color(0xFFFDF2F2) // Premium soft pink/red pastel background
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, radius, bgPaint);

//     // 2. Draw dress hangers & dresses on the sides
//     final leftX = center.dx - radius * 0.42;
//     final rightX = center.dx + radius * 0.42;
//     final dressY = center.dy + radius * 0.08;

//     // Draw Left Dress (Soft Pink)
//     _drawDress(
//       canvas,
//       position: Offset(leftX, dressY),
//       height: radius * 0.72,
//       width: radius * 0.42,
//       color: const Color(0xFFEC4899), // Elegant deep pink/rose
//       hangerColor: const Color(0xFF475569),
//     );

//     // Draw Right Dress (Orange-Yellow)
//     _drawDress(
//       canvas,
//       position: Offset(rightX, dressY),
//       height: radius * 0.72,
//       width: radius * 0.42,
//       color: const Color(0xFFF59E0B), // Golden warm yellow-orange
//       hangerColor: const Color(0xFF475569),
//     );

//     // 3. Draw Center Tailor Figure (Teal dress, head, arms, hair)
//     _drawTailor(
//       canvas,
//       position: Offset(center.dx, center.dy + radius * 0.08),
//       height: radius * 0.88,
//       width: radius * 0.48,
//       bodyColor: const Color(0xFF06B6D4), // Modern Cyan/Teal
//       skinColor: const Color(0xFFFDBA74), // Warm soft skin tone
//       hairColor: const Color(0xFF1E293B), // Dark slate hair
//     );
//   }

//   void _drawDress(
//     Canvas canvas, {
//     required Offset position,
//     required double height,
//     required double width,
//     required Color color,
//     required Color hangerColor,
//   }) {
//     final hangerPaint = Paint()
//       ..color = hangerColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     // Hanger hook (arc)
//     final hookCenter = Offset(position.dx, position.dy - height * 0.45);
//     final hookRadius = width * 0.18;
//     canvas.drawArc(
//       Rect.fromCircle(center: hookCenter, radius: hookRadius),
//       -math.pi,
//       math.pi,
//       false,
//       hangerPaint,
//     );

//     // Hanger triangle/shoulders
//     final hangerPath = Path()
//       ..moveTo(position.dx, position.dy - height * 0.45 + hookRadius)
//       ..lineTo(position.dx - width * 0.45, position.dy - height * 0.35)
//       ..lineTo(position.dx + width * 0.45, position.dy - height * 0.35)
//       ..close();
//     canvas.drawPath(hangerPath, hangerPaint);

//     // Dress gown shape
//     final dressPaint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final dressPath = Path()
//       ..moveTo(position.dx - width * 0.22, position.dy - height * 0.35) // Left neckline
//       ..lineTo(position.dx - width * 0.38, position.dy - height * 0.22) // Left armhole
//       ..lineTo(position.dx - width * 0.18, position.dy - height * 0.02) // Left waist
//       ..lineTo(position.dx - width * 0.48, position.dy + height * 0.45) // Left hemline
//       ..lineTo(position.dx + width * 0.48, position.dy + height * 0.45) // Right hemline
//       ..lineTo(position.dx + width * 0.18, position.dy - height * 0.02) // Right waist
//       ..lineTo(position.dx + width * 0.38, position.dy - height * 0.22) // Right armhole
//       ..lineTo(position.dx + width * 0.22, position.dy - height * 0.35) // Right neckline
//       ..close();
//     canvas.drawPath(dressPath, dressPaint);
//   }

//   void _drawTailor(
//     Canvas canvas, {
//     required Offset position,
//     required double height,
//     required double width,
//     required Color bodyColor,
//     required Color skinColor,
//     required Color hairColor,
//   }) {
//     final bodyPaint = Paint()..color = bodyColor..style = PaintingStyle.fill;
//     final skinPaint = Paint()..color = skinColor..style = PaintingStyle.fill;
//     final hairPaint = Paint()..color = hairColor..style = PaintingStyle.fill;

//     // Head
//     final headRadius = width * 0.25;
//     final headCenter = Offset(position.dx, position.dy - height * 0.45);
//     canvas.drawCircle(headCenter, headRadius, skinPaint);

//     // Hair
//     final hairPath = Path()
//       ..moveTo(headCenter.dx - headRadius, headCenter.dy - headRadius * 0.1)
//       ..arcToPoint(
//         Offset(headCenter.dx + headRadius, headCenter.dy - headRadius * 0.1),
//         radius: Radius.circular(headRadius),
//         clockwise: true,
//       )
//       ..lineTo(headCenter.dx + headRadius * 1.1, headCenter.dy + headRadius * 0.4)
//       ..lineTo(headCenter.dx + headRadius * 0.8, headCenter.dy)
//       ..lineTo(headCenter.dx - headRadius * 0.8, headCenter.dy)
//       ..lineTo(headCenter.dx - headRadius * 1.1, headCenter.dy + headRadius * 0.4)
//       ..close();
//     canvas.drawPath(hairPath, hairPaint);

//     // Dress gown/body
//     final dressPath = Path()
//       ..moveTo(position.dx - width * 0.18, position.dy - height * 0.3) // Left neck
//       ..lineTo(position.dx - width * 0.38, position.dy - height * 0.18) // Left shoulder
//       ..lineTo(position.dx - width * 0.2, position.dy + height * 0.05) // Left waist
//       ..lineTo(position.dx - width * 0.48, position.dy + height * 0.45) // Left hem
//       ..lineTo(position.dx + width * 0.48, position.dy + height * 0.45) // Right hem
//       ..lineTo(position.dx + width * 0.2, position.dy + height * 0.05) // Right waist
//       ..lineTo(position.dx + width * 0.38, position.dy - height * 0.18) // Right shoulder
//       ..lineTo(position.dx + width * 0.18, position.dy - height * 0.3) // Right neck
//       ..close();
//     canvas.drawPath(dressPath, bodyPaint);

//     // Hands/Arms displaying the dresses
//     final armPaint = Paint()
//       ..color = skinColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = width * 0.08
//       ..strokeCap = StrokeCap.round;

//     // Left arm
//     canvas.drawLine(
//       Offset(position.dx - width * 0.32, position.dy - height * 0.22),
//       Offset(position.dx - width * 0.72, position.dy - height * 0.08),
//       armPaint,
//     );

//     // Right arm
//     canvas.drawLine(
//       Offset(position.dx + width * 0.32, position.dy - height * 0.22),
//       Offset(position.dx + width * 0.72, position.dy - height * 0.08),
//       armPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
