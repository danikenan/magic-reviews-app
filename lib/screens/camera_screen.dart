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
  List<TextBlock> blocks = [];
  CustomPaint? customPaint;

  @override
  Widget build(BuildContext context) {
    var focusRect = getFoucsRect(context);
    return Scaffold(
      bottomSheet: _buildBottomSheet(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.pause),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: blocks.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                // color: Colors.amber[colorCodes[index]],
                child: Center(child: Text('Entry ${blocks[index].text}')),
              );
            }));
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

    var textBlocks = recognisedText.blocks
        .where((b) =>
            b.rect.bottom < focusRect.bottom && b.rect.top > focusRect.top)
        .where((b) {
      var t = b.text.trim().toUpperCase();
      return t != "N" && t != 'TOP' && t != 'TOP\n10' && t != "NEW EPISODES";
    }).toList();
    // .where((block) => isContained(focusRect, block.rect))
    // .toList();

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          textBlocks,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {
        blocks = textBlocks;
      });
    }
  }
}
