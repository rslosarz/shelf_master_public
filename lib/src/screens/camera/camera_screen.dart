import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:shelf_master/src/repo/internal_storage_repository.dart';
import 'package:shelf_master/src/screens/camera/camera_control_widget.dart';
import 'package:shelf_master/src/screens/camera/image_preview_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  List<CameraDescription> cameras = <CameraDescription>[];
  StreamSubscription? orientationSubscription;
  NativeDeviceOrientation orientation = NativeDeviceOrientation.portraitUp;

  CameraController? controller;
  File? imageFile;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    orientationSubscription = NativeDeviceOrientationCommunicator().onOrientationChanged(useSensor: true).listen(
      (event) async {
        orientation = event;
      },
    );
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await orientationSubscription?.cancel();
    await controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> load() async {
    cameras = await availableCameras();
    await _initializeCameraController(cameras.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: imageFile != null
          ? ImagePreviewWidget(
              imageFile: imageFile!,
              onImageAccepted: () {
                context.pop(imageFile!);
              },
              onImageRejected: () {
                setState(() {
                  context.read<InternalStorageRepository>().clearCacheFromImages(imageFile?.parent);
                  imageFile = null;
                });
              },
            )
          : FutureBuilder<void>(
              future: load(),
              builder: (context, snapshot) {
                if (cameras.isNotEmpty) {
                  return _buildTakePictureView(context);
                } else {
                  return Container();
                }
              },
            ),
    );
  }

  Widget _buildTakePictureView(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 100,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Center(
              child: _cameraPreviewWidget(),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: CameraControlWidget(
            onFlashModePicked: onSetFlashModeButtonPressed,
            onTakePictureClick: onTakePictureButtonPressed,
            onCameraSourceClick: onCameraToggleClick,
            initialFlashMode: controller?.value.flashMode,
          ),
        ),
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Icon(Icons.camera),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onTapDown: (details) => onViewFinderTap(details, constraints),
              );
            },
          ),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController.getMaxZoomLevel().then((value) => _maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }
  }

  void onCameraToggleClick() {
    final currentCamera = controller?.description;
    final newCameraDescription = cameras.firstWhereOrNull((element) => element != currentCamera);
    if (newCameraDescription != null) {
      onNewCameraSelected(newCameraDescription);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  void onTakePictureButtonPressed() async {
    final file = await takePicture();
    if (mounted) {
      setState(() {
        imageFile = file;
      });
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<File?> takePicture() async {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final currentOrientation = orientation;
      final file = await cameraController.takePicture();
      return await fixExifRotation(file.path, currentOrientation);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<File> fixExifRotation(String imagePath, NativeDeviceOrientation orientation) async {
    final originalFile = File(imagePath);
    if (orientation == NativeDeviceOrientation.portraitUp) {
      return originalFile;
    }

    final imageBytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;

    img.Image? fixedImage;

    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      fixedImage = img.copyRotate(originalImage, angle: -90);
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      fixedImage = img.copyRotate(originalImage, angle: 180);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      fixedImage = img.copyRotate(originalImage, angle: 90);
    }

    final fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage!));

    return fixedFile;
  }

  void _showCameraException(CameraException e) {
    debugPrint('$runtimeType: ${e.code}, ${e.description}');
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
