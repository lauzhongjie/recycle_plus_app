import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_cubit.dart';
import 'package:recycle_plus_app/main.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionAllowed = false;
  bool _isCheckingPermission = true;

  // Focus
  Offset? _tapPosition;

  // Zoom
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
      _isCameraPermissionAllowed = true;
      _isCheckingPermission = false;
      cameraController
          .getMaxZoomLevel()
          .then((value) => _maxAvailableZoom = value);

      cameraController
          .getMinZoomLevel()
          .then((value) => _minAvailableZoom = value);
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
      _isCheckingPermission = false;
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setFocusPoint(offset);
    cameraController.setExposurePoint(offset);

    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  void _handlePinchStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handlePinchUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      double newZoomLevel = (_baseZoomLevel * details.scale).clamp(
          _minAvailableZoom, _maxAvailableZoom); // Assuming max zoom is 8x
      _setCameraZoom(newZoomLevel);
    }
  }

  void _handlePinchEnd(ScaleEndDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  Future<void> _setCameraZoom(double zoomLevel) async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    final double newZoomLevel =
        zoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom);
    if (newZoomLevel != _currentZoomLevel) {
      setState(() {
        _currentZoomLevel = newZoomLevel;
      });
      await controller!.setZoomLevel(_currentZoomLevel);
    }
  }

  @override
  void initState() {
    super.initState();
    _isCheckingPermission = true;
    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraController != null && !cameraController.value.isInitialized) {
        // Reinitialize the existing controller
        initializeCameraController(cameraController);
      }
    }
  }

  void initializeCameraController(CameraController cameraController) async {
    try {
      await cameraController.initialize();
    } catch (e) {
      print('Error reinitializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _isCameraPermissionAllowed
          ? (_isCameraInitialized
              ? _buildBlocConsumerCameraView()
              : Container())
          : _buildAskForPermission(),
    );
  }

  Widget _buildBlocConsumerCameraView() {
    return BlocConsumer<ScanningCubit, ScanningState>(
      listener: (context, state) {
        if (state is ScanningLoaded) {
          // Navigate to the results page with the scanning results
          Navigator.pushNamed(
            context,
            PageConst.scanningResultPage,
            arguments: state.scanResults,
          );
        }
      },
      builder: (context, state) {
      if (state is ScanningLoading) {
        return _buildLoadingWidget();
      } else {
        return _buildCameraView();
      }
    },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Detecting objects ...',
            style: TextStyle(
              color: colorSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final mediaSize = MediaQuery.of(context).size;
    final scale = controller!.value.isInitialized
        ? 1 / (controller!.value.aspectRatio * mediaSize.aspectRatio)
        : 1.0;

    return GestureDetector(
      onScaleStart: _handlePinchStart,
      onScaleUpdate: _handlePinchUpdate,
      onScaleEnd: _handlePinchEnd,
      child: Stack(
        children: [
          ClipRect(
            clipper: _MediaSizeClipper(mediaSize),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: CameraPreview(controller!),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => onViewFinderTap(details, constraints),
                  child: CustomPaint(
                    painter: FocusSquarePainter(_tapPosition),
                  ),
                );
              },
            ),
          ),
          _buildBackButton(),
          _buildCameraButton(),
          _buildZoomLevelIndicator(),
        ],
      ),
    );
  }

  Widget _buildAskForPermission() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: colorPrimary,
        backgroundColor: white,
        surfaceTintColor: white,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please enable camera access to use this feature.'),
                TextButton(
                  child: const Text(
                    'Click here to allow camera access',
                    style: TextStyle(color: colorPrimary),
                  ),
                  onPressed: () => onNewCameraSelected(cameras[0]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 64.0),
        child: FloatingActionButton(
          onPressed: () async {
            if (controller!.value.isInitialized) {
              try {
                await controller!.setFocusMode(FocusMode.auto);
                await controller!.setFlashMode(FlashMode.off);
                await controller!.setExposureMode(ExposureMode.auto);

                XFile picture = await controller!.takePicture();
                if (!mounted) return;

                // Object Detection
                context.read<ScanningCubit>().detectObj(picture);
              } on CameraException catch (e) {
                print("Error occurred while taking picture: $e");
              }
            }
          },
          child: const Icon(Icons.camera_alt, size: 24),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 25,
      top: 50,
      child: Container(
        width: 50,
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomLevelIndicator() {
    return Positioned(
      right: 25,
      top: 50,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${_currentZoomLevel.toStringAsFixed(1)}x',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class FocusSquarePainter extends CustomPainter {
  final Offset? tapPosition;
  FocusSquarePainter(this.tapPosition);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition == null) return;
    final paint = Paint()
      ..color = colorSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final centerSquare =
        Rect.fromCenter(center: tapPosition!, width: 60, height: 60);
    canvas.drawRect(centerSquare, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
