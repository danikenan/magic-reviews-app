import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:magic_reviews_app/utils/focusRect.dart';

class CameraView extends StatefulWidget {
  final CameraDescription camera;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage)? onImage;
  final Rect focusRect;

  const CameraView(
      {Key? key,
      required this.camera,
      required this.customPaint,
      required this.onImage,
      required this.focusRect})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  // double _prevScale = 1.0;
  // double _scale = 1.0;
  late double _maxScale, _minScale, _scale, _prevScale;

  @override
  void initState() {
    super.initState();
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Future _startLiveFeed() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.getMinZoomLevel().then((value) {
        _scale = value;
        _prevScale = value;
        _minScale = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxScale = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _processCameraImage(CameraImage image) async {
    if (widget.onImage == null) {
      return;
    }

    //CameraImage croppedInputImage = cropCameraImage(image, rect);

    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = widget.camera;
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage!(inputImage);
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    print(widget.focusRect);

    return GestureDetector(
      onScaleStart: (details) {
        print('onScaleStart');
        setState(() => _prevScale = _scale);
      },
      onScaleUpdate: (details) {
        var newScale = (_prevScale * details.scale);
        newScale = max(min(newScale, _maxScale), _minScale);
        setState(() => _scale = newScale);
        _controller?.setZoomLevel(newScale);
      },
      onScaleEnd: (details) {
        print('onScaleEnd');
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CameraPreview(_controller!),
            if (widget.customPaint != null) widget.customPaint!,
            Positioned(
              height: widget.focusRect.height,
              left: widget.focusRect.left,
              width: widget.focusRect.width,
              top: widget.focusRect.top,
              child: Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
