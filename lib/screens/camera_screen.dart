import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/text_decorator_painter.dart';
import 'package:magic_reviews_app/widgets/camera_view.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as IMG;

import '../utils/focusRect.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  String text = '';
  CustomPaint? customPaint;

  @override
  Widget build(BuildContext context) {
    var focusRect = getFoucsRect(context);
    return Scaffold(
      bottomSheet: Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
            text,
            // style: TextStyle(color: Colors.white),
          ))),
      body: Center(
        child: CameraView(
          camera: widget.camera,
          onImage: (inputImage) {
            _processImage(inputImage, focusRect);
          },
          focusRect: focusRect,
          customPaint: customPaint,
        ),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage, Rect focusRect) async {
    if (isBusy) return;
    isBusy = true;

    // InputImage croppedInputImage = cropInputImage(inputImage, rect);

    // var src = IMG.decodeImage(inputImage.bytes!);

    // var cropped = IMG.copyCrop(src!, 30, 60, src.width - 60, 100);

    final recognisedText = await textDetector.processImage(inputImage);
    // print(
    //     'Found ${recognisedText.text} ${recognisedText.blocks.length} textBlocks');

    var blocks = recognisedText.blocks;
    // .where((block) => isContained(focusRect, block.rect))
    // .toList();

    var text = blocks.map((e) => e.text).join(" ");

    // print(text);

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          blocks,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {
        text = text;
      });
    }
  }
}
