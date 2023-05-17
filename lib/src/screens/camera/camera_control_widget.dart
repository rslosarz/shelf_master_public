import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraControlWidget extends StatefulWidget {
  final void Function(FlashMode) onFlashModePicked;
  final VoidCallback onTakePictureClick;
  final VoidCallback onCameraSourceClick;
  final FlashMode? initialFlashMode;

  const CameraControlWidget({
    Key? key,
    required this.onFlashModePicked,
    required this.onTakePictureClick,
    required this.onCameraSourceClick,
    required this.initialFlashMode,
  }) : super(key: key);

  @override
  State<CameraControlWidget> createState() => _CameraControlWidgetState();
}

class _CameraControlWidgetState extends State<CameraControlWidget> with TickerProviderStateMixin {
  NativeDeviceOrientation orientation = NativeDeviceOrientation.portraitUp;
  StreamSubscription? orientationSubscription;

  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late FlashMode? flashMode = widget.initialFlashMode;

  @override
  void initState() {
    super.initState();
    orientationSubscription = NativeDeviceOrientationCommunicator().onOrientationChanged(useSensor: true).listen(
      (event) async {
        setRotation(newOrientation: event);
      },
    );

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _flashModeControlRowAnimationController.dispose();
    orientationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _flashControl(),
              _cameraCaptureControl(),
              _cameraSourceControl(),
            ],
          ),
          _flashModeControlRowWidget(),
        ],
      ),
    );
  }

  double rotation = 0;

  void setRotation({required NativeDeviceOrientation newOrientation}) {
    setState(() {
      rotation = newOrientation.toTurns();
    });
  }

  Widget _rotationWrapper(Widget child) {
    return AnimatedRotation(
      turns: rotation,
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _flashControl() {
    return _rotationWrapper(
      IconButton(
        icon: const Icon(Icons.flash_on),
        color: Colors.white,
        onPressed: _onFlashModeClick,
      ),
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _rotationWrapper(
              IconButton(
                icon: const Icon(Icons.flash_off),
                color: flashMode == FlashMode.off ? Colors.orange : Colors.white,
                onPressed: () => _onSetFlashModeClick(FlashMode.off),
              ),
            ),
            _rotationWrapper(
              IconButton(
                icon: const Icon(Icons.flash_auto),
                color: flashMode == FlashMode.auto ? Colors.orange : Colors.white,
                onPressed: () => _onSetFlashModeClick(FlashMode.auto),
              ),
            ),
            _rotationWrapper(
              IconButton(
                icon: const Icon(Icons.flash_on),
                color: flashMode == FlashMode.always ? Colors.orange : Colors.white,
                onPressed: () => _onSetFlashModeClick(FlashMode.always),
              ),
            ),
            _rotationWrapper(
              IconButton(
                icon: const Icon(Icons.highlight),
                color: flashMode == FlashMode.torch ? Colors.orange : Colors.white,
                onPressed: () => _onSetFlashModeClick(FlashMode.torch),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraCaptureControl() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTakePictureClick,
        child: Ink(
          child: Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraSourceControl() {
    return _rotationWrapper(
      IconButton(
        icon: const Icon(Icons.cameraswitch),
        color: Colors.white,
        onPressed: widget.onCameraSourceClick,
      ),
    );
  }

  void _onFlashModeClick() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
    }
  }

  void _onSetFlashModeClick(FlashMode flashMode) {
    setState(() {
      this.flashMode = flashMode;
    });
    widget.onFlashModePicked(flashMode);
  }
}

extension NativeDeviceOrientationExtension on NativeDeviceOrientation {
  double toTurns() {
    switch (this) {
      case NativeDeviceOrientation.portraitUp:
      case NativeDeviceOrientation.unknown:
        return 0;
      case NativeDeviceOrientation.portraitDown:
        return 0.5;
      case NativeDeviceOrientation.landscapeLeft:
        return 0.25;
      case NativeDeviceOrientation.landscapeRight:
        return 0.75;
    }
  }
}
