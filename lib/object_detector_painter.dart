import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
    this._objects,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<DetectedObject> _objects;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
     ..color = Colors.lightGreenAccent;


    final Paint background = Paint()..color = Color(0x99000000);

    for (final DetectedObject detectedObject in _objects) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.red, background: background));
      if (detectedObject.labels.isNotEmpty) {
        // final label = detectedObject.labels
        //     .reduce((a, b) => a.confidence > b.confidence ? a : b);


        detectedObject.labels.sort((a, b) =>
            a.confidence.compareTo(b.confidence));
        print("test here");
        print(detectedObject.labels.last);
        print(detectedObject.labels.last.confidence);

        final label = detectedObject.labels.last;

        if (label.confidence > 0.9)
          // builder.addText('${label.text}\n ${label.confidence}test\n');

          builder.addText('${label.text}\n ${label.confidence}test\n');


        // final label = detectedObject.labels
        //     .reduce((a, b) => a.confidence > b.confidence ? (a.confidence>0.9 ? a : Label(confidence: 0, index: 0, text: "")) : b);


        //    }
        builder.pop();

        final left = translateX(
          detectedObject.boundingBox.left,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final top = translateY(
          detectedObject.boundingBox.top,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final right = translateX(
          detectedObject.boundingBox.right,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final bottom = translateY(
          detectedObject.boundingBox.bottom,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );

        if (label.confidence > 0.9) {
          canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom),
            paint,
          );
        }

        canvas.drawParagraph(
          builder.build()
            ..layout(ParagraphConstraints(
              width: (right - left).abs(),
            )),
          Offset(
              Platform.isAndroid &&
                  cameraLensDirection == CameraLensDirection.front
                  ? right
                  : left,
              top),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
